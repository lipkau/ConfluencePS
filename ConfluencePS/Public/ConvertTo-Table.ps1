function ConvertTo-Table {
    # .ExternalHelp ..\ConfluencePS-help.xml
    [CmdletBinding()]
    [OutputType( [String] )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    param (
        [Parameter( Mandatory, ValueFromPipeline )]
        $Content,

        [Switch]
        $Vertical,

        [Switch]
        $NoHeader
    )

    begin {
        Write-Verbose "Function started"

        $sb = [System.Text.StringBuilder]::new()

        $script:HeaderGenerated = $NoHeader
    }

    process {
        Write-DebugMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "PSBoundParameters: $($PSBoundParameters | Out-String)"

        # This ForEach needed if the content wasn't piped in
        $Content | ForEach-Object {
            if ($Vertical) {
                if ($script:HeaderGenerated) {$pipe = '|'}
                else {$pipe = '||'}

                # Put an empty row between multiple tables (objects)
                if ($Spacer) {
                    $null = $sb.AppendLine('')
                }

                $_.PSObject.Properties | ForEach-Object {
                    $row = ("$pipe {0} $pipe {1} |" -f $_.Name, $_.Value) -replace "\|\s\s", "| "
                    $null = $sb.AppendLine($row)
                }

                $Spacer = $true
            } else {
                # Header row enclosed by ||
                if (-not $script:HeaderGenerated) {
                    $null = $sb.AppendLine("|| {0} ||" -f ($_.PSObject.Properties.Name -join " || "))
                    $script:HeaderGenerated = $true
                }

                # All other rows enclosed by |
                $row = ("| " + ($_.PSObject.Properties.Value -join " | ") + " |") -replace "\|\s\s", "| "
                $null = $sb.AppendLine($row)
            }
        }
    }

    end {
        $script:HeaderGenerated = $null

        # Return the array as one large, multi-line string
        $sb.ToString()

        Write-Verbose "Function ended"
    }
}
