function ConvertTo-CommentInlineProperty {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.CommentInlineProperties] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to CommentInlineProperties"

            [AtlassianPS.ConfluencePS.CommentInlineProperties](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                        markerReference,
                    originalSelection
                ))
        }
    }
}
