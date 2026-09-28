# Optional Intune audit

This script reads inventory data from an Intune tenant through Microsoft Graph. Use only a tenant you are authorized to administer.

## Prerequisites

- PowerShell 5.1 or PowerShell 7 on Windows
- Microsoft.Graph.Authentication from the PowerShell Gallery
- A work or school account with consent for DeviceManagementManagedDevices.Read.All
- An active Intune license in the tenant

The script uses delegated sign-in with process-scoped Graph context. It does not ask you to paste a password, client secret, or access token into the script.

## Run

    Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
    .\Get-IntuneDeviceComplianceReport.ps1 -StaleAfterDays 30 -OutputPath .\reports\intune-devices.json

The first run prompts for sign-in and any required consent. The report checks compliance state and whether each device synced within the configured number of days. It returns aggregate counts to the console. The optional JSON file includes device names and other inventory details.

## Demo output

The aggregate-only example in demo-intune-audit-summary.json is simulated. It is provided to show the report shape and does not represent a real organization or tenant.

## Data handling

Do not commit exports from a real tenant. Treat device names and timestamps as internal operational data. The repository ignores the reports folder.
