[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InputCsvPath,

    [string]$OutputDirectory = '.\reports\backup-compliance',

    [ValidateRange(1, 720)]
    [int]$MaxBackupAgeHours = 24,

    [ValidateRange(1, 3650)]
    [int]$RestoreTestMaxAgeDays = 180,

    [ValidateRange(1, 3650)]
    [int]$MinimumRetentionDays = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-UtcDate {
    param([AllowNull()][string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $parsed = [DateTimeOffset]::MinValue
    $styles = [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
    if ([DateTimeOffset]::TryParse($Value, [Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$parsed)) {
        return $parsed
    }

    return $null
}

function ConvertTo-HtmlText {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) {
        return ''
    }

    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

if (-not (Test-Path -LiteralPath $InputCsvPath -PathType Leaf)) {
    throw "Input CSV not found: $InputCsvPath"
}

$sourceRows = @(Import-Csv -LiteralPath $InputCsvPath)
if ($sourceRows.Count -eq 0) {
    throw 'Input CSV has no data rows.'
}

$requiredColumns = @(
    'Client',
    'Device',
    'LastBackupStatus',
    'LastSuccessfulBackupUtc',
    'RetentionDays',
    'LastRestoreTestUtc'
)
$availableColumns = @($sourceRows[0].PSObject.Properties.Name)
$missingColumns = @($requiredColumns | Where-Object { $_ -notin $availableColumns })
if ($missingColumns.Count -gt 0) {
    throw "Input CSV is missing required columns: $($missingColumns -join ', ')"
}

$nowUtc = [DateTimeOffset]::UtcNow
$reportRows = foreach ($source in $sourceRows) {
    $findings = @()
    $client = ([string]$source.Client).Trim()
    $device = ([string]$source.Device).Trim()
    $status = ([string]$source.LastBackupStatus).Trim()
    $lastBackup = ConvertTo-UtcDate ([string]$source.LastSuccessfulBackupUtc)
    $lastRestore = ConvertTo-UtcDate ([string]$source.LastRestoreTestUtc)
    $retention = 0
    $retentionIsNumber = [int]::TryParse(
        ([string]$source.RetentionDays).Trim(),
        [Globalization.NumberStyles]::Integer,
        [Globalization.CultureInfo]::InvariantCulture,
        [ref]$retention
    )

    if ([string]::IsNullOrWhiteSpace($client)) {
        $findings += 'ClientNameMissing'
    }
    if ([string]::IsNullOrWhiteSpace($device)) {
        $findings += 'DeviceNameMissing'
    }
    if ($status -notin @('success', 'succeeded', 'completed', 'ok')) {
        $findings += 'LatestBackupNotSuccessful'
    }
    if ($null -eq $lastBackup) {
        $findings += 'SuccessfulBackupTimeMissingOrInvalid'
    } else {
        $backupAgeHours = ($nowUtc - $lastBackup).TotalHours
        if ($backupAgeHours -lt -1) {
            $findings += 'SuccessfulBackupTimeInFuture'
        } elseif ($backupAgeHours -gt $MaxBackupAgeHours) {
            $findings += 'SuccessfulBackupIsStale'
        }
    }
    if (-not $retentionIsNumber) {
        $findings += 'RetentionValueMissingOrInvalid'
    } elseif ($retention -lt $MinimumRetentionDays) {
        $findings += 'RetentionBelowTarget'
    }
    if ($null -eq $lastRestore) {
        $findings += 'RestoreTestMissingOrInvalid'
    } else {
        $restoreAgeDays = ($nowUtc - $lastRestore).TotalDays
        if ($restoreAgeDays -lt -1) {
            $findings += 'RestoreTestDateInFuture'
        } elseif ($restoreAgeDays -gt $RestoreTestMaxAgeDays) {
            $findings += 'RestoreTestOverdue'
        }
    }

    $health = if ($findings.Count -eq 0) { 'Healthy' } else { 'Attention' }
    [pscustomobject]@{
        Client                  = $client
        Device                  = $device
        Health                  = $health
        Findings                = if ($findings.Count -eq 0) { 'None' } else { $findings -join '; ' }
        LastBackupStatus        = $status
        LastSuccessfulBackupUtc = if ($null -eq $lastBackup) { '' } else { $lastBackup.ToString('yyyy-MM-dd HH:mm:ss UTC') }
        RetentionDays           = if ($retentionIsNumber) { $retention } else { '' }
        LastRestoreTestUtc      = if ($null -eq $lastRestore) { '' } else { $lastRestore.ToString('yyyy-MM-dd HH:mm:ss UTC') }
    }
}

$reportRows = @($reportRows)
$attentionRows = @($reportRows | Where-Object { $_.Health -eq 'Attention' })
$healthyCount = @($reportRows | Where-Object { $_.Health -eq 'Healthy' }).Count
$clientCount = @($reportRows | Select-Object -ExpandProperty Client -Unique).Count

if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$exceptionsPath = Join-Path $OutputDirectory 'backup-exceptions.csv'
$csvLines = @($attentionRows | ConvertTo-Csv -NoTypeInformation)
if ($csvLines.Count -eq 0) {
    $csvLines = @('"Client","Device","Health","Findings","LastBackupStatus","LastSuccessfulBackupUtc","RetentionDays","LastRestoreTestUtc"')
}
Set-Content -LiteralPath $exceptionsPath -Value $csvLines -Encoding UTF8

$clientSummaryRows = foreach ($group in ($reportRows | Group-Object Client | Sort-Object Name)) {
    $clientAttention = @($group.Group | Where-Object { $_.Health -eq 'Attention' }).Count
    [pscustomobject]@{
        Client = $group.Name
        Devices = $group.Count
        Attention = $clientAttention
    }
}
$clientSummaryHtml = foreach ($summary in $clientSummaryRows) {
    '<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f (ConvertTo-HtmlText $summary.Client), $summary.Devices, $summary.Attention
}

$detailHtml = foreach ($row in ($reportRows | Sort-Object Client, Device)) {
    $statusClass = if ($row.Health -eq 'Healthy') { 'healthy' } else { 'attention' }
    $rowValues = @(
        $statusClass,
        (ConvertTo-HtmlText $row.Client),
        (ConvertTo-HtmlText $row.Device),
        (ConvertTo-HtmlText $row.Health),
        (ConvertTo-HtmlText $row.Findings),
        (ConvertTo-HtmlText $row.LastBackupStatus),
        (ConvertTo-HtmlText $row.LastSuccessfulBackupUtc),
        (ConvertTo-HtmlText $row.RetentionDays),
        (ConvertTo-HtmlText $row.LastRestoreTestUtc)
    )
    '<tr class="{0}"><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td><td>{8}</td></tr>' -f $rowValues
}

$generatedAt = $nowUtc.ToString('yyyy-MM-dd HH:mm:ss UTC')
$reportHtml = @'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>MSP Backup Compliance Report</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;max-width:1200px;margin:2rem auto;padding:0 1rem;color:#17212b;background:#f5f7fa}
h1,h2{color:#102a43}.meta,.note{color:#52606d}.cards{display:flex;gap:1rem;flex-wrap:wrap;margin:1.2rem 0}
.card{background:#fff;border:1px solid #d9e2ec;border-radius:8px;padding:1rem 1.4rem;min-width:140px}
.number{font-size:1.8rem;font-weight:700}.attention{background:#fff3f0}.healthy{background:#f0fff4}
.table-wrap{overflow-x:auto;background:#fff;border:1px solid #d9e2ec;border-radius:8px}
table{border-collapse:collapse;width:100%;font-size:.9rem}th,td{text-align:left;padding:.65rem;border-bottom:1px solid #d9e2ec;vertical-align:top}
th{background:#eaf0f6;position:sticky;top:0}.note{margin:1rem 0;padding:1rem;background:#fff;border-left:4px solid #627d98}
</style>
</head>
<body>
<h1>MSP Backup Compliance Report</h1>
<p class="meta">Generated __GENERATED_AT__ from the supplied CSV export. Thresholds: successful backup within __BACKUP_HOURS__ hours; restore test within __RESTORE_DAYS__ days; retention at least __RETENTION_DAYS__ days.</p>
<div class="cards">
<div class="card"><div>Total devices</div><div class="number">__DEVICE_COUNT__</div></div>
<div class="card"><div>Clients</div><div class="number">__CLIENT_COUNT__</div></div>
<div class="card"><div>Healthy</div><div class="number">__HEALTHY_COUNT__</div></div>
<div class="card attention"><div>Needs attention</div><div class="number">__ATTENTION_COUNT__</div></div>
</div>
<div class="note">This report evaluates the supplied export only. It does not connect to a backup platform, confirm that backup data is recoverable, or replace a documented restore test.</div>
<h2>Client summary</h2>
<div class="table-wrap"><table><thead><tr><th>Client</th><th>Devices</th><th>Needs attention</th></tr></thead><tbody>__CLIENT_ROWS__</tbody></table></div>
<h2>Device details</h2>
<div class="table-wrap"><table><thead><tr><th>Client</th><th>Device</th><th>Health</th><th>Findings</th><th>Latest job</th><th>Last successful backup (UTC)</th><th>Retention days</th><th>Last restore test (UTC)</th></tr></thead><tbody>__DEVICE_ROWS__</tbody></table></div>
<p class="meta">The companion backup-exceptions.csv contains only rows needing attention. Keep reports private because device and client names can be sensitive.</p>
</body>
</html>
'@
$reportHtml = $reportHtml.Replace('__GENERATED_AT__', (ConvertTo-HtmlText $generatedAt))
$reportHtml = $reportHtml.Replace('__BACKUP_HOURS__', [string]$MaxBackupAgeHours)
$reportHtml = $reportHtml.Replace('__RESTORE_DAYS__', [string]$RestoreTestMaxAgeDays)
$reportHtml = $reportHtml.Replace('__RETENTION_DAYS__', [string]$MinimumRetentionDays)
$reportHtml = $reportHtml.Replace('__DEVICE_COUNT__', [string]$reportRows.Count)
$reportHtml = $reportHtml.Replace('__CLIENT_COUNT__', [string]$clientCount)
$reportHtml = $reportHtml.Replace('__HEALTHY_COUNT__', [string]$healthyCount)
$reportHtml = $reportHtml.Replace('__ATTENTION_COUNT__', [string]$attentionRows.Count)
$reportHtml = $reportHtml.Replace('__CLIENT_ROWS__', ($clientSummaryHtml -join [Environment]::NewLine))
$reportHtml = $reportHtml.Replace('__DEVICE_ROWS__', ($detailHtml -join [Environment]::NewLine))

$htmlPath = Join-Path $OutputDirectory 'backup-compliance-report.html'
Set-Content -LiteralPath $htmlPath -Value $reportHtml -Encoding UTF8

[pscustomobject]@{
    InputRows = $reportRows.Count
    Healthy = $healthyCount
    NeedsAttention = $attentionRows.Count
    HtmlReport = (Resolve-Path -LiteralPath $htmlPath).Path
    ExceptionsCsv = (Resolve-Path -LiteralPath $exceptionsPath).Path
}
