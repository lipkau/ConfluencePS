function Get-Space {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType([AtlassianPS.ConfluencePS.Space])]
    param(
        [Parameter( ValueFromPipeline )]
        [Alias('Key')]
        [AtlassianPS.ConfluencePS.Space[]]
        $Space,

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

        $resourceURi = "/rest/api/space{0}"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri          = ""
            ServerName   = $ServerName
            Method       = 'Get'
            GetParameter = @{
                expand = "description.plain,icon,homepage,metadata.labels"
                limit  = $PageSize
            }
            OutputType   = [AtlassianPS.ConfluencePS.Space]
            Credential   = $Credential
            Verbose      = $false
        }

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
        }

        if ($Space) {
            foreach ($_space in $Space) {
                if ( -not (Get-Member -InputObject $_space -Name Key) -or -not ($_space.Key)) {
                    $writeErrorSplat = @{
                        ExceptionType = "System.ApplicationException"
                        Message       = "Space is missing the Key"
                        ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                        Category      = "InvalidData"
                        Cmdlet        = $PSCmdlet
                    }
                    WriteError @writeErrorSplat
                }

                $iwParameters["Uri"] = $resourceURi -f "/$($_space.Key)"

                Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
                Invoke-Method @iwParameters
            }
        }
        else {
            $iwParameters["Uri"] = $resourceURi -f ""
            $iwParameters["Paging"] = $true

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            Invoke-Method @iwParameters
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
