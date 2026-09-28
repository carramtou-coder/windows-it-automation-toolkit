# Windows and Microsoft 365 IT Automation Toolkit

Read-only PowerShell reports for endpoint, Microsoft 365, and backup operations. Local checks use Windows built-ins. Optional reports audit Intune-managed devices through Microsoft Graph and summarize a normalized, multi-client backup export.

## Automations

- **Get-DeviceInventory.ps1** collects local computer, operating system, processor, memory, and fixed-volume details.
- **Get-DiskHealthReport.ps1** flags fixed volumes below a free-space threshold.
- **Get-ServiceHealthReport.ps1** compares selected Windows service states to an expected state.
- **Get-SystemEventSummary.ps1** counts recent critical and error events by provider and event ID without exporting event messages.
- **Invoke-ReadOnlyAudit.ps1** runs the local checks and saves one combined report.
- **Get-IntuneDeviceComplianceReport.ps1** reads Intune-managed device compliance and sync status through Microsoft Graph.
- **backup-compliance/New-MspBackupComplianceReport.ps1** converts a normalized backup CSV export into an HTML portfolio view and an exceptions CSV, with per-client summaries and configurable backup, retention, and restore-test thresholds.

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or PowerShell 7
- No third-party modules for the local checks
- Microsoft.Graph.Authentication for the optional Intune report

Run PowerShell from the project folder. If your execution policy blocks local scripts, follow your organization's policy rather than changing it globally.

## Local endpoint audit

    .\Invoke-ReadOnlyAudit.ps1 -OutputPath .\reports\endpoint-audit.json

The combined audit checks Winmgmt, EventLog, and BITS by default, reviews the last 24 hours of the System event log, and flags disks with less than 15% free space.

Individual local checks:

    .\Get-DeviceInventory.ps1 -OutputPath .\reports\inventory.json
    .\Get-DiskHealthReport.ps1 -MinimumFreePercent 20 -OutputPath .\reports\disks.json
    .\Get-ServiceHealthReport.ps1 -ServiceName Winmgmt,EventLog,BITS -OutputPath .\reports\services.json
    .\Get-SystemEventSummary.ps1 -Hours 12 -OutputPath .\reports\system-events.json

Omit -OutputPath to return results to the PowerShell pipeline instead of writing a report.

## Optional Intune device report

Install the Microsoft Graph authentication module if it is not already available:

    Install-Module Microsoft.Graph.Authentication -Scope CurrentUser

Then run:

    .\Get-IntuneDeviceComplianceReport.ps1 -StaleAfterDays 30 -OutputPath .\reports\intune-devices.json

The script requests only the delegated DeviceManagementManagedDevices.Read.All scope and makes GET requests. This permission requires administrator consent, a work or school account, and an active Intune license in the tenant. See Microsoft's [managed devices API documentation](https://learn.microsoft.com/graph/api/intune-devices-manageddevice-list?view=graph-rest-1.0).

The summary appears in the console. If OutputPath is supplied, the JSON file also includes per-device names, operating systems, compliance states, and sync timestamps. Use a test tenant or an environment you are authorized to administer. Review reports before sharing them.

A simulated aggregate example is in demo-intune-audit-summary.json. It contains no tenant data.

## Safety and data handling

The scripts do not change accounts, services, registry settings, network configuration, backup jobs, retention policies, or managed devices. The Intune report makes Graph GET requests only. The backup report reads the supplied CSV and writes its HTML and CSV output locally.

Reports may contain computer names, device names, operating system details, or service status. Keep real reports local and review them before sharing. The reports folder is ignored by Git.

## Example workflow

1. Run the local audit on a workstation.
2. Review disk and service findings.
3. In an authorized test tenant, run the optional Intune report.
4. Save reports only in an approved local location and review them before sharing.

See daily-check.md and graph-audit.md for short runbooks.

## MSP backup compliance report

The second project demonstrates a multi-client backup review workflow. It reads the included fictional sample export and generates reports locally:

    .\backup-compliance\New-MspBackupComplianceReport.ps1 -InputCsvPath .\backup-compliance\sample-backup-export.csv -OutputDirectory .\backup-compliance\demo-output

The HTML report summarizes clients and devices; the exceptions CSV includes only rows that need attention. Defaults flag backups older than 24 hours, restore tests older than 180 days, and retention below 30 days. Set thresholds to match the service agreement or policy being reviewed. The script expects a documented CSV format and does not connect to a vendor platform. An export cannot prove recoverability; verify through actual restore tests. See [backup-compliance/README.md](backup-compliance/README.md).

## License

No license has been selected yet. Add one before reusing or redistributing the project.
