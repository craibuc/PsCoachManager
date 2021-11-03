BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsCoachManager/Public/"

    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $SUT)

}

Describe "Get-CoachManagerPayroll" {

    Context 'Parameter validation' {

        BeforeAll {
            $Command = Get-Command 'Get-CoachManagerPayroll'
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

        Context 'FromDate' {
            BeforeAll {
                $ParameterName='FromDate'
            }

            It 'is a [datetime]' {
                $Command | Should -HaveParameter $ParameterName -Type [datetime]
            }
            It 'is optional' {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

        Context 'ToDate' {
            BeforeAll {
                $ParameterName='ToDate'
            }

            It 'is a [datetime]' {
                $Command | Should -HaveParameter $ParameterName -Type [datetime]
            }
            It 'is optional' {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

        Context 'Company' {
            BeforeAll {
                $ParameterName='Company'
            }

            It 'is a [string[]]' {
                $Command | Should -HaveParameter $ParameterName -Type [string[]]
            }
            It 'is optional' {
                $Command | Should -HaveParameter $ParameterName -Not -Mandatory
            }
        }

        Context 'Driver' {
            BeforeAll {
                $ParameterName='Driver'
            }

            It 'is a [string[]]' {
                $Command | Should -HaveParameter $ParameterName -Type [string[]]
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
                Get-CoachManagerPayroll @Authentication
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
            It "queries the expected table" {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*FROM*vwPayrollProductionCalculations01*"
                }
            }

        }

        Context 'when a FromDate is supplied' {
            
            BeforeEach {
                $FromDate = '10/01/2020'
                Get-CoachManagerPayroll @Authentication -FromDate $FromDate
            }

            It 'adds a FromDate filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*PayrollProductionStartDate = '$([datetime]$FromDate)'*"
                }
            }

        }

        Context 'when a ToDate is supplied' {
            
            BeforeEach {
                $ToDate = '10/31/2020'
                Get-CoachManagerPayroll @Authentication -ToDate $ToDate
            }

            It 'adds a ToDate filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*PayrollProductionFinishDate = '$([datetime]$ToDate)'*"
                }
            }

        }

        Context 'when a Company is supplied' {
         
            BeforeEach {
                $Company = 'Acme'

                Get-CoachManagerPayroll @Authentication -Company $Company
            }

            It 'adds a Company filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*PayrollCompanyID IN ('$Company')*"
                }    
            }

        }

        Context 'when a Driver is supplied' {
         
            BeforeEach {
                $Driver = 'AA1234'

                Get-CoachManagerPayroll @Authentication -Driver $Driver
            }

            It 'adds a Driver filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*DriverID IN ('$Driver')*"
                }    
            }

        }
    
    }

}