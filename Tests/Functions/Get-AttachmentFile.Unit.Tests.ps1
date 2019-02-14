#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Get-AttachmentFile" -Tag Unit {

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

    Mock Invoke-Method -ModuleName $env:BHProjectName -ParameterFilter { $Method -eq "GET" } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Get-ConfluenceAttachmentFile

        It "has a mandatory parameter 'Attachment'" {
            $command | Should -HaveParameter "Attachment" -Mandatory
        }

        It "has a parameter 'Attachment' of type [AtlassianPS.ConfluencePS.Attachment[]]" {
            $command | Should -HaveParameter "Attachment" -Type [AtlassianPS.ConfluencePS.Attachment[]]
        }

        It "has a parameter 'Path' of type [String]" {
            $command | Should -HaveParameter "Path" -Type [String]
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
            Get-ConfluenceAttachmentFile -Attachment $invalidAttachment1 -ErrorAction SilentlyContinue
            Get-ConfluenceAttachmentFile -Attachment $invalidAttachment2 -ErrorAction SilentlyContinue
            Get-ConfluenceAttachmentFile -Attachment $invalidAttachment3 -ErrorAction SilentlyContinue
        }

        It "throws a terminating error if the path is invalid" {
            { Get-ConfluenceAttachmentFile -Attachment $attachment -Path "TestDrive:/" } | Should -Not -Throw

            { Get-ConfluenceAttachmentFile -Attachment $attachment -Path "TestDrive:/folder" } | Should -Throw "Path not found"

            $null = New-item -Path "TestDrive:/folder" -ItemType Directory
            { Get-ConfluenceAttachmentFile -Attachment $attachment -Path "TestDrive:/folder" } | Should -Not -Throw
        }
    }
}
