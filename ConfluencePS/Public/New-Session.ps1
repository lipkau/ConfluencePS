function New-Session {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter( Mandatory )]
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
        $ServerName,

        [Parameter( Mandatory )]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Hashtable]
        $Headers = @{}
    )

    begin {
        Write-Verbose "Function started"

        $resourceURi = "/rest/api/space"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            URI          = $resourceURi
            ServerName   = $ServerName
            Method       = "GET"
            Headers      = $Headers
            StoreSession = $true
            Credential   = $Credential
        }
        Write-DebugMessage "Invoking Method with `$iwParameters" -BreakPoint
        Invoke-Method @iwParameters
    }

    end {
        Write-Verbose "Complete"
    }
}
