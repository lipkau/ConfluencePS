#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "[AtlassianPS.ConfluencePS.User] Tests" -Tag Unit {

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

    It "allows for an empty object" {
        { [AtlassianPS.ConfluencePS.User]::new() } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.User]@{} } | Should -Not -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.User } | Should -Not -Throw
    }

    It "converts a [Hashtable] to [AtlassianPS.ConfluencePS.User]" {
        { [AtlassianPS.ConfluencePS.User]@{ UserName = "jon.doe" } } | Should -Not -Throw
    }

    It "has a constructor" {
        { [AtlassianPS.ConfluencePS.User]::new("jon.doe", "Jon Doe") } | Should -Not -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.User -ArgumentList "jon.doe", "Jon Doe" } | Should -Not -Throw
    }

    It "has a string representation" {
        $object = [AtlassianPS.ConfluencePS.User]::new("jon.doe", "Jon Doe")

        $object.ToString() | Should -Be "jon.doe"
    }

    Context "Types of properties" {
        $object = [AtlassianPS.ConfluencePS.User]@{
            UserName       = "jon.doe"
            DisplayName    = "Jon Doe"
            UserKey        = "1"
            ProfilePicture = @{ Path = "." }
            Self           = "https://google.com"
        }

        It "has a UserName of type String" {
            $object.UserName| Should -BeOfType [String]
        }

        It "has a DisplayName of type String" {
            $object.DisplayName | Should -BeOfType [String]
        }

        It "has a UserKey of type String" {
            $object.UserKey | Should -BeOfType [String]
        }

        It "has a ProfilePicture of type AtlassianPS.ConfluencePS.Icon" {
            $object.ProfilePicture | Should -BeOfType [AtlassianPS.ConfluencePS.Icon]
        }

        It "has a Self of type Uri" {
            $object.Self | Should -BeOfType [Uri]
        }
    }
}
