# Qorvexa Technologies - Employee Data Validation
# Test-only script. Does not modify accounts or source data.

$path = "./data/test-employees.csv"
$reportPath = "./reports/validation-report.csv"
$employees = @(Import-Csv $path)
$findings = [System.Collections.Generic.List[object]]::new()

$requiredFields = @(
    "EmployeeID", "FirstName", "LastName",
    "Department", "JobTitle", "Status", "Email"
)

# Check required fields and valid status.
foreach ($employee in $employees) {
    foreach ($field in $requiredFields) {
        if ([string]::IsNullOrWhiteSpace($employee.$field)) {
            $findings.Add([PSCustomObject]@{
                EmployeeID = $employee.EmployeeID
                Field      = $field
                Issue      = "Missing required value"
            })
        }
    }

    if ($employee.Status -notin @("Active", "Terminated")) {
        $findings.Add([PSCustomObject]@{
            EmployeeID = $employee.EmployeeID
            Field      = "Status"
            Issue      = "Invalid status: $($employee.Status)"
        })
    }
}

# Check duplicate employee IDs and email addresses.
foreach ($field in @("EmployeeID", "Email")) {
    $duplicates = $employees |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.$field) } |
        Group-Object -Property $field |
        Where-Object { $_.Count -gt 1 }

    foreach ($duplicate in $duplicates) {
        foreach ($employee in $duplicate.Group) {
            $findings.Add([PSCustomObject]@{
                EmployeeID = $employee.EmployeeID
                Field      = $field
                Issue      = "Duplicate value: $($duplicate.Name)"
            })
        }
    }
}

$findings | Export-Csv $reportPath -NoTypeInformation

Write-Host "`nEmployee data validation completed."
Write-Host "Records checked: $($employees.Count)"
Write-Host "Findings identified: $($findings.Count)"
Write-Host "Report saved to: $reportPath"
Write-Host "No source records or accounts were modified."
