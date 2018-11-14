function ConvertTo-CamelCase {
    
    <#

    .SYNOPSIS
    Converts a given string to CamelCase notation

    .DESCRIPTION
    ConvertTo-CamelCase converts a given string to CamelCase notation.
    By default, the UpperCamelCase notation will be used. This can be changed to LowerCamelCase by using the Switch '-LowerCamelCase'

    .PARAMETER String
    The string that will be converted to CamelCase notation

    .PARAMETER Seperator
    One or more chars/strings that will be used as seperator between words.
    Default are whitespace ( ), unterscore (_), and hyphen (-)

    .PARAMETER LowerCamelCase
    If LowerCamelCase Switch is activated, the string will be returned with first lower first letter

    .EXAMPLE
    C:\> ConvertTo-CamelCase 'Report Template_Official'
    ReportTemplateOfficial

    .EXAMPLE
    C:\> ConvertTo-CamelCase 'Report Template_Official' -Seperator ' '
    ReportTemplate_official

    .EXAMPLE
    C:\> 'Report Template_Official' | ConvertTo-CamelCase -Seperator ' ' -LowerCamelCase
    reportTemplate_official    
    
    .OUTPUTS
    System.String. ConvertTo-CamelCase will return the string in CamelCase Notation

    #>

    [OutputType([System.String])]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
            [System.String]$String,
        [System.String[]]$Seperator = @(' ','-','_'),
        [Switch]$LowerCamelCase
    )

    Process {

        # Split String
        $Words = $String.ToLower().Split($Seperator)
        $Words = $Words | Where-Object {$_.Length -ne 0} # Remove empty words

        # Convert to CamelCase
        $Words = $Words | ForEach-Object {$_[0].ToString().ToUpper() + $_.Substring(1)}
        $Words | ForEach-Object { $CamelCaseString += $_}

        # Handle LowerCamelCase
        if ($LowerCamelCase) {
            $CamelCaseString = $CamelCaseString[0].ToString().ToLower() + $CamelCaseString.Substring(1)
        }

        return [System.String]$CamelCaseString
    }

}