function Invoke-Method {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType(
        [PSObject],
        [AtlassianPS.ConfluencePS.Page],
        [AtlassianPS.ConfluencePS.Space],
        [AtlassianPS.ConfluencePS.Label],
        [AtlassianPS.ConfluencePS.Icon],
        [AtlassianPS.ConfluencePS.Version],
        [AtlassianPS.ConfluencePS.User],
        [AtlassianPS.ConfluencePS.Attachment]
    )]
    param(
        [Parameter( Mandatory )]
        [String]
        $Uri,

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

        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = "GET",

        [String]
        $Body,

        [Switch]
        $RawBody,

        [Hashtable]
        $Headers = @{},

        [Hashtable]
        $GetParameter = @{},

        [Switch]
        $Paging,

        [String]
        $InFile,

        [String]
        $OutFile,

        [Switch]
        $StoreSession,

        [ValidateSet(
            [AtlassianPS.ConfluencePS.Attachment],
            [AtlassianPS.ConfluencePS.BlogPost],
            [AtlassianPS.ConfluencePS.Comment],
            [AtlassianPS.ConfluencePS.Icon],
            [AtlassianPS.ConfluencePS.Label],
            [AtlassianPS.ConfluencePS.Page],
            [AtlassianPS.ConfluencePS.Space],
            [AtlassianPS.ConfluencePS.User],
            [AtlassianPS.ConfluencePS.Version]
        )]
        [System.Type]
        $OutputType,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        # [Parameter( DontShow )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = $PSCmdlet
    )

    begin {
        Write-Verbose "Function started"

        function ConvertResults {
            param(
                [Parameter( ValueFromPipeline )]
                $InputObject,

                $OutputType
            )

            process {
                $InputObject | ForEach-Object {
                    $item = $_
                    if ($OutputType) {
                        $converter = "ConvertTo-$($OutputType.Name)"
                    }
                    elseif ($item.type) {
                        $converter = "ConvertTo-$($item.type)"
                    }

                    if ($converter -and (Test-Path function:\$converter)) {
                        $item | & $converter
                    }
                    else {
                        $item
                    }
                }
            }
        }

        function ExpandResults {
            param(
                [Parameter( Mandatory, ValueFromPipeline )]
                $InputObject
            )

            process {
                foreach ($container in $script:PagingContainers) {
                    if (($InputObject) -and ($InputObject | Get-Member -Name $container)) {
                        Write-DebugMessage "Extracting data from [$container] containter"
                        $InputObject.$container
                    }
                }
            }
        }

        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        Set-TlsLevel -Tls12

        $server = Get-AtlassianServerConfiguration -ErrorAction Stop 4>$null 5>$null |
            Where-Object Type -eq "CONFLUENCE" |
            Where-Object Name -eq $ServerName

        if (@($server).Count -ne 1) {
            $throwErrorSplat = @{
                ExceptionType = "System.ApplicationException"
                Message       = "Missing Server"
                ErrorId       = "AtlassianPS.ConfluencePS.MissingServer"
                Category      = "InvalidData"
                Cmdlet = $Cmdlet
            }
            ThrowError @throwErrorSplat
        }

        [Uri]$Uri = "{0}{1}" -f $server.Uri, $Uri

        # Sanitize double slash `//`
        # Happens when the BaseUri is the domain name
        # [Uri]"http://google.com" vs [Uri]"http://google.com/foo"
        $URi = $URi -replace '(?<!:)\/\/', '/'

        # load DefaultParameters for Invoke-WebRequest
        # as the global PSDefaultParameterValues is not used
        $PSDefaultParameterValues = Resolve-DefaultParameterValue -Reference $global:PSDefaultParameterValues -CommandName 'Invoke-WebRequest'

        #region Headers
        # Construct the Headers with the folling priority:
        # - Headers passes as parameters
        # - User's Headers in $PSDefaultParameterValues
        # - Module's default Headers
        $_headers = Join-Hashtable -Hashtable $script:DefaultHeaders, $PSDefaultParameterValues["Invoke-WebRequest:Headers"], $Headers
        #endregion Headers

        #region Manage URI
        # Amend query from URI with GetParameter
        $uriQuery = ConvertTo-ParameterHash -Uri $Uri
        $internalGetParameter = Join-Hashtable $uriQuery, $GetParameter
        Write-DebugMessage "Using `$internalGetParameter: $($internalGetParameter | Out-String)"

        # And remove it from URI
        [Uri]$Uri = $Uri.GetLeftPart("Path")
        $PaginatedUri = $Uri

        # Append GET parameters to URi
        $offset = 0
        if ($PSCmdlet.PagingParameters) {
            if ($PSCmdlet.PagingParameters.Skip) {
                $internalGetParameter["start"] = $PSCmdlet.PagingParameters.Skip
                $offset = $PSCmdlet.PagingParameters.Skip
            }
            if ($PSCmdlet.PagingParameters.First -lt $internalGetParameter["maxResults"]) {
                $internalGetParameter["maxResults"] = $PSCmdlet.PagingParameters.First
            }
        }

        [Uri]$PaginatedUri = "{0}{1}" -f $PaginatedUri, (ConvertTo-GetParameter $internalGetParameter)
        #endregion Manage URI

        #region Constructe IWR Parameter
        $splatParameters = @{
            Uri             = $PaginatedUri
            Method          = $Method
            Headers         = $_headers
            ContentType     = $script:DefaultContentType
            UseBasicParsing = $true
            Credential      = $Credential
            ErrorAction     = "Stop"
            Verbose         = $false
        }

        if ($_headers.ContainsKey("Content-Type")) {
            $splatParameters["ContentType"] = $_headers["Content-Type"]
            $splatParameters["Headers"].Remove("Content-Type")
            $_headers.Remove("Content-Type")
        }

        if ($Body) {
            if ($RawBody) {
                $splatParameters["Body"] = $Body
            }
            else {
                # Encode Body to preserve special chars
                # http://stackoverflow.com/questions/15290185/invoke-webrequest-issue-with-special-characters-in-json
                $splatParameters["Body"] = [System.Text.Encoding]::UTF8.GetBytes($Body)
            }
        }

        if ((-not $Credential) -or ($Credential -eq [System.Management.Automation.PSCredential]::Empty)) {
            $splatParameters.Remove("Credential")
            if ($server.Session) {
                Write-Verbose "Using stores session for authentication"
                $splatParameters["WebSession"] = $server.Session
            }
        }

        if ($StoreSession) {
            $splatParameters["SessionVariable"] = "newSessionVar"
            $splatParameters.Remove("WebSession")
        }

        if ($InFile) {
            $splatParameters["InFile"] = $InFile
        }
        if ($OutFile) {
            $splatParameters["OutFile"] = $OutFile
        }
        #endregion Constructe IWR Parameter

        #region Execute the actual query
        try {
            Write-Verbose "$($splatParameters.Method) $($splatParameters.Uri)"
            Write-DebugMessage "Invoke-WebRequest with `$splatParameters: $($splatParameters | Out-String)"
            # Invoke the API
            $webResponse = Invoke-WebRequest @splatParameters
        }
        catch {
            Write-Verbose "Failed to get an answer from the server"

            $exception = $_
            $webResponse = $exception.Exception.Response
        }

        Write-DebugMessage "Executed WebRequest. Access `$webResponse to see details" -BreakPoint
        Test-ServerResponse -InputObject $webResponse -Cmdlet $Cmdlet
        #endregion Execute the actual query
    }

    process {
        if ($webResponse) {
            # In PowerShellCore (v6+) the StatusCode of an exception is somewhere else
            if (-not ($statusCode = $webResponse.StatusCode)) {
                $statusCode = $webResponse.Exception.Response.StatusCode
            }
            Write-Verbose "Status code: $($statusCode)"

            #region Code 400+
            if ($statusCode.value__ -ge 400) {
                Resolve-ErrorWebResponse -Exception $exception -StatusCode $statusCode -Cmdlet $Cmdlet
            }
            #endregion Code 400+

            #region Code 399-
            else {
                if ($StoreSession) {
                    Write-Verbose "Storing Session"

                    # $null = $newSessionVar.Headers.Remove("Authorization")

                    Write-DebugMessage "Storing `$newSessionVar to `$server" -BreakPoint
                    $server | Set-AtlassianServerConfiguration -Session $newSessionVar
                    return
                }

                if ($webResponse.Content) {
                    $response = ConvertFrom-Json ([Text.Encoding]::UTF8.GetString($webResponse.RawContentStream.ToArray()))

                    if ($Paging) {
                        # Remove Parameters that don't need propagation
                        $script:PSDefaultParameterValues.Remove("$($MyInvocation.MyCommand.Name):IncludeTotalCount")
                        $null = $PSBoundParameters.Remove("Paging")
                        $null = $PSBoundParameters.Remove("Skip")
                        if (-not $PSBoundParameters["GetParameter"]) {
                            $PSBoundParameters["GetParameter"] = $internalGetParameter
                        }

                        $total = 0
                        do {
                            Write-Verbose "Invoking pagination [currentTotal: $total]"

                            $result = ExpandResults -InputObject $response

                            $total += @($result).Count
                            $pageSize = $response.maxResults

                            if ($total -gt $PSCmdlet.PagingParameters.First) {
                                Write-DebugMessage "Only output the first $($PSCmdlet.PagingParameters.First % $pageSize) of page"
                                $result = $result | Select-Object -First ($PSCmdlet.PagingParameters.First % $pageSize)
                            }

                            ConvertResults -InputObject $result -OutputType $OutputType

                            if (@($result).Count -lt $response.limit) {
                                Write-DebugMessage "Stopping paging, as page had less entries than $($response.limit)"
                                break
                            }

                            if ($total -ge $PSCmdlet.PagingParameters.First) {
                                Write-DebugMessage "Stopping paging, as $total reached $($PSCmdlet.PagingParameters.First)"
                                break
                            }

                            # calculate the size of the next page
                            $PSBoundParameters["GetParameter"]["start"] = $total + $offset
                            $expectedTotal = $PSBoundParameters["GetParameter"]["start"] + $pageSize
                            if ($expectedTotal -gt $PSCmdlet.PagingParameters.First) {
                                $reduceBy = $expectedTotal - $PSCmdlet.PagingParameters.First
                                $PSBoundParameters["GetParameter"]["maxResults"] = $pageSize - $reduceBy
                            }

                            # Inquire the next page
                            $response = Invoke-Method @PSBoundParameters

                            $result = ExpandResults -InputObject $response
                        } while (@($result).Count -gt 0)

                        if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
                            [double]$Accuracy = 1.0
                            $PSCmdlet.PagingParameters.NewTotalCount($total, $Accuracy)
                        }
                    }
                    else {
                        $caller = (Get-PSCallstack | Select-Object -First 2)[-1].Command
                        if ($PSCmdlet.MyInvocation.MyCommand.Name -eq $caller) {
                            $response
                        }
                        else {
                            ConvertResults -InputObject $response -OutputType $OutputType
                        }
                    }
                }
                else {
                    # No content, although statusCode < 400
                    # This could be wanted behavior of the API
                    Write-Verbose "No content was returned from."
                }
            }
            #endregion Code 399-
        }
        else {
            Write-Verbose "No Web result object was returned from. This is unusual!"
        }
    }

    end {
        Set-TlsLevel -Revert

        Write-Verbose "Function ended"
    }
}
