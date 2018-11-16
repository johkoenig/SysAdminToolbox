function Get-ADBitlockerRecoveryInformation {

    <#

    .SYNOPSIS
    
    Extracts the Bitlocker Recovery Information for a given computer identity
    
    .DESCRIPTION

    In an Active Directory environment, it is possible to store recovery keys in the directory.
    This allows administrators a centralized management of keys, which ensures that encrypted drives
    can be decrypted even if the user forgets its key.

    .PARAMETER Identity
    
    The active directory computer identity for which the key should be extracted.

    .PARAMETER NewestOnly

    The output is limited to the key with the newest date.

    .INPUTS

    The active directory computer identity can be piped to the function.

    .OUTPUTS

    Microsoft.ActiveDirectory.Management.ADObject[]. The recovery key(s).

    #>


    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [Microsoft.ActiveDirectory.Management.ADComputer]$Identity,

        [Switch]$NewestOnly
    )

    Begin {

        Import-Module ActiveDirectory

    }

    Process {

        # Retrieve Key
        $StoredKey = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $Identity.DistinguishedName -Properties 'msFVE-RecoveryPassword'

        # Return Key(s)
        if ($NewestOnly) {
            return ($StoredKey | Sort-Object -Property "Name" -Descending | Select-Object -First 1)
        }
        else {
            return $StoredKey
        }

    }
}