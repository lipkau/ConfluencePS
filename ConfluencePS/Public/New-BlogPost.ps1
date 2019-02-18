function New-BlogPost {
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess )]
    [OutputType( [AtlassianPS.ConfluencePS.BlogPost] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline)]
        [Alias('Name')]
        [String]$Title,

        [Parameter( Mandatory )]
        [AtlassianPS.ConfluencePS.Space]$Space,

        [String]$Body,

        [Switch]$ConvertBody,

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

        if ( -not (Get-Member -InputObject $Space -Name Key) -or -not ($Space.Key)) {
            $writeErrorSplat = @{
                ExceptionType = "System.ApplicationException"
                Message       = "Space is missing the Key"
                ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                Category      = "InvalidData"
                Cmdlet        = $PSCmdlet
            }
            WriteError @writeErrorSplat
            continue
        }

        if ($ConvertBody) {
            $Body = ConvertTo-StorageFormat -Content $Body -ServerName $ServerName -Credential $Credential -ErrorAction Stop
        }

        $payload = [PSObject]@{
            type      = "blogpost"
            space     = [PSObject]@{ key = $Space.Key}
            title     = $Title
            body      = [PSObject]@{
                storage = [PSObject]@{
                    value          = $Body
                    representation = 'storage'
                }
            }
        }

        $iwParameters = @{
            Uri        = $resourceApi
            ServerName = $ServerName
            Method     = 'Post'
            Body       = ConvertTo-Json $payload
            OutputType = [AtlassianPS.ConfluencePS.BlogPost]
            Credential = $Credential
        }

        Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
        if ($PSCmdlet.ShouldProcess("spaceKey=[$($payload.space.key)]", "Creating new BlogPost")) {
            Invoke-Method @iwParameters
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
