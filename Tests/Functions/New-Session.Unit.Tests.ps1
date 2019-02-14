#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    "PSAvoidUsingConvertToSecureStringWithPlainText",
    "",
    Justification = "Converting received plaintext token to SecureString"
)]
param()

Describe "New-Session" -Tag Unit {

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
        $Uri -eq "/rest/api/space" -and
        $Method -eq "GET"
    } { }
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name New-ConfluenceSession

        It "has a parameter 'Headers' of type [Hashtable]" {
            $command | Should -HaveParameter "Headers" -Type [Hashtable]
        }

        It "has a mandatory parameter 'ServerName'" {
            $command | Should -HaveParameter "ServerName" -Mandatory
        }

        It "has a parameter 'ServerName' with ArgumentCompleter" {
            $command | Should -HaveParameter "ServerName" -HasArgumentCompleter
        }

        It "has a parameter 'ServerName' with a default value" {
            $command | Should -HaveParameter "ServerName" -DefaultValue ""
        }

        It "has a mandatory parameter 'Credential'" {
            $command | Should -HaveParameter "Credential" -Mandatory
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }

        It "has a parameter 'Credential' with a default value" {
            $command | Should -HaveParameter "Credential" -DefaultValue ""
        }
    }

    Context "Behavior checking" {

        #region Arrange
        $Pass = ConvertTo-SecureString -AsPlainText -Force -String "lorem ipsum"
        $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("user", $Pass)
        #endregion Arrange

        It "calls Invoke-Method with StoreSession" {
            New-ConfluenceSession -ServerName "TestServer" -Credential $Cred

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
            & (Get-Module $env:BHProjectName) { $script:DefaultServer = "wrongValue" }
        }
        $Pass = ConvertTo-SecureString -AsPlainText -Force -String "lorem ipsum"
        $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("user", $Pass)
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { New-ConfluenceSession -ServerName "" -Credential $Cred } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { New-ConfluenceSession -ServerName $null -Credential $Cred } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name New-ConfluenceSession
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "uses Headers provided as parameter" {
            New-ConfluenceSession -ServerName "TestServer" -Credential ([System.Management.Automation.PSCredential]::Empty) -Headers @{"X-Test" = $true}

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
