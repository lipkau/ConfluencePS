#requires -modules BuildHelpers
#requires -modules Configuration
#requires -modules Pester

Describe "Validation of build environment" -Tag Build {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $changelogFile = if ($env:BHisBuild) {
        "$env:BHBuildOutput/$env:BHProjectName/CHANGELOG.md"
    }
    else {
        "$env:BHProjectPath/CHANGELOG.md"
    }

    Context "CHANGELOG" {

        foreach ($line in (Get-Content $changelogFile)) {
            if ($line -match "(?:##|\<h2.*?\>)\s*\[(?<Version>(\d+\.?){1,2})\]") {
                $changelogVersion = $matches.Version
                break
            }
        }

        It "has a changelog file" {
            $changelogFile | Should -Exist
        }

        It "has a valid version in the changelog" {
            $changelogVersion            | Should -Not -BeNullOrEmpty
            [Version]($changelogVersion)  | Should -BeOfType [Version]
        }

        It "has a version changelog that matches the manifest version" {
            Configuration\Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion | Should -BeLike "$changelogVersion*"
        }
    }
}
