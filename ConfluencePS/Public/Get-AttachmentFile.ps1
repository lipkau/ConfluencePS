function Get-AttachmentFile {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding()]
    [OutputType( [Bool] )]
    param (
        [Parameter( Mandatory, ValueFromPipeline )]
        [AtlassianPS.ConfluencePS.Attachment[]]$Attachment,

        [ValidateScript(
            {
                if (-not (Test-Path $_)) {
                    $errorItem = [System.Management.Automation.ErrorRecord]::new(
                        ([System.ArgumentException]"Path not found"),
                        'ParameterValue.FileNotFound',
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                        $_
                    )
                    $errorItem.ErrorDetails = "Invalid path '$_'."
                    $PSCmdlet.ThrowTerminatingError($errorItem)
                }
                else {
                    return $true
                }
            }
        )]
        [String]$Path,

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
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_attachment in $Attachment) {
            if ( -not (Get-Member -InputObject $_attachment -Name Filename) -or -not ($_attachment.Filename)) {
                $writeErrorSplat = @{
                    ExceptionType = "System.ApplicationException"
                    Message       = "Attachment is missing the Filename"
                    ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                    Category      = "InvalidData"
                    Cmdlet        = $PSCmdlet
                }
                WriteError @writeErrorSplat
                continue
            }
            if ( -not (Get-Member -InputObject $_attachment -Name URL) -or -not ($_attachment.URL)) {
                $writeErrorSplat = @{
                    ExceptionType = "System.ApplicationException"
                    Message       = "Attachment is missing the URL"
                    ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                    Category      = "InvalidData"
                    Cmdlet        = $PSCmdlet
                }
                WriteError @writeErrorSplat
                continue
            }
            if ( -not (Get-Member -InputObject $_attachment -Name MediaType) -or -not ($_attachment.MediaType)) {
                $writeErrorSplat = @{
                    ExceptionType = "System.ApplicationException"
                    Message       = "Attachment is missing the MediaType"
                    ErrorId       = "AtlassianPS.ConfluencePS.MissingProperty"
                    Category      = "InvalidData"
                    Cmdlet        = $PSCmdlet
                }
                WriteError @writeErrorSplat
                continue
            }

            if ($Path) {
                $filename = Join-Path $Path $_attachment.Filename
            }
            else {
                $filename = $_attachment.Filename
            }

            $iwParameters = @{
                Uri        = $_attachment.URL
                ServerName = $ServerName
                Method     = 'Get'
                Headers    = @{"Accept" = $_attachment.MediaType}
                OutFile    = $filename
                Credential = $Credential
            }

            Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
            $result = Invoke-Method @iwParameters
            (-not $result)
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
