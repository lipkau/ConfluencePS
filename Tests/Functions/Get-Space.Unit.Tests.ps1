#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "Get-Space" -Tag Unit {

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
        $Uri -like "/rest/api/space*" -and
        $Method -eq "GET"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Get-ConfluenceSpace

        It "has a [AtlassianPS.ConfluencePS.Space[]] -Space parameter" {
            $command.Parameters.ContainsKey("Space")
            $command.Parameters["Space"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Space[]"
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
