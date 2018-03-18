function Get-User {
    [CmdletBinding(
        DefaultParameterSetName = '_self'
    )]
    [OutputType([ConfluencePS.User])]
    param (
        [Parameter( Mandatory = $true )]
        [URi]$apiURi,

        [Parameter( Mandatory = $true )]
        [PSCredential]$Credential,

        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = 'byName'
        )]
        [Alias('Name')]
        [string]$UserName,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'byAccount'
        )]
        [Alias('Id')]
        [string]$AccountId,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'byKey'
        )]
        [Alias('Key')]
        [string]$UserKey
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceApi = "$apiURi/user"
    }

    PROCESS {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri           = $resourceApi
            Method        = 'Get'
            GetParameters = @{
                expand = "details.personal,details.business"
                limit  = $PageSize
            }
            OutputType    = [ConfluencePS.User]
            Credential    = $Credential
        }

        switch ($PsCmdlet.ParameterSetName) {
            "_self" {
                $iwParameters["Uri"] = "$resourceApi/current"
            }
            "byName" {
                $iwParameters["GetParameters"]["username"] = $UserName
            }
            "byAccount" {
                $iwParameters["GetParameters"]["accountId"] = $AccountId
            }
            "byKey" {
                $iwParameters["GetParameters"]["key"] = $Key
            }
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking API with `$iwParameters"
        Invoke-Method @iwParameters
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
