#region Dependencies
# Load the ConfluencePS namespace from C#
if (!("AtlassianPS.ConfluencePS.Space" -as [Type])) {
    Add-Type -Path (Join-Path $PSScriptRoot ConfluencePS.Types.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation
}
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Add-Type -Path (Join-Path $PSScriptRoot AtlassianPS.Configuration.Attributes.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation
}

# Load Web assembly when needed
# PowerShell Core has the assembly preloaded
if (!("System.Web.HttpUtility" -as [Type])) {
    Add-Type -Assembly System.Web
}
#endregion Dependencies

#region Configuration
$script:PagingContainers = @("results")
$moduleSettings = Get-AtlassianConfiguration -Name ConfluencePS -ValueOnly
if ($moduleSettings) {
    if (-not $moduleSettings["PageSize"]) { $moduleSettings["PageSize"] = 25 }
    if (-not $moduleSettings["ContentType"]) { $moduleSettings["ContentType"] = "application/json; charset=utf-8" }
}
else {
    $moduleSettings = @{
        PageSize    = 25
        ContentType = "application/json; charset=utf-8"
    }
}
Set-AtlassianConfiguration -Name ConfluencePS -Value $moduleSettings
#endregion Configuration

#region LoadFunctions
$PublicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the functions
ForEach ($file in @($PublicFunctions + $PrivateFunctions)) {
    Try {
        . $file.FullName
    }
    Catch {
        $errorItem = [System.Management.Automation.ErrorRecord]::new(
            ([System.ArgumentException]"Function not found"),
            'Load.Function',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $File
        )
        $errorItem.ErrorDetails = "Failed to import function $($file.BaseName)"
        $PSCmdlet.ThrowTerminatingError($errorItem)
    }
}
Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *
#endregion LoadFunctions
