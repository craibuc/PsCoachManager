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

        BeforeDiscovery {
            $Parameters = @(
                @{ParameterName='ServerInstance'; Type='[string]'; Mandatory=$true}
                @{ParameterName='Database'; Type='[string]'; Mandatory=$false}
                @{ParameterName='Credential'; Type='[pscredential]'; Mandatory=$true}
    
                @{ParameterName='DriverID'; Type='[string]'; Mandatory=$true}
                @{ParameterName='DriverType'; Type='[string]'; Mandatory=$true}
                @{ParameterName='FirstName'; Type='[string]'; Mandatory=$true}
                @{ParameterName='Surname'; Type='[string]'; Mandatory=$true}
                @{ParameterName='EmploymentStarted'; Type='[datetime]'; Mandatory=$true}

                @{ParameterName='Title'; Type='[string]'; Mandatory=$false}
                @{ParameterName='DateOfBirth'; Type=[System.Nullable[datetime]]; Mandatory=$false}
                @{ParameterName='Gender'; Type='[string]'; Mandatory=$false}
                @{ParameterName='Address1'; Type='[string]'; Mandatory=$false}
                @{ParameterName='Address2'; Type='[string]'; Mandatory=$false}
                @{ParameterName='City'; Type='[string]'; Mandatory=$false}
                @{ParameterName='RegionCode'; Type='[string]'; Mandatory=$false}
                @{ParameterName='PostalCode'; Type='[string]'; Mandatory=$false}
                @{ParameterName='TelNo1'; Type='[string]'; Mandatory=$false}
                @{ParameterName='TelNo1Comment'; Type='[string]'; Mandatory=$false}
                @{ParameterName='TelNo2'; Type='[string]'; Mandatory=$false}
                @{ParameterName='TelNo2Comment'; Type='[string]'; Mandatory=$false}
                @{ParameterName='TelNo3'; Type='[string]'; Mandatory=$false}
                @{ParameterName='TelNo3Comment'; Type='[string]'; Mandatory=$false}
                @{ParameterName='FaxNo'; Type='[string]'; Mandatory=$false}
                @{ParameterName='FaxNoComment'; Type='[string]'; Mandatory=$false}
                @{ParameterName='EMail'; Type='[string]'; Mandatory=$false}
                @{ParameterName='LicenceValidFrom'; Type=[System.Nullable[datetime]]; Mandatory=$false}
                @{ParameterName='LicenceValidTo'; Type=[System.Nullable[datetime]]; Mandatory=$false}
                @{ParameterName='CompanyID'; Type='[string]'; Mandatory=$false}
                @{ParameterName='EmploymentFinished'; Type=[System.Nullable[datetime]]; Mandatory=$false}
                @{ParameterName='PayrollID'; Type='[int]'; Mandatory=$false}
                @{ParameterName='Schedule'; Type='[bool]'; Mandatory=$false}
            )    
        }

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
                EmploymentStarted='2021-10-01'
            } 
        }

        BeforeDiscovery {
            $Mandatory = @{
                DriverID='DriverID'
                DriverType='DriverType'
                FirstName='FirstName'
                Surname='Surname'
                EmploymentStarted='2021-10-01'
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
            It "updates the expected table" {
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Query -like "INSERT INTO *Drivers*"
                }
            }
            It "sets the column '<Name>' with the value '<Value>'" -TestCases ( $Mandatory.GetEnumerator() | ForEach-Object { @{Name=$_.Key; Value=$_.Value} } ) {
                param($Name, $Value)

                Should -Invoke Invoke-Sqlcmd -ParameterFilter {

                    Write-Debug "$Name`: $value"

                    $Query -match 'insert into.*\((?<KEY>.*)\)[\s]*values.*\((?<VALUE>.*)\)'

                    # Write-Debug $Matches['KEY'].Trim()
                    # Write-Debug $Matches['VALUE'].Trim()

                    $K = $Matches['KEY'].Trim() -split ','
                    $V = $Matches['VALUE'].Trim() -split ','

                    $Actual = $V[$K.IndexOf($Name)]
                    $Value -eq "'$Actual'"

                }
            }
        }
        
    }

}