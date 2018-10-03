#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }

Describe "[AtlassianPS.ConfluencePS.CommentLocation] Tests" -Tag Unit {

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

    It "creates an [AtlassianPS.ConfluencePS.CommentLocation] from a string" {
        { [AtlassianPS.ConfluencePS.CommentLocation]"inline" } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.CommentLocation]"footer" } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.CommentLocation]"resolved" } | Should -Not -Throw
    }

    It "throws when an invalid string is provided" {
        { [AtlassianPS.ConfluencePS.CommentLocation]"bar" } | Should -Throw 'Cannot convert value "bar" to type "AtlassianPS.ConfluencePS.CommentLocation"'
    }

    It "has no constructor" {
        { [AtlassianPS.ConfluencePS.CommentLocation]::new("inline") } | Should -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.CommentLocation -ArgumentList "inline" } | Should -Throw
    }

    It "can enumerate it's values" {
        $values = [System.Enum]::GetNames('AtlassianPS.ConfluencePS.CommentLocation')

        $values.Count | Should -Be 3
        $values | Should -Contain "inline"
        $values | Should -Contain "footer"
        $values | Should -Contain "resolved"
    }
}
