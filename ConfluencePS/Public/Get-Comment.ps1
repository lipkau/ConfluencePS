function Get-Comment {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType( [AtlassianPS.ConfluencePS.Comment] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateRange(1, [UInt32]::MaxValue)]
        [Alias('ID', 'PageID', 'AttachmentID', 'BlogID')]
        [UInt32[]]
        $ContentID,

        [UInt32]
        $ParentVersion,

        [AtlassianPS.ConfluencePS.CommentLocation[]]
        $Location = @("inline", "footer", "resolved"),

        [Switch]
        $All,

        [String]
        $Expand = "extensions.inlineProperties,extensions.resolution,body.storage,version,history",

        [ValidateRange(1, [int]::MaxValue)]
        [UInt32]$PageSize = (Get-AtlassianConfiguration -Name "ConfluencePS" -ValueOnly)["PageSize"],

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

        $resourceApi = "/rest/api/content/{0}/child/comment"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_contentID in $ContentID) {
            $iwParameters = @{
                Uri          = $resourceApi -f $_contentID
                ServerName   = $ServerName
                Method       = "Get"
                GetParameter = @{
                    expand = $Expand
                    limit  = $PageSize
                }
                Paging       = $true
                OutputType   = [AtlassianPS.ConfluencePS.Comment]
                Credential   = $Credential
                Verbose    = $false
            }
            if ($ParentVersion) { $iwParameters["GetParameter"]["parentVersion"] = $ParentVersion }
            if ($Location) { $iwParameters["GetParameter"]["location"] = $Location -join "&location=" }
            if ($All) { $iwParameters["GetParameter"]["depth"] = "all" }

            # Paging
            ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
            }

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            Invoke-Method @iwParameters
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
