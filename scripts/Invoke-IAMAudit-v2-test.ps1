# Qorvexa Technologies - IAM Lifecycle Audit v2
# Simulation only. No accounts are modified.

$previous = @(Import-Csv "./data/previous-employees.csv")
$current  = @(Import-Csv "./data/test-employees.csv")
$reportPath = "./reports/iam-audit-test-report.csv"

$findings = [System.Collections.Generic.List[object]]::new()
$required = @("EmployeeID","FirstName","LastName","Department","JobTitle","Status","Email")
$validStatuses = @("Active","Terminated")

# Find duplicate IDs and emails in current data.
$duplicateIds = @(
    $current | Where-Object { $_.EmployeeID } |
    Group-Object EmployeeID | Where-Object Count -gt 1 |
    ForEach-Object Name
)
$duplicateEmails = @(
    $current | Where-Object { $_.Email } |
    Group-Object Email | Where-Object Count -gt 1 |
    ForEach-Object Name
)

$previousById = @{}
foreach ($person in $previous) {
    if ($person.EmployeeID -and -not $previousById.ContainsKey($person.EmployeeID)) {
        $previousById[$person.EmployeeID] = $person
    }
}

$currentIds = @($current | ForEach-Object EmployeeID)

foreach ($person in $current) {
    $name = "$($person.FirstName) $($person.LastName)".Trim()
    $issues = [System.Collections.Generic.List[string]]::new()

    foreach ($field in $required) {
        if ([string]::IsNullOrWhiteSpace($person.$field)) {
            $issues.Add("Missing $field")
        }
    }

    if ($person.Status -notin $validStatuses) {
        $issues.Add("Invalid status '$($person.Status)'")
    }
    if ($person.EmployeeID -in $duplicateIds) {
        $issues.Add("Duplicate employee ID")
    }
    if ($person.Email -in $duplicateEmails) {
        $issues.Add("Duplicate email")
    }

    if ($issues.Count -gt 0) {
        $findings.Add([PSCustomObject]@{
            EmployeeID = $person.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = $issues -join "; "
        })
        continue
    }

    if ($person.Status -eq "Terminated") {
        $findings.Add([PSCustomObject]@{
            EmployeeID = $person.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Leaver: verify access removal and account disabling"
        })
        continue
    }

    if (-not $previousById.ContainsKey($person.EmployeeID)) {
        $findings.Add([PSCustomObject]@{
            EmployeeID = $person.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Joiner: verify account provisioning requirements"
        })
        continue
    }

    $old = $previousById[$person.EmployeeID]

    if ($old.Status -ne "Active") {
        $findings.Add([PSCustomObject]@{
            EmployeeID = $person.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Previous status was not Active; verify before access changes"
        })
        continue
    }

    if ($old.Department -ne $person.Department -or
        $old.JobTitle -ne $person.JobTitle) {
        $findings.Add([PSCustomObject]@{
            EmployeeID = $person.EmployeeID
            Employee   = $name
            Action     = "Review"
            Reason     = "Mover: review department and job-title access"
        })
    }
}

foreach ($old in $previous) {
    if ($old.EmployeeID -and $old.EmployeeID -notin $currentIds) {
        $findings.Add([PSCustomObject]@{
            EmployeeID = $old.EmployeeID
            Employee   = "$($old.FirstName) $($old.LastName)".Trim()
            Action     = "Review"
            Reason     = "Missing from current data; verify employment status"
        })
    }
}

$findings | Export-Csv $reportPath -NoTypeInformation
Write-Host "`nIAM audit v2 completed."
Write-Host "Current records: $($current.Count)"
Write-Host "Review findings: $($findings.Count)"
Write-Host "Report: $reportPath"
Write-Host "Simulation only: no accounts were modified."

