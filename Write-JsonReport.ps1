function Write-JsonReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Data,

        [string]$OutputPath
    )

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $fullPath = [System.IO.Path]::GetFullPath($OutputPath)
        $parentPath = Split-Path -Path $fullPath -Parent

        if (-not [string]::IsNullOrWhiteSpace($parentPath) -and
            -not (Test-Path -LiteralPath $parentPath)) {
            New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
        }

        $Data | ConvertTo-Json -Depth 8 |
            Set-Content -LiteralPath $fullPath -Encoding utf8
    }

    return $Data
}
