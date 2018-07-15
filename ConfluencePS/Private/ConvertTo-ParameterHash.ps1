function ConvertTo-ParameterHash {
    [CmdletBinding( DefaultParameterSetName = 'ByString' )]
    [OutputType( [Hashtable] )]
    param(
        # URI from which to use the query
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByUri' )]
        [Uri]
        $Uri,

        # Query string
        [Parameter( Position = 0, Mandatory, ParameterSetName = 'ByString' )]
        [String]
        $Query
    )

    process {
        $getParameter = @{}

        if ($Uri) {
            $Query = $Uri.Query
        }

        if ($Query -match "^\?.+") {
            $Query.TrimStart("?").Split("&") | ForEach-Object {
                $key, $value = $_.Split("=")
                $getParameter.Add($key, $value)
            }
        }

        $getParameter
    }
}
