BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsCoachManager/Public/"

    $sut = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $sut)

}

Describe "Set-CoachManagerDriver" {

    Context "Parameter validation" {

        BeforeAll {
            write-verbose 'Describe\Context[parm validation]\BeforeAll'
            $Command = Get-Command 'Set-CoachManagerDriver'
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
                @{ParameterName='EmploymentStarted'; Type=[System.Nullable[datetime]]; Mandatory=$true}
    
                @{ParameterName='Title'; Type='[string]'; Mandatory=$false}
                @{ParameterName='DateOfBirth'; Type=[System.Nullable[datetime]]; Mandatory=$false}
                @{ParameterName='Gender'; Type='[string]'; Mandatory=$false}
                @{ParameterName='Address1'; Type='[string]'; Mandatory=$false}
                @{ParameterName='Address2'; Type='[string]'; Mandatory=$false}
                @{ParameterName='City'; Type='[string]'; Mandatory=$false}
                @{ParameterName='RegionCode'; Type='[string]'; Mandatory=$false}
                @{ParameterName='PostalCode'; Type='[string]'; Mandatory=$false}
                @{ParameterName='CellularPhone'; Type='[string]'; Mandatory=$false}
                @{ParameterName='HomePhone'; Type='[string]'; Mandatory=$false}
                @{ParameterName='EMail'; Type='[string]'; Mandatory=$false}
                @{ParameterName='LicenseValidFrom'; Type=[System.Nullable[datetime]]; Mandatory=$false}
                @{ParameterName='LicenseValidTo'; Type=[System.Nullable[datetime]]; Mandatory=$false}
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
                DriverSerialNo=1
                DriverID='DriverID'
                DriverType='DriverType'
                FirstName='FirstName'
                Surname='Surname'
                EmploymentStarted='2021-10-01'
            }
        }

        BeforeDiscovery {
            write-verbose 'Describe\Context[Usage]\BeforeDiscovery'
            $Mandatory = @{
                DriverSerialNo=1
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
                [pscustomobject]$Mandatory | Set-CoachManagerDriver @Authentication
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
                    $Query -like "UPDATE*$($Authentication.Database)..Drivers*"
                }
            }
            It "sets the column '<Name>' with the value '<Value>'" -TestCases ( $Mandatory.GetEnumerator() | ForEach-Object { @{Name=$_.Key; Value=$_.Value} } ) {
                param($Name, $Value)

                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Test = 
                        if ( $Name -in 'DriverSerialNo') {
                            "*WHERE*{0}={1}*" -f $Name, $Value
                        }
                        elseif ( $Name -in 'EmploymentStarted') {
                            "*{0}='{1}'*" -f $Name, ([datetime]$Value).ToString('MM/dd/yyyy')
                        }
                        else {
                            "*{0}='{1}'*" -f $Name, $Value
                        }

                    $Query -like $Test
                }
            }

        }
        
        Context 'Optional parameters' {

            BeforeDiscovery {
                $Optional = @{
                    Title='Title'
                    DateOfBirth='10/02/2021'
                    Gender='Male'
                    Address1='Address1'
                    Address2='Address2'
                    City='City'
                    RegionCode='RegionCode'
                    PostalCode='PostalCode'
                    CellularPhone='CellularPhone'
                    HomePhone='HomePhone'
                    EMail='EMail'
                    LicenseValidFrom='10/03/21'
                    LicenseValidTo='10/04/21'
                    CompanyID='CompanyID'
                    EmploymentFinished='10/05/21'
                    PayrollID=1
                    Schedule=[int]$true
                }
            }

            BeforeAll {
                $Optional = @{
                    Title='Title'
                    DateOfBirth='10/02/2021'
                    Gender='Male'
                    Address1='Address1'
                    Address2='Address2'
                    City='City'
                    RegionCode='RegionCode'
                    PostalCode='PostalCode'
                    CellularPhone='CellularPhone'
                    HomePhone='HomePhone'
                    EMail='EMail'
                    LicenseValidFrom='10/03/21'
                    LicenseValidTo='10/04/21'
                    CompanyID='CompanyID'
                    EmploymentFinished='10/05/21'
                    PayrollID=1
                    Schedule=[int]$true
                }
            }

            BeforeEach {
                Mock Invoke-Sqlcmd
                [pscustomobject]($Mandatory+$Optional) | Set-CoachManagerDriver @Authentication
            }
            
            It "sets the column '<Name>' with the value '<Value>'" -TestCases ( $Optional.GetEnumerator() | ForEach-Object { @{Name=$_.Key; Value=$_.Value} } ) {
                param($Name, $Value)
                
                Assert-MockCalled Invoke-Sqlcmd -ParameterFilter {
                    $Test = 
                        if ( $Name -in 'PayrollID','Schedule') {
                            "*{0}={1}*" -f $Name, $Value
                        }
                        elseif ( $Name -in 'LicenseValidFrom','LicenseValidTo','EmploymentFinished') {
                            "*{0}='{1}'*" -f $Name, ([datetime]$Value).ToString('MM/dd/yyyy')
                        }
                        else {
                            "*{0}='{1}'*" -f $Name, $Value
                        }

                    $Query -like $Test
                }   
            }

        }
    }

}