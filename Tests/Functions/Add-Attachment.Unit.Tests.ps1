#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "Add-Attachment" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
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
        $Uri -like "/rest/api/content/*/child/attachment"
        $Method -eq "POST"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Add-ConfluenceAttachment

        It "has a [AtlassianPS.ConfluencePS.Content] -Content parameter" {
            $command.Parameters.ContainsKey("Content")
            $command.Parameters["Content"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Content"
        }

        It "has a [String[]] -Path parameter" {
            $command.Parameters.ContainsKey("Path")
            $command.Parameters["Path"].ParameterType | Should -Be "String[]"
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

        #region Arrange
        $null = New-Item -Path "TestDrive:/file.txt" -ItemType File
        #endregion Arrange

        It "uploads a file to a Page" {
            Add-ConfluenceAttachment -Content 123 -Path "TestDrive:/file.txt"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/child/attachment" -and
                    $InFile -eq "TestDrive:/file.txt"
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
        $null = New-Item -Path "TestDrive:/folder" -ItemType Directory
        $null = New-Item -Path "TestDrive:/file.txt" -ItemType File
        $blogpost = [AtlassianPS.ConfluencePS.BlogPost]@{Id = 123}
        $content = [AtlassianPS.ConfluencePS.Content]@{Id = 123}
        $page = [AtlassianPS.ConfluencePS.Page]@{Id = 123}
        $invalidPage = [AtlassianPS.ConfluencePS.Page]@{Title = "Foo"}
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Add-ConfluenceAttachment -Attachment $attachment -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Add-ConfluenceAttachment -Attachment $attachment -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Add-ConfluenceAttachment
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "accepts a [String] as input for -Content" {
            Add-ConfluenceAttachment -Content "123" -Path "TestDrive:/file.txt"
        }

        It "accepts a [Int] as input for -Content" {
            Add-ConfluenceAttachment -Content 123 -Path "TestDrive:/file.txt"
        }

        It "accepts a [Int] as input for -Content over the pipeline" {
            123 | Add-ConfluenceAttachment -Path "TestDrive:/file.txt"
        }

        It "accepts a [AtlassianPS.ConfluencePS.BlogPost] as input for -Content" {
            Add-ConfluenceAttachment -Path "TestDrive:/file.txt"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content" {
            Add-ConfluenceAttachment -Content $content -Path "TestDrive:/file.txt"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Content" {
            Add-ConfluenceAttachment -Content $page -Path "TestDrive:/file.txt"
        }

        It "accepts a [AtlassianPS.ConfluencePS.BlogPost] as input for -Content over the pipeline" {
            $blogpost | Add-ConfluenceAttachment -Path "TestDrive:/file.txt"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content over the pipeline" {
            $content | Add-ConfluenceAttachment -Path "TestDrive:/file.txt"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Content over the pipeline" {
            $page | Add-ConfluenceAttachment -Path "TestDrive:/file.txt"
        }

        It "accepts a [String] as input for -Path over the pipeline" {
            "TestDrive:/file.txt" | Add-ConfluenceAttachment -Content 123
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Page] object is provided" {
            { Add-ConfluenceAttachment -Content $invalidPage -Path "TestDrive:/file.txt" -ErrorAction Stop } | Should -Throw "Content is missing the Id"
            { Add-ConfluenceAttachment -Content $invalidPage -Path "TestDrive:/file.txt" -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "throws a terminating error if the path is not a file and exists" {
            { Add-ConfluenceAttachment -Content $page -Path "TestDrive:\" } | Should -Throw "File not found"

            { Add-ConfluenceAttachment -Content $page -Path "TestDrive:\folder" } | Should -Throw "File not found"

            { Add-ConfluenceAttachment -Content $page -Path "TestDrive:\newfile.txt" } | Should -Throw "File not found"

            $null = New-Item -Path "TestDrive:/newfile.txt" -ItemType File
            { Add-ConfluenceAttachment -Content $page -Path "TestDrive:\newfile.txt" } | Should -Not -Throw
        }
    }
}
