function Convert-MacToIPv6 {
    <#
    
    .SYNOPSIS
    Converts a given MAC address to a link-local IPv6 address

    .PARAMETER MacAddress
    Specifies the MAC-Address to be converted

    .OUTPUTS
    System.String. Convert-MacToIPv6 returns the converted link-local IPv6 address as a string   

    .EXAMPLE
    C:\PS> Convert-MacToIPv6 'aa:bb:cc:dd:ee:ff'
    fe80::a8bb:ccff:fedd:eeff

    .EXAMPLE
    C:\PS> Convert-MacToIPv6 'de:ad:de:ad:be:ef'
    fe80::dcad:deff:fead:beef

    #>
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline = $true)]
        [System.String]
        $MacAddress
    )
    
    Process {

        # Check for valid MAC address
        if (!(Test-MacAddress $MacAddress)) {
            Write-Error -Message ('"' + $MacAddress + '" is not valid MAC address') -Category InvalidData
            return
        }

        # Reformat MAC address to lowercase and colons
        $MacAddress = $MacAddress.Replace('-', ':').ToLower()

        # Put ff:fe into the middle and remove unneccessary colons
        $IPv6InterfaceIdentfier = $MacAddress.Substring(0, 2) + $MacAddress.Substring(3, 5) + 'ff:fe' + $MacAddress.Substring(9, 5) + $MacAddress.Substring(15, 2)

        #Inverting bit at index 6 (counted from 0)
        $octet = [Convert]::ToString(('0x' + $IPv6InterfaceIdentfier.Substring(0, 2)), 2)
        $octet_length = $octet.Length
        for ($i = 1; $i -le (8 - $octet_length); $i++) { $octet = ('0' + $octet) }
        if ($octet[6] -eq '0') {
            $octet = $octet.Substring(0,6) + '1' + $octet[7]
        }
        else {
            $octet = $octet.Substring(0,6) + '0' + $octet[7]
        }
        $octet = [Convert]::ToString([Convert]::ToInt32($octet,2),16)
        $octet_length = $octet.Length
        for ($i = 1; $i -le (2 - $octet_length); $i++) { $octet = ('0' + $octet) }        
        $IPv6InterfaceIdentfier = ($octet + $IPv6InterfaceIdentfier.Substring(2))
        
        # Adding link-local prefix
        $IPv6 = ('fe80::' + $IPv6InterfaceIdentfier)

        # Return
        return [System.String]$IPv6        
    }
}