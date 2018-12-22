function Get-Attachment {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType( [AtlassianPS.ConfluencePS.Attachment] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.Page[]]
        $Page,

        [String]$FileNameFilter,

        [String]$MediaTypeFilter,

        [ValidateRange(1, [int]::MaxValue)]
        [UInt32]$PageSize = (Get-AtlassianConfiguration -Name "ConfluencePS" -ValueOnly)["PageSize"],

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

        foreach ($_page in $Page) {
            if ( -not (Get-Member -InputObject $_page -Name Id) -or -not ($_page.Id)) {
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

            $iwParameters = @{
                Uri          = $resourceApi -f $_page.Id
                ServerName   = $ServerName
                Method       = 'Get'
                GetParameter = @{
                    expand = "version"
                    limit  = $PageSize
                }
                Paging       = $true
                OutputType   = [AtlassianPS.ConfluencePS.Attachment]
                Credential   = $Credential
            }

            if ($FileNameFilter) {
                $iwParameters["GetParameter"]["filename"] = $FileNameFilter
            }

            if ($MediaTypeFilter) {
                $iwParameters["GetParameter"]["mediaType"] = $MediaTypeFilter
            }

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
