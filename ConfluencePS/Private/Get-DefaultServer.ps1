function Get-DefaultServer {
    [CmdletBinding()]
    [OutputType( [String] )]
    param()

    $script:DefaultServer
}
