#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    "PSAvoidUsingConvertToSecureStringWithPlainText",
    "",
    Justification = "Converting received plaintext token to SecureString"
)]
param()

Describe "Connect-Server" -Tag Unit {

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

        Mock New-Session -ModuleName $env:BHProjectName {}
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name Connect-Server

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

            #region Arrange
            BeforeEach {
                $script:DefaultServer = "wrongValue"
            }
            $Pass = ConvertTo-SecureString -AsPlainText -Force -String "lorem ipsum"
            $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("user", $Pass)
            #endregion Arrange

            It "sets the ServerName as default" {
                $script:DefaultServer | Should -Not -Be "TestServer"

                Connect-Server -ServerName "TestServer"

                $script:DefaultServer | Should -Be "TestServer"
            }

            It "creates a new Session for ServerName" {
                Connect-Server -ServerName "TestServer" -Credential $Cred

                $assertMockCalledSplat = @{
                    CommandName = "New-Session"
                    ModuleName  = $env:BHProjectName
                    Exactly     = $true
                    Times       = 1
                    Scope       = 'It'
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
                    $script:Configuration.Add("ServerList",[System.Collections.Generic.List[AtlassianPS.ServerData]]::new())
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
                { Connect-Server -ServerName "" } | Should -Throw
            }

            It "does not allow a null ServerName" {
                { Connect-Server -ServerName $null } | Should -Throw
            }

            It "accepts ServerName over the pipeline" {
                $script:DefaultServer | Should -Not -Be "TestServer"

                "TestServer" | Connect-Server

                $script:DefaultServer | Should -Be "TestServer"
            }

            It "completes ServerName arguments" {
                Get-Command -Name Connect-Server
                $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                    Where-Object {$_ -is [ArgumentCompleter]}
                $completion = & $argumentCompleter.ScriptBlock

                $completion.CompletionText | Should -Contain "lorem"
            }

            It "does not create a Session for null Credential" {
                Connect-Server -ServerName "TestServer" -Credential $null

                $assertMockCalledSplat = @{
                    CommandName = "New-Session"
                    ModuleName  = $env:BHProjectName
                    Exactly     = $true
                    Times       = 0
                    Scope       = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "does not create a Session for empty Credential" {
                Connect-Server -ServerName "TestServer" -Credential ([System.Management.Automation.PSCredential]::Empty)

                $assertMockCalledSplat = @{
                    CommandName = "New-Session"
                    ModuleName  = $env:BHProjectName
                    Exactly     = $true
                    Times       = 0
                    Scope       = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }
        }
    }
}
