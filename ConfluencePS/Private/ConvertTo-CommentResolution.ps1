function ConvertTo-CommentResolution {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.CommentResolution] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to CommentResolution"

            [AtlassianPS.ConfluencePS.CommentResolution](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                        status,
                    @{Name = "lastModifier"; Expression = {
                            if ($_.lastModifier) {
                                ConvertTo-User $_.lastModifier
                            }
                            else {$null}
                        }
                    },
                    lastModifiedDate
                ))
        }
    }
}
