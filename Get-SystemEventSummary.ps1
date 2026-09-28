[CmdletBinding()]
param(
    [ValidateRange(1, 720)]
    [int]$Hours = 24,

    [ValidateNotNullOrEmpty()]
    [string]$LogName = 'System',

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Write-JsonReport.ps1')

$windowEnd = Get-Date
$windowStart = $windowEnd.AddHours(-$Hours)

try {
    $events = @(
        Get-WinEvent -FilterHashtable @{
            LogName   = $LogName
            StartTime = $windowStart
            Level     = @(1, 2)
        } -ErrorAction Stop
    )
}
catch {
    if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') {
        $events = @()
    }
    else {
        throw
    }
}

$breakdown = @(
    $events |
        Group-Object -Property ProviderName, Id |
        ForEach-Object {
            [pscustomobject]@{
                Provider = $_.Group[0].ProviderName
                EventId  = $_.Group[0].Id
                Count    = $_.Count
            }
        } |
        Sort-Object -Property Count -Descending
)

$report = [pscustomobject][ordered]@{
    LogName                    = $LogName
    WindowStartLocal           = $windowStart.ToString('o')
    WindowEndLocal             = $windowEnd.ToString('o')
    CriticalAndErrorEventCount = $events.Count
    Breakdown                  = $breakdown
}

Write-JsonReport -Data $report -OutputPath $OutputPath

