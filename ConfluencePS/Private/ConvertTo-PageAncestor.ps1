function ConvertTo-PageAncestor {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.Page] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to Page (Ancestor)"

            [AtlassianPS.ConfluencePS.Page](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                id,
                status,
                title
            ))
        }
    }
}
