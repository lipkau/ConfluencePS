function ConvertTo-StorageFormat {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding()]
    [OutputType( [String] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [String[]]
        $Content,

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

        $resourceApi = "/rest/api/contentbody/convert/storage"
    }

    process {
        Write-Debug "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Debug "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_content in $Content) {
            $iwParameters = @{
                Uri        = $resourceApi
                ServerName = $ServerName
                Method     = 'Post'
                Body       = ConvertTo-Json @{
                    value          = "$_content"
                    representation = 'wiki'
                }
                Credential = $Credential
            }

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            (Invoke-Method @iwParameters).value
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
