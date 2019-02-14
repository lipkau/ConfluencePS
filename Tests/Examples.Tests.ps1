#requires -modules BuildHelpers
#requires -modules Pester

Describe "Validation of example codes in the documentation" -Tag Documentation, Build, NotImplemented {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Assert-True { $env:BHisBuild } "Examples can only be tested in the build environment. Please run `Invoke-Build -Task Build`."

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
