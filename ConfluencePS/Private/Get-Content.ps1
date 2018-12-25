function Get-Content {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging, DefaultParameterSetName = "byFilters" )]
    [OutputType(
        [AtlassianPS.ConfluencePS.BlogPost],
        [AtlassianPS.ConfluencePS.Page]
    )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = "byId" )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.Content[]]
        $Content,

        [Parameter( ParameterSetName = "byId" )]
        [ValidateRange(1, [int]::MaxValue)]
        [UInt32]
        $Version,

        [Parameter( ParameterSetName = "byFilters" )]
        [ValidateSet("page", "blogpost")]
        [String]
        $ContentType = "page",

        [Parameter( ParameterSetName = "byFilters" )]
        [Alias('Key')]
        [AtlassianPS.ConfluencePS.Space]
        $Space,

        [Parameter( ParameterSetName = "byFilters" )]
        [String]
        $Title,

        [ValidateNotNullOrEmpty()]
        [AtlassianPS.ConfluencePS.ContentStatus]
        $Status = "current",

        [Parameter( ParameterSetName = "byFilters" )]
        [DateTime]
        $PostingDay,

        [Parameter( Mandatory, ParameterSetName = "byQuery" )]
        [String]
        $Query,

        [String]
        $Expand = "history,space,version,body.storage,ancestors",

        [Parameter( ParameterSetName = "byFilters" )]
        [Parameter( ParameterSetName = "byQuery" )]
        [ValidateRange(1, [int]::MaxValue)]
        [UInt32]
        $PageSize = (Get-AtlassianConfiguration -Name "ConfluencePS" -ValueOnly)["PageSize"],

        [Parameter()]
        [ValidateNotNullOrEmpty()]
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

        if ($Space) {
            if ( -not (Get-Member -InputObject $Space -Name Key) -or -not ($Space.Key)) {
                $writeErrorSplat = @{
                    ExceptionType = "System.ApplicationException"
                    Message       = "Space is missing the Key"
                    ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                    Category      = "InvalidData"
                    Cmdlet        = $PSCmdlet
                }
                WriteError @writeErrorSplat
                continue
            }
        }
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri          = ""
            ServerName   = $ServerName
            Method       = "Get"
            GetParameter = @{
                expand = $Expand
                limit  = $PageSize
            }
            Credential   = $Credential
            Verbose      = $false
        }

        switch ($PsCmdlet.ParameterSetName) {
            "byId" {
                foreach ($_content in $Content) {
                    if ( -not (Get-Member -InputObject $_content -Name Id) -or -not ($_content.ID)) {
                        $writeErrorSplat = @{
                            ExceptionType = "System.ApplicationException"
                            Message       = "Content is missing the Id"
                            ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                            Category      = "InvalidData"
                            Cmdlet        = $PSCmdlet
                        }
                        WriteError @writeErrorSplat
                        continue
                    }

                    $iwParameters["Uri"] = $resourceApi -f "/$($_content.Id)"
                    if ($Status) { $iwParameters["GetParameter"]["status"] = $Status }
                    if ($Version) { $iwParameters["GetParameter"]["version"] = $Version }

                    Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                    Invoke-Method @iwParameters
                }
                break
            }
            "byFilters" {
                $iwParameters["Uri"] = $resourceApi -f ""
                $iwParameters["Paging"] = $true
                $iwParameters["GetParameter"]["type"] = $ContentType
                $iwParameters["GetParameter"]["status"] = $Status

                if ($Space) { $iwParameters["GetParameter"]["spaceKey"] = $Space.Key }

                if ($ContentType -eq "page") {
                    if ($Title) { $iwParameters["GetParameter"]["title"] = $Title }
                }
                elseif ($ContentType -eq "blogpost") {
                    if ($PostingDay) { $iwParameters["GetParameter"]["postingDay"] = $PostingDay.ToString("yyyy-MM-dd") }
                }

                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
                }

                Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                Invoke-Method @iwParameters
                break
            }
            "byQuery" {
                $iwParameters["Uri"] = $resourceApi -f "/search"
                $iwParameters["Paging"] = $true
                $iwParameters["GetParameter"]["cql"] = ConvertTo-URLEncoded "$Query"

                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
                }

                Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                Invoke-Method @iwParameters
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
