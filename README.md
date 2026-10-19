# Qorvexa IAM Automation

A PowerShell-based Identity and Access Management (IAM) audit and employee data validation project designed to simulate identity lifecycle reviews, identify data quality issues, and generate actionable audit reports.

## Project Overview

Identity and Access Management helps organizations ensure that users have appropriate access to systems and that access is reviewed when employees join, change roles, or leave an organization.

This project simulates IAM auditing using employee CSV datasets and PowerShell scripts. It identifies potential identity data issues and generates reports that an IAM analyst could use to investigate access and account lifecycle concerns.

**All operations are simulation-only. The scripts do not modify actual user accounts.**

## Project Objectives

- Compare previous and current employee records.
- Identify duplicate employee IDs and email addresses.
- Validate required employee data fields.
- Detect invalid employment status values.
- Flag employees requiring review due to changes in employment status, department, or job title.
- Generate CSV reports containing audit findings and recommended review actions.
- Demonstrate PowerShell scripting, data validation, and IAM audit concepts.

## Technologies Used

- **PowerShell** — scripting and automation
- **CSV** — employee datasets and audit reports
- **Git and GitHub** — version control and project documentation

## Repository Structure

```text
Qorvexa-IAM-Automation/
├── data/
│   ├── employees.csv
│   ├── previous-employees.csv
│   └── test-employees.csv
├── reports/
│   ├── iam-audit-report.csv
│   ├── iam-audit-report-v2.csv
│   ├── iam-audit-test-report.csv
│   └── validation-report.csv
├── screenshots/
│   └── Project execution and audit evidence
└── scripts/
    ├── Invoke-IAMAudit.ps1
    ├── Invoke-IAMAudit-v1-backup.ps1
    ├── Invoke-IAMAudit-v2.ps1
    ├── Invoke-IAMAudit-v2-test.ps1
    └── Test-EmployeeData.ps1
```

## Scripts and Functionality

### 1. IAM Lifecycle Audit

**Script:** `scripts/Invoke-IAMAudit.ps1`

Compares previous and current employee datasets to identify potential identity lifecycle changes and data issues requiring review.

The script generates `reports/iam-audit-report.csv`.

### 2. Enhanced IAM Audit

**Script:** `scripts/Invoke-IAMAudit-v2.ps1`

Provides an updated audit implementation that checks employee records for issues such as duplicate identifiers, duplicate email addresses, and changes requiring review.

The script generates `reports/iam-audit-report-v2.csv`.

### 3. Employee Data Validation

**Script:** `scripts/Test-EmployeeData.ps1`

Validates employee test data for missing required fields, invalid employment statuses, and duplicate employee IDs or email addresses.

The script generates `reports/validation-report.csv`.

### 4. IAM Audit Testing

**Script:** `scripts/Invoke-IAMAudit-v2-test.ps1`

Runs the audit logic against a test dataset designed to exercise identity audit scenarios and produce findings for review.

The script generates `reports/iam-audit-test-report.csv`.

## Sample Findings

The sample reports demonstrate how the project can flag:

- Duplicate employee IDs.
- Duplicate email addresses.
- Missing required department information.
- Invalid employment status values.
- Employees missing from the current employee dataset.
- Employees whose employment status or organizational information may require review.

These findings represent review recommendations based on simulated employee records. They do not independently establish that an account is improperly provisioned or that unauthorized access has occurred.

## How to Run

### Prerequisites

- Git
- PowerShell 7 or another compatible PowerShell environment

### 1. Clone the repository

```bash
git clone https://github.com/FoxCyberGeek/Qorvexa-IAM-Automation.git
cd Qorvexa-IAM-Automation
```

### 2. Run the IAM audit

From the repository root, run:

```powershell
pwsh -File ./scripts/Invoke-IAMAudit.ps1
```

### 3. Run the enhanced IAM audit

```powershell
pwsh -File ./scripts/Invoke-IAMAudit-v2.ps1
```

### 4. Run employee data validation

```powershell
pwsh -File ./scripts/Test-EmployeeData.ps1
```

### 5. Run the audit test script

```powershell
pwsh -File ./scripts/Invoke-IAMAudit-v2-test.ps1
```

The scripts use relative paths to access the project's datasets and report files. Run them from the repository root, and ensure the expected input files exist before execution.

Review the generated CSV files in the `reports/` directory to inspect the findings.

## Security and Testing Considerations

- Uses simulated employee data rather than a live directory or identity provider.
- Does not modify actual user accounts.
- Produces review recommendations rather than automatically granting or revoking access.
- Includes test data containing intentional validation issues.
- Keeps audit findings in CSV format for inspection and further analysis.

This is a portfolio simulation, not a production IAM integration. Before using similar automation in a real environment, additional testing, error handling, access controls, logging, and approval safeguards would be necessary.

## Skills Demonstrated

- PowerShell scripting and automation
- Identity lifecycle auditing
- Employee record validation
- Duplicate detection and data quality checks
- CSV data processing and reporting
- IAM access review concepts
- Git and GitHub version control
- Security-conscious, simulation-based testing

## Project Purpose

This project demonstrates practical exploration of IAM auditing and PowerShell automation through simulated employee lifecycle scenarios. It provides a foundation for further development in identity governance, access reviews, account lifecycle management, and security administration.

**Author:** Marsyas Fox

**Repository:** https://github.com/FoxCyberGeek/Qorvexa-IAM-Automation
