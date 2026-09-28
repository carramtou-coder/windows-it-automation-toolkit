[CmdletBinding()]
param(
    [ValidateRange(1, 365)]
    [int]$StaleAfterDays = 30,

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$requiredScope = 'DeviceManagementManagedDevices.Read.All'

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    throw 'Microsoft.Graph.Authentication is required. Install it with: Install-Module Microsoft.Graph.Authentication -Scope CurrentUser'
}

Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

$context = Get-MgContext
if ($null -eq $context -or $requiredScope -notin @($context.Scopes)) {
    Connect-MgGraph -Scopes $requiredScope -ContextScope Process -NoWelcome
}

$context = Get-MgContext
if ($null -eq $context -or $requiredScope -notin @($context.Scopes)) {
    throw "The signed-in Graph session is missing the required read-only scope: $requiredScope"
}

$nextUri = 'https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$select=deviceName,operatingSystem,osVersion,complianceState,lastSyncDateTime,managementAgent&$top=999'
$deviceRecords = New-Object 'System.Collections.Generic.List[object]'

while (-not [string]::IsNullOrWhiteSpace($nextUri)) {
    $page = Invoke-MgGraphRequest -Method GET -Uri $nextUri -OutputType PSObject

    foreach ($device in @($page.value)) {
        if ($null -ne $device) {
            $deviceRecords.Add($device)
        }
    }

    $nextUri = [string]$page.'@odata.nextLink'
    if (-not [string]::IsNullOrWhiteSpace($nextUri)) {
        $nextPageUri = [uri]$nextUri
        if ($nextPageUri.Scheme -ne 'https' -or
            $nextPageUri.Host -ne 'graph.microsoft.com') {
            throw 'Microsoft Graph returned an unexpected pagination URL.'
        }
    }
}

$staleCutoffUtc = (Get-Date).ToUniversalTime().AddDays(-$StaleAfterDays)
$deviceReport = @(
    foreach ($device in $deviceRecords) {
        $lastSyncUtc = $null
        if (-not [string]::IsNullOrWhiteSpace([string]$device.lastSyncDateTime)) {
            $lastSyncUtc = [DateTimeOffset]::Parse(
                [string]$device.lastSyncDateTime
            ).UtcDateTime
        }

        $syncStatus = if ($null -eq $lastSyncUtc) {
            'NeverSynced'
        }
        elseif ($lastSyncUtc -lt $staleCutoffUtc) {
            'Stale'
        }
        else {
            'Current'
        }

        $complianceState = if ([string]::IsNullOrWhiteSpace([string]$device.complianceState)) {
            'Unknown'
        }
        else {
            [string]$device.complianceState
        }

        $deviceName = if ([string]::IsNullOrWhiteSpace([string]$device.deviceName)) {
            'Unnamed device'
        }
        else {
            [string]$device.deviceName
        }

        [pscustomobject][ordered]@{
            DeviceName      = $deviceName
            OperatingSystem = [string]$device.operatingSystem
            OsVersion       = [string]$device.osVersion
            ComplianceState = $complianceState
            SyncStatus      = $syncStatus
            LastSyncUtc     = if ($lastSyncUtc) { $lastSyncUtc.ToString('o') } else { $null }
            ManagementAgent = [string]$device.managementAgent
        }
    }
)

$osBreakdown = @(
    $deviceReport |
        Group-Object -Property OperatingSystem |
        Sort-Object -Property Count -Descending |
        ForEach-Object {
            [pscustomobject]@{
                OperatingSystem = $_.Name
                Count           = $_.Count
            }
        }
)

$summary = [pscustomobject][ordered]@{
    GeneratedAtUtc              = (Get-Date).ToUniversalTime().ToString('o')
    StaleAfterDays              = $StaleAfterDays
    ManagedDeviceCount          = $deviceReport.Count
    CompliantDeviceCount        = @($deviceReport | Where-Object { $_.ComplianceState -ieq 'compliant' }).Count
    NonCompliantDeviceCount     = @($deviceReport | Where-Object { $_.ComplianceState -ieq 'noncompliant' }).Count
    StaleOrNeverSyncedCount     = @($deviceReport | Where-Object { $_.SyncStatus -in @('Stale', 'NeverSynced') }).Count
    OperatingSystems            = $osBreakdown
}

if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $fullPath = [System.IO.Path]::GetFullPath($OutputPath)
    $parentPath = Split-Path -Path $fullPath -Parent

    if (-not [string]::IsNullOrWhiteSpace($parentPath) -and
        -not (Test-Path -LiteralPath $parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    [pscustomobject][ordered]@{
        Summary = $summary
        Devices = $deviceReport
    } | ConvertTo-Json -Depth 8 |
        Set-Content -LiteralPath $fullPath -Encoding utf8
}

Write-Output $summary
