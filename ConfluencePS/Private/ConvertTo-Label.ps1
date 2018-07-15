function ConvertTo-Label {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.Label] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to Label"

            [AtlassianPS.ConfluencePS.Label](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                id,
                name,
                prefix
            ))
        }
    }
}
