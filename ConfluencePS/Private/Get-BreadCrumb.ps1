function Get-BreadCrumb {
    <#
    .SYNOPSIS
        Create a breadcrumb of the functions wgich called this
    #>
    [CmdletBinding()]
    [OutputType( [String] )]
    param(
        # String with which to separete the entries
        [String]
        $Delimiter = " > "
    )

    begin {
        $depth = 1
        $path = New-Object -TypeName System.Collections.ArrayList

        while ($depth) {
            try {
                $null = $path.Add((Get-Variable MyInvocation -Scope $depth -ValueOnly).MyCommand.Name)
                $depth++
            }
            catch {
                $depth = 0
            }
        }

        $path.Remove("")
        $path -join $Delimiter
    }
}
