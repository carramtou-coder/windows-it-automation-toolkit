# MSP Backup Compliance Report

A small PowerShell reporting project for multi-client IT operations. It turns a normalized backup-platform CSV export into an HTML overview and a CSV containing only rows that need attention.

It checks whether the latest job succeeded, the last successful backup is recent, retention meets a configurable target, and a restore test is recent. The sample data is fictional.

## Run the sample

From the repository root:

    .\backup-compliance\New-MspBackupComplianceReport.ps1 -InputCsvPath .\backup-compliance\sample-backup-export.csv -OutputDirectory .\backup-compliance\demo-output

The output folder contains backup-compliance-report.html and backup-exceptions.csv. The default thresholds are a successful backup within 24 hours, a restore test within 180 days, and at least 30 days of retention. Set them for the service agreement or policy you are reviewing:

    .\backup-compliance\New-MspBackupComplianceReport.ps1 -InputCsvPath .\backup-compliance\sample-backup-export.csv -OutputDirectory .\reports\backup -MaxBackupAgeHours 12 -RestoreTestMaxAgeDays 90 -MinimumRetentionDays 60

## CSV format

The export needs these column names. Timestamps should be ISO 8601; UTC timestamps ending in Z are recommended.

| Column | Example | Purpose |
| --- | --- | --- |
| Client | Example Dental Group | Client or tenant label |
| Device | EDG-FS01 | Protected server or endpoint |
| LastBackupStatus | Success | Status of the most recent backup job |
| LastSuccessfulBackupUtc | 2026-09-28T03:15:00Z | Time of the most recent successful backup |
| RetentionDays | 30 | Configured retention period |
| LastRestoreTestUtc | 2026-08-12T14:00:00Z | Time of the most recent restore test |

Status values accepted as successful are success, succeeded, completed, and ok (case-insensitive). All other values are flagged.

## Findings

- Latest job failed or has an unrecognized status
- Successful backup timestamp is missing, invalid, too old, or in the future
- Retention is missing, invalid, or below the selected minimum
- Restore test is missing, invalid, too old, or in the future
- Client or device name is blank

The script reads the CSV and writes local reports. It does not make network calls or change backup jobs, retention policies, clients, or devices. It is vendor-neutral: map your backup product's export columns to this documented CSV format first.

An export summary cannot prove that the backup is recoverable. Validate recovery with actual, documented restore tests and review the thresholds against the client agreement. Treat generated reports as private because names and backup state can be sensitive. The demo output folder is ignored by Git.
