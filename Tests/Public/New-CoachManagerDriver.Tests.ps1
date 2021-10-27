BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsCoachManager/Public/"

    $sut = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $sut)

}

Describe "New-CoachManagerDriver" {

    Context "Parameter validation" {

        BeforeAll {
            $Command = Get-Command 'New-CoachManagerDriver'
        }

        $Parameters = @(
            @{ParameterName='ServerInstance'; Type='[string]'; Mandatory=$true}
            @{ParameterName='Database'; Type='[string]'; Mandatory=$false}
            @{ParameterName='Credential'; Type='[pscredential]'; Mandatory=$true}

            @{ParameterName='DriverID'; Type='[string]'; Mandatory=$true}
            @{ParameterName='DriverType'; Type='[string]'; Mandatory=$true}
            @{ParameterName='FirstName'; Type='[string]'; Mandatory=$true}
            @{ParameterName='Surname'; Type='[string]'; Mandatory=$true}
            @{ParameterName='EmploymentStarted'; Type='[datetime]'; Mandatory=$true}
        )

        Context 'Data type' {
        
            It "<ParameterName> is a <Type>" -TestCases $Parameters {
                param ($ParameterName, $Type)
                $Command | Should -HaveParameter $ParameterName -Type $Type
            }

        }

        Context "Mandatory" {
            it "<ParameterName> Mandatory is <Mandatory>" -TestCases $Parameters {
                param($ParameterName, $Mandatory)

                if ($Mandatory) { $Command | Should -HaveParameter $ParameterName -Mandatory }
                else { $Command | Should -HaveParameter $ParameterName -Not -Mandatory }    
            }    
        }
    }

    Context "Usage" {
        BeforeAll {
            $Authentication = @{
                ServerInstance='0.0.0.0'
                Database='Database'
                Credential=[pscredential]::new('user',('password' | ConvertTo-SecureString -AsPlainText))
            }
            $Mandatory = @{
                DriverID='DriverID'
                DriverType='DriverType'
                FirstName='FirstName'
                Surname='Surname'
                EmploymentStarted='2021-10-20'
            } 
        }

        Context "Mandatory parameters" {

            BeforeEach {
                Mock Invoke-Sqlcmd
                [pscustomobject]$Mandatory | New-CoachManagerDriver @Authentication
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
            It "uses the expected Query" {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    # $Query -eq $Expected.Query
                }
            }

        }
        
    }

}