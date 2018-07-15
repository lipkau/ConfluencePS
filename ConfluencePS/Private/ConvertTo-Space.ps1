function ConvertTo-Space {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.Space] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to Space"

            [AtlassianPS.ConfluencePS.Space](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                id,
                key,
                name,
                @{Name = "description"; Expression = {$_.description.plain.value}},
                @{Name = "Icon"; Expression = {
                        if ($_.icon) {
                            ConvertTo-Icon $_.icon
                        }
                        else {$null}
                    }
                },
                type,
                @{Name = "Homepage"; Expression = {
                    if ($_.homepage -is [PSCustomObject]) {
                            ConvertTo-Page $_.homepage
                    } else {$null} # homepage might be a string
                }}
            ))
        }
    }
}
