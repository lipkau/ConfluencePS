#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "Get-Page" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1"
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #region Mocking
    Mock Write-DebugMessage -ModuleName $env:BHProjectName {}
    Mock Write-Verbose -ModuleName $env:BHProjectName {}

    Mock Get-Content -ModuleName $env:BHProjectName {
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
            Get-ConfluencePage -Page 123 -ServerName "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Content.Id -eq 123
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches all pages from a Space" {
            Get-ConfluencePage -Space "Foo" -ServerName "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Space.Key -eq "Foo"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by Title" {
            Get-ConfluencePage -Space "Foo" -Title "Bar" -ServerName "foo" | Should -HaveCount 1

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Space.Key -eq "Foo"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by Title supporting wildcards" {
            Get-ConfluencePage -Space "Foo" -Title "Ba*" -ServerName "foo" | Should -HaveCount 2

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Space.Key -eq "Foo"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by Label" {
            Get-ConfluencePage -Label "Bar" -ServerName "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Query -eq 'type=page AND (label="Bar")'
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by multiple Labels" {
            Get-ConfluencePage -Label "Bar", "Baz" -ServerName "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Query -eq 'type=page AND (label="Bar" OR label="Baz")'
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by Label in a specific Space" {
            Get-ConfluencePage -Space "Foo" -Label "Bar" -ServerName "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Query -eq 'type=page AND (label="Bar") AND space="Foo"'
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches pages by cql query" {
            Get-ConfluencePage -Query "mention = jsmith and creator != jsmith" -ServerName "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Query -eq "type=page AND (mention = jsmith and creator != jsmith)"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns [AtlassianPS.ConfluencePS.Page] objects" {}

        It "returns paginated results" {}
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
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Get-ConfluencePage -ServerName "" -ServerName "foo" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Get-ConfluencePage -ServerName $null -ServerName "foo" } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Get-ConfluencePage
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "uses the `$PageSize when fetching results" {
            Get-ConfluencePage -Space "Foo" -ServerName "foo"
            Get-ConfluencePage -Space "Foo" -PageSize 5 -ServerName "foo"

            $assertMockCalledSplat = @{
                CommandName     = "Get-Content"
                ModuleName      = $env:BHProjectName
                ParameterFilter = { $PageSize -eq 25 }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat["ParameterFilter"] = { $PageSize -eq 5 }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "accepts a [String] as input for -Page" {
            Get-ConfluencePage -Page "123" -ServerName "foo"
        }

        It "accepts a [String] as input for -Page over the pipeline" {
            "123" | Get-ConfluencePage -ServerName "foo"
        }

        It "accepts a [Int] as input for -Page" {
            Get-ConfluencePage -Page 123 -ServerName "foo"
        }

        It "accepts a [Int] as input for -Page over the pipeline" {
            123 | Get-ConfluencePage -ServerName "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page" {
            Get-ConfluencePage -Page $page -ServerName "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page over the pipeline" {
            $page | Get-ConfluencePage -ServerName "foo"
        }

        It "accepts a [String] as input for -Space" {
            Get-ConfluencePage -Space "Foo" -ServerName "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Space] object as input for -Space" {
            Get-ConfluencePage -Space $space -ServerName "foo"
        }
    }
}
