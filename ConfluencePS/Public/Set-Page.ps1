function Set-Page {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( ConfirmImpact = 'Medium', SupportsShouldProcess )]
    [OutputType( [AtlassianPS.ConfluencePS.Page] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [AtlassianPS.ConfluencePS.Page]
        $Page,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Title,

        [Parameter()]
        [String]
        $Body,

        [Parameter()]
        [Switch]
        $ConvertBody,

        [Parameter()]
        [AtlassianPS.ConfluencePS.Page]
        $Parent,

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

        $resourceApi = "/rest/api/content/{0}"

        if ($Parent) {
            if ( -not (Get-Member -InputObject $Parent -Name Id) -or -not ($Parent.ID)) {
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
        }
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        # Check if $Page has all properties we need
        if (-not ($Page.Version.Number -and $Page.Title)) {
            Write-Verbose "Incomplete Page. Fetching a new copy."
            $Page = Get-Content -Content $Page -ServerName $ServerName -Credential $Credential
        }

        if ($Title) { $Page.Title = $Title }
        # $Body might be empty
        if ($PSBoundParameters.Keys -contains "Body") {
            if ($ConvertBody) {
                $Body = ConvertTo-StorageFormat -Content $Body -ServerName $ServerName -Credential $Credential -ErrorAction Stop
            }
            $Page.Body = $Body
        }
        # Ancestors is undocumented! May break in the future
        # http://stackoverflow.com/questions/23523705/how-to-create-new-page-in-confluence-using-their-rest-api
        if ($Parent) {
            $Page.Ancestors = @( @{ id = $Parent.ID } )
        }

        $Content = [PSCustomObject]@{
            type      = "page"
            title     = $Page.Title
            body      = [PSCustomObject]@{
                storage = [PSCustomObject]@{
                    value          = $Page.Body
                    representation = 'storage'
                }
            }
            version   = [PSCustomObject]@{
                number = ++$Page.Version.Number
            }
            ancestors = $Page.Ancestors
        }

        Write-Verbose "body: $Content"

        $iwParameters = @{
            Uri        = $resourceApi -f $Page.ID
            ServerName = $ServerName
            Method     = 'Put'
            Body       = ConvertTo-Json $Content
            OutputType = [AtlassianPS.ConfluencePS.Page]
            Credential = $Credential
            Verbose    = $false
        }

        Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
        If ($PSCmdlet.ShouldProcess("title=[$($Page.Title)]", "Updating Page")) {
            Invoke-Method @iwParameters
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
