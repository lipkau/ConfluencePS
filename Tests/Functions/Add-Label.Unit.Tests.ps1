#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "Add-Label" -Tag Unit {

    BeforeAll {
        Remove-Item -Path Env:\BH*
        $projectRoot = (Resolve-Path "$PSScriptRoot/../..").Path
        if ($projectRoot -like "*Release") {
            $projectRoot = (Resolve-Path "$projectRoot/..").Path
        }

        Import-Module BuildHelpers
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path $projectRoot -ErrorAction SilentlyContinue

        $env:BHManifestToTest = $env:BHPSModuleManifest
        $script:isBuild = $PSScriptRoot -like "$env:BHBuildOutput*"
        if ($script:isBuild) {
            $Pattern = [regex]::Escape($env:BHProjectPath)

            $env:BHBuildModuleManifest = $env:BHPSModuleManifest -replace $Pattern, $env:BHBuildOutput
            $env:BHManifestToTest = $env:BHBuildModuleManifest
        }

        Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    #region Mocking
    Mock Write-DebugMessage -ModuleName $env:BHProjectName {}
    Mock Write-Verbose -ModuleName $env:BHProjectName {}

    Mock Invoke-Method -ModuleName $env:BHProjectName -ParameterFilter {
        $Uri -like "/rest/api/content/*/label"
        $Method -eq "POST"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Add-ConfluenceLabel

        It "has a [AtlassianPS.ConfluencePS.Content[]] -Content parameter" {
            $command.Parameters.ContainsKey("Content")
            $command.Parameters["Content"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Content[]"
        }

        It "has a [AtlassianPS.ConfluencePS.Label[]] -Label parameter" {
            $command.Parameters.ContainsKey("Label")
            $command.Parameters["Label"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Label[]"
        }

        It "has a [String] -ServerName parameter" {
            $command.Parameters.ContainsKey("ServerName")
            $command.Parameters["ServerName"].ParameterType | Should -Be "String"
        }

        It "has an ArgumentCompleter for -ServerName" {
            $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]} |
                Should -Not -BeNullOrEmpty
        }

        It "has a [PSCredential] -Credential parameter" {
            $command.Parameters.ContainsKey('Credential')
            $command.Parameters["Credential"].ParameterType | Should -Be "PSCredential"
        }
    }

    Context "Behavior checking" {

        It "adds a label to a Content" {
            Add-ConfluenceLabel -Content 123 -Label "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/label" -and
                    $Body -match "`"name`"\s*:\s*`"foo`""
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "adds multiple labels to a Content" {
            Add-ConfluenceLabel -Content 123 -Label "foo","bar"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/label" -and
                    $Body -match "`"name`"\s*:\s*`"foo`"" -and
                    $Body -match "`"name`"\s*:\s*`"bar`"" -and
                    $Body -match "[{.+},\s*{.+}]"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns [AtlassianPS.ConfluencePS.Label] objects from the API" {
            Add-ConfluenceLabel -Content 123 -Label "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/label" -and
                    $OutputType -eq [AtlassianPS.ConfluencePS.Label]
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Context "Parameter checking" {

        #region Arrange
        BeforeAll {
            # backup current configuration
            & (Get-Module AtlassianPS.Configuration) {
                $script:previousConfig = $script:Configuration
                $script:Configuration = @{}
                $script:Configuration.Add("ConfluencePS", @{PageSize = 25})
                $script:Configuration.Add("ServerList", [System.Collections.Generic.List[AtlassianPS.ServerData]]::new())
            }
            Add-AtlassianServerConfiguration -Name "lorem" -Uri "https://google.com" -Type CONFLUENCE -ErrorAction Stop
        }
        AfterAll {
            #restore previous configuration
            & (Get-Module AtlassianPS.Configuration) {
                $script:Configuration = $script:previousConfig
                Save-Configuration
            }
        }
        $blogpost = [AtlassianPS.ConfluencePS.BlogPost]@{Id = 123}
        $content = [AtlassianPS.ConfluencePS.Content]@{Id = 123}
        $page = [AtlassianPS.ConfluencePS.Page]@{Id = 123}
        $invalidPage = [AtlassianPS.ConfluencePS.Page]@{Title = "Foo"}
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Add-ConfluenceLabel -Content 123 -Label "foo" -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Add-ConfluenceLabel -Content 123 -Label "foo" -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Add-ConfluenceLabel
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "accepts a [String] as input for -Content" {
            Add-ConfluenceLabel -Content "123" -Label "foo"
        }

        It "accepts a [String] as input for -Content over the pipeline" {
            "123" | Add-ConfluenceLabel -Label "foo"
        }

        It "accepts a [Int] as input for -Content" {
            Add-ConfluenceLabel -Content 123 -Label "foo"
        }

        It "accepts a [Int] as input for -Content over the pipeline" {
            123 | Add-ConfluenceLabel -Label "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.BlogPost] as input for -Content" {
            Add-ConfluenceLabel -Content $blogpost -Label "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content" {
            Add-ConfluenceLabel -Content $content -Label "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Content" {
            Add-ConfluenceLabel -Content $page -Label "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.BlogPost] as input for -Content over the pipeline" {
            $blogpost | Add-ConfluenceLabel -Label "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content over the pipeline" {
            $content | Add-ConfluenceLabel -Label "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Content over the pipeline" {
            $page | Add-ConfluenceLabel -Label "foo"
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Page] object is provided" {
            { Add-ConfluenceLabel -Content $invalidPage -Label "foo" -ErrorAction Stop } | Should -Throw "Content is missing the Id"
            { Add-ConfluenceLabel -Content $invalidPage -Label "foo" -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
