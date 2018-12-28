function Get-User {
    [CmdletBinding(
        SupportsPaging = $true,
        DefaultParameterSetName = 'Self'
    )]
    [OutputType([ConfluencePS.User])]
    param (
        [Parameter( Mandatory = $true )]
        [URi]$ApiURi,

        [Parameter( Mandatory = $true )]
        [PSCredential]$Credential,

        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline,
            ParameterSetName = 'byUsername'
        )]
        [Alias("Name")]
        [string]$Username,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'byAccount'
        )]
        [Alias('Id')]
        [string]$AccountId,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'byUserKey'
        )]
        [string]$UserKey
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceApi = "$apiURi/user{0}"
    }

    PROCESS {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri        = $resourceApi
            Method     = 'Get'
            GetParameters = @{
                expand = "details.personal,details.business"
                limit  = $PageSize
            }
            OutputType = [ConfluencePS.User]
            Credential = $Credential
        }

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
        }
        switch ($PsCmdlet.ParameterSetName) {
            "_self" {
                $iwParameters["Uri"] = "$resourceApi/current"
            }
            'byUsername' {
                $iwParameters["GetParameters"]["username"] = $UserName
                break
            }
            "byAccount" {
                $iwParameters["GetParameters"]["accountId"] = $AccountId
            }
            'byUserKey' {
                $iwParameters["GetParameters"]["key"] = $UserKey
                break
            }
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking API with `$iwParameters"
        Invoke-Method @iwParameters
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
