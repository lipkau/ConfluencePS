#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "Get-Content" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1"
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope $env:BHProjectName {

        #region Mocking
        Mock Write-DebugMessage -ModuleName $env:BHProjectName {}
        Mock Write-Verbose -ModuleName $env:BHProjectName {}

        Mock Invoke-Method -ModuleName $env:BHProjectName -ParameterFilter {
            $Uri -like "/rest/api/content*" -and
            $Method -eq "GET"
        } {
            [AtlassianPS.ConfluencePS.Page]@{
                Title = "Foo"
            }
            [AtlassianPS.ConfluencePS.Page]@{
                Title = "Bar"
            }
            [AtlassianPS.ConfluencePS.Page]@{
                Title = "Baz"
            }
        }
        Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
        #endregion Mocking

        Context "Sanity checking" {

            $command = Get-Command -Name Get-Content

            It "has a [AtlassianPS.ConfluencePS.Content[]] -Content parameter" {
                $command.Parameters.ContainsKey("Content")
                $command.Parameters["Content"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Content[]"
            }

            It "has a [UInt32] -Version parameter" {
                $command.Parameters.ContainsKey("Version")
                $command.Parameters["Version"].ParameterType | Should -Be "UInt32"
            }

            It "has a [AtlassianPS.ConfluencePS.Space] -Space parameter" {
                $command.Parameters.ContainsKey("Space")
                $command.Parameters["Space"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Space"
            }

            It "has a [String] -Title parameter" {
                $command.Parameters.ContainsKey("Title")
                $command.Parameters["Title"].ParameterType | Should -Be "String"
            }

            It "has a [AtlassianPS.ConfluencePS.ContentStatus] -Status parameter" {
                $command.Parameters.ContainsKey("Status")
                $command.Parameters["Status"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.ContentStatus"
            }

            It "has a [String] -Query parameter" {
                $command.Parameters.ContainsKey("Query")
                $command.Parameters["Query"].ParameterType | Should -Be "String"
            }

            It "has a [DateTime] -PostingDay parameter" {
                $command.Parameters.ContainsKey("PostingDay")
                $command.Parameters["PostingDay"].ParameterType | Should -Be "DateTime"
            }

            It "has a [UInt32] -PageSize parameter" {
                $command.Parameters.ContainsKey("PageSize")
                $command.Parameters["PageSize"].ParameterType | Should -Be "UInt32"
            }

            It "has a [String] -Expand parameter" {
                $command.Parameters.ContainsKey("Expand")
                $command.Parameters["Expand"].ParameterType | Should -Be "String"
            }

            It "has a [String] -ServerName parameter" {
                $command.Parameters.ContainsKey("ServerName")
                $command.Parameters["ServerName"].ParameterType | Should -Be "String"
            }

            It "has a [UInt32] -PageSize parameter" {
                $command.Parameters.ContainsKey("PageSize")
                $command.Parameters["PageSize"].ParameterType | Should -Be "UInt32"
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

            It "fetches a specific Content by it's ID" {
                Get-Content -Content 123

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -eq "/rest/api/content/123"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches a specific Version of a Content" {
                Get-Content -Content 123 -Version 5

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -eq "/rest/api/content/123" -and
                        $GetParameter["version"] -eq 5
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches a specific Status of a Content" {
                Get-Content -Content 123 -Status draft

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -eq "/rest/api/content/123"
                        $GetParameter["status"] -eq "draft"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches all pages" {
                Get-Content -Space "Foo"

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["type"] -eq "page"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches all pages from a Space" {
                Get-Content -Space "Foo"

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["spaceKey"] -eq "Foo" -and
                        $GetParameter["type"] -eq "page"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches pages by Title" {
                Get-Content -Title "Bar"

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["title"] -eq "Bar" -and
                        $GetParameter["type"] -eq "page"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches pages by Title in a spcific Space" {
                Get-Content -Space "Foo" -Title "Bar"

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["spaceKey"] -eq "Foo" -and
                        $GetParameter["title"] -eq "Bar" -and
                        $GetParameter["type"] -eq "page"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches pages by Space and Title filtering by Status of a Content" {
                Get-Content -Space "Foo" -Title "Bar" -Status draft

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["spaceKey"] -eq "Foo" -and
                        $GetParameter["title"] -eq "Bar" -and
                        $GetParameter["status"] -eq "draft"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches all blogposts" {
                Get-Content -ContentType "blogpost"

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["type"] -eq "blogpost"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches all blogposts in a Space" {
                Get-Content -ContentType "blogpost" -Space "Foo"

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["spaceKey"] -eq "Foo" -and
                        $GetParameter["type"] -eq "blogpost"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches blogposts in a specific status" {
                Get-Content -ContentType "blogpost" -Status draft

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["status"] -eq "draft" -and
                        $GetParameter["type"] -eq "blogpost"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches blogposts by the date they were posted" {
                Get-Content -ContentType "blogpost" -PostingDay (Get-Date -Year 2000 -Month 01 -Day 31)

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -like "/rest/api/content" -and
                        $GetParameter["postingDay"] -eq "2000-01-31" -and
                        $GetParameter["type"] -eq "blogpost"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "fetches pages by cql query" {
                Get-Content -Query "mention = jsmith and creator != jsmith"

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -eq "/rest/api/content/search" -and
                        $GetParameter["cql"] -eq "mention+%3d+jsmith+and+creator+!%3d+jsmith"
                    }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }

            It "returns [AtlassianPS.ConfluencePS.Page] objects" { }
            It "returns [AtlassianPS.ConfluencePS.BlogPost] objects" { }

            It "returns paginated results" {
                Get-Content -Content 123
                Get-Content -Space "Foo"
                Get-Content -Space "Foo" -ContentType "blogpost"
                Get-Content -Query "mention = jsmith"

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = {
                        $Uri -eq "/rest/api/content/123" -and
                        $Paging -eq $true
                    }
                    Exactly         = $true
                    Times           = 0
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat

                $assertMockCalledSplat["ParameterFilter"] = {
                    $Uri -like "/rest/api/content" -and
                    $GetParameter["spaceKey"] -eq "Foo" -and
                    $GetParameter["type"] -eq "page" -and
                    $Paging -eq $true
                }
                $assertMockCalledSplat["Times"] = 1
                Assert-MockCalled @assertMockCalledSplat

                $assertMockCalledSplat["ParameterFilter"] = {
                    $Uri -like "/rest/api/content" -and
                    $GetParameter["spaceKey"] -eq "Foo" -and
                    $GetParameter["type"] -eq "blogpost" -and
                    $Paging -eq $true
                }
                $assertMockCalledSplat["Times"] = 1
                Assert-MockCalled @assertMockCalledSplat

                $assertMockCalledSplat["ParameterFilter"] = {
                    $Uri -like "/rest/api/content/search" -and
                    $GetParameter["cql"] -like "mention*" -and
                    $Paging -eq $true
                }
                $assertMockCalledSplat["Times"] = 1
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
            $page = [AtlassianPS.ConfluencePS.Page]@{Id = 123}
            $blogpost = [AtlassianPS.ConfluencePS.BlogPost]@{Id = 123}
            $content = [AtlassianPS.ConfluencePS.Content]@{Id = 123}
            $space = [AtlassianPS.ConfluencePS.Space]@{Key = "Foo"}
            $invalidPage = [AtlassianPS.ConfluencePS.Page]@{Title = "Foo"}
            $invalidBlogpost = [AtlassianPS.ConfluencePS.BlogPost]@{Title = "Foo"}
            $invalidContent = [AtlassianPS.ConfluencePS.Content]@{Title = "Foo"}
            $invalidSpace = [AtlassianPS.ConfluencePS.Space]@{Id = 123}
            #endregion Arrange

            It "does not allow an empty ServerName" {
                { Get-Content -ServerName "" } | Should -Throw
            }

            It "does not allow a null ServerName" {
                { Get-Content -ServerName $null } | Should -Throw
            }

            It "completes ServerName arguments" {
                $command = Get-Command -Name Get-Content
                $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                    Where-Object {$_ -is [ArgumentCompleter]}
                $completion = & $argumentCompleter.ScriptBlock

                $completion.CompletionText | Should -Contain "lorem"
            }

            It "uses the `$PageSize when fetching results" {
                Get-Content
                Get-Content -PageSize 5

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
                Get-Content -Content "123"
            }

            It "accepts a [String] as input for -Content over the pipeline" {
                "123" | Get-Content
            }

            It "accepts a [Int] as input for -Content" {
                Get-Content -Content 123
            }

            It "accepts a [Int] as input for -Content over the pipeline" {
                123 | Get-Content
            }

            It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content" {
                Get-Content -Content $page
                Get-Content -Content $blogpost
                Get-Content -Content $Content
            }

            It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Page over the pipeline" {
                $page | Get-Content
                $blogpost | Get-Content
                $content | Get-Content
            }

            It "accepts a [String] as input for -Space" {
                Get-Content -Space "Foo"
            }

            It "accepts a [AtlassianPS.ConfluencePS.Space] object as input for -Space" {
                Get-Content -Space $space
            }

            It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Content] object is provided" {
                { Get-Content -Content $invalidPage -ErrorAction Stop } | Should -Throw "Content is missing the Id"
                { Get-Content -Content $invalidBlogpost -ErrorAction Stop } | Should -Throw "Content is missing the Id"
                { Get-Content -Content $invalidContent -ErrorAction Stop } | Should -Throw "Content is missing the Id"
                { Get-Content -Content $invalidPage -ErrorAction SilentlyContinue } | Should -Not -Throw
                { Get-Content -Content $invalidBlogpost -ErrorAction SilentlyContinue } | Should -Not -Throw
                { Get-Content -Content $invalidContent -ErrorAction SilentlyContinue } | Should -Not -Throw
            }

            It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Space] object is provided" {
                { Get-Content -Space $invalidSpace -ErrorAction Stop } | Should -Throw "Space is missing the Key"
                { Get-Content -Space $invalidSpace -ErrorAction SilentlyContinue } | Should -Not -Throw
            }

            It "URL encodes the -Query input" {
                Get-Content -Query ' %$§"!+#-`´*;'

                $assertMockCalledSplat = @{
                    CommandName     = "Invoke-Method"
                    ModuleName      = $env:BHProjectName
                    ParameterFilter = { $GetParameter["cql"] -like "*+%25%24%c3%82%c2%a7%22!%2b%23-%60%c3%82%c2%b4*%3b*" }
                    Exactly         = $true
                    Times           = 1
                    Scope           = 'It'
                }
                Assert-MockCalled @assertMockCalledSplat
            }
        }
    }
}
