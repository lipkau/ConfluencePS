function ConvertTo-Comment {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.Comment] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to Comment"

            [AtlassianPS.ConfluencePS.Comment](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                        id,
                    status,
                    title,
                    @{Name = "author"; Expression = {
                            if ($_.history -and $_.history.createdBy) {
                                ConvertTo-User $_.history.createdBy
                            }
                            else {$null}
                        }
                    },
                    @{Name = "version"; Expression = {
                            if ($_.version) {
                                ConvertTo-Version $_.version
                            }
                            else {$null}
                        }
                    },
                    @{Name = "body"; Expression = {$_.body.storage.value}},
                    @{Name = "location"; Expression = {
                            if ($_.extensions -and $_.extensions.location) {
                                $_.extensions.location
                            }
                            else {$null}
                        }
                    },
                    @{Name = "resolution"; Expression = {
                            if ($_.extensions -and $_.extensions.resolution) {
                                ConvertTo-CommentResolution $_.extensions.resolution
                            }
                            else {$null}
                        }
                    },
                    @{Name = "inlineProperties"; Expression = {
                            if ($_.extensions -and $_.extensions.inlineProperties) {
                                ConvertTo-CommentInlineProperty $_.extensions.inlineProperties
                            }
                            else {$null}
                        }
                    },
                    @{Name = "URL"; Expression = {
                            $base = $_._links.base
                            if (!($base)) { $base = $_._links.self -replace '\/rest.*', '' }
                            if ($_._links.webui) {
                                "{0}{1}" -f $base, $_._links.webui
                            }
                            else {$null}
                        }
                    },
                    @{Name = "Self"; Expression = {$_._links.self}}
                ))
        }
    }
}
