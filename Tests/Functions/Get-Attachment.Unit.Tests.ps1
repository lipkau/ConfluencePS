#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.2" }

Describe "Get-Attachment" -Tag Unit {

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

    Mock Invoke-Method -ModuleName $env:BHProjectName -ParameterFilter {
        $Uri -like "/rest/api/content/*/child/attachment" -and
        $Method -eq "GET"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Get-ConfluenceAttachment

        It "has a [AtlassianPS.ConfluencePS.Page[]] -Page parameter" {
            $command.Parameters.ContainsKey("Page")
            $command.Parameters["Page"].ParameterType | Should -Be "AtlassianPS.ConfluencePS.Page[]"
        }

        It "has a [String] -FileNameFilter parameter" {
            $command.Parameters.ContainsKey("FileNameFilter")
            $command.Parameters["FileNameFilter"].ParameterType | Should -Be "String"
        }

        It "has a [String] -MediaTypeFilter parameter" {
            $command.Parameters.ContainsKey("MediaTypeFilter")
            $command.Parameters["MediaTypeFilter"].ParameterType | Should -Be "String"
        }

        It "has a [UInt32] -PageSize parameter" {
            $command.Parameters.ContainsKey("PageSize")
            $command.Parameters["PageSize"].ParameterType | Should -Be "UInt32"
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

        It "fetches attachments of a page" {
            Get-ConfluenceAttachment -Page 123

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
            Get-ConfluenceAttachment -Page 123 -FileNameFilter "file.txt"

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
            Get-ConfluenceAttachment -Page 123 -MediaTypeFilter "image/png"

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
            Get-ConfluenceAttachment -Page 123 -MediaTypeFilter "image/png" -FileNameFilter "file.txt"

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
        $invalidPage = [AtlassianPS.ConfluencePS.Page]@{Title = "Foo"}
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Get-ConfluenceAttachment -Page 123 -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Get-ConfluenceAttachment -Page 123 -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Get-ConfluenceAttachment
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "uses the `$PageSize when fetching results" {
            Get-ConfluenceAttachment -Page 123
            Get-ConfluenceAttachment -Page 123 -PageSize 5

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

        It "accepts a [String] as input for -Page" {
            { Get-ConfluenceAttachment -Page "123" } | Should -Not -Throw
        }

        It "accepts a [String] as input for -Page over the pipeline" {
            { "123" | Get-ConfluenceAttachment } | Should -Not -Throw
        }

        It "accepts a [Int] as input for -Page" {
            { Get-ConfluenceAttachment -Page 123 } | Should -Not -Throw
        }

        It "accepts a [Int] as input for -Page over the pipeline" {
            { 123 | Get-ConfluenceAttachment } | Should -Not -Throw
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page" {
            { Get-ConfluenceAttachment -Page $page } | Should -Not -Throw
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Page over the pipeline" {
            { $page | Get-ConfluenceAttachment } | Should -Not -Throw
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Page] object is provided" {
            { Get-ConfluenceAttachment -Page $invalidPage -ErrorAction Stop } | Should -Throw "Page is missing the Id"
            { Get-ConfluenceAttachment -Page $invalidPage -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
