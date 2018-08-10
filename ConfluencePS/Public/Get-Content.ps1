function Get-Content {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging, DefaultParameterSetName = "allPages" )]
    [OutputType(
        [AtlassianPS.ConfluencePS.Attachment],
        [AtlassianPS.ConfluencePS.BlogPost],
        [AtlassianPS.ConfluencePS.Comment],
        [AtlassianPS.ConfluencePS.Page]
    )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "byId" )]
        [ValidateRange(1, [UInt32]::MaxValue)]
        [Alias('ID')]
        [UInt32[]]
        $ContentID,

        [Parameter( ParameterSetName = "byId" )]
        [UInt32]
        $Version,

        [Parameter( ParameterSetName = "allPages" )]
        [Parameter( ParameterSetName = "allPosts" )]
        [Alias("Key")]
        [String]
        $SpaceKey,

        [Parameter( ParameterSetName = "allPages" )]
        [String]
        $Title,

        [ValidateNotNullOrEmpty()]
        [AtlassianPS.ConfluencePS.ContentStatus]
        $Status = "current",

        [Parameter( ParameterSetName = "allPosts" )]
        [DateTime]
        $PostingDay,

        [String]
        $Expand = "history,space,version,body.storage,ancestors",

        [ValidateRange(1, [int]::MaxValue)]
        [UInt32]$PageSize = (Get-AtlassianConfiguration -Name "ConfluencePS" -ValueOnly)["PageSize"],

        [Parameter()]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $command = Get-Command "Get-*ServerConfiguration" -Module AtlassianPS.Configuration
                & $command.Name |
                    Where-Object { $_.Type -eq [AtlassianPS.ServerType]"Confluence" } |
                    Where-Object { $_.Name -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.Name, $_.Name, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.Name ) }
            }
        )]
        [String]
        $ServerName = (Get-DefaultServer),

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "Function started"

        $resourceApi = "/rest/api/content{0}"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri           = ""
            ServerName    = $ServerName
            Method        = "Get"
            GetParameter = @{
                expand = $Expand
                limit  = $PageSize
            }
            Credential    = $Credential
            Verbose    = $false
        }

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
        }

        switch ($PsCmdlet.ParameterSetName) {
            "byId" {
                foreach ($_contentID in $ContentID) {
                    $iwParameters["Uri"] = $resourceApi -f "/$_contentID"
                    $iwParameters["GetParameter"]["status"] = $Status

                    if ($Version) { $iwParameters["GetParameter"]["version"] = $Version }

                    Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                    Invoke-Method @iwParameters
                }
                break
            }
            "allPages" {
                $iwParameters["Uri"] = $resourceApi -f ""
                $iwParameters["Paging"] = $true
                $iwParameters["GetParameter"]["type"] = "page"
                $iwParameters["GetParameter"]["status"] = $Status

                if ($SpaceKey) { $iwParameters["GetParameter"]["spaceKey"] = $SpaceKey }
                if ($Title) { $iwParameters["GetParameter"]["title"] = $Title }

                Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                Invoke-Method @iwParameters
                break
            }
            "allPosts" {
                $iwParameters["Uri"] = $resourceApi -f ""
                $iwParameters["Paging"] = $true
                $iwParameters["GetParameter"]["type"] = "blogpost"
                $iwParameters["GetParameter"]["status"] = $Status

                if ($SpaceKey) { $iwParameters["GetParameter"]["spaceKey"] = $SpaceKey }
                if ($PostingDay) { $iwParameters["GetParameter"]["postingDay"] = $PostingDay.ToString("yyyy-MM-dd") }

                Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                Invoke-Method @iwParameters
                break
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
