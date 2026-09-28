[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PsaTicketCsvPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RmmAlertCsvPath,

    [string]$OutputDirectory = '.\reports\psa-rmm-triage',

    [ValidateRange(0, 168)]
    [int]$SlaWarningHours = 2
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

function Get-DeviceKey {
    param(
        [AllowNull()][string]$Client,
        [AllowNull()][string]$Device
    )

    if ([string]::IsNullOrWhiteSpace($Client) -or [string]::IsNullOrWhiteSpace($Device)) {
        return ''
    }

    return $Client.Trim().ToLowerInvariant() + '|' + $Device.Trim().ToLowerInvariant()
}

function Test-OpenPsaTicket {
    param([string]$Status)

    return $Status.Trim().ToLowerInvariant() -notin @(
        'closed', 'resolved', 'complete', 'completed', 'cancelled', 'canceled'
    )
}

function Test-ActiveRmmAlert {
    param([string]$Status)

    return $Status.Trim().ToLowerInvariant() -notin @(
        'closed', 'resolved', 'cleared', 'complete', 'completed', 'normal', 'healthy'
    )
}

function Test-PrioritySufficient {
    param(
        [string]$Severity,
        [string]$Priority
    )

    $priorityText = $Priority.Trim().ToLowerInvariant()
    if ($Severity.Trim().ToLowerInvariant() -match '^(critical|emergency|urgent)$') {
        return $priorityText -match '(^|[^a-z0-9])(p?1|critical|emergency|urgent)([^a-z0-9]|$)'
    }
    if ($Severity.Trim().ToLowerInvariant() -eq 'high') {
        return $priorityText -match '(^|[^a-z0-9])(p?1|p?2|critical|emergency|urgent|high)([^a-z0-9]|$)'
    }

    return $true
}

function Assert-CsvColumns {
    param(
        [object[]]$Rows,
        [string[]]$RequiredColumns,
        [string]$Label
    )

    if ($Rows.Count -eq 0) {
        throw "$Label CSV has no data rows."
    }

    $available = @($Rows[0].PSObject.Properties.Name)
    $missing = @($RequiredColumns | Where-Object { $_ -notin $available })
    if ($missing.Count -gt 0) {
        throw "$Label CSV is missing required columns: $($missing -join ', ')"
    }
}

if (-not (Test-Path -LiteralPath $PsaTicketCsvPath -PathType Leaf)) {
    throw "PSA ticket CSV not found: $PsaTicketCsvPath"
}
if (-not (Test-Path -LiteralPath $RmmAlertCsvPath -PathType Leaf)) {
    throw "RMM alert CSV not found: $RmmAlertCsvPath"
}

$psaRows = @(Import-Csv -LiteralPath $PsaTicketCsvPath)
$rmmRows = @(Import-Csv -LiteralPath $RmmAlertCsvPath)
Assert-CsvColumns -Rows $psaRows -RequiredColumns @(
    'TicketId', 'Client', 'Device', 'Summary', 'Priority', 'Status', 'SlaDueUtc', 'AssignedTo'
) -Label 'PSA ticket'
Assert-CsvColumns -Rows $rmmRows -RequiredColumns @(
    'AlertId', 'Client', 'Device', 'Category', 'Severity', 'Status', 'Summary', 'FirstSeenUtc', 'LastSeenUtc'
) -Label 'RMM alert'

$nowUtc = [DateTimeOffset]::UtcNow
$openTickets = @($psaRows | Where-Object { Test-OpenPsaTicket ([string]$_.Status) })
$activeAlerts = @($rmmRows | Where-Object { Test-ActiveRmmAlert ([string]$_.Status) })
$actionRows = @()
$criticalHighUnmatchedCount = 0

foreach ($alert in $activeAlerts) {
    $client = ([string]$alert.Client).Trim()
    $device = ([string]$alert.Device).Trim()
    $severity = ([string]$alert.Severity).Trim()
    $alertId = ([string]$alert.AlertId).Trim()
    $deviceKey = Get-DeviceKey $client $device
    $matchingTickets = @()
    if (-not [string]::IsNullOrWhiteSpace($deviceKey)) {
        $matchingTickets = @($openTickets | Where-Object {
            (Get-DeviceKey ([string]$_.Client) ([string]$_.Device)) -eq $deviceKey
        })
    }

    $ticketIds = @($matchingTickets | ForEach-Object { ([string]$_.TicketId).Trim() } | Where-Object { $_ })
    $priorityIsSufficient = $false
    if ($matchingTickets.Count -gt 0) {
        $priorityIsSufficient = @($matchingTickets | Where-Object {
            Test-PrioritySufficient -Severity $severity -Priority ([string]$_.Priority)
        }).Count -gt 0
    }

    $recommendation = ''
    if ([string]::IsNullOrWhiteSpace($deviceKey)) {
        $recommendation = 'Identify the client and device before matching this alert.'
    } elseif ($matchingTickets.Count -eq 0) {
        if ($severity -match '^(critical|emergency|urgent|high)$') {
            $recommendation = 'Review the alert and create or link a PSA ticket.'
            $criticalHighUnmatchedCount++
        } else {
            $recommendation = 'Review the alert during normal triage.'
        }
    } elseif (-not $priorityIsSufficient) {
        $recommendation = 'Review whether the linked PSA ticket priority reflects this alert.'
    } else {
        $recommendation = 'Confirm the linked PSA ticket has an owner and current notes.'
    }

    $sameCategoryCount = @($activeAlerts | Where-Object {
        (Get-DeviceKey ([string]$_.Client) ([string]$_.Device)) -eq $deviceKey -and
        ([string]$_.Category).Trim() -ieq ([string]$alert.Category).Trim()
    }).Count
    if ($sameCategoryCount -gt 1) {
        $recommendation += " Correlate $sameCategoryCount active alerts for this device and category."
    }

    $actionRows += [pscustomobject]@{
        WorkItemType = 'RMM alert'
        Client = $client
        Device = $device
        TicketIds = $ticketIds -join ', '
        AlertIds = $alertId
        Severity = $severity
        Priority = (@($matchingTickets | ForEach-Object { ([string]$_.Priority).Trim() } | Select-Object -Unique) -join ', ')
        Status = ([string]$alert.Status).Trim()
        SlaDueUtc = ''
        AssignedTo = (@($matchingTickets | ForEach-Object { ([string]$_.AssignedTo).Trim() } | Select-Object -Unique) -join ', ')
        Recommendation = $recommendation
        Details = ([string]$alert.Summary).Trim()
    }
}

$slaOverdueCount = 0
$slaDueSoonCount = 0
foreach ($ticket in $openTickets) {
    $ticketId = ([string]$ticket.TicketId).Trim()
    $client = ([string]$ticket.Client).Trim()
    $device = ([string]$ticket.Device).Trim()
    $dueUtc = ConvertTo-UtcDate ([string]$ticket.SlaDueUtc)
    $recommendation = ''

    if ($null -eq $dueUtc) {
        $recommendation = 'Check or set the missing or invalid SLA deadline in PSA.'
    } else {
        $remainingHours = ($dueUtc - $nowUtc).TotalHours
        if ($remainingHours -lt 0) {
            $recommendation = 'SLA deadline has passed; review the next action and escalation.'
            $slaOverdueCount++
        } elseif ($remainingHours -le $SlaWarningHours) {
            $recommendation = 'SLA deadline is approaching; confirm the next action and owner.'
            $slaDueSoonCount++
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($recommendation)) {
        $relatedAlerts = @($activeAlerts | Where-Object {
            (Get-DeviceKey ([string]$_.Client) ([string]$_.Device)) -eq (Get-DeviceKey $client $device)
        })
        $actionRows += [pscustomobject]@{
            WorkItemType = 'PSA SLA'
            Client = $client
            Device = $device
            TicketIds = $ticketId
            AlertIds = (@($relatedAlerts | ForEach-Object { ([string]$_.AlertId).Trim() } | Where-Object { $_ }) -join ', ')
            Severity = ''
            Priority = ([string]$ticket.Priority).Trim()
            Status = ([string]$ticket.Status).Trim()
            SlaDueUtc = if ($null -eq $dueUtc) { '' } else { $dueUtc.ToString('yyyy-MM-dd HH:mm:ss UTC') }
            AssignedTo = ([string]$ticket.AssignedTo).Trim()
            Recommendation = $recommendation
            Details = ([string]$ticket.Summary).Trim()
        }
    }
}

if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$actionsPath = Join-Path $OutputDirectory 'psa-rmm-action-queue.csv'
$actionColumns = 'WorkItemType,Client,Device,TicketIds,AlertIds,Severity,Priority,Status,SlaDueUtc,AssignedTo,Recommendation,Details'
if ($actionRows.Count -gt 0) {
    $csvLines = @($actionRows | ConvertTo-Csv -NoTypeInformation)
} else {
    $csvLines = @('"' + ($actionColumns -replace ',', '","') + '"')
}
Set-Content -LiteralPath $actionsPath -Value $csvLines -Encoding UTF8

$activeCriticalHighCount = @($activeAlerts | Where-Object {
    ([string]$_.Severity).Trim() -match '^(critical|emergency|urgent|high)$'
}).Count
$matchedAlertCount = $activeAlerts.Count - $criticalHighUnmatchedCount
$generatedAt = $nowUtc.ToString('yyyy-MM-dd HH:mm:ss UTC')
$detailHtml = foreach ($row in ($actionRows | Sort-Object Client, WorkItemType, Device, TicketIds)) {
    $cells = @(
        (ConvertTo-HtmlText $row.WorkItemType),
        (ConvertTo-HtmlText $row.Client),
        (ConvertTo-HtmlText $row.Device),
        (ConvertTo-HtmlText $row.TicketIds),
        (ConvertTo-HtmlText $row.AlertIds),
        (ConvertTo-HtmlText $row.Severity),
        (ConvertTo-HtmlText $row.Priority),
        (ConvertTo-HtmlText $row.Status),
        (ConvertTo-HtmlText $row.SlaDueUtc),
        (ConvertTo-HtmlText $row.AssignedTo),
        (ConvertTo-HtmlText $row.Recommendation),
        (ConvertTo-HtmlText $row.Details)
    )
    '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td><td>{8}</td><td>{9}</td><td>{10}</td><td>{11}</td></tr>' -f $cells
}

$reportHtml = @'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>PSA and RMM Triage Report</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;max-width:1400px;margin:2rem auto;padding:0 1rem;color:#17212b;background:#f5f7fa}
h1,h2{color:#102a43}.meta,.note{color:#52606d}.cards{display:flex;gap:1rem;flex-wrap:wrap;margin:1.2rem 0}
.card{background:#fff;border:1px solid #d9e2ec;border-radius:8px;padding:1rem 1.4rem;min-width:150px}
.number{font-size:1.8rem;font-weight:700}.table-wrap{overflow-x:auto;background:#fff;border:1px solid #d9e2ec;border-radius:8px}
table{border-collapse:collapse;width:100%;font-size:.88rem}th,td{text-align:left;padding:.65rem;border-bottom:1px solid #d9e2ec;vertical-align:top}
th{background:#eaf0f6;position:sticky;top:0}.note{margin:1rem 0;padding:1rem;background:#fff;border-left:4px solid #627d98}
</style>
</head>
<body>
<h1>PSA and RMM Triage Report</h1>
<p class="meta">Generated __GENERATED_AT__. Active alerts: __ACTIVE_ALERTS__. Open tickets: __OPEN_TICKETS__. SLA warning window: __SLA_HOURS__ hours.</p>
<div class="cards">
<div class="card"><div>Active RMM alerts</div><div class="number">__ACTIVE_ALERTS__</div></div>
<div class="card"><div>Open PSA tickets</div><div class="number">__OPEN_TICKETS__</div></div>
<div class="card"><div>Unlinked critical or high alerts</div><div class="number">__UNLINKED_HIGH__</div></div>
<div class="card"><div>Overdue SLAs</div><div class="number">__SLA_OVERDUE__</div></div>
<div class="card"><div>SLAs due soon</div><div class="number">__SLA_SOON__</div></div>
</div>
<div class="note">Recommendations are generated from the supplied exports by matching client and device names. Review them in your PSA/RMM before acting. This report does not create or update tickets, change alert state, or contact clients.</div>
<h2>Review queue</h2>
<div class="table-wrap"><table><thead><tr><th>Type</th><th>Client</th><th>Device</th><th>Ticket IDs</th><th>Alert IDs</th><th>Severity</th><th>Priority</th><th>Status</th><th>SLA due (UTC)</th><th>Assigned to</th><th>Recommendation</th><th>Details</th></tr></thead><tbody>__ACTION_ROWS__</tbody></table></div>
<p class="meta">The companion psa-rmm-action-queue.csv contains the same review queue for filtering or importing into a separate workflow.</p>
</body>
</html>
'@
$reportHtml = $reportHtml.Replace('__GENERATED_AT__', (ConvertTo-HtmlText $generatedAt))
$reportHtml = $reportHtml.Replace('__ACTIVE_ALERTS__', [string]$activeAlerts.Count)
$reportHtml = $reportHtml.Replace('__OPEN_TICKETS__', [string]$openTickets.Count)
$reportHtml = $reportHtml.Replace('__UNLINKED_HIGH__', [string]$criticalHighUnmatchedCount)
$reportHtml = $reportHtml.Replace('__SLA_OVERDUE__', [string]$slaOverdueCount)
$reportHtml = $reportHtml.Replace('__SLA_SOON__', [string]$slaDueSoonCount)
$reportHtml = $reportHtml.Replace('__SLA_HOURS__', [string]$SlaWarningHours)
$reportHtml = $reportHtml.Replace('__ACTION_ROWS__', ($detailHtml -join [Environment]::NewLine))

$htmlPath = Join-Path $OutputDirectory 'psa-rmm-triage-report.html'
Set-Content -LiteralPath $htmlPath -Value $reportHtml -Encoding UTF8

[pscustomobject]@{
    ActiveAlerts = $activeAlerts.Count
    OpenTickets = $openTickets.Count
    CriticalHighUnlinkedAlerts = $criticalHighUnmatchedCount
    SlaOverdue = $slaOverdueCount
    SlaDueSoon = $slaDueSoonCount
    ReviewQueueRows = $actionRows.Count
    HtmlReport = (Resolve-Path -LiteralPath $htmlPath).Path
    ActionQueueCsv = (Resolve-Path -LiteralPath $actionsPath).Path
}
