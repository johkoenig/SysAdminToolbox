# Preparing
$VP = $VerbosePreference

# Creating Testing Environment
Import-Module ActiveDirectoryManager -Force -Prefix ADMTesting
$VerbosePreference = "Continue"

# Testing
New-ADMTestingHomeFolder -Path "C:\UserHomeFolder_Testing\"


# Cleaning Up
$VerbosePreference = $VP