<#
.SYNOPSIS
Return records from PHCS..Drivers table.

#>
function Get-CoachManagerDriver {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ServerInstance,
        
        [Parameter()]
        [string]$Database = 'PHCS',

        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter(ParameterSetName='BySerialNo',Mandatory)]
        [int]$DriverSerialNo,

        [Parameter(ParameterSetName='ById',Mandatory)]
        [string]$DriverID
    )
    
    begin {}
    
    process {
        
        $Predicate = [pscustomobject]@{
            SELECT = "SELECT * FROM $Database..Drivers"
            WHERE = "WHERE 1=1"
        }
    
        if ( $DriverSerialNo ) { $Predicate.WHERE += "`r`nAND DriverSerialNo = $DriverSerialNo" }
        if ( $DriverID ) { $Predicate.WHERE += "`r`nAND DriverID = '$DriverID'" }
    
        $Query = $Predicate.PsObject.Properties.Value -join "`r`n"
        Write-Debug $Query

        Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential | ForEach-Object {

            @{
                DriverSerialNo = $_.DriverSerialNo
                Title = $_.Title | nz
                FirstName = $_.FirstName | nz
                Surname = $_.Surname | nz
                Gender = $_.Gender
                DateOfBirth = $_.DateOfBirth
                # address
                Address1 = $_.Address1 | nz
                Address2 = $_.Address2 | nz
                City = $_.Address3 | nz
                RegionCode = $_.Address4 | nz
                PostalCode = $_.PostCode | nz
                CountryCode = $_.International -eq 0 ? 'US' : $null
                # contact
                TelNo1 = $_.TelNo1 | nz
                TelNo2 = $_.TelNo2 | nz
                TelNo3 = $_.TelNo3 | nz
                Email = $_.Email | nz
                # 
                DriverID = $_.DriverID
                DriverType = $_.DriverType
                DateCreated = $_.DateCreated
                # license
                LicenseNumber = $_.LicenseNumber | nz
                LicenseValidFrom = $_.LicenseValidFrom | nz
                LicenseValidTo = $_.LicenseValidTo | nz
                # employment
                EmploymentStarted = $_.EmploymentStarted | nz
                EmploymentFinished = $_.EmploymentFinished | nz
                # flags
                Suspend = [bool]$_.Suspend
                Deleted = [bool]$_.Deleted
                Schedule = [bool]$_.Schedule
                Subcontractor = [bool]$_.Subcontractor
                PartTime = [bool]$_.PartTime
                SecondaryDriver = [bool]$_.SecondaryDriver
            }

        }
    }
    
    end {}

}