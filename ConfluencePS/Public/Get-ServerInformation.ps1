function Get-ServerInformation {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding()]
    # [OutputType( [AtlassianPS.ConfluencePS.Space] )]
    param(
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

        $resourceURi = "/rest/applinks/1.0/manifest"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri        = $resourceURi
            ServerName = $ServerName
            Method     = 'Get'
            Headers    = @{
                "Content-Type" = "application/xml; charset=utf-8"
            }
            # OutputType   = [AtlassianPS.ConfluencePS.Space]
            Credential = $Credential
            Verbose    = $false
        }

        Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
        Invoke-Method @iwParameters
    }

    end {
        Write-Verbose "Function ended"
    }
}
