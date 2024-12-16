<#
.SYNOPSIS
    Enhanced menu-driven tool to list and export detailed Active Directory data.

.DESCRIPTION
    Lists detailed attributes of AD users, OUs, groups, and computers, with options to export results to a file.

.REQUIREMENTS
    Active Directory PowerShell module must be installed and imported.

.NOTES
    Author: Kjetil
    Version: 1.1
#>

# Ensure the Active Directory module is loaded
Import-Module ActiveDirectory -ErrorAction Stop

# Function: Display the main menu
function Show-Menu {
    Write-Host "========== Active Directory Information Explorer ==========" -ForegroundColor Cyan
    Write-Host "1. List all users in the domain"
    Write-Host "2. List all Organizational Units (OUs)"
    Write-Host "3. List all groups in the domain"
    Write-Host "4. List all computers in the domain"
    Write-Host "5. Export last search result to a file"
    Write-Host "6. Exit"
    Write-Host "=========================================================="
}

# Function: Export data to a file
function Export-Data {
    param (
        [array]$Data,
        [string]$FileName
    )
    if (-not $Data) {
        Write-Host "No data to export. Perform a search first." -ForegroundColor Red
        return
    }
    try {
        $FilePath = "./$FileName"
        $Data | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8
        Write-Host "Data successfully exported to $FilePath" -ForegroundColor Green
    } catch {
        Write-Host "Error exporting data. $_" -ForegroundColor Red
    }
}

# Variables
$currentData = $null
$exit = $false

# Main script logic
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-6)"
    switch ($choice) {
        "1" {
            Write-Host "Fetching all users in the domain with details..." -ForegroundColor Yellow
            $currentData = Get-ADUser -Filter * -Properties SamAccountName, DisplayName, EmailAddress, Title, Department, Enabled, LastLogonDate | 
                           Select-Object SamAccountName, DisplayName, EmailAddress, Title, Department, Enabled, LastLogonDate
            $currentData | Format-Table -AutoSize
            Write-Host "Total Users: $($currentData.Count)" -ForegroundColor Cyan
        }
        "2" {
            Write-Host "Fetching all Organizational Units (OUs) with details..." -ForegroundColor Yellow
            $currentData = Get-ADOrganizationalUnit -Filter * | 
                           Select-Object Name, DistinguishedName, ProtectedFromAccidentalDeletion
            $currentData | Format-Table -AutoSize
            Write-Host "Total OUs: $($currentData.Count)" -ForegroundColor Cyan
        }
        "3" {
            Write-Host "Fetching all groups in the domain with details..." -ForegroundColor Yellow
            $currentData = Get-ADGroup -Filter * -Properties Name, GroupScope, Description, ManagedBy | 
                           Select-Object Name, GroupScope, Description, ManagedBy
            $currentData | Format-Table -AutoSize
            Write-Host "Total Groups: $($currentData.Count)" -ForegroundColor Cyan
        }
        "4" {
            Write-Host "Fetching all computers in the domain with details..." -ForegroundColor Yellow
            $currentData = Get-ADComputer -Filter * -Properties Name, OperatingSystem, LastLogonDate, IPv4Address | 
                           Select-Object Name, OperatingSystem, LastLogonDate, IPv4Address
            $currentData | Format-Table -AutoSize
            Write-Host "Total Computers: $($currentData.Count)" -ForegroundColor Cyan
        }
        "5" {
            Write-Host "Enter the filename to export data (e.g., data.csv):" -ForegroundColor Yellow
            $fileName = Read-Host
            Export-Data -Data $currentData -FileName $fileName
        }
        "6" {
            Write-Host "Exiting... Goodbye!" -ForegroundColor Cyan
            $exit = $true
        }
        Default {
            Write-Host "Invalid choice. Please select an option between 1 and 6." -ForegroundColor Red
        }
    }
} while (-not $exit)
