function Add-Attachment {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess )]
    [OutputType( [AtlassianPS.ConfluencePS.Attachment] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.Page]
        $Page,

        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateScript(
            {
                if (-not (Test-Path $_ -PathType Leaf)) {
                    $errorItem = [System.Management.Automation.ErrorRecord]::new(
                        ([System.ArgumentException]"File not found"),
                        'ParameterValue.FileNotFound',
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                        $_
                    )
                    $errorItem.ErrorDetails = "No file could be found with the provided path '$_'."
                    $PSCmdlet.ThrowTerminatingError($errorItem)
                }
                else {
                    return $true
                }
            }
        )]
        [Alias('InFile', 'PSPath')]
        [String[]]
        $Path,

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

        $resourceApi = "/rest/api/content/{0}/child/attachment"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ( -not (Get-Member -InputObject $Page -Name Id) -or -not ($Page.Id)) {
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

        foreach ($_path in $Path) {
            $iwParameters = @{
                URI        = $resourceApi -f $Page.Id
                ServerName = $ServerName
                Method     = 'Post'
                InFile     = $_path
                Credential = $Credential
                OutputType = [AtlassianPS.ConfluencePS.Attachment]
                Verbose    = $false
            }

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            if ($PSCmdlet.ShouldProcess("pageid=[$($Page.ID)]", "Adding Attachment(s)")) {
                Invoke-Method @iwParameters
            }
        }
    }

    end {
        Write-Verbose "Complete"
    }
}
