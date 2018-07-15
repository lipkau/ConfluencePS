function ConvertTo-URLEncoded {
    <#
    .SYNOPSIS
        Encode a string into URL (eg: %20 instead of " ")
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
        Write-Verbose "Encoding string to URL"

        [System.Web.HttpUtility]::UrlEncode($InputString)
    }
}
