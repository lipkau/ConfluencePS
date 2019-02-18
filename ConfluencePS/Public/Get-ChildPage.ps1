function Get-ChildPage {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType( [AtlassianPS.ConfluencePS.Page] )]
    param (
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.Page]
        $Page,

        [Switch]
        $Recurse,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
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

        $resourceApi = "/rest/api/content/{0}/{1}/page"

        $depthLevel = "child"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ( -not $Page.ID) {
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

        if ($Recurse) { $depthLevel = "descendant" } # depth = ALL

        $iwParameters = @{
            Uri           = $resourceApi -f $Page.ID, $depthLevel
            ServerName    = $ServerName
            Method        = 'Get'
            GetParameter = @{
                expand = "space,version,body.storage,ancestors"
                limit  = $PageSize
            }
            Paging        = $true
            OutputType    = [AtlassianPS.ConfluencePS.Page]
            Credential    = $Credential
        }

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
        }

        Invoke-Method @iwParameters
    }

    end {
        Write-Verbose "Function ended"
    }
}
