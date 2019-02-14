@{
    RootModule           = 'ConfluencePS.psm1'
    ModuleVersion        = '2.4'
    GUID                 = '20d32089-48ef-464d-ba73-6ada240e26b3'
    Author               = 'AtlassianPS'
    CompanyName          = 'AtlassianPS'
    Copyright            = 'MIT License'
    Description          = 'PowerShell module to interact with the Atlassian Confluence REST API'
    PowerShellVersion    = '3.0'
    RequiredModules      = @("AtlassianPS.Configuration")
    FormatsToProcess     = @("ConfluencePS.format.ps1xml")
    # NestedModules        = @()
    FunctionsToExport    = '*'
    # CmdletsToExport      = '*'
    # VariablesToExport    = '*'
    AliasesToExport      = '*'
    # FileList             = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('confluence', 'wiki', 'atlassian')
            LicenseUri   = 'https://github.com/AtlassianPS/ConfluencePS/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/AtlassianPS/ConfluencePS'
            IconUri      = 'https://atlassianps.org/assets/img/ConfluencePS.png'
            ReleaseNotes = 'https://github.com/AtlassianPS/ConfluencePS/blob/master/CHANGELOG.md'
        }
    }
    DefaultCommandPrefix = 'Confluence'
}

