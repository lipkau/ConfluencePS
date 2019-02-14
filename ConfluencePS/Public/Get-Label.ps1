function Get-Label {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType(
        [AtlassianPS.ConfluencePS.Attachment],
        [AtlassianPS.ConfluencePS.BlogPost],
        [AtlassianPS.ConfluencePS.Page]
    )]
    param (
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.Content[]]
        $Content,

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

        $resourceApi = "/rest/api/content/{0}/label"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_content in $Content) {
            if ( -not (Get-Member -InputObject $_content -Name Id) -or -not ($_content.ID)) {
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

            $_content = Resolve-ContentType -InputObject $_content -ServerName $ServerName -Credential $Credential

            $iwParameters = @{
                Uri          = $resourceApi -f $_content.ID
                ServerName   = $ServerName
                Method       = 'Get'
                GetParameter = @{
                    limit = $PageSize
                }
                Paging       = $true
                OutputType   = [AtlassianPS.ConfluencePS.Label]
                Credential   = $Credential
            }

            # Paging
            ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
            }

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            $_content.Labels = Invoke-Method @iwParameters

            $_content
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
