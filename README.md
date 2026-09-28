# Windows IT Automation Toolkit

A small collection of read-only PowerShell automations for routine Windows endpoint support. The scripts collect inventory and health signals, then return objects to the pipeline or save a local JSON report.

## Automations

- **Get-DeviceInventory.ps1** gathers computer, operating system, processor, memory, and fixed-volume details.
- **Get-DiskHealthReport.ps1** checks fixed-volume free space against a configurable threshold.
- **Get-ServiceHealthReport.ps1** checks whether selected Windows services match an expected state.
- **Get-SystemEventSummary.ps1** counts recent critical and error events by provider and event ID without exporting event messages.
- **Invoke-ReadOnlyAudit.ps1** runs the checks together and saves one combined report.

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or PowerShell 7
- No third-party PowerShell modules

Run PowerShell from the project folder. If your execution policy blocks local scripts, follow your organization's policy rather than changing it globally.

## Quick start

    .\Invoke-ReadOnlyAudit.ps1 -OutputPath .\reports\endpoint-audit.json

The combined audit defaults to checking the Winmgmt, EventLog, and BITS services, looking at the last 24 hours of the System event log, and flagging disks with less than 15% free space.

Run an individual automation:

    .\Get-DeviceInventory.ps1 -OutputPath .\reports\inventory.json
    .\Get-DiskHealthReport.ps1 -MinimumFreePercent 20 -OutputPath .\reports\disks.json
    .\Get-ServiceHealthReport.ps1 -ServiceName Winmgmt,EventLog,BITS -OutputPath .\reports\services.json
    .\Get-SystemEventSummary.ps1 -Hours 12 -OutputPath .\reports\system-events.json

Omit -OutputPath to receive PowerShell objects in the console or pipeline. Output folders are created when needed.

## Safety and data handling

These scripts only query local Windows information. They do not change accounts, services, registry settings, network configuration, or system files. The service and disk checks report findings but take no corrective action.

Inventory and audit reports can include a computer name, device model, operating system build, storage details, and service status. Keep reports local and review them before sharing. The reports folder and generated JSON/CSV files are ignored by Git.

## Example workflow

1. Run the combined audit on a workstation.
2. Review the disk and service findings.
3. Save reports locally for troubleshooting or an approved asset-management process.
4. Re-run after remediation to compare results.

See daily-check.md for a short operator workflow.

## Project files

    Get-DeviceInventory.ps1
    Get-DiskHealthReport.ps1
    Get-ServiceHealthReport.ps1
    Get-SystemEventSummary.ps1
    Invoke-ReadOnlyAudit.ps1
    Write-JsonReport.ps1
    daily-check.md

## License

No license has been selected yet. Add one before reusing or redistributing the project.
