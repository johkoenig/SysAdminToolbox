
function New-HomeFolder {
    <#

    .SYNOPSIS

    Generate home folders for AD Users

    .PARAMETER Path

    The parent folder in which the user home folders shall be created
    
    .PARAMETER IncludeDisabled

    If used, home folders will also be created for disabled AD accounts

    .OUTPUTS

    None. 
    
    #>
    [OutputType()]
    Param (

        [Parameter(Mandatory = $true)]
        [System.String]$Path,

        [Switch]$IncludeDisabled

    )
    
    Process {

        # Checking if path exists
        if ((Test-Path $Path) -eq $false) {

            $Err_Message = ($MyInvocation.MyCommand.Name + " : Die Datei """ + $Path + """ konnte nicht gefunden werden.")
            Write-Error -Message $Err_Message -Category OpenError -ErrorAction Stop
            
        }          

        # Retrieving User List
        if ($IncludeDisabled) {
            $Users = Get-ADUser -Filter *
        } else {
            $Users = (Get-ADUser -Filter * | Where-Object -Property "Enabled" -eq -Value $true)
        }

        # Iterating through User List
        foreach ($User in $Users) {

            # Definition of Home Folder Path
            $UserHomeFolderPath = Join-Path -Path $Path -ChildPath $User.sAMAccountName

            # Creating Home Folder, if not existing
            if (!(Test-Path -Path $UserHomeFolderPath -PathType Container)) {

                # Creating Folder
                Write-Verbose ("Creating Folder for User """ + $User.sAMAccountName + """")
                New-Item -ItemType Directory -Path $UserHomeFolderPath | Out-Null

            }
            else {
                Write-Verbose ("Skipping """ + $User.sAMAccountName + """: folder already exists")
            }

        }

    }

}