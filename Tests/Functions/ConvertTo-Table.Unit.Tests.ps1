#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe 'ConvertTo-Table' -Tag Unit {

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
    #endregion Mocking

    Context "Sanity checking" {
        $command = Get-Command -Name ConvertTo-ConfluenceTable

        It "has a mandatory parameter 'Content'" {
            $command | Should -HaveParameter "Content" -Mandatory
        }

        It "has a parameter 'Content' of type [System.Object]" {
            $command | Should -HaveParameter "Content" -Type [System.Object]
        }

        It "has a parameter 'Vertical' of type [Switch]" {
            $command | Should -HaveParameter "Vertical" -Type [Switch]
        }

        It "has a parameter 'NoHeader' of type [Switch]" {
            $command | Should -HaveParameter "NoHeader" -Type [Switch]
        }
    }

    Context "Behavior checking" {

        #region Mocking
        # linux and macOS don't have Get-Service
        function Get-FakeService {
            [PSCustomObject]@{
                Name        = "AppMgmt"
                DisplayName = "Application Management"
                Status      = "Running"
            }
            [PSCustomObject]@{
                Name        = "BITS"
                DisplayName = "Background Intelligent Transfer Service"
                Status      = "Running"
            }
            [PSCustomObject]@{
                Name        = "Dhcp"
                DisplayName = "DHCP Client"
                Status      = "Running"
            }
            [PSCustomObject]@{
                Name        = "DsmSvc"
                DisplayName = "Device Setup Manager"
                Status      = "Running"
            }
            [PSCustomObject]@{
                Name        = "EFS"
                DisplayName = "Encrypting File System (EFS)"
                Status      = "Running"
            }
            [PSCustomObject]@{
                Name        = "lmhosts"
                DisplayName = "TCP/IP NetBIOS Helper"
                Status      = "Running"
            }
            [PSCustomObject]@{
                Name        = "MSDTC"
                DisplayName = "Distributed Transaction Coordinator"
                Status      = "Stopped"
            }
            [PSCustomObject]@{
                Name        = "NlaSvc"
                DisplayName = "Network Location Awareness"
                Status      = "Stopped"
            }
            [PSCustomObject]@{
                Name        = "PolicyAgent"
                DisplayName = "IPsec Policy Agent"
                Status      = "Stopped"
            }
            [PSCustomObject]@{
                Name        = "SessionEnv"
                DisplayName = "Remote Desktop Configuration"
                Status      = "Stopped"
            }
        }
        #endregion Mocking

        It "creates a table with a header row" {
            $table = ConvertTo-ConfluenceTable -Content (Get-FakeService)
            $row = $table -split [Environment]::NewLine

            $row | Should -HaveCount 12
            $row[0] | Should -BeExactly '|| Name || DisplayName || Status ||'
            $row[1..10] | ForEach-Object {
                $_ | Should -Match '^| [\w\s]+? | [\w\s]+? | [\w\s]+? |$'
                $_ | Should -Not -Match '\|\|'
                $_ | Should -Not -Match '\|\s\s+\|'
            }
            $row[11] | Should -BeNullOrEmpty
        }

        It "creates an empty table with header row" {
            $table = ConvertTo-ConfluenceTable ([PSCustomObject]@{ Name = $null; DisplayName = $null; Status = $null })
            $row = $table -split [Environment]::NewLine

            $row | Should -HaveCount 3
            $row[0] | Should -BeExactly '|| Name || DisplayName || Status ||'
            $row[1] | Should -BeExactly '| | | |'
            $row[2] | Should -BeNullOrEmpty
        }

        It "creates a table without a header row" {
            $table = ConvertTo-ConfluenceTable (Get-FakeService) -NoHeader
            $row = $table -split [Environment]::NewLine

            $row | Should -HaveCount 11
            $row[0..9] | ForEach-Object {
                $_ | Should -Match '^| [\w\s]+? | [\w\s]+? | [\w\s]+? |$'
                $_ | Should -Not -Match '\|\|'
                $_ | Should -Not -Match '\|\s\s+\|'
            }
            $row[10] | Should -BeNullOrEmpty
        }

        It "creates a vertical table with a header column" {
            $table = ConvertTo-ConfluenceTable ([PSCustomObject]@{ Name = "winlogon"; DisplayName = "Windows logon"; Status = "Running" }) -Vertical
            $row = $table -split [Environment]::NewLine

            $row | Should -HaveCount 4
            $row[0..2] | ForEach-Object {
                $_ | Should -Match '^|| [\w\s]+ || [\w\s]+ |$'
                $_ | Should -Not -Match '\|\|$'
                $_ | Should -Not -Match '\|\s\s+\|'
            }
            $row[3] | Should -BeNullOrEmpty
        }

        It "creates an empty vertical table with a header column" {
            $table = ConvertTo-ConfluenceTable ([PSCustomObject]@{ Name = $null; DisplayName = $null; Status = $null }) -Vertical
            $row = $table -split [Environment]::NewLine

            $row | Should -HaveCount 4
            $row[0..2] | ForEach-Object {
                $_ | Should -Match '^|| [\w\s]+? || |$'
                $_ | Should -Not -Match '\|\|$'
                $_ | Should -Not -Match '\|\s\s+\|'
            }
            $row[3] | Should -BeNullOrEmpty
        }

        It "creates a vertical table without a header column" {
            $table = ConvertTo-ConfluenceTable ([PSCustomObject]@{ Name = "winlogon"; DisplayName = "Windows logon"; Status = "Running" }) -Vertical -NoHeader
            $row = $table -split [Environment]::NewLine

            $row | Should -HaveCount 4
            $row[0..2] | ForEach-Object {
                $_ | Should -Match '^| [\w\s]+? | [\w\s]+? |$'
                $_ | Should -Not -Match '\|\|$'
                $_ | Should -Not -Match '\|\s\s+\|'
            }
            $row[3] | Should -BeNullOrEmpty
        }

        It "creates an empty vertical table without a header column" {
            $table = ConvertTo-ConfluenceTable ([PSCustomObject]@{ Name = $null; DisplayName = $null; Status = $null }) -Vertical -NoHeader
            $row = $table -split [Environment]::NewLine

            $row | Should -HaveCount 4
            $row[0..2] | ForEach-Object {
                $_ | Should -Match '^| [\w\s]+? | |$'
                $_ | Should -Not -Match '\|\|$'
                $_ | Should -Not -Match '\|\s\s+\|'
            }
            $row[3] | Should -BeNullOrEmpty
        }

        It "returns a single string object" {
            $table = ConvertTo-ConfluenceTable (Get-FakeService)
            $row = $table -split [Environment]::NewLine

            $table | Should -HaveCount 1
            @($row).Count | Should -BeGreaterThan 1
        }
    }
}
