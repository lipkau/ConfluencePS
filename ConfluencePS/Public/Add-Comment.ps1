function Add-Comment {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess )]
    [OutputType( [AtlassianPS.ConfluencePS.Comment] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.Content[]]
        $Content,

        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Comment,

        [Switch]
        $ConvertBody,

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

        $resourceApi = "/rest/api/content"
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_content in $Content) {
            if ( -not $_content.Id ) {
                $writeErrorSplat = @{
                    ExceptionType = "System.ApplicationException"
                    Message       = "Content is missing the ID"
                    ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                    Category      = "InvalidData"
                    Cmdlet        = $PSCmdlet
                }
                WriteError @writeErrorSplat
                continue
            }

            $_content = Resolve-ContentType -InputObject $_content -ServerName $ServerName -Credential $Credential

            if ($ConvertBody) {
                $Comment = ConvertTo-StorageFormat -Content $Comment -ServerName $ServerName -Credential $Credential -ErrorAction Stop
            }

            $payload = [PSObject]@{
                type      = "comment"
                body      = [PSObject]@{
                    storage = [PSObject]@{
                        value          = $Comment
                        representation = 'storage'
                    }
                }
                container = [PSObject]@{
                    type = $_content.GetType().Name.ToLower()
                    id   = $_content.Id
                }
            }

            $iwParameters = @{
                Uri        = $resourceApi
                ServerName = $ServerName
                Method     = 'Post'
                Body       = ConvertTo-Json $payload
                OutputType = [AtlassianPS.ConfluencePS.Comment]
                Credential = $Credential
            }

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            if ($PSCmdlet.ShouldProcess("contentId=[$($_content.Id)]", "Creating new Comment")) {
                Invoke-Method @iwParameters
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
