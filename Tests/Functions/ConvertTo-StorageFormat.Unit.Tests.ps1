#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "ConvertTo-StorageFormat" -Tag Unit {

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
        $Uri -like "/rest/api/contentbody/convert/storage" -and
        $Method -eq "Post"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name ConvertTo-ConfluenceStorageFormat

        It "has a mandatory parameter 'Content'" {
            $command | Should -HaveParameter "Content" -Mandatory
        }

        It "has a parameter 'Content' of type [String[]]" {
            $command | Should -HaveParameter "Content" -Type [String[]]
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
            ConvertTo-ConfluenceStorageFormat -Content "foo"
            ConvertTo-ConfluenceStorageFormat -Content "foo", "bar"

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
            "foo", "bar" | ConvertTo-ConfluenceStorageFormat

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
