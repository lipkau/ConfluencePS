#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "ConvertTo-StorageFormat" -Tag Unit {

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
        $Uri -like "/rest/api/contentbody/convert/storage" -and
        $Method -eq "Post"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name ConvertTo-ConfluenceStorageFormat

        It "has a [String[]] -Content parameter" {
            $command.Parameters.ContainsKey("Content")
            $command.Parameters["Content"].ParameterType | Should -Be "String[]"
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

        It "converts string to storage format" {
            ConvertTo-ConfluenceStorageFormat -Content 'foo'

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/contentbody/convert/storage" -and
                    $Body -match '"representation"\s*:\s*"wiki"'
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
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { ConvertTo-ConfluenceStorageFormat -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { ConvertTo-ConfluenceStorageFormat -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name ConvertTo-ConfluenceStorageFormat
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "accepts a [String] as input for -Content" {
            { ConvertTo-ConfluenceStorageFormat -Content "foo" } | Should -Not -Throw
            { ConvertTo-ConfluenceStorageFormat -Content "foo", "bar" } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Body -match '"value"\s*:\s*"(foo|bar)"'
                }
                Exactly         = $true
                Times           = 3
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "accepts a [String] as input for -Content over the pipeline" {
            { "foo", "bar" | ConvertTo-ConfluenceStorageFormat } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Body -match '"value"\s*:\s*"(foo|bar)"'
                }
                Exactly         = $true
                Times           = 2
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }
}
