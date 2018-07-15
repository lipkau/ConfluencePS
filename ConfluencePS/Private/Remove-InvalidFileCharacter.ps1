function Remove-InvalidFileCharacter {
    <#
    .SYNOPSIS
        Replace any invalid filename characters from a string with underscores
    #>
    [CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $false )]
    [OutputType( [String] )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        # string to process
        [Parameter( ValueFromPipeline )]
        [String]
        $InputString
    )

    begin {
        $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
        $regExInvalid = "[{0}]" -f [RegEx]::Escape($invalidChars)
    }

    process {
        foreach ($_string in $InputString) {
            Write-Verbose "Removing invalid characters"

            $_string -replace $regExInvalid, '_'
        }
    }
}
