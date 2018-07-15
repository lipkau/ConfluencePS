function Set-TlsLevel {
    <#
    .SYNOPSIS
        Enable TLS1.2 support and store the previous value so we can revert the change
    #>
    [CmdletBinding( SupportsShouldProcess )]
    [OutputType( [void] )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        # Enable TLS1.2 support
        [Parameter( Mandatory, ParameterSetName = 'Set' )]
        [Switch]
        $Tls12,

        # Revert to previous setting
        [Parameter( Mandatory, ParameterSetName = 'Revert' )]
        [Switch]
        $Revert
    )

    begin {
        switch ($PSCmdlet.ParameterSetName) {
            "Set" {
                $Script:originalTlsSettings = [Net.ServicePointManager]::SecurityProtocol

                [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            }
            "Revert" {
                if ($Script:originalTlsSettings) {
                    [Net.ServicePointManager]::SecurityProtocol = $Script:originalTlsSettings
                }
            }
        }
    }
}
