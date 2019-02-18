#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.4" }

Describe "Add-Comment" -Tag Unit {

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

    Mock ConvertTo-StorageFormat -ModuleName $env:BHProjectName {}
    Mock Resolve-ContentType -ModuleName $env:BHProjectName {
        [AtlassianPS.ConfluencePS.Page]@{
            Id = $InputObject.Id
        }
    }

    Mock Invoke-Method -ModuleName $env:BHProjectName -ParameterFilter {
        $Uri -like "/rest/api/content"
        $Method -eq "POST"
    } {}
    Mock Invoke-Method -ModuleName $env:BHProjectName { throw "Invalid call to Invoke-Method" }
    #endregion Mocking

    Context "Sanity checking" {

        $command = Get-Command -Name Add-ConfluenceComment

        It "has a mandatory parameter 'Content'" {
            $command | Should -HaveParameter "Content" -IsMandatory
        }

        It "has a parameter 'Content' of type [AtlassianPS.ConfluencePS.Content[]]" {
            $command | Should -HaveParameter "Content" -OfType [AtlassianPS.ConfluencePS.Content[]]
        }

        It "has a parameter 'Comment' of type [String]" {
            $command | Should -HaveParameter "Comment" -OfType [String]
        }

        It "has a parameter 'ConvertBody' of type [Switch]" {
            $command | Should -HaveParameter "ConvertBody" -OfType [Switch]
        }

        It "has a parameter 'ServerName' of type [String]" {
            $command | Should -HaveParameter "ServerName" -OfType [String]
        }

        It "has a parameter 'ServerName' with ArgumentCompleter" {
            $command | Should -HaveParameter "ServerName" -HasArgumentCompleter
        }

        It "has a parameter 'ServerName' with a default value" {
            $command | Should -HaveParameter "ServerName" -Default "(Get-DefaultServer)"
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -OfType [PSCredential]
        }

        It "has a parameter 'Credential' with a default value" {
            $command | Should -HaveParameter "Credential" -Default "[System.Management.Automation.PSCredential]::Empty"
        }
    }

    Context "Behavior checking" {

        BeforeAll {
            $PSDefaultParameterValues["Add-ConfluenceComment:ServerName"] = "Foo"
        }
        AfterAll {
            $PSDefaultParameterValues.Remove("Add-ConfluenceComment:ServerName")
        }

        It "adds a Comment to a Content" {
            Add-ConfluenceComment -Content 123 -Comment "Foo"

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-Method"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $Uri -eq "/rest/api/content" -and
                    $Body -match "`"type`"\s*:\s*`"comment`"" -and
                    $Body -match "`"body`"\s*:\s*\{\s*`"storage`"\s*:\s*\{\s*`"representation`"\s*:\s*`"storage`",\s*`"value`"\s*:\s*`"Foo`"\s*\}\s*\}" -and
                    $Body -match "`"container`"\s*:\s*\{\s*`"id`"\s*:\s*123\s*,\s*`"type`"\s*:\s*`"page`"\s*\}"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "resolves the input object" {
            [AtlassianPS.ConfluencePS.Content]@{Id = 123} | Add-ConfluenceComment -Comment "Foo"
            [AtlassianPS.ConfluencePS.BlogPost]@{Id = 123} | Add-ConfluenceComment -Comment "Foo"
            [AtlassianPS.ConfluencePS.Page]@{Id = 123} | Add-ConfluenceComment -Comment "Foo"
            123 | Add-ConfluenceComment -Comment "Foo"

            $assertMockCalledSplat = @{
                CommandName = "Resolve-ContentType"
                ModuleName  = $env:BHProjectName
                Exactly     = $true
                Times       = 4
                Scope       = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "uses ConvertTo-StorageFormat on the Comment string when -ConvertBody is used" {
            Add-ConfluenceComment -Content 123 -Comment "Foo" -ConvertBody

            $assertMockCalledSplat = @{
                CommandName = "ConvertTo-StorageFormat"
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
            Backup-Configuration
        }
        AfterAll {
            Restore-Configuration
        }
        $blogpost = [AtlassianPS.ConfluencePS.BlogPost]@{Id = 123}
        $content = [AtlassianPS.ConfluencePS.Content]@{Id = 123}
        $page = [AtlassianPS.ConfluencePS.Page]@{Id = 123}
        $invalidPage = [AtlassianPS.ConfluencePS.Page]@{Title = "Foo"}
        #endregion Arrange

        It "does not allow an empty ServerName" {
            { Add-ConfluenceComment -Content 123 -ServerName "" } | Should -Throw
        }

        It "does not allow a null ServerName" {
            { Add-ConfluenceComment -Content 123 -ServerName $null } | Should -Throw
        }

        It "completes ServerName arguments" {
            $command = Get-Command -Name Add-ConfluenceComment
            $argumentCompleter = $command.Parameters["ServerName"].Attributes |
                Where-Object {$_ -is [ArgumentCompleter]}
            $completion = & $argumentCompleter.ScriptBlock

            $completion.CompletionText | Should -Contain "lorem"
        }

        It "accepts a [String] as input for -Content" {
            Add-ConfluenceComment -Content "123" -Comment "Foo"
        }

        It "accepts a [Int] as input for -Content" {
            Add-ConfluenceComment -Content 123 -Comment "Foo"
        }

        It "accepts a [Int] as input for -Content over the pipeline" {
            123 | Add-ConfluenceComment -Comment "Foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.BlogPost] as input for -Content" {
            Add-ConfluenceComment -Content $blogpost -Comment "Foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content" {
            Add-ConfluenceComment -Content $content -Comment "Foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Content" {
            Add-ConfluenceComment -Content $page -Comment "Foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.BlogPost] as input for -Content over the pipeline" {
            $blogpost | Add-ConfluenceComment -Comment "Foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Content] as input for -Content over the pipeline" {
            $content | Add-ConfluenceComment -Comment "Foo"
        }

        It "accepts a [AtlassianPS.ConfluencePS.Page] as input for -Content over the pipeline" {
            $page | Add-ConfluenceComment -Comment "Foo"
        }

        It "accepts a [String] as input for -Comment over the pipeline" {
            "TestDrive:/file.txt" | Add-ConfluenceComment -Content 123
        }

        It "writes an error when an incomplete [AtlassianPS.ConfluencePS.Page] object is provided" {
            { Add-ConfluenceComment -Content $invalidPage -Path "TestDrive:/file.txt" -ErrorAction Stop } | Should -Throw "Content is missing the Id"
            { Add-ConfluenceComment -Content $invalidPage -Path "TestDrive:/file.txt" -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "throws a terminating error if the path is not a file and exists" {
            { Add-ConfluenceComment -Content $page -Path "TestDrive:\" } | Should -Throw "File not found"

            { Add-ConfluenceComment -Content $page -Path "TestDrive:\folder" } | Should -Throw "File not found"

            { Add-ConfluenceComment -Content $page -Path "TestDrive:\newfile.txt" } | Should -Throw "File not found"

            $null = New-Item -Path "TestDrive:/newfile.txt" -ItemType File
            { Add-ConfluenceComment -Content $page -Path "TestDrive:\newfile.txt" } | Should -Not -Throw
        }
    }
}
