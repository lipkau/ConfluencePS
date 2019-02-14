function Resolve-ContentType {
    <#
    .SYNOPSIS
        Fetches a generic content object from the server

    .DESCRIPTION
        Fetches a generic content object from the server.
        By doing this, the response will be of the specific content type (Page, BlogPost, Attachment).

    .EXAMPLE
        [AtlassianPS.ConfluencePS.Content]$Content = ...
        $Content = Resolve-ContentType -InputObject $Content -ServerName $ServerName -Credential $Credential
    #>
    param(
        # Object to be resolved
        [Parameter( Mandatory, ValueFromPipeline )]
        [AtlassianPS.ConfluencePS.Content[]]
        $InputObject,

        # Server to use
        [Parameter( Mandatory )]
        [String]
        $ServerName,

        # Credentials to use
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = $((Get-Variable -Scope 1 PSCmdlet).Value)
    )

    process {
        foreach ($item in $InputObject) {
            if ($item.GetType().FullName -like "AtlassianPS.ConfluencePS.Content*") {
                $getContentSplat = @{
                    Content     = $item
                    ServerName  = $ServerName
                    Credential  = $Credential
                    ErrorAction = 'SilentlyContinue'
                }
                if ($output = Get-Content @getContentSplat) {
                    $output
                }
                else {
                    $writeErrorSplat = @{
                        ExceptionType = "System.ApplicationException"
                        Message       = "Content could not be resolved."
                        ErrorId       = "AtlassianPS.ConfluencePS.UnknownType"
                        Category      = "InvalidData"
                        Cmdlet        = $Cmdlet
                    }
                    WriteError @writeErrorSplat
                    continue
                }
            }
            else {
                $item
            }
        }
    }
}
