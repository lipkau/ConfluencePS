#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "[AtlassianPS.ConfluencePS.Version] Tests" -Tag Unit {

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
        { [AtlassianPS.ConfluencePS.Version]::new() } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.Version]@{} } | Should -Not -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.Version } | Should -Not -Throw
    }

    It "converts a [Hashtable] to [AtlassianPS.ConfluencePS.Version]" {
        { [AtlassianPS.ConfluencePS.Version]@{} } | Should -Not -Throw
    }

    It "does not have a constructor" {
        { [AtlassianPS.ConfluencePS.Version]::new("") } | Should -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.Version -ArgumentList "" } | Should -Throw
    }

    It "has a string representation" {
        $object = [AtlassianPS.ConfluencePS.Version]@{ Number = 55 }

        $object.ToString() | Should -Be "55"
    }

    Context "Types of properties" {
        $object = [AtlassianPS.ConfluencePS.Version]@{
            By           = @{ UserName = "jon.doe" }
            When         = (Get-Date)
            FriendlyWhen = "1 day ago"
            Number       = 55
            Message      = "lorem ipsum"
            MinorEdit    = $false
            Self         = "https://google.com"
        }

        It "has a By of type User" {
            $object.By| Should -BeOfType [AtlassianPS.ConfluencePS.User]
        }

        It "has a When of type DateTime" {
            $object.When | Should -BeOfType [DateTime]
        }

        It "has a FriendlyWhen of type String" {
            $object.FriendlyWhen | Should -BeOfType [String]
        }

        It "has a Number of type UInt32" {
            $object.Number | Should -BeOfType [UInt32]
        }

        It "has a Message of type String" {
            $object.Message | Should -BeOfType [String]
        }

        It "has a MinorEdit of type Boolean" {
            $object.MinorEdit | Should -BeOfType [Boolean]
        }

        It "has a Self of type Uri" {
            $object.Self | Should -BeOfType [Uri]
        }
    }
}
