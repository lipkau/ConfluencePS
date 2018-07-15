function Write-Verbose {
    <#
    .SYNOPSIS
        Write a verbose message

    .DESCRIPTION
        Write a verbose message

        This function allows the user to decide how the Verbose Message
        should be formatted. The configuration is inside `$scrpit:Configuration`
        and supports the following structure (json representation):

        {
            "message": {
                "style": {
                    // show a line with the Bread Crumbs of the caller stack
                    "breadcrumbs": true,

                    // how many whitespaces should be used for indenting the
                    // message
                    "indent": true,

                    // show the name of the calling function - this is ignored
                    // if breadcrumbs is active
                    "functionname": true,

                    // show the timestamp (HH:mm:ss format) of the message
                    "timestamp": true
                }
            }
        }

    .EXAMPLE
        Write-Verbose "The value of `$var is: $var"
        ----------
        Description
        Shows the message if the user added `-Debug` to the command but does not create a breakpoint
    #>
    [CmdletBinding()]
    param(
        # Message to write
        [Parameter( Mandatory, ValueFromPipeline )]
        [String]
        $Message,

        # Context with which this function wass called
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = ((Get-Variable -Scope 1 PSCmdlet).Value)
    )

    begin {
        $indent, $functionName, $timeStamp = ""

        Import-MqcnAlias -Alias "WriteVerbose" -Command "Microsoft.PowerShell.Utility\Write-Verbose"

        $messageSettings = Get-AtlassianConfiguration -Name Message -ValueOnly 4>$null 5>$null
    }

    process {

        if ((Get-PSCallstack | Select-Object -Last 1 -Skip 1).Arguments.Contains("Verbose")) {
            $VerbosePreference = 'Continue'
        }

        if ($messageSettings["style"]["breadcrumbs"]) {
            WriteVerbose "[$(Get-BreadCrumb)]:"

            if ($messageSettings["style"]["indent"]) {
                $indent = " " * $messageSettings["style"]["indent"]
            }
            else {
                $indent = " " * 4
            }
        }
        else {
            if ($messageSettings["style"]["functionname"]) {
                $functionName = "[$($Cmdlet.MyInvocation.MyCommand.Name)] "
            }
        }

        if ($messageSettings["style"]["timestamp"]) {
            $timeStamp = "[$(Get-Date -f "HH:mm:ss")] "
        }

        WriteVerbose ("{0}{1}{2}{3}" -f $timeStamp, $functionName, $indent, $Message)
    }
}
