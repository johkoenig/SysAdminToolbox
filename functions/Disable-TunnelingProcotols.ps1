function Disable-TunnelingProtocols {
    
    <#
    .SYNOPSIS
    Disabled the tunneling protocols Teredo, Isatap and 6to4

    .DESCRIPTION
    On Windows 10 systems, the tunneling protocols ISATAP, Teredo and 6to4 are enabled by default.
    These procotols are not used in most environments and can cause network connection problems.
    Disable-TunnelingProtocols disables these tunneling protocols.

    .EXAMPLE
    PS C:\> Disable-TunnelingProtocols

    .EXAMPLE
    PS C:\> Disable-TunnelingProtocols -Verbose
    ISATAP: disabled
    Teredo: No action, already disabled
    6to4: No action, already disabled

    .NOTES
    This function must be run as administrator.

    #>

    [CmdletBinding()]
    Param()

    Process {

        # ISATAP
        if ((Get-NetIsatapConfiguration).State -ne 'Disabled') {
            Set-NetIsatapConfiguration -State Disabled -ErrorAction Stop
            Write-Verbose "ISATAP: Disabled"
        }
        else {
            Write-Verbose "ISATAP: No action, already disabled"
        }

        # Teredo
        if ((Get-NetTeredoConfiguration).Type -ne 'Disabled') {
            Set-NetTeredoConfiguration -Type Disabled -ErrorAction Stop
            Write-Verbose "Teredo: Disabled"
        }
        else {
            Write-Verbose "Teredo: No action, already disabled"
        }

        # 6to4
        if ((Get-Net6to4Configuration).State -ne 'Disabled') {
            Set-Net6to4Configuration -State Disabled -ErrorAction Stop
            Write-Verbose "6to4: Disabled"
        }
        else {
            Write-Verbose "6to4: No action, already disabled"
        }

    }
}