function Get-AbandonedHomeFolder {
    <#
    
    .SYNOPSIS

    Return a list of home folders for which no AD account exists
    
    .PARAMETER Path

    The parent folder which shall be checked for abandoned home folders

    .PARAMETER IncludeDisabled

    If used, disabled users will be treated as non-existent

    .OUTPUTS

    System.IO.DirectoryInfo. A list of home folders für which no AD accounts exists

    #>
    
    [OutputType([System.IO.DirectoryInfo])]

    Param(

        [System.String]$Path,
        
        [Switch]$IncludeDisabled

    )

    Process {

        # Checking if path exists
        if ((Test-Path $Path) -eq $false) {

            $Err_Message = ($MyInvocation.MyCommand.Name + " : Die Datei """ + $Path + """ konnte nicht gefunden werden.")
            Write-Error -Message $Err_Message -Category OpenError -ErrorAction Stop
            
        }        

        # Retrieving user list
        if ($IncludeDisabled) {
            $Users = (Get-ADUser -Filter * | Where-Object -Property "Enabled" -eq -Value $true)
        }
        else {
            $Users = Get-ADUser -Filter *
        }

        # Retrieving folder list
        $Folders = Get-ChildItem -Path $Path -Directory        
        
        # Returning $null if $Path has no subfolders
        if ($Folders.Length -eq 0) {
            return $null
        }
        else {

            $AbandonedFolders = (Compare-Object -ReferenceObject $Folders -DifferenceObject $Users.sAMAccountName | Where-Object -Property "SideIndicator" -eq -Value "<=").InputObject
            return $AbandonedFolders

        }
        
    }

}