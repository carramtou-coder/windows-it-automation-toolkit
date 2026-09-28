# Daily workstation check

This example is an operator workflow, not a scheduled task. Review your organization's monitoring and retention rules before storing reports.

1. Open PowerShell in the project folder.
2. Generate a local audit report:

       .\scripts\Invoke-ReadOnlyAudit.ps1 -OutputPath .\reports\workstation-audit.json

3. Check OverallStatus, Findings, and the disk and service sections.
4. If a service is expected to be stopped in your environment, name it explicitly with -ExpectedServiceStatus Stopped or remove it from the service list.
5. Review and protect the generated file; reports can contain device details.
