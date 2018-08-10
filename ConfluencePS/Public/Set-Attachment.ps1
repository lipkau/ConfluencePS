function Set-Attachment {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess )]
    [OutputType( [AtlassianPS.ConfluencePS.Attachment] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [AtlassianPS.ConfluencePS.Attachment]
        $Attachment,

        # Path of the file to upload and attach
        [Parameter( Mandatory )]
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
        [String]
        $FilePath,

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

        $resourceApi = "/rest/api/content/{0}/child/attachment/{1}/data"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $parameter = @{
            URI        = $resourceApi -f $Attachment.PageID, $Attachment.ID
            ServerName = $ServerName
            Method     = "POST"
            InFile     = $FilePath
            Credential = $Credential
            OutputType = [AtlassianPS.ConfluencePS.Attachment]
            Verbose    = $false
        }
        Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
        if ($PSCmdlet.ShouldProcess($Attachment.PageID, "Updating attachment '$($Attachment.Title)'.")) {
            Invoke-Method @parameter
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
