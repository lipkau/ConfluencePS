function ConvertTo-User {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.User] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to User"

            [AtlassianPS.ConfluencePS.User](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                username,
                userKey,
                @{Name = "profilePicture"; Expression = { ConvertTo-Icon $_.profilePicture }},
                displayname,
                @{Name = "Self"; Expression = {$_._links.self}}
            ))
        }
    }
}
