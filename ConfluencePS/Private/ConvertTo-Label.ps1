function ConvertTo-Label {
    <#
    .SYNOPSIS
    Extracted the conversion to private function in order to have a single place to
    select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    param (
    [OutputType( [AtlassianPS.ConfluencePS.Label] )]
        # object to convert
        [Parameter( Position = 0, ValueFromPipeline = $true )]
        $InputObject
    )

    Process {
        foreach ($object in $InputObject) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Converting Object to Label"
            [AtlassianPS.ConfluencePS.Label](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                id,
                name,
                prefix
            ))
        }
    }
}
