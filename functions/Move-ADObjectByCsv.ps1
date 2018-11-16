function Move-ADObjectByCsv {
    <#

    .SYNOPSIS

    Move Objects into corresponding OUs based on their name

    .DESCRIPTION

    The Move-ADObjectByCsv function is a sophisticated version of the Move-ADObject function that comes with the ActiveDirectory module.
    It moves all sorts of AD objects based on LDAP filters. The filters must be defined in a CSV file.


    .PARAMETER TargetPathCSV

    Specifies the path to the CSV file to import. You can also pipe the path to Move-Object.
    Move-Object will only work if the CSV follows a certain layout.
    Mandatory columns are:
        - LDAPFilter (containing a valid LDAP Filter for which objects the TargetPath should apply to)
        - TargetPath (containing the DN of the OU to which the filtered objects should be moved to)
    Optional columns are:
        - IgnoreWhenInSubOU (defines whether an object will be moved to the parent OU. default is 'true')
    
    .OUTPUTS

    None.

    .EXAMPLE

    PS C:\> Move-ADObjectByCsv -TargetPathCSV ".\example.csv"

    .NOTES
    
    You must run this functions as a user who is privileged to move AD objects

    #>

    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][System.String]$TargetPathCSV
    )

    Process {

        # Load CSV
        $CSV = Import-Csv $TargetPathCSV

        # Validate CSV
        $CsvHeader = $CSV | Get-Member -MemberType NoteProperty
        if (($CsvHeader.Name -eq "LDAPFilter").Count -ne 1) {
            Write-Error "CSV-file is missing column 'LDAPHeader'"
        }
        if (($CsvHeader.Name -eq "TargetPath").Count -ne 1) {
            Write-Error "CSV-file is missing column 'TargetPath'"
        }

        # Iterating through the CSV
        foreach ($Target in $CSV) {
            
            # Retrieving all objects based on the LDAP filter
            $ADObjects = Get-ADObject -LDAPFilter $Target.LDAPFilter 

            # Checking for parameter "IgnoreWhenInSubOU"
            if (($Target | Get-Member -Type NoteProperty -Name IgnoreWhenInSubOU).Count -ne 1) {

                # Adding Property with standard behaviour
                Add-Member -InputObject $Target -MemberType NoteProperty -Name 'IgnoreWhenInSubOU' -Value $true
            
            } else {

                # Converting String to Boolean
                if ($Target.IgnoreWhenInSubOU.ToLower() -eq "false") {
                    $Target.IgnoreWhenInSubOU = $false
                } elseif ($Target.IgnoreWhenInSubOU.ToLower() -eq "true") {
                    $Target.IgnoreWhenInSubOU = $true
                } else {
                    Write-Error "Entries in 'IgnoreWhenInSubOU' must be either 'true' or 'false'"
                }

            }
            
            # Iterating through found ADObjects
            foreach ($ADObject in $ADObjects) {
                
                $targetDN = "CN=" + $ADObject.Name + "," + $Target.TargetPath
                $currentDN = $ADObject.DistinguishedName

                # Check if computer object needs to be moved
                if ($Target.IgnoreWhenInSubOU) {

                    # if targetDN is aboce currentDN, object will not be moved
                    $ObjectInCorrectOU = $currentDN.EndsWith($Target.TargetPath)

                } else {

                    # currentDN and targetDN must match precisely
                    $ObjectInCorrectOU = ($targetDN -eq $currentDN)   

                }

                if ($ObjectInCorrectOU) {

                    # Computer already in assigned OU. Report no moving necessary
                    Write-Verbose ("Skipping " + $ADObject.Name + " (already in " + $targetDN + ")")

                }
                else {

                    # Moving misassigned computer object
                    try {

                        Move-ADObject -Identity $ADObject -TargetPath $Target.TargetPath -ErrorAction Stop
                        Write-Host -ForegroundColor Green ("   -- Moving " + $ADObject.Name + " into " + $targetDN)

                    }
                    catch {

                        Write-Host -ForegroundColor Magenta ("   -- Unable to move " + $ADObject.Name + ": " + $_.Exception.Message)

                    }
        
                }

            }

        }

        return
        
    }

}