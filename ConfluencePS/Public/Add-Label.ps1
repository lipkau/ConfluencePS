function Add-Label {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess )]
    [OutputType(
        [AtlassianPS.ConfluencePS.BlogPost],
        [AtlassianPS.ConfluencePS.Content],
        [AtlassianPS.ConfluencePS.Page]
    )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.Content[]]
        $Content,

        [Parameter( Mandatory )]
        [AtlassianPS.ConfluencePS.Label[]]
        $Label,

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

        $resourceApi = "/rest/api/content/{0}/label"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_content in $Content) {
            if ( -not (Get-Member -InputObject $_content -Name Id) -or -not ($_content.Id)) {
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

            $iwParameters = @{
                Uri        = $resourceApi -f $_content.Id
                ServerName = $ServerName
                Method     = 'Post'
                # need to create a new hashtable to have the correct case of the keys in the body
                Body       = ConvertTo-Json ($Label | ForEach-Object {@{prefix = $_.Prefix; name = $_.Name}})
                OutputType = [AtlassianPS.ConfluencePS.Label]
                Credential = $Credential
            }

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            if ($PSCmdlet.ShouldProcess("contentId=[$($_content.Id)]", "Adding Label")) {
                $_content.Labels = Invoke-Method @iwParameters

                $_content
            }
        }
    }

    END {
        Write-Verbose "Function ended"
    }
}
