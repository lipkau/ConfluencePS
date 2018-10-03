#requires -modules @{ ModuleName = "BuildHelpers"; ModuleVersion = "1.2" }
#requires -modules Configuration
#requires -modules Pester

Describe "General project validation" -Tag Unit {

    BeforeAll {
        Remove-Item -Path Env:\BH*
        $projectRoot = (Resolve-Path "$PSScriptRoot/..").Path
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
        # Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Remove-Module BuildTools
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }
    AfterEach {
        Get-ChildItem TestDrive:\FunctionCalled* | Remove-Item
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    }

    It "passes Test-ModuleManifest" {
        { Test-ModuleManifest -Path $env:BHManifestToTest -ErrorAction Stop } | Should -Not -Throw
    }

    It "imports '$env:BHProjectName' cleanly" {
        Import-Module $env:BHManifestToTest -ErrorAction Stop

        $module = Get-Module $env:BHProjectName

        $module | Should BeOfType [PSModuleInfo]
        $module.Prefix | Should Be "Confluence"
    }

    It "imports '$env:BHProjectName' with custom prefix" {
        Import-Module $env:BHManifestToTest -Prefix "Wiki" -ErrorAction Stop

        $module = Get-Module $env:BHProjectName

        $module | Should BeOfType [PSModuleInfo]
        $module.Prefix | Should Be "Wiki"
        (Get-Command -Module $env:BHProjectName).Name | ForEach-Object {
            $_ -match "\-Wiki" | Should Be $true
        }
    }

    It "has public functions" {
        Import-Module $env:BHManifestToTest -ErrorAction Stop

        (Get-Command -Module $env:BHProjectName | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "uses the correct root module" {
        Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName RootModule | Should -Be 'ConfluencePS.psm1'
    }

    It "uses the correct guid" {
        Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName Guid | Should -Be '20d32089-48ef-464d-ba73-6ada240e26b3'
    }

    It "uses a valid version" {
        [Version](Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -Not -BeNullOrEmpty
        [Version](Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -BeOfType [Version]
    }

    It "requires AtlassianPS.Configuration" {
        # this workaround will be obsolete with
        # https://github.com/PoshCode/Configuration/pull/20
        $pureExpression = Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName RequiredModules -Passthru
        [Scriptblock]::Create($pureExpression.Extent.Text).Invoke() | Should -Contain 'AtlassianPS.Configuration'
    }

    It "loads Configuration into the global scope" {
        Remove-Module Configuration -Force -ErrorAction SilentlyContinue
        (Get-Module).Name | Should -Not -Contain Configuration

        Import-Module $env:BHManifestToTest -Force

        (Get-Module).Name | Should -Contain Configuration

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    }

    It "loads saved configurations states on import" {
        Test-Path "TestDrive:\FunctionCalled.Import-Configuration.txt" | Should -Be $false

        New-Alias -Name Import-Configuration -Value LogCall -Scope Global
        Import-Module $env:BHManifestToTest
        Remove-Item alias:\Import-Configuration -ErrorAction SilentlyContinue

        "TestDrive:\FunctionCalled.Import-Configuration.txt" | Should -FileContentMatchExactly "Import-Configuration"
    }
}
