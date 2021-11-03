BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsCoachManager/Public/"

    $sut = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'

    . (Join-Path $PublicPath $sut)

}

Describe "Set-CoachManagerDriver" {

    Context "Parameter validation" {

        BeforeAll {
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
                @{ParameterName='Address3'; Type='[string]'; Mandatory=$false}
                @{ParameterName='Address4'; Type='[string]'; Mandatory=$false}
                @{ParameterName='PostCode'; Type='[string]'; Mandatory=$false}
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
                DriverSerialNo=1
                DriverID='DriverID'
                DriverType='DriverType'
                FirstName='FirstName'
                Surname='Surname'
                EmploymentStarted='2021-10-01'
            }
        }

        BeforeDiscovery {
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
                    Address3='Address3'
                    Address4='Address4'
                    PostCode='PostCode'
                    TelNo1='TelNo1'
                    TelNo1Comment='TelNo1Comment'
                    TelNo2='TelNo2'
                    TelNo2Comment='TelNo2Comment'
                    TelNo3='TelNo3'
                    TelNo3Comment='TelNo3Comment'
                    FaxNo='FaxNo'
                    FaxNoComment='FaxNoComment'
                    EMail='EMail'
                    LicenceValidFrom='10/03/21'
                    LicenceValidTo='10/04/21'
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
                    Address3='Address3'
                    Address4='Address4'
                    PostCode='PostCode'
                    TelNo1='TelNo1'
                    TelNo1Comment='TelNo1Comment'
                    TelNo2='TelNo2'
                    TelNo2Comment='TelNo2Comment'
                    TelNo3='TelNo3'
                    TelNo3Comment='TelNo3Comment'
                    FaxNo='FaxNo'
                    FaxNoComment='FaxNoComment'
                    EMail='EMail'
                    LicenceValidFrom='10/03/21'
                    LicenceValidTo='10/04/21'
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
                        elseif ( $Name -in 'LicenceValidFrom','LicenceValidTo','EmploymentFinished') {
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