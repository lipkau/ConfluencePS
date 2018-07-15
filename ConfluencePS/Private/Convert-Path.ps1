function Convert-Path {
    <#
    .SYNOPSIS
        A Convert-Path that actually returns the correct _case_ for file system paths on Windows
    .EXAMPLE
        New-PSDrive PS FileSystem C:\WINDOWS\SYSTEM32\WINDOWSPOWERSHELL
        Set-Location PS:\
        Convert-Path .\v*\modules\activedirectory
        This is the classic test case. The built-in Convert-Path would return:
        "C:\WINDOWS\SYSTEM32\WINDOWSPOWERSHELL\v1.0\modules\ActiveDirectory"

        This implementation should return the case-sensitive correct path:
        "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\ActiveDirectory"
    #>
    [CmdletBinding()]
    [OutputType( [String] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("PSPath")]
        [String[]]
        $Path
    )

    process {
        # First, resolve any relative paths or wildcards in the argument
        # Use Get-Item -Force to make sure it doesn't miss "hidden" items
        $literalPath = @(Get-Item $Path -Force | Select-Object -Expand FullName)
        Write-Verbose "Resolved '$Path' to '$($literalPath -join ', ')'"

        # Then, wildcard in EACH path segment forces OS to look up the actual case of the path
        $wildcarded = $literalPath -replace '(?<!(?::|\\\\))(\\|/)', '*$1' -replace '$', '*'
        $caseCorrected = Get-Item $wildcarded -Force | Microsoft.PowerShell.Management\Convert-Path
        Write-Verbose "Case correct options: '$($caseCorrected -join ', ')'"

        # Finally, a case-insensitive compare returns only the original paths
        $caseCorrected | Where-Object { $literalPath -iContains "$_" }
    }
}
