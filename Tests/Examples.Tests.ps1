#requires -modules BuildHelpers
#requires -modules Pester

Describe "Validation of example codes in the documentation" -Tag Documentation, NotImplemented {

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
        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    Assert-True $script:isBuild "Examples can only be tested in the build environment. Please run `Invoke-Build -Task Build`."

    #region Mocks
    Mock Invoke-WebRequest { }
    Mock Invoke-RestMethod { }
    #endregion Mocks

    $functions = Get-Command -Module $env:BHProjectName
    foreach ($function in $functions) {
        Context "Examples of $($function.Name)" {
            $help = Get-Help $function.Name

            foreach ($example in $help.examples.example) {
                $exampleName = ($example.title -replace "-").trim()

                It "has a working example: $exampleName" {
                    <# {
                        $scriptBlock = [Scriptblock]::Create($example.code)

                        & $scriptBlock 2>$null
                    } | Should -Not -Throw #>
                }
            }
        }
    }
}
