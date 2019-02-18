#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Get-BlogPost" -Tag Unit {

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

        $command = Get-Command -Name Get-ConfluenceBlogPost

        It "has a mandatory parameter 'Page'" {
            $command | Should -HaveParameter "Page" -Mandatory
        }

        It "has a parameter 'Page' of type [AtlassianPS.ConfluencePS.Page[]]" {
            $command | Should -HaveParameter "Page" -Type [AtlassianPS.ConfluencePS.Page[]]
        }

        It "has a parameter 'Title' of type [String]" {
            $command | Should -HaveParameter "Title" -Type [String]
        }

        It "has a parameter 'Space' of type [AtlassianPS.ConfluencePS.Space]" {
            $command | Should -HaveParameter "Space" -Type [AtlassianPS.ConfluencePS.Space]
        }

        It "has a mandatory parameter 'Label'" {
            $command | Should -HaveParameter "Label" -Mandatory
        }

        It "has a parameter 'Label' of type [String[]]" {
            $command | Should -HaveParameter "Label" -Type [String[]]
        }

        It "has a mandatory parameter 'Query'" {
            $command | Should -HaveParameter "Query" -IsMandatory
        }

        It "has a parameter 'Query' of type [String]" {
            $command | Should -HaveParameter "Query" -Type [String]
        }

        It "has a parameter 'PageSize' of type [UInt32]" {
            $command | Should -HaveParameter "PageSize" -Type [UInt32]
        }

        It "has a parameter 'PageSize' with a default value" {
            $command | Should -HaveParameter "PageSize" -DefaultValue '(Get-AtlassianConfiguration -Name "ConfluencePS" -ValueOnly)["PageSize"]'
        }

        It "has a parameter 'ServerName' of type [String]" {
            $command | Should -HaveParameter "ServerName" -Type [String]
        }

        It "has a parameter 'ServerName' with ArgumentCompleter" {
            $command | Should -HaveParameter "ServerName" -HasArgumentCompleter
        }

        It "has a parameter 'ServerName' with a default value" {
            $command | Should -HaveParameter "ServerName" -DefaultValue "(Get-DefaultServer)"
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }

        It "has a parameter 'Credential' with a default value" {
            $command | Should -HaveParameter "Credential" -DefaultValue "[System.Management.Automation.PSCredential]::Empty"
        }
    }

    Context "Behavior checking" {

        It "fetches a specific page" {
            Get-ConfluenceBlogPost -Page 123 -ServerName "foo"

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
            Get-ConfluenceBlogPost -Space "Foo" -ServerName "foo"

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
            Get-ConfluenceBlogPost -Space "Foo" -Title "Bar" -ServerName "foo" | Should -HaveCount 1

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
            Get-ConfluenceBlogPost -Space "Foo" -Title "Ba*" -ServerName "foo" | Should -HaveCount 2

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
            Get-ConfluenceBlogPost -Label "Bar" -ServerName "foo"

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
            Get-ConfluenceBlogPost -Label "Bar", "Baz" -ServerName "foo"

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
            Get-ConfluenceBlogPost -Space "Foo" -Label "Bar" -ServerName "foo"

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
            Get-ConfluenceBlogPost -Query "mention = jsmith and creator != jsmith" -ServerName "foo"

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
            { Get-ConfluenceBlogPost -ServerName "" -ServerName "foo" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Get-ConfluenceBlogPost -ServerName $null -ServerName "foo" } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Get-ConfluenceBlogPost
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "uses the `$PageSize when fetching results" {
            Get-ConfluenceBlogPost -Space "Foo" -ServerName "foo"
            Get-ConfluenceBlogPost -Space "Foo" -PageSize 5 -ServerName "foo"

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
            Get-ConfluenceBlogPost -Page "123" -ServerName "foo"
        }

        It "accepts a [String] as input for -Page over the pipeline" {
            "123" | Get-ConfluenceBlogPost -ServerName "foo"
        }

        It "accepts a [Int] as input for -Page" {
            Get-ConfluenceBlogPost -Page 123 -ServerName "foo"
        }

        It "accepts a [Int] as input for -Page over the pipeline" {
            123 | Get-ConfluenceBlogPost -ServerName "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page" {
            Get-ConfluenceBlogPost -Page $page -ServerName "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page over the pipeline" {
            $page | Get-ConfluenceBlogPost -ServerName "foo"
        }

        It "accepts a [String] as input for -Space" {
            Get-ConfluenceBlogPost -Space "Foo" -ServerName "foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Space] object as input for -Space" {
            Get-ConfluenceBlogPost -Space $space -ServerName "foo"
        }
    }
}
