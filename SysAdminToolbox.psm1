# Import everything in the 'functions' folder
(Get-ChildItem -Path ($PSScriptRoot + "\functions\*.ps1")) | ForEach-Object {
    . $_.FullName
}

# Export all functions
Export-ModuleMember -Function *