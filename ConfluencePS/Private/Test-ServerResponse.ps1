function Test-ServerResponse {
    <#
    .SYNOPSIS
        Evauluate the response header of the API call (Atlassian specific)
    .LINK
        https://docs.atlassian.com/software/jira/docs/api/7.6.1/com/atlassian/jira/bc/security/login/LoginReason.html
    #>
    [CmdletBinding()]
    [OutputType()]
    param(
        # Response of Invoke-WebRequest
        [Parameter( ValueFromPipeline )]
        [PSObject]
        $InputObject,

        # Context which will be used for throwing errors.
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = $PSCmdlet
    )

    begin {
        $loginReasonKey = "X-Seraph-LoginReason"
    }

    process {
        Write-Verbose "Checking response headers for authentication errors"
        Write-DebugMessage "Investigating `$InputObject.Headers['$loginReasonKey']"

        if ($InputObject.Headers -and $InputObject.Headers[$loginReasonKey]) {
            $loginReason = $InputObject.Headers[$loginReasonKey] -split ","

            switch ($true) {
                {$loginReason -contains "AUTHENTICATED_FAILED"} {
                    $errorParameter = @{
                        ExceptionType = "System.Net.Http.HttpRequestException"
                        Message       = "The user could not be authenticated."
                        ErrorId       = "AuthenticationFailed"
                        Category      = "AuthenticationError"
                        Cmdlet        = $Cmdlet
                    }
                    ThrowError @errorParameter
                }
                {$loginReason -contains "AUTHENTICATION_DENIED"} {
                    $errorParameter = @{
                        ExceptionType = "System.Net.Http.HttpRequestException"
                        Message       = "For security reasons Jira requires you to log on to the website before continuing."
                        ErrorId       = "AuthenticaionDenied"
                        Category      = "AuthenticationError"
                        Cmdlet        = $Cmdlet
                    }
                    ThrowError @errorParameter
                }
                {$loginReason -contains "AUTHORISATION_FAILED"} {
                    $errorParameter = @{
                        ExceptionType = "System.Net.Http.HttpRequestException"
                        Message       = "The user could not be authorised."
                        ErrorId       = "AuthorisationFailed"
                        Category      = "AuthenticationError"
                        Cmdlet        = $Cmdlet
                    }
                    ThrowError @errorParameter
                }
                {$loginReason -contains "OK"} {} # The login was OK
                {$loginReason -contains "OUT"} {} # This indicates that person has in fact logged "out"
            }
        }
    }
}
