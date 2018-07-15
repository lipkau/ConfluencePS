function ConvertTo-GetParameter {
    <#
    .SYNOPSIS
        Generate the GET parameter string for an URL from a hashtable
    #>
    [CmdletBinding()]
    [OutputType( [String] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [Hashtable]
        $InputObject
    )

    begin {
        [String]$parameters = "?"
    }

    process {
        Write-Verbose "Making HTTP get parameter string out of a hashtable"

        foreach ($key in $InputObject.Keys) {
            $parameters += "$key=$($InputObject[$key])&"
        }
    }

    end {
        $parameters -replace ".$"
    }
}
