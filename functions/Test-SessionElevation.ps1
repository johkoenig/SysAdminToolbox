function Test-SessionElevation {

    <#

    .SYNOPSIS
    Tests whether the current session is elevated

    .EXAMPLE
    PS C:\>Test-SessionElevation
    True

    .OUTPUTS
    System.Boolean. Test-SessionElevation returns whether the current PowerShell Session is elevated.

    .NOTES
    Copied from https://ss64.com/ps/syntax-elevate.html

    #>

    [OutputType([System.Boolean])]
    Param()

    Process {
        
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        return [System.Boolean]$isAdmin
    }
}
