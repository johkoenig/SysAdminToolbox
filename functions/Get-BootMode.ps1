function Get-BootMode {

    <#

    .SYNOPSIS

    Returns the current boot mode

    .EXAMPLE

    PS C:\> Get-BootMode
    Legacy    

    .OUTPUTS

    System.String. The current Boot Mode, either 'Legacy' or 'UEFI'

    #>
    [OutputType([System.String])]
    Param()

    Process {
        return [System.String]$env:firmware_type
    }
    
}