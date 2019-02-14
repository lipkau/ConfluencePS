#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Get-Space" -Tag Unit {

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
        $Uri -like "/rest/api/space*" -and
        $Method -eq "GET"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Get-ConfluenceSpace

        It "has a mandatory parameter 'Space'" {
            $command | Should -HaveParameter "Space"
        }

        It "has a parameter 'Space' of type [AtlassianPS.ConfluencePS.Space[]]" {
            $command | Should -HaveParameter "Space" -Type [AtlassianPS.ConfluencePS.Space[]]
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

        It "fetches all Spaces the user has permissions to see" {
            Get-ConfluenceSpace

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/space"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches the requested Spaces" {
            Get-ConfluenceSpace -Space "Foo"
            Get-ConfluenceSpace -Space "Bar", "Baz"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -match "\/rest\/api\/space\/[Foo|Bar|Baz]"
                }
                Exactly         = $true
                Times           = 3
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns [AtlassianPS.ConfluencePS.Space] objects" {
            Get-ConfluenceSpace
            Get-ConfluenceSpace -Space "Foo", "Bar"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -like "/rest/api/space*" -and
                    $OutputType -eq [AtlassianPS.ConfluencePS.Space]
                }
                Exactly         = $true
                Times           = 3
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns paginated results when fetching all spaces" {
            Get-ConfluenceSpace
            Get-ConfluenceSpace -Space "Foo", "Bar"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/space" -and
                    $Paging -eq $true
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat["ParameterFilter"] = {
                $Uri -like "/rest/api/space/*" -and
                $Paging -eq $true
            }
            $assertMockCalledSplat["Times"] = 0
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
        $space = [AtlassianPS.ConfluencePS.Space]@{Key = "Foo"}
        $invalidSpace = [AtlassianPS.ConfluencePS.Space]@{Id = 123}
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Get-ConfluenceSpace -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Get-ConfluenceSpace -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Get-ConfluenceSpace
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "uses the `$PageSize when fetching results" {
            Get-ConfluenceSpace
            Get-ConfluenceSpace -PageSize 5

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

        It "accepts a [String] as input for -Space" {
            Get-ConfluenceSpace -Space "Foo"
        }

        It "accepts a [String] as input for -Space over the pipeline" {
            "Foo" | Get-ConfluenceSpace
        }

        It "accepts a [AtlassianPS.ConfluencePS.Space] object as input for -Space" {
            Get-ConfluenceSpace -Space $space
        }

        It "accepts a [AtlassianPS.ConfluencePS.Space] object as input for -Space over the pipeline" {
            $space | Get-ConfluenceSpace
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Space] object is provided" {
            { Get-ConfluenceSpace -Space $invalidSpace -ErrorAction Stop } | Should -Throw "Space is missing the Key"
            { Get-ConfluenceSpace -Space $invalidSpace -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
