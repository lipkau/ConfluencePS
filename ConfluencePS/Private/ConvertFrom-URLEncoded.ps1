function ConvertFrom-URLEncoded {
    <#
    .SYNOPSIS
        Decode a URL encoded string
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
        Write-Verbose "Decoding string from URL"

        [System.Web.HttpUtility]::UrlDecode($InputString)
    }
}
