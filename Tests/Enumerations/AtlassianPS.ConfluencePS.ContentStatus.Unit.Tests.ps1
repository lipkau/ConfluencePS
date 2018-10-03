#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }

Describe "[AtlassianPS.ConfluencePS.ContentStatus] Tests" -Tag Unit {

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

    It "creates an [AtlassianPS.ConfluencePS.ContentStatus] from a string" {
        { [AtlassianPS.ConfluencePS.ContentStatus]"current" } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.ContentStatus]"trashed" } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.ContentStatus]"historical" } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.ContentStatus]"draft" } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.ContentStatus]"any" } | Should -Not -Throw
    }

    It "throws when an invalid string is provided" {
        { [AtlassianPS.ConfluencePS.ContentStatus]"foo" } | Should -Throw 'Cannot convert value "foo" to type "AtlassianPS.ConfluencePS.ContentStatus"'
    }

    It "has no constructor" {
        { [AtlassianPS.ConfluencePS.ContentStatus]::new("current") } | Should -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.ContentStatus -ArgumentList "current" } | Should -Throw
    }

    It "can enumerate it's values" {
        $values = [System.Enum]::GetNames('AtlassianPS.ConfluencePS.ContentStatus')

        $values.Count | Should -Be 5
        $values | Should -Contain "current"
        $values | Should -Contain "trashed"
        $values | Should -Contain "historical"
        $values | Should -Contain "draft"
        $values | Should -Contain "any"
    }
}
