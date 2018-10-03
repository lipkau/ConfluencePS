#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }

Describe "[AtlassianPS.ConfluencePS.Icon] Tests" -Tag Unit {

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
        { [AtlassianPS.ConfluencePS.Icon]::new() } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.Icon]@{} } | Should -Not -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.Icon } | Should -Not -Throw
    }

    It "converts a [Hashtable] to [AtlassianPS.ConfluencePS.Icon]" {
        { [AtlassianPS.ConfluencePS.Icon]@{ Path = ""; Width = ""; Height = ""; IsDefault = "" } } | Should -Not -Throw
    }

    It "does not have a constructor" {
        { [AtlassianPS.ConfluencePS.Icon]::new("","","","") } | Should -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.Icon -ArgumentList "","","","" } | Should -Throw
    }

    It "has a string representation" {
        $object = [AtlassianPS.ConfluencePS.Icon]@{ Path = "/images/foo.png"}

        $object.ToString() | Should -Be "/images/foo.png"
    }

    Context "Types of properties" {
        $object = [AtlassianPS.ConfluencePS.Icon]@{ Path = ""; Width = ""; Height = ""; IsDefault = "" }

        It "has a Path of type String" {
            $object.Path | Should -BeOfType [String]
        }

        It "has a Width of type UInt32" {
            $object.Width | Should -BeOfType [UInt32]
        }

        It "has a Height of type UInt32" {
            $object.Height | Should -BeOfType [UInt32]
        }

        It "has a IsDefault of type Boolean" {
            $object.IsDefault | Should -BeOfType [Boolean]
        }
    }
}
