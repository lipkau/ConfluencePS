function ConvertTo-HTMLEncoded {
    <#
    .SYNOPSIS
        Encode a string into HTML (eg: &gt; instead of >)
    #>
    [CmdletBinding()]
    [OutputType( [String] )]
    param(
        # String to encode
        [Parameter( Mandatory, ValueFromPipeline )]
        [String]
        $InputString
    )

    process {
        Write-Verbose "Encoding string to HTML"

        [System.Web.HttpUtility]::HtmlEncode($InputString)
    }
}
