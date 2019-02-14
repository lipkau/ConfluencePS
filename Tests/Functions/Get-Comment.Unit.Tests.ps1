#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "Get-Attachment" -Tag Unit {

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
        $Uri -like "/rest/api/content/*/child/attachment" -and
        $Method -eq "GET"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Get-ConfluenceAttachment

        It "has a mandatory parameter 'Content'" {
            $command | Should -HaveParameter "Content" -Mandatory
        }

        It "has a parameter 'Content' of type [AtlassianPS.ConfluencePS.Content[]]" {
            $command | Should -HaveParameter "Content" -Type [AtlassianPS.ConfluencePS.Content[]]
        }

        It "has a parameter 'FileNameFilter' of type [String]" {
            $command | Should -HaveParameter "FileNameFilter" -Type [String]
        }

        It "has a parameter 'MediaTypeFilter' of type [String]" {
            $command | Should -HaveParameter "MediaTypeFilter" -Type [String]
        }

        It "has a parameter 'PageSize' of type [UInt32]" {
            $command | Should -HaveParameter "PageSize" -Type [UInt32]
        }

        It "has a parameter 'PageSize' with a default value" {
            $command | Should -HaveParameter "PageSize" -DefaultValue '(Get-AtlassianConfiguration -Name "ConfluencePS" -ValueOnly)["PageSize"]'
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

        It "fetches attachments of a page" {
            Get-ConfluenceAttachment -Content 123

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/child/attachment"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches attachments of a page filtered by file name" {
            Get-ConfluenceAttachment -Content 123 -FileNameFilter "file.txt"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/child/attachment" -and
                    $GetParameter["filename"] -eq "file.txt"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches attachments of a page filtered by media type" {
            Mock Invoke-Method -ModuleName $env:BHProjectName { Write-Host "Get Parameter: $GetParameter" }
            Get-ConfluenceAttachment -Content 123 -MediaTypeFilter "image/png"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/child/attachment" -and
                    $GetParameter["mediaType"] -eq "image/png"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "fetches attachments of a page filtered by media type and file name" {
            Get-ConfluenceAttachment -Content 123 -MediaTypeFilter "image/png" -FileNameFilter "file.txt"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/child/attachment" -and
                    $GetParameter["mediaType"] -eq "image/png" -and
                    $GetParameter["filename"] -eq "file.txt"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "returns [AtlassianPS.ConfluencePS.Attachment] objects" {
            Get-ConfluenceAttachment -Content 123

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content/123/child/attachment" -and
                    $OutputType -eq [AtlassianPS.ConfluencePS.Attachment]
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
        $blogpost = [AtlassianPS.ConfluencePS.BlogPost]@{Id = 123}
        $content = [AtlassianPS.ConfluencePS.Content]@{Id = 123}
        $page = [AtlassianPS.ConfluencePS.Page]@{Id = 123}
        $invalidPage = [AtlassianPS.ConfluencePS.Page]@{Title = "Foo"}
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Get-ConfluenceAttachment -Content 123 -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Get-ConfluenceAttachment -Content 123 -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Get-ConfluenceAttachment
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "uses the `$PageSize when fetching results" {
            Get-ConfluenceAttachment -Content 123
            Get-ConfluenceAttachment -Content 123 -PageSize 5

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

        It "accepts a [String] as input for -Content" {
            Get-ConfluenceAttachment -Content "123"
        }

        It "accepts a [String] as input for -Content over the pipeline" {
            "123" | Get-ConfluenceAttachment
        }

        It "accepts a [Int] as input for -Content" {
            Get-ConfluenceAttachment -Content 123
        }

        It "accepts a [Int] as input for -Content over the pipeline" {
            123 | Get-ConfluenceAttachment
        }

        It "accepts a [AtlassianPS.ConfluencePS.BlogPost] as input for -Content" {
            Get-ConfluenceAttachment -Content $blogpost
        }

        It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content" {
            Get-ConfluenceAttachment -Content $content
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Content" {
            Get-ConfluenceAttachment -Content $page
        }

        It "accepts a [AtlassianPS.ConfluencePS.BlogPost] as input for -Content over the pipeline" {
            $blogpost | Get-ConfluenceAttachment
        }

        It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content over the pipeline" {
            $content | Get-ConfluenceAttachment
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Content over the pipeline" {
            $page | Get-ConfluenceAttachment
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Page] object is provided" {
            { Get-ConfluenceAttachment -Content $invalidPage -ErrorAction Stop } | Should -Throw "Page is missing the Id"
            { Get-ConfluenceAttachment -Content $invalidPage -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
