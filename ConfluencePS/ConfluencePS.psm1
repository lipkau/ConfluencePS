#region Dependencies
# Load the ConfluencePS namespace from C#
if (!("AtlassianPS.ConfluencePS.Space" -as [Type])) {
    Add-Type -Path (Join-Path $PSScriptRoot ConfluencePS.Types.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation, System.Runtime.Extensions
}
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Add-Type -Path (Join-Path $PSScriptRoot AtlassianPS.Configuration.Attributes.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation, System.Runtime.Extensions
}

# Load Web assembly when needed
# PowerShell Core has the assembly preloaded
if (!("System.Web.HttpUtility" -as [Type])) {
    Add-Type -Assembly System.Web
}
#endregion Dependencies

#region LoadFunctions
$publicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$privateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the functions
foreach ($file in @($PublicFunctions + $PrivateFunctions)) {
    try {
        . $file.FullName
    }
    catch {
        $errorItem = [System.Management.Automation.ErrorRecord]::new(
            ([System.ArgumentException]"Function not found"),
            'Load.Function',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $File
        )
        $errorItem.ErrorDetails = "Failed to import function $($file.BaseName)"
        # $PSCmdlet.ThrowTerminatingError($errorItem)
        throw $_
    }
}
Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *
#endregion LoadFunctions

#region Configuration
$script:moduleSettings = Join-Hashtable -Hashtable @{
    PageSize = 25
    Headers  = @{
        "Content-Type" = "application/json; charset=utf-8"
    }
    PagingContainers = @("results")
}, (Get-AtlassianConfiguration -Name ConfluencePS -ValueOnly)

Set-AtlassianConfiguration -Name ConfluencePS -Value $script:moduleSettings
#endregion Configuration
