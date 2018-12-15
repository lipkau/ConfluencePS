function Write-DebugMessage {
    <#
    .SYNOPSIS
        Write a message to the debug stream without creating a breakpoint

    .DESCRIPTION
        Write a message to the debug stream without creating a breakpoint

        This function allows the user to decide how the Debug Message
        should be formatted. The configuration is inside `$scrpit:Configuration`
        and supports the following structure (json representation):

        {
            "message": {
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

    .EXAMPLE
        Write-DebugMessage "The value of `$var is: $var"
        ----------
        Description
        Shows the message if the user added `-Debug` to the command but does not create a breakpoint
    #>
    [CmdletBinding()]
    [OutputType( [void] )]
    param(
        # Message to write
        [Parameter( Mandatory, ValueFromPipeline )]
        [String]
        $Message,

        # Inquire to break on the message
        [Switch]
        $BreakPoint,

        # Context with which this function wass called
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = ((Get-Variable -Scope 1 PSCmdlet).Value)
    )

    begin {
        $oldDebugPreference = $DebugPreference

        $indent, $functionName, $timeStamp = ""

        Import-MqcnAlias -Alias "WriteDebug" -Command "Microsoft.PowerShell.Utility\Write-Debug"

        $messageSettings = Get-AtlassianConfiguration -Name Message -ValueOnly 4>$null 5>$null
    }

    process {

        if ((Get-PSCallstack | Select-Object -Last 1 -Skip 1).Arguments.Contains("Debug")) {
            $DebugPreference = 'Continue'
        }
        if ($BreakPoint) {
            if ($DebugPreference -eq "Continue") {
                $DebugPreference = "Inquire"
            }
        }

        if ($messageSettings.Breadcrumbs) {
            WriteDebug "[$(Get-BreadCrumb)]:"

            if ($messageSettings.Indent) {
                $indent = " " * $messageSettings.Indent
            }
            else {
                $indent = " " * 4
            }
        }
        else {
            if ($messageSettings.FunctionName) {
                $functionName = "[$($Cmdlet.MyInvocation.MyCommand.Name)] "
            }
        }

        if ($messageSettings.Timestamp) {
            $timeStamp = "[$(Get-Date -f "HH:mm:ss")] "
        }

        WriteDebug ("{0}{1}{2}{3}" -f $timeStamp, $functionName, $indent, $Message)
    }

    end {
        $DebugPreference = $oldDebugPreference
    }
}
