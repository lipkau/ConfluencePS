#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.6.0" }

Describe "[AtlassianPS.ConfluencePS.SpaceType] Tests" -Tag Unit {

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

    It "creates an [AtlassianPS.ConfluencePS.SpaceType] from a string" {
        { [AtlassianPS.ConfluencePS.SpaceType]"global" } | Should -Not -Throw
        { [AtlassianPS.ConfluencePS.SpaceType]"personal" } | Should -Not -Throw
    }

    It "throws when an invalid string is provided" {
        { [AtlassianPS.ConfluencePS.SpaceType]"foo" } | Should -Throw 'Cannot convert value "foo" to type "AtlassianPS.ConfluencePS.SpaceType"'
    }

    It "has no constructor" {
        { [AtlassianPS.ConfluencePS.SpaceType]::new("global") } | Should -Throw
        { New-Object -TypeName AtlassianPS.ConfluencePS.SpaceType -ArgumentList "global" } | Should -Throw
    }

    It "can enumerate it's values" {
        $values = [System.Enum]::GetNames('AtlassianPS.ConfluencePS.SpaceType')

        $values | Should -HaveCount 2
        $values | Should -Contain "global"
        $values | Should -Contain "personal"
    }
}
