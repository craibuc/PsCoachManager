BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PrivatePath = Join-Path $ProjectDirectory "/PsCoachManager/Private/"

    $sut = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PrivatePath $sut)

}

Describe 'nz' {

    Context 'Parameter validation' {

        BeforeAll {
            $Command = Get-Command 'nz'
        }

        Context 'InputObject' {
            BeforeAll {
                $ParameterName='InputObject'
            }

            It 'is an [object]' {
                $Command | Should -HaveParameter $ParameterName -Type [object]
            }
            It 'is position 0' {
                $Command.Parameters[$ParameterName].Attributes.Position | Should -Be 0
            }
            It 'is accepts ValueFromPipeline' {
                $Command.Parameters[$ParameterName].Attributes.ValueFromPipeline | Should -Be $true
            }
        }

    }

    Context 'Usage' {

        It 'converts [System.DBNull] to $null' {
            $InputObject=[DBNull]::Value

            $Actual = nz -InputObject $InputObject

            $Actual | Should -Be $null
        }
        It 'converts a zero-length string to $null' {
            $InputObject=''

            $Actual = nz -InputObject $InputObject

            $Actual | Should -Be $null
        }
        It "converts 'white space' to `$null" {
            $InputObject='
            '

            $Actual = nz -InputObject $InputObject

            $Actual | Should -Be $null
        }
        It "non-null [<Type>] values are returned" -ForEach @(
            @{ Type=[datetime]; Value=(Get-Date) }
            @{ Type=[string]; Value='lorem ipsum' }
            @{ Type=[int]; Value=100 }
            @{ Type=[bool]; Value=$true }
        ) {
            param($Type, $Value)

            $Actual = nz -InputObject $Value

            $Actual | Should -Be $Value
        }
    }

}