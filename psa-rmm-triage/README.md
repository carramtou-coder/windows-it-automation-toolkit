# PSA and RMM Alert-to-Ticket Triage

A vendor-neutral MSP operations project. It reads sample exports from a PSA ticket queue and an RMM alert queue, matches records by client and device, and produces a review queue for technicians.

The report highlights active alerts without a matching open ticket, critical or high alerts whose linked ticket priority may be too low, repeated alerts on the same device and category, and missing, approaching, or overdue PSA SLA deadlines. It creates an HTML summary and a CSV action queue. Both included input files contain fictional records.

## Run the sample

From the repository root:

    .\psa-rmm-triage\New-PsaRmmTriageReport.ps1 -PsaTicketCsvPath .\psa-rmm-triage\sample-psa-tickets.csv -RmmAlertCsvPath .\psa-rmm-triage\sample-rmm-alerts.csv -OutputDirectory .\psa-rmm-triage\demo-output

By default, an open ticket is considered due soon when its SLA deadline is within two hours. Change that warning window with SlaWarningHours:

    .\psa-rmm-triage\New-PsaRmmTriageReport.ps1 -PsaTicketCsvPath .\psa-rmm-triage\sample-psa-tickets.csv -RmmAlertCsvPath .\psa-rmm-triage\sample-rmm-alerts.csv -OutputDirectory .\reports\psa-rmm -SlaWarningHours 4

## Input columns

The PSA CSV needs TicketId, Client, Device, Summary, Priority, Status, SlaDueUtc, and AssignedTo. The RMM CSV needs AlertId, Client, Device, Category, Severity, Status, Summary, FirstSeenUtc, and LastSeenUtc. Use ISO 8601 timestamps; UTC values ending in Z are recommended.

The example joins an alert to tickets using a case-insensitive client and device match. A real PSA/RMM environment may use a configuration ID or another stable asset identifier; adjust the match rule before using real exports. Closed, resolved, cleared, completed, normal, and healthy records are excluded from the active queues.

## What it does not do

This is an offline reporting demo, not a vendor integration. It makes no network requests and does not create, modify, close, or reprioritize tickets or alerts. A technician reviews each recommendation and takes any action in the PSA/RMM console. Real exports may include client names, device names, ticket details, and assigned staff, so keep reports private.
