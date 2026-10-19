# Qorvexa Technologies - IAM Lifecycle Automation
# Simulation only: does not modify user accounts.

$previousPath = "./data/previous-employees.csv"
$currentPath  = "./data/employees.csv"
$reportPath   = "./reports/iam-audit-report.csv"

$previous = @(Import-Csv $previousPath)
$current  = @(Import-Csv $currentPath)

$actions = [System.Collections.Generic.List[object]]::new()

# Check for duplicate employee IDs and email addresses.
foreach ($dataset in @(
    @{ Name = "Previous"; Records = $previous },
    @{ Name = "Current";  Records = $current }
)) {
    foreach ($field in @("EmployeeID", "Email")) {
        $duplicates = $dataset.Records |
            Group-Object -Property $field |
            Where-Object { $_.Count -gt 1 -or [string]::IsNullOrWhiteSpace($_.Name) }

        foreach ($duplicate in $duplicates) {
            $actions.Add([PSCustomObject]@{
                EmployeeID = $duplicate.Name
                Employee   = ""
                Action     = "Review"
                Reason     = "$($dataset.Name) data: duplicate or missing $field"
            })
        }
    }
}

$previousById = @{}
foreach ($employee in $previous) {
    if (-not [string]::IsNullOrWhiteSpace($employee.EmployeeID) -and
        -not $previousById.ContainsKey($employee.EmployeeID)) {
        $previousById[$employee.EmployeeID] = $employee
    }
}

$currentIds = @($current | ForEach-Object { $_.EmployeeID })

foreach ($employee in $current) {
    $name = "$($employee.FirstName) $($employee.LastName)".Trim()
    $required = @(
        "EmployeeID", "FirstName", "LastName",
        "Department", "JobTitle", "Status", "Email"
    )

    $missing = @(
        $required | Where-Object {
            [string]::IsNullOrWhiteSpace($employee.$_)
        }
    )

    if ($missing.Count -gt 0) {
        $actions.Add([PSCustomObject]@{
            EmployeeID = $employee.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Missing required fields: $($missing -join ', ')"
        })
        continue
    }

    if ($employee.Status -notin @("Active", "Terminated")) {
        $actions.Add([PSCustomObject]@{
            EmployeeID = $employee.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Invalid employment status: $($employee.Status)"
        })
        continue
    }

    if ($employee.Status -eq "Terminated") {
        $actions.Add([PSCustomObject]@{
            EmployeeID = $employee.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Leaver: review access removal and account disabling"
        })
        continue
    }

    if (-not $previousById.ContainsKey($employee.EmployeeID)) {
        $actions.Add([PSCustomObject]@{
            EmployeeID = $employee.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Joiner: review account provisioning requirements"
        })
        continue
    }

    $old = $previousById[$employee.EmployeeID]

    if ($old.Status -ne "Active") {
        $actions.Add([PSCustomObject]@{
            EmployeeID = $employee.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Employment status changed; verify before provisioning"
        })
        continue
    }

    if ($old.Department -ne $employee.Department -or
        $old.JobTitle -ne $employee.JobTitle) {
        $actions.Add([PSCustomObject]@{
            EmployeeID = $employee.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Mover: review department and job-title access"
        })
    }
}

# Identify employees present in the baseline but missing from current data.
foreach ($old in $previous) {
    if ($old.EmployeeID -and $old.EmployeeID -notin $currentIds) {
        $actions.Add([PSCustomObject]@{
            EmployeeID = $old.EmployeeID
            Employee   = "$($old.FirstName) $($old.LastName)".Trim()
            Action     = "Review"
            Reason     = "Missing from current data: verify employment status"
        })
    }
}

$actions | Export-Csv $reportPath -NoTypeInformation

Write-Host "`nIAM audit simulation completed."
Write-Host "Employees in current file: $($current.Count)"
Write-Host "Proposed review actions: $($actions.Count)"
Write-Host "Report saved to: $reportPath"
Write-Host "No user accounts were modified."
