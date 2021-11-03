BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsCoachManager/Public/"

    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $SUT)

}

Describe "Get-CoachManagerPrivateHireMovement" {

    Context 'Parameter validation' {

        BeforeAll {
            $Command = Get-Command 'Get-CoachManagerPrivateHireMovement'
        }

        Context 'ServerInstance' {
            BeforeAll {
                $ParameterName='ServerInstance'
            }

            It 'is a [string]' {
                $Command | Should -HaveParameter $ParameterName -Type [string]
            }
            It 'is mandatory' {
                $Command | Should -HaveParameter $ParameterName -Mandatory
            }
        }

        Context 'Database' {
            BeforeAll {
                $ParameterName='Database'
            }

            It 'is a [string]' {
                $Command | Should -HaveParameter $ParameterName -Type [string]
            }
            It 'is optional' {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

        Context 'Credential' {
            BeforeAll {
                $ParameterName='Credential'
            }

            It 'is a [PsCredential]' {
                $Command | Should -HaveParameter $ParameterName -Type [PsCredential]
            }
            It 'is mandatory' {
                $Command | Should -HaveParameter $ParameterName -Mandatory
            }
        }

        Context 'ID' {
            BeforeAll {
                $ParameterName='ID'
            }

            It 'is a [int]' {
                $Command | Should -HaveParameter $ParameterName -Type [int]
            }
            It 'is mandatory' {
                $Command | Should -HaveParameter $ParameterName -Mandatory
            }
        }

        Context 'BookingType' {
            BeforeAll {
                $ParameterName='BookingType'
            }

            It 'is a [string]' {
                $Command | Should -HaveParameter $ParameterName -Type [string]
            }
            It 'is optional' {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

        Context 'StartingDateTime' {
            BeforeAll {
                $ParameterName='StartingDateTime'
            }

            It 'is a [datetime]' {
                $Command | Should -HaveParameter $ParameterName -Type [datetime]
            }
            It 'is optional' {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

        Context 'EndingDateTime' {
            BeforeAll {
                $ParameterName='EndingDateTime'
            }

            It 'is a [datetime]' {
                $Command | Should -HaveParameter $ParameterName -Type [datetime]
            }
            It 'is optional' {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

    }

    Context 'Usage' {

        BeforeAll {
            $Authentication = @{
                ServerInstance='0.0.0.0'
                Database='Database'
                Credential=[pscredential]::new('user',('password' | ConvertTo-SecureString -AsPlainText))
            }
        }

        BeforeEach {
            Mock Invoke-Sqlcmd
        }

        Context 'when authentication parameters are supplied' {

            BeforeEach {
                Get-CoachManagerPrivateHireMovement @Authentication
            }

            It "uses the expected ServerInstance" {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $ServerInstance -eq $Authentication.ServerInstance
                }
            }
            It "uses the expected Database" {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Database -eq $Authentication.Database
                }
            }
            It "uses the expected Credential" {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Credential -eq $Authentication.Credential
                }
            }
        }

        Context 'when a BookingType is supplied' {
         
            BeforeEach {
                $BookingType = 'lorem'

                Get-CoachManagerPrivateHireMovement @Authentication -BookingType $BookingType
            }

            It 'adds a BookingType filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*BookingType IN ('$BookingType')*"
                }    
            }

        }

        Context 'when a StartingDateTime is supplied' {
            
            BeforeEach {
                $StartingDateTime = '10/01/2020'
                Get-CoachManagerPrivateHireMovement @Authentication -StartingDateTime $StartingDateTime
            }

            It 'adds a StartingDateTime filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*StartDateTime >= '$([datetime]$StartingDateTime)'*"
                }
            }

        }

        Context 'when a EndingDateTime is supplied' {
            
            BeforeEach {
                $EndingDateTime = '10/31/2020'
                Get-CoachManagerPrivateHireMovement @Authentication -EndingDateTime $EndingDateTime
            }

            It 'adds a EndingDateTime filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*StartDateTime <= '$([datetime]$EndingDateTime)'*"
                }
            }

        }
    }

}