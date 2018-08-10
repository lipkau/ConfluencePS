function Set-Page {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( ConfirmImpact = 'Medium', SupportsShouldProcess, DefaultParameterSetName = 'byParameters' )]
    [OutputType( [AtlassianPS.ConfluencePS.Page] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ParameterSetName = 'byObject' )]
        [AtlassianPS.ConfluencePS.Page]
        $InputObject,

        [Parameter( Mandatory, ValueFromPipeline, ParameterSetName = 'byParameters' )]
        [ValidateRange(1, [UInt32]::MaxValue)]
        [Alias('ID')]
        [UInt32]
        $PageID,

        [Parameter(ParameterSetName = 'byParameters')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Title,

        [Parameter(ParameterSetName = 'byParameters')]
        [String]
        $Body,

        [Parameter(ParameterSetName = 'byParameters')]
        [Switch]
        $Convert,

        [Parameter(ParameterSetName = 'byParameters')]
        [ValidateRange(1, [Uint32]::MaxValue)]
        [UInt32]
        $ParentID,

        [Parameter(ParameterSetName = 'byParameters')]
        [AtlassianPS.ConfluencePS.Page]
        $Parent,

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

        $resourceApi = "/rest/api/content/{0}"

        # If -Convert is flagged, call ConvertTo-ConfluenceStorageFormat against the -Body
        If ($Convert) {
            Write-Verbose '-Convert flag active; converting content to Confluence storage format'
            $Body = ConvertTo-StorageFormat -Content $Body -ServerName $ServerName -Credential $Credential
        }
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri        = ""
            ServerName = $ServerName
            Method     = 'Put'
            Body       = ""
            OutputType = [AtlassianPS.ConfluencePS.Page]
            Credential = $Credential
            Verbose    = $false
        }

        $Content = [PSCustomObject]@{
            type      = "page"
            title     = ""
            body      = [PSCustomObject]@{
                storage = [PSCustomObject]@{
                    value          = ""
                    representation = 'storage'
                }
            }
            version   = [PSCustomObject]@{
                number = 0
            }
            ancestors = @()
        }

        switch ($PsCmdlet.ParameterSetName) {
            "byObject" {
                $iwParameters["Uri"] = $resourceApi -f $InputObject.ID
                $Content.version.number = ++$InputObject.Version.Number
                $Content.title = $InputObject.Title
                $Content.body.storage.value = $InputObject.Body
                # if ($InputObject.Ancestors) {
                # $Content["ancestors"] += @( $InputObject.Ancestors | Foreach-Object { @{ id = $_.ID } } )
                # }
            }
            "byParameters" {
                $iwParameters["Uri"] = $resourceApi -f $PageID
                $originalPage = Get-Page -PageID $PageID -ApiURi $apiURi -Credential $Credential

                if (($Parent -is [ConfluencePS.Page]) -and ($Parent.ID)) {
                    $ParentID = $Parent.ID
                }

                $Content.version.number = ++$originalPage.Version.Number
                if ($Title) { $Content.title = $Title }
                else { $Content.title = $originalPage.Title }
                # $Body might be empty
                if ($PSBoundParameters.Keys -contains "Body") {
                    $Content.body.storage.value = $Body
                }
                else {
                    $Content.body.storage.value = $originalPage.Body
                }
                # Ancestors is undocumented! May break in the future
                # http://stackoverflow.com/questions/23523705/how-to-create-new-page-in-confluence-using-their-rest-api
                if ($ParentID) {
                    $Content.ancestors = @( @{ id = $ParentID } )
                }
            }
        }

        $iwParameters["Body"] = $Content | ConvertTo-Json

        Write-DebugMessage "Invoking API Method with `$iwParameters" -BreakPoint
        If ($PSCmdlet.ShouldProcess("Page $($Content.title)")) {
            Invoke-Method @iwParameters
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
