<#
.SYNOPSIS
Return records from PHCS..Drivers table.

.PARAMETER ServerInstance
The database server's address.

.PARAMETER Database
The name of the database; defaults to 'PHCS'.

.PARAMETER Credential
A PsCredenial representing valid database credentials.

.PARAMETER DriverSerialNo
The primary key for the PHCS..Drivers table.

.PARAMETER DriverID
TAn alternate key for the PHCS..Drivers table.

.EXAMPLE
Get-CoachManagerDriver

Get all driver records.

.EXAMPLE
Get-CoachManagerDriver -DriverID 'AZ0000'

Get single driver record for AZ0000.

.EXAMPLE
Get-CoachManagerDriver -DriverSerialNo 1001

Get single driver record for 1001.
#>
function Get-CoachManagerDriver {

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName='Default',Mandatory)]
        [Parameter(ParameterSetName='BySerialNo',Mandatory)]
        [Parameter(ParameterSetName='ById',Mandatory)]
        [string]$ServerInstance,
        
        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='BySerialNo')]
        [Parameter(ParameterSetName='ById')]
        [string]$Database = 'PHCS',

        [Parameter(ParameterSetName='Default',Mandatory)]
        [Parameter(ParameterSetName='BySerialNo',Mandatory)]
        [Parameter(ParameterSetName='ById',Mandatory)]
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
            ORDERBY = 'ORDER BY Surname, FirstName'
        }
    
        if ( $DriverSerialNo ) { $Predicate.WHERE += "`r`nAND DriverSerialNo = $DriverSerialNo" }
        if ( $DriverID ) { $Predicate.WHERE += "`r`nAND DriverID = '$DriverID'" }
    
        $Query = $Predicate.PsObject.Properties.Value -join "`r`n"
        Write-Debug $Query

        Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential | ForEach-Object {

            @{
                DriverSerialNo = $_.DriverSerialNo
                # person
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
                International = [bool]$_.International
                # contact
                TelNo1 = $_.TelNo1 | nz
                TelNo1Comment = $_.TelNo1Comment | nz
                TelNo2 = $_.TelNo2 | nz
                TelNo2Comment = $_.TelNo2Comment | nz
                TelNo3 = $_.TelNo3 | nz
                TelNo3Comment = $_.TelNo3Comment | nz
                FaxNo = $_.FaxNo | nz
                FaxNoComment = $_.FaxNoComment | nz
                Email = $_.Email | nz
                # driver
                Base = $_.Base
                DriverID = $_.DriverID
                DriverType = $_.DriverType
                DateCreated = $_.DateCreated
                # license
                LicenceNumber = $_.LicenceNumber | nz
                LicenceValidFrom = $_.LicenceValidFrom | nz
                LicenceValidTo = $_.LicenceValidTo | nz
                # employment
                EmploymentStarted = $_.EmploymentStarted | nz
                EmploymentFinished = $_.EmploymentFinished | nz
                # flags
                Deleted = [bool]$_.Deleted
                PartTime = [bool]$_.PartTime
                Schedule = [bool]$_.Schedule
                SecondaryDriver = [bool]$_.SecondaryDriver
                Subcontractor = [bool]$_.Subcontractor
                Suspend = [bool]$_.Suspend
            }

        }
    }
    
    end {}

}