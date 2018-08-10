function ConvertTo-Attachment {
    <#
    .SYNOPSIS
        Extracted the conversion to private function in order to have a single place to
        select the properties to use when casting to custom object type
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPS.ConfluencePS.Attachment] )]
    param(
        # object to convert
        [Parameter( ValueFromPipeline )]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Verbose "Converting Object to Attachment"

            if($_.container.id) {
                $pageId = $_.container.id
            }
            else {
                $pageID = $_._expandable.container -replace '^.*\/content\/', ''
                $pageID = [Convert]::ToInt32($pageID, 10)
            }

            [AtlassianPS.ConfluencePS.Attachment](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                    @{Name = "id"; Expression = {
                            $ID = $_.id -replace 'att', ''
                            [Convert]::ToInt32($ID, 10)
                        }
                    },
                    status,
                    title,
                    @{Name = "filename";  Expression = {
                            '{0}_{1}' -f $pageID,  $_.title | Remove-InvalidFileCharacter
                        }
                    },
                    @{Name = "mediatype";  Expression = {
                            $_.extensions.mediaType
                        }
                    },
                    @{Name = "filesize";  Expression = {
                            [convert]::ToInt32($_.extensions.fileSize, 10)
                        }
                    },
                    @{Name = "comment";  Expression = {
                            $_.extensions.comment
                        }
                    },
                    @{Name = "spacekey"; Expression = {
                            $_._expandable.space -replace '^.*\/space\/', ''
                        }
                    },
                    @{Name = "pageid"; Expression = {
                            $pageID
                        }
                    },
                    @{Name = "version"; Expression = {
                            if ($_.version) {
                                ConvertTo-Version $_.version
                            }
                            else {$null}
                        }
                    },
                    @{Name = "URL"; Expression = {
                            $base = $_._links.base
                            if (!($base)) { $base = $_._links.self -replace '\/rest.*', '' }
                            if ($_._links.download) {
                                "{0}{1}" -f $base, $_._links.download
                            }
                            else {$null}
                        }
                    },
                    @{Name = "Self"; Expression = {$_._links.self}}
                ))
        }
    }
}
