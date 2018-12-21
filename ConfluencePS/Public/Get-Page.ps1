function Get-Page {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging, DefaultParameterSetName = "byId" )]
    [OutputType( [AtlassianPS.ConfluencePS.Page] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = "byId" )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.Page[]]
        $Page,

        [Parameter( ParameterSetName = "bySpace" )]
        [Alias('Name')]
        [String]
        $Title,

        [Parameter( Mandatory, ParameterSetName = "bySpace" )]
        [Parameter( ParameterSetName = "byLabel" )]
        [Alias('Key')]
        [AtlassianPS.ConfluencePS.Space]
        $Space,

        [Parameter( Mandatory, ParameterSetName = "byLabel" )]
        [String[]]
        $Label,

        [Parameter( Mandatory, ParameterSetName = "byQuery" )]
        [String]$Query,

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
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri           = ""
            ServerName    = $ServerName
            Method        = 'Get'
            GetParameter = @{
                expand = "space,version,body.storage,ancestors"
                limit  = $PageSize
            }
            OutputType    = [AtlassianPS.ConfluencePS.Page]
            Credential    = $Credential
            Verbose       = $false
        }

        switch ($PsCmdlet.ParameterSetName) {
            "byId" {
                foreach ($_page in $Page) {
                    if ( -not (Get-Member -InputObject $_page -Name Id) -or -not ($_page.ID)) {
                        $writeErrorSplat = @{
                            ExceptionType = "System.ApplicationException"
                            Message       = "Page is missing the Id"
                            ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                            Category      = "InvalidData"
                            Cmdlet        = $PSCmdlet
                        }
                        WriteError @writeErrorSplat
                        continue
                    }

                    $iwParameters["Uri"] = $resourceApi -f "/$($_page.ID)"

                    Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                    Invoke-Method @iwParameters
                }
                break
            }
            "bySpace" {
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

                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
                }
                $iwParameters["Paging"] = $true

                $iwParameters["Uri"] = $resourceApi -f ''
                $iwParameters["GetParameter"] = @{
                    type = "page"
                    spaceKey = $Space.Key
                }

                Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                if ($Title) {
                    Invoke-Method @iwParameters | Where-Object { $_.Title -like $Title }
                }
                else {
                    Invoke-Method @iwParameters
                }
                break
            }
            "byLabel" {
                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
                }
                $iwParameters["Paging"] = $true

                $iwParameters["Uri"] = $resourceApi -f "/search"

                $CQLparameters = @("type=page", "label=$Label")
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

                    $CQLparameters += "space=$($Space.Key)"
                }
                $cqlQuery = ConvertTo-URLEncoded ($CQLparameters -join (" AND "))

                $iwParameters["GetParameter"]["cql"] = $cqlQuery

                Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                Invoke-Method @iwParameters
                break
            }
            "byQuery" {
                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
                }
                $iwParameters["Paging"] = $true

                $iwParameters["Uri"] = $resourceApi -f "/search"

                $iwParameters["GetParameter"]["cql"] = ConvertTo-URLEncoded "type=page AND ($Query)"

                Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                Invoke-Method @iwParameters
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
