[CmdletBinding()]
param(
    [ValidateRange(1, 100)]
    [int]$MinimumFreePercent = 15,

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Write-JsonReport.ps1')

$report = @(
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' |
        Sort-Object -Property DeviceID |
        ForEach-Object {
            if ($_.Size -gt 0) {
                $freePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 1)
                [pscustomobject][ordered]@{
                    Drive              = $_.DeviceID
                    VolumeName         = $_.VolumeName
                    SizeGB             = [math]::Round($_.Size / 1GB, 2)
                    FreeGB             = [math]::Round($_.FreeSpace / 1GB, 2)
                    FreePercent        = $freePercent
                    MinimumFreePercent = $MinimumFreePercent
                    Status             = if ($freePercent -lt $MinimumFreePercent) {
                        'NeedsAttention'
                    }
                    else {
                        'OK'
                    }
                }
            }
        }
)

Write-JsonReport -Data $report -OutputPath $OutputPath

