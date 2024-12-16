<#
.SYNOPSIS
    Disables all Active Directory users who have not logged on in the past 30 days.

.DESCRIPTION
    This script will find all users in Active Directory whose last logon date is more than 30 days ago
    and disable their accounts.

.REQUIREMENTS
    Active Directory PowerShell module must be installed and imported.

.NOTES
    Author: Kjetil
    Version: 1.0
#>

# Ensure the Active Directory module is loaded
Import-Module ActiveDirectory -ErrorAction Stop

# Get the current date
$currentDate = Get-Date

# Define the cutoff date (30 days ago)
$cutoffDate = $currentDate.AddDays(-30)

# Get all users in the domain whose LastLogonDate is older than the cutoff date
$inactiveUsers = Get-ADUser -Filter * -Properties SamAccountName, LastLogonDate |
                 Where-Object { $_.LastLogonDate -lt $cutoffDate -or !$_.LastLogonDate }

# Disable each inactive user
foreach ($user in $inactiveUsers) {
    try {
        # Disable the user account
        Disable-ADAccount -Identity $user.SamAccountName
        Write-Host "Successfully disabled user: $($user.SamAccountName)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to disable user: $($user.SamAccountName). Error: $_" -ForegroundColor Red
    }
}

Write-Host "Script completed. Total users disabled: $($inactiveUsers.Count)" -ForegroundColor Cyan
