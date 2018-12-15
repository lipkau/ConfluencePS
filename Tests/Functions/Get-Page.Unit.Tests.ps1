#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "Get-Page" -Tag Unit {

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
        $Uri -like "/rest/api/content*" -and
        $Method -eq "GET"
    } {
        [AtlassianPS.ConfluencePS.Page]@{
            Title = "Foo"
        }
        [AtlassianPS.ConfluencePS.Page]@{
            Title = "Bar"
        }
        [AtlassianPS.ConfluencePS.Page]@{
            Title = "Baz"
        }
    }
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Get-ConfluencePage

        It "has a [AtlassianPS.ConfluencePS.Page[]] -Page parameter" {
            $command.Parameters.ContainsKey("Page")
            $command.Parameters["Page"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Page[]"
        }

        It "has a [String] -Title parameter" {
            $command.Parameters.ContainsKey("Title")
            $command.Parameters["Title"].ParameterType | Should -Be "String"
        }

        It "has a [AtlassianPS.ConfluencePS.Space] -Space parameter" {
            $command.Parameters.ContainsKey("Space")
            $command.Parameters["Space"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Space"
        }

        It "has a [String[]] -Label parameter" {
            $command.Parameters.ContainsKey("Label")
            $command.Parameters["Label"].ParameterType | Should -Be "String[]"
        }

        It "has a [String] -Query parameter" {
            $command.Parameters.ContainsKey("Query")
            $command.Parameters["Query"].ParameterType | Should -Be "String"
        }

        It "has a [UInt32] -PageSize parameter" {
            $command.Parameters.ContainsKey("PageSize")
            $command.Parameters["PageSize"].ParameterType | Should -Be "UInt32"
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

        It "fetches a specific page" {
            Get-ConfluencePage -Page 123

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches all pages from a Space" {
            Get-ConfluencePage -Space "Foo"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -like "/rest/api/content" -and
                    $GetParameter["spaceKey"] -eq "Foo"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by Title" {
            (Get-ConfluencePage -Space "Foo" -Title "Bar").Count | Should -Be 1

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -like "/rest/api/content" -and
                    $GetParameter["spaceKey"] -eq "Foo"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by Title supporting wildcards" {
            (Get-ConfluencePage -Space "Foo" -Title "Ba*").Count | Should -Be 2

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -like "/rest/api/content" -and
                    $GetParameter["spaceKey"] -eq "Foo"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by Label" {
            Get-ConfluencePage -Label "Bar"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/search" -and
                    $GetParameter["cql"] -eq "type%3dpage+AND+label%3dBar"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by Label in a specific Space" {
            Get-ConfluencePage -Space "Foo" -Label "Bar"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/search" -and
                    $GetParameter["cql"] -eq "type%3dpage+AND+label%3dBar+AND+space%3dFoo"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by cql query" {
            Get-ConfluencePage -Query "mention = jsmith and creator != jsmith"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/search" -and
                    $GetParameter["cql"] -eq "type%3dpage+AND+(mention+%3d+jsmith+and+creator+!%3d+jsmith)"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns [AtlassianPS.ConfluencePS.Page] objects" {
            Get-ConfluencePage 123
            Get-ConfluencePage -Space "Foo"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -like "/rest/api/content*" -and
                    $OutputType -eq [AtlassianPS.ConfluencePS.Page]
                }
                Exactly         = $true
                Times           = 2
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns paginated results" {
            Get-ConfluencePage -Page 123
            Get-ConfluencePage -Space "Foo"
            Get-ConfluencePage -Label "Foo"
            Get-ConfluencePage -Query "mention = jsmith"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123" -and
                    $Paging -eq $true
                }
                Exactly         = $true
                Times           = 0
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat["ParameterFilter"] = {
                $Uri -like "/rest/api/content" -and
                $GetParameter["spaceKey"] -eq "Foo" -and
                $Paging -eq $true
            }
            $assertMockCalledSplat["Times"] = 1
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat["ParameterFilter"] = {
                $Uri -like "/rest/api/content/search" -and
                $GetParameter["cql"] -like "type%3dpage+AND+label*" -and
                $Paging -eq $true
            }
            $assertMockCalledSplat["Times"] = 1
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat["ParameterFilter"] = {
                $Uri -like "/rest/api/content/search" -and
                $GetParameter["cql"] -like "type%3dpage+AND+(mention*" -and
                $Paging -eq $true
            }
            $assertMockCalledSplat["Times"] = 1
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
        $page = [AtlassianPS.ConfluencePS.Page]@{Id = 123}
        $space = [AtlassianPS.ConfluencePS.Space]@{Key = "Foo"}
        $invalidPage = [AtlassianPS.ConfluencePS.Page]@{Title = "Foo"}
        $invalidSpace = [AtlassianPS.ConfluencePS.Space]@{Id = 123}
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Get-ConfluencePage -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Get-ConfluencePage -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Get-ConfluencePage
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "uses the `$PageSize when fetching results" {
            Get-ConfluencePage -Page 123
            Get-ConfluencePage -Page 123 -PageSize 5

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = { $GetParameter["limit"] -eq 25 }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat["ParameterFilter"] = { $GetParameter["limit"] -eq 5 }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "accepts a [String] as input for -Page" {
            { Get-ConfluencePage -Page "123" } | Should -Not -Throw
        }

        It "accepts a [String] as input for -Page over the pipeline" {
            { "123" | Get-ConfluencePage } | Should -Not -Throw
        }

        It "accepts a [Int] as input for -Page" {
            { Get-ConfluencePage -Page 123 } | Should -Not -Throw
        }

        It "accepts a [Int] as input for -Page over the pipeline" {
            { 123 | Get-ConfluencePage } | Should -Not -Throw
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page" {
            { Get-ConfluencePage -Page $page } | Should -Not -Throw
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page over the pipeline" {
            { $page | Get-ConfluencePage } | Should -Not -Throw
        }

        It "accepts a [String] as input for -Space" {
            { Get-ConfluencePage -Space "Foo" } | Should -Not -Throw
        }

        It "accepts a [AtlassianPS.ConfluencePS.Space] object as input for -Space" {
            { Get-ConfluencePage -Space $space } | Should -Not -Throw
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Page] object is provided" {
            { Get-ConfluencePage -Page $invalidPage -ErrorAction Stop } | Should -Throw "Page is missing the Id"
            { Get-ConfluencePage -Page $invalidPage -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Space] object is provided" {
            { Get-ConfluencePage -Space $invalidSpace -ErrorAction Stop } | Should -Throw "Space is missing the Key"
            { Get-ConfluencePage -Space $invalidSpace -Label Foo -ErrorAction Stop } | Should -Throw "Space is missing the Key"
            { Get-ConfluencePage -Space $invalidSpace -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Get-ConfluencePage -Space $invalidSpace -Label Foo -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "URL encodes the -Query input" {
            Get-ConfluencePage -Query ' %$§"!+#-`´*;'

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = { $GetParameter["cql"] -like "*+%25%24%c3%82%c2%a7%22!%2b%23-%60%c3%82%c2%b4*%3b*" }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }
}
