BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsCoachManager/Public/"

    $sut = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $sut)

}

Describe "Get-CoachManagerDriver" {

    Context 'Parameter validation' {

        BeforeAll {
            $Command = Get-Command 'Get-CoachManagerDriver'
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

        Context 'DriverSerialNo' {
            BeforeAll {
                $ParameterName='DriverSerialNo'
            }

            It 'is a [int]' {
                $Command | Should -HaveParameter $ParameterName -Type [int]
            }
            It 'is mandatory' {
                $Command | Should -HaveParameter $ParameterName -Mandatory
            }
        }

        Context 'DriverId' {
            BeforeAll {
                $ParameterName='DriverId'
            }

            It 'is a [string]' {
                $Command | Should -HaveParameter $ParameterName -Type [string]
            }
            It 'is mandatory' {
                $Command | Should -HaveParameter $ParameterName -Mandatory
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
                Get-CoachManagerDriver @Authentication
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
                    $Query -like "*FROM*Drivers*"
                }
            }

        }

        Context 'when a DriverSerialNo is supplied' {
         
            BeforeEach {
                $DriverSerialNo = 123456

                Get-CoachManagerDriver @Authentication -DriverSerialNo $DriverSerialNo
            }

            It 'adds a DriverSerialNo filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*DriverSerialNo = $DriverSerialNo*"
                }    
            }

        }

        Context 'when a DriverId is supplied' {
            
            BeforeEach {
                $DriverId = 123456
                Get-CoachManagerDriver @Authentication -DriverID $DriverId
            }

            It 'adds a DriverId filter to the where-clause' {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "*DriverId = '$DriverId'*"
                }
            }

        }

    }
}