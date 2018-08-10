function ConvertTo-Version {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.Version] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to Version"

            [AtlassianPS.ConfluencePS.Version](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                @{Name = "by"; Expression = { ConvertTo-User $_.by }},
                when,
                friendlyWhen,
                number,
                message,
                minoredit,
                @{Name = "Self"; Expression = {$_._links.self}}
            ))
        }
    }
}
