#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.3.1" }

Describe "[AtlassianPS.ConfluencePS.Icon] Tests" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest
    }
    AfterAll {
        Invoke-TestCleanup
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
