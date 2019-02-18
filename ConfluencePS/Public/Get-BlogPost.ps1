function Get-BlogPage {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding( SupportsPaging, DefaultParameterSetName = "byId" )]
    [OutputType( [AtlassianPS.ConfluencePS.Page] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = "byId" )]
        [Alias('ID')]
        [AtlassianPS.ConfluencePS.BlogPost[]]
        $BlogPost,

        [Parameter( ParameterSetName = "byParameters" )]
        [Alias('Name')]
        [String]
        $Title,

        [Parameter( ParameterSetName = "byParameters" )]
        [Parameter( ParameterSetName = "byLabel" )]
        [Alias('Key')]
        [AtlassianPS.ConfluencePS.Space]
        $Space,

        [Parameter( ParameterSetName = "byParameters")]
        [DateTime]
        $PostingDay,

        [Parameter( Mandatory, ParameterSetName = "byLabel" )]
        [String[]]
        $Label,

        [Parameter( Mandatory, ParameterSetName = "byQuery" )]
        [String]
        $Query,

        [Parameter( ParameterSetName = "byParameters" )]
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
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PsCmdlet.ParameterSetName) {
            "byId" {
                $getContentSplat = @{
                    Content    = $BlogPost
                    ServerName = $ServerName
                    Credential = $Credential
                }
                Get-Content @getContentSplat
                break
            }
            "byParameters" {
                $getContentSplat = @{
                    PageSize   = $PageSize
                    ServerName = $ServerName
                    Credential = $Credential
                }
                if ($Title) { $getContentSplat["Title"] = $Title }
                if ($Space) { $getContentSplat["Space"] = $Space }
                if ($PostingDay) { $getContentSplat["PostingDay"] = $PostingDay.ToString("yyyy-MM-dd") }

                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $getContentSplat[$_] = $PSCmdlet.PagingParameters.$_
                }
                Get-Content @getContentSplat
                break
            }
            "byLabel" {
                $cqlLabel = @()
                foreach ($_label in $Label) {
                    $cqlLabel += "label=`"$_label`""
                }
                $CQLparameters = @("type=blogpost", "($($cqlLabel -join " OR "))")
                if ($Space) {
                    $CQLparameters += "space=`"$($Space.Key)`""
                }
                $getContentSplat = @{
                    Query      = $CQLparameters -join (" AND ")
                    PageSize   = $PageSize
                    ServerName = $ServerName
                    Credential = $Credential
                }

                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $getContentSplat[$_] = $PSCmdlet.PagingParameters.$_
                }
                Get-Content @getContentSplat
                break
            }
            "byQuery" {
                $getContentSplat = @{
                    Query      = "type=blogpost AND ($Query)"
                    PageSize   = $PageSize
                    ServerName = $ServerName
                    Credential = $Credential
                }

                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $getContentSplat[$_] = $PSCmdlet.PagingParameters.$_
                }
                Get-Content @getContentSplat
                break
            }
        }
    }

    end {
        Write-Verbose "Function ended"
    }
}
