function Set-Label {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess )]
    [OutputType(
        [AtlassianPS.ConfluencePS.Attachment],
        [AtlassianPS.ConfluencePS.BlogPost],
        [AtlassianPS.ConfluencePS.Comment],
        [AtlassianPS.ConfluencePS.Page]
    )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateRange(1, [UInt32]::MaxValue)]
        [Alias('ID', 'PageID', 'CommentID', 'BlogPostID', 'AttachmentID')]
        [UInt32[]]
        $ContentID,

        [Parameter( Mandatory )]

        [AtlassianPS.ConfluencePS.Label[]]
        $Label,

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

        $resourceApi = "/rest/api/content/{0}/label"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri        = ""
            ServerName = $ServerName
            Method     = "Post"
            Body       = ""
            Credential = $Credential
            Verbose    = $false
        }

        foreach ($_contentID in $ContentID) {
            Write-Verbose "Removing all previous labels"
            $null = Remove-Label -ContentID $_contentID -ServerName $ServerName -Credential $Credential

            $iwParameters["Uri"] = $resourceApi -f $_contentID
            $iwParameters["Body"] = $Label | Foreach-Object {@{prefix = 'global'; name = $_}} | ConvertTo-Json

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            If ($PSCmdlet.ShouldProcess("Label $Label, PageID $_contentID")) {
                $output = [ConfluencePS.ContentLabelSet]@{ Page = $InputObject }
                $output.Labels += (Invoke-Method @iwParameters)
                $output
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
