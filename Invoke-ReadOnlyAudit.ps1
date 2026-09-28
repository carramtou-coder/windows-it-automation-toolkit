[CmdletBinding()]
param(
    [ValidateRange(1, 100)]
    [int]$MinimumFreePercent = 15,

    [string[]]$ServiceName = @('Winmgmt', 'EventLog', 'BITS'),

    [ValidateSet('Running', 'Stopped')]
    [string]$ExpectedServiceStatus = 'Running',

    [ValidateRange(1, 720)]
    [int]$EventLookbackHours = 24,

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Write-JsonReport.ps1')

$inventory = & (Join-Path $PSScriptRoot 'Get-DeviceInventory.ps1')
$diskHealth = @(
    & (Join-Path $PSScriptRoot 'Get-DiskHealthReport.ps1') -MinimumFreePercent $MinimumFreePercent
)
$serviceHealth = @(
    & (Join-Path $PSScriptRoot 'Get-ServiceHealthReport.ps1') -ServiceName $ServiceName -ExpectedStatus $ExpectedServiceStatus
)
$eventSummary = & (Join-Path $PSScriptRoot 'Get-SystemEventSummary.ps1') -Hours $EventLookbackHours

$findings = @(
    $diskHealth | Where-Object { $_.Status -ne 'OK' } |
        ForEach-Object {
            "Disk $($_.Drive) has $($_.FreePercent)% free space."
        }

    $serviceHealth | Where-Object { $_.Result -ne 'OK' } |
        ForEach-Object {
            "Service $($_.ServiceName) is $($_.ActualStatus); expected $($_.ExpectedStatus)."
        }
)

$overallStatus = if ($findings.Count -gt 0) {
    'NeedsAttention'
}
else {
    'OK'
}

$audit = [pscustomobject][ordered]@{
    GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    OverallStatus  = $overallStatus
    Findings       = $findings
    Device         = $inventory
    DiskHealth     = $diskHealth
    ServiceHealth  = $serviceHealth
    SystemEvents   = $eventSummary
}

Write-JsonReport -Data $audit -OutputPath $OutputPath

