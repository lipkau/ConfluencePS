#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Get-ChildPage" -Tag Unit {

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

    Mock Invoke-Method -ModuleName $env:BHProjectName -ParameterFilter {
        $Uri -like "/rest/api/content/*/*/page" -and
        $Method -eq "GET"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Get-ConfluenceChildPage

        It "has a mandatory parameter 'Page'" {
            $command | Should -HaveParameter "Page" -Mandatory
        }

        It "has a parameter 'Page' of type [AtlassianPS.ConfluencePS.Page]" {
            $command | Should -HaveParameter "Page" -Type [AtlassianPS.ConfluencePS.Page]
        }

        It "has a parameter 'Recurse' of type [Switch]" {
            $command | Should -HaveParameter "Recurse" -Type [Switch]
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

        It "fetches direct children of a page" {
            Get-ConfluenceChildPage -Page 123

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/child/page"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches children of a page recurively" {
            Get-ConfluenceChildPage -Page 123 -Recurse

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/descendant/page"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns [AtlassianPS.ConfluencePS.Page] objects" {
            Get-ConfluenceChildPage -Page 123 -Recurse

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/descendant/page" -and
                    $OutputType -eq [AtlassianPS.ConfluencePS.Page]
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns paginated results" {
            Get-ConfluenceChildPage -Page 123

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Paging -eq $true
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
        $page = [AtlassianPS.ConfluencePS.Page]@{Id = 123}
        $space = [AtlassianPS.ConfluencePS.Space]@{Key = "Foo"}
        $invalidPage = [AtlassianPS.ConfluencePS.Page]@{Title = "Foo"}
        $invalidSpace = [AtlassianPS.ConfluencePS.Space]@{Name = "Foo"}
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Get-ConfluenceChildPage -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Get-ConfluenceChildPage -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Get-ConfluenceChildPage
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "uses the `$PageSize when fetching results" {
            Get-ConfluenceChildPage -Page 123
            Get-ConfluenceChildPage -Page 123 -PageSize 5

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $GetParameter["limit"] -eq 25
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat["ParameterFilter"] = { $GetParameter["limit"] -eq 5 }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "accepts a [String] as input for -Page" {
            Get-ConfluenceChildPage -Page "123"
        }

        It "accepts a [String] as input for -Page over the pipeline" {
            "123" | Get-ConfluenceChildPage
        }

        It "accepts a [Int] as input for -Page" {
            Get-ConfluenceChildPage -Page 123
        }

        It "accepts a [Int] as input for -Page over the pipeline" {
            123 | Get-ConfluenceChildPage
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page" {
            Get-ConfluenceChildPage -Page $page
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page over the pipeline" {
            $page | Get-ConfluenceChildPage
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Page] object is provided" {
            { Get-ConfluenceChildPage -Page $invalidPage -ErrorAction Stop } | Should -Throw "Page is missing the Id"
            { Get-ConfluenceChildPage -Page $invalidPage -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

    }
}
