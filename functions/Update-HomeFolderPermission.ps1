function Update-HomeFolderPermission {
    <#

    .SYNOPSIS

    Updates permissions of users home folders
    
    .PARAMETER Path

    The parent folder in which the users home folders are located

    .PARAMETER UserRights

    The FileSystemRights that will be granted to each user on its home folder (default: FullControl)

    .PARAMETER SetAdminGroupAsOwner

    If used, the ownership of all files and folders will be set to the group "Domain Admins" recursively

    .OUTPUTS

    None.

    #>

    [CmdletBinding()]
    [OutputType()]

    Param(

        [Parameter(Mandatory = $true)]
        [System.String]$Path,

        [System.Security.AccessControl.FileSystemRights]$UserRights = [System.Security.AccessControl.FileSystemRights]::FullControl,

        [Switch]$SetAdminGroupAsOwner

    )

    Process {

        # Checking if path exists
        if ((Test-Path $Path) -eq $false) {

            $Err_Message = ($MyInvocation.MyCommand.Name + " : Die Datei """ + $Path + """ konnte nicht gefunden werden.")
            Write-Error -Message $Err_Message -Category OpenError -ErrorAction Stop

        }

        # Modifying Home Folder Permissions
        $UserFolders = Get-ChildItem $Path -Directory
        foreach ($UserFolder in $UserFolders) {

            # Find user of folder and create NT account object
            try {

                $User = Get-ADUser -Identity $UserFolder.Name -ErrorAction Stop
                $UserNTAccount = New-Object System.Security.Principal.NTAccount($Domain, $User.sAMAccountName)
    
                Write-Verbose ("Setting permissions of user """ + $User.sAMAccountName + """ on his folder to " + $UserRights.ToString())            
    
                # Modify ACL
                $FolderACL = Get-ACL -path $UserFolder
                $IFl = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"
                $PFl = [System.Security.AccessControl.PropagationFlags]::None
                $AC = [System.Security.AccessControl.AccessControlType]::Allow 
                $AccRule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserNTAccount, $UserRights, $IFl, $PFl, $AC) 
                $FolderACL.SetAccessRule($AccRule)
                Set-ACL -path $UserFolder -AclObject $FolderACL              

            }
            catch {
                Write-Error -Exception $_.Exception
            }


        }      
        
        # Setting Ownership of all files, if requested
        if ($SetAdminGroupAsOwner) {

            Write-Verbose "Enforcing Ownership of Domain Administrators Group"

            # Creating Domain Administrators Group Object
            $DomainAdministratorGroup = Get-ADGroup ((Get-ADDomain).DomainSid.Value.ToString() + "-512")
            $DomainAdministratorGroupNTAccount = New-Object System.Security.Principal.NTAccount($Domain, $DomainAdministratorGroup.sAMAccountName)

            # Setting Files and Subfolders Ownership
            $AllFiles = Get-ChildItem -Recurse -Path $Path
            foreach ($File in $AllFiles) {
                $FileACL = Get-ACL -path $File.FullName
                $FileACL.SetOwner($DomainAdministratorGroupNTAccount)
                Set-ACL -Path $File.FullName -AclObject $FileACL
            }

        }        

    }

}