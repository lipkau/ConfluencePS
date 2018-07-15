function ConvertFrom-HTMLEncoded {
    <#
    .SYNOPSIS
        Decode a HTML encoded string
    #>
    [CmdletBinding()]
    [OutputType( [String] )]
    param(
        # String to decode
        [Parameter( Mandatory, ValueFromPipeline )]
        [String]
        $InputString
    )

    process {
        Write-Verbose "Decoding string from HTML"

        [System.Web.HttpUtility]::HtmlDecode($InputString)
    }
}
