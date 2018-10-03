#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    "PSAvoidUsingConvertToSecureStringWithPlainText",
    "",
    Justification = "Converting received plaintext token to SecureString"
)]
param()

Describe "New-Session" -Tag Unit {

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

    InModuleScope $env:BHProjectName {

        #region Mocking
        Mock Write-DebugMessage -ModuleName $env:BHProjectName {}
        Mock Write-Verbose -ModuleName $env:BHProjectName {}

        Mock Invoke-Method -ModuleName $env:BHProjectName {}
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name New-Session

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

            It "has a [Hashtable] -Headers parameter" {
                $command.Parameters.ContainsKey('Headers')
                $command.Parameters["Headers"].ParameterType | Should -Be "Hashtable"
            }
        }

        Context "Behavior checking" {

            #region Arrange
            $Pass = ConvertTo-SecureString -AsPlainText -Force -String "lorem ipsum"
            $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("user", $Pass)
            #endregion Arrange

            It "calls Invoke-Method with StoreSession" {
                New-Session -ServerName "TestServer" -Credential $Cred

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $ServerName -eq "TestServer" -and
                        $StoreSession -eq $true -and
                        $Credential -eq $Cred
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
            BeforeEach {
                $script:DefaultServer = "wrongValue"
            }
            $Pass = ConvertTo-SecureString -AsPlainText -Force -String "lorem ipsum"
            $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("user", $Pass)
            #endregion Arrange

            It "does not allow an empty ServerName" {
                { New-Session -ServerName "" -Credential $Cred } | Should -Throw
            }

            It "does not allow a null ServerName" {
                { New-Session -ServerName $null -Credential $Cred } | Should -Throw
            }

            It "completes ServerName arguments" {
                Get-Command -Name New-Session
                $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                    Where-Object {$_ -is [ArgumentCompleter]}
                $completion = & $argumentCompleter.ScriptBlock

                $completion.CompletionText | Should -Contain "lorem"
            }

            It "uses Headers provided as parameter" {
                New-Session -ServerName "TestServer" -Credential ([System.Management.Automation.PSCredential]::Empty) -Headers @{"X-Test" = $true}

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Headers = @{"X-Test" = $true}
                    }
                    Exactly         = $true
                    Times           = 0
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }
        }
    }
}
