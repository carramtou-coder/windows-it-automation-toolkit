[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]]$ServiceName,

    [ValidateSet('Running', 'Stopped')]
    [string]$ExpectedStatus = 'Running',

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Write-JsonReport.ps1')

$report = @(
    foreach ($name in $ServiceName) {
        if ($name -match '[*?]') {
            throw "Use an exact service name, not a wildcard: $name"
        }

        try {
            $service = Get-Service -Name $name -ErrorAction Stop |
                Select-Object -First 1

            $actualStatus = $service.Status.ToString()
            $result = if ($actualStatus -eq $ExpectedStatus) {
                'OK'
            }
            else {
                'NeedsAttention'
            }

            [pscustomobject][ordered]@{
                ServiceName    = $service.Name
                DisplayName    = $service.DisplayName
                ExpectedStatus = $ExpectedStatus
                ActualStatus   = $actualStatus
                Result         = $result
            }
        }
        catch {
            [pscustomobject][ordered]@{
                ServiceName    = $name
                DisplayName    = $null
                ExpectedStatus = $ExpectedStatus
                ActualStatus   = 'MissingOrUnavailable'
                Result         = 'NeedsAttention'
            }
        }
    }
)

Write-JsonReport -Data $report -OutputPath $OutputPath

