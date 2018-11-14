function Test-SecureBoot {
    <#
    
    .SYNOPSIS
    Returns whether Secure Boot is activated or not

    .OUTPUTS
    System.Boolean. Returns whether Secure Boot is activated or not.

    #>
    
    [OutputType([System.Boolean])]
    Param()

    Process {

        try {
            return [System.Boolean](Confirm-SecureBootUEFI -ErrorAction Stop)
        } catch {
            # Return false if system is in Legacy mode
            return $false
        }
    }
    
}