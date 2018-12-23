#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "Get-AttachmentFile" -Tag Unit {

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

    Mock Invoke-Method -ModuleName $env:BHProjectName -ParameterFilter { $Method -eq "GET" } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Get-ConfluenceAttachmentFile

        It "has a [AtlassianPS.ConfluencePS.Attachment[]] -Attachment parameter" {
            $command.Parameters.ContainsKey("Attachment")
            $command.Parameters["Attachment"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Attachment[]"
        }

        It "has a [String] -Path parameter" {
            $command.Parameters.ContainsKey("Path")
            $command.Parameters["Path"].ParameterType | Should -Be "String"
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

        It "downloads an attachment to disk" {
            Get-ConfluenceAttachmentFile -Attachment ([AtlassianPS.ConfluencePS.Attachment]@{
                URL = "https://google.com"
                MediaType = "text/plain"
                Filename = "test.txt"
            })

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "https://google.com/" -and
                    $OutFile -eq "test.txt"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "downloads an attachment to a specific location" {
            Get-ConfluenceAttachmentFile -Attachment ([AtlassianPS.ConfluencePS.Attachment]@{
                URL = "https://google.com/"
                MediaType = "text/plain"
                Filename = "test.txt"
            }) -Path "TestDrive:/"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "https://google.com/" -and
                    $OutFile -match "^TestDrive:[\/\\]test.txt$"
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
        $attachment = [AtlassianPS.ConfluencePS.Attachment]@{
            URL = "https://google.com"
            MediaType = "text/plain"
            Filename = "test.txt"
        }
        $invalidAttachment1 = [AtlassianPS.ConfluencePS.Attachment]@{
            URL = "https://google.com"
            MediaType = "text/plain"
        }
        $invalidAttachment2 = [AtlassianPS.ConfluencePS.Attachment]@{
            URL = "https://google.com"
            Filename = "test.txt"
        }
        $invalidAttachment3 = [AtlassianPS.ConfluencePS.Attachment]@{
            MediaType = "text/plain"
            Filename = "test.txt"
        }
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Get-ConfluenceAttachmentFile -Attachment $attachment -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Get-ConfluenceAttachmentFile -Attachment $attachment -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Get-ConfluenceAttachmentFile
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Page] object is provided" {
            { Get-ConfluenceAttachmentFile -Attachment $invalidAttachment1 -ErrorAction Stop } | Should -Throw "Attachment is missing the Filename"
            { Get-ConfluenceAttachmentFile -Attachment $invalidAttachment2 -ErrorAction Stop } | Should -Throw "Attachment is missing the MediaType"
            { Get-ConfluenceAttachmentFile -Attachment $invalidAttachment3 -ErrorAction Stop } | Should -Throw "Attachment is missing the URL"
            { Get-ConfluenceAttachmentFile -Attachment $invalidAttachment1 -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Get-ConfluenceAttachmentFile -Attachment $invalidAttachment2 -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Get-ConfluenceAttachmentFile -Attachment $invalidAttachment3 -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "throws a terminating error if the path is invalid" {
            { Get-ConfluenceAttachmentFile -Attachment $attachment -Path "TestDrive:/" } | Should -Not -Throw

            { Get-ConfluenceAttachmentFile -Attachment $attachment -Path "TestDrive:/folder" } | Should -Throw "Path not found"

            $null = New-item -Path "TestDrive:/folder" -ItemType Directory
            { Get-ConfluenceAttachmentFile -Attachment $attachment -Path "TestDrive:/folder" } | Should -Not -Throw
        }
    }
}
