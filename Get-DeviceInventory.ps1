[CmdletBinding()]
param(
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Write-JsonReport.ps1')

$computer = Get-CimInstance -ClassName Win32_ComputerSystem
$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
$processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

$volumes = @(
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' |
        Sort-Object -Property DeviceID |
        ForEach-Object {
            [pscustomobject]@{
                Drive      = $_.DeviceID
                VolumeName = $_.VolumeName
                FileSystem = $_.FileSystem
                SizeGB     = if ($_.Size) {
                    [math]::Round($_.Size / 1GB, 2)
                }
                else {
                    $null
                }
                FreeGB     = if ($_.FreeSpace) {
                    [math]::Round($_.FreeSpace / 1GB, 2)
                }
                else {
                    $null
                }
            }
        }
)

$lastBoot = [datetime]$operatingSystem.LastBootUpTime

$inventory = [pscustomobject][ordered]@{
    CollectedAtUtc    = (Get-Date).ToUniversalTime().ToString('o')
    ComputerName      = $computer.Name
    Manufacturer      = $computer.Manufacturer
    Model             = $computer.Model
    OperatingSystem   = $operatingSystem.Caption
    OsVersion         = $operatingSystem.Version
    BuildNumber       = $operatingSystem.BuildNumber
    LastBootUtc       = $lastBoot.ToUniversalTime().ToString('o')
    Processor         = ($processor.Name).Trim()
    LogicalProcessors = $computer.NumberOfLogicalProcessors
    InstalledMemoryGB = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
    FixedVolumes      = $volumes
}

Write-JsonReport -Data $inventory -OutputPath $OutputPath

