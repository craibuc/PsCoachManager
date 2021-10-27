<#
.SYNOPSIS
Make changes to an existing driver record.

.PARAMETER ServerInstance
The database server's address.

.PARAMETER Database
The name of the database; defaults to 'PHCS'.

.PARAMETER Credential
A PsCredenial representing valid database credentials.

.PARAMETER DriverSerialNo
The primary key for the PHCS..Drivers table.

.PARAMETER DriverID

.PARAMETER DriverType

.PARAMETER Title

.PARAMETER FirstName

.PARAMETER Surname

.PARAMETER DateOfBirth

.PARAMETER Gender

.PARAMETER Address1

.PARAMETER Address2

.PARAMETER City

.PARAMETER RegionCode

.PARAMETER PostalCode

.PARAMETER CellularPhone

.PARAMETER HomePhone

.PARAMETER EMail

.PARAMETER LicenseNumber

.PARAMETER LicenseValidFrom

.PARAMETER LicenseValidTo

.PARAMETER CompanyID

.PARAMETER EmploymentStarted

.PARAMETER EmploymentFinished

.PARAMETER PayrollID

.PARAMETER Schedule

.EXAMPLE

Set-CoachManagerDriver -DriverSerialNo 1000 -DriverID 'ABCDEF' -DriverType 'Regular' -FirstName 'First' -Surname 'Last' -EmploymentStarted '10/01/2021'
                        
Update driver record, supplying mandatory fields, using explicit parameter values.

.EXAMPLE

$Driver = @{
    DriverSerialNo=1000
    DriverID='ABCDEF'
    DriverType='Regular'
    FirstName='First'
    Surname='Last'
    EmploymentStarted='10/01/2021'
    Email=$null
}
Set-CoachManagerDriver @Driver

Update driver record, supplying mandatory fields, using 'splatted' parameter values.

.EXAMPLE

[pscustomobject]@{
    DriverSerialNo=1000
    DriverID='ABCDEF'
    DriverType='Regular'
    FirstName='First'
    Surname='Last'
    EmploymentStarted='10/01/2021'
} | Set-CoachManagerDriver

Update driver record, supplying mandatory fields, using the pipeline.
#>

function Set-CoachManagerDriver {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$ServerInstance,
        
        [Parameter()]
        [string]$Database='PHCS',

        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [int]$DriverSerialNo,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$DriverID,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$DriverType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Title,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$FirstName,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$Surname,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Nullable[datetime]]$DateOfBirth,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Female','Male')]
        [string]$Gender,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Address1,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Address2,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$City,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RegionCode,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$PostalCode,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CellularPhone,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$HomePhone,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$EMail,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LicenseNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Nullable[datetime]]$LicenseValidFrom,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Nullable[datetime]]$LicenseValidTo,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CompanyID,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [System.Nullable[datetime]]$EmploymentStarted,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Nullable[datetime]]$EmploymentFinished,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$PayrollID,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Schedule
    )
    
    begin {
        $Parameters = [System.Management.Automation.CommandMetadata]::new($MyInvocation.MyCommand).Parameters
    }
    
    process {

        # $Clone =  ([PSCustomObject]$PSBoundParameters)

        # remove parameters that shouldn't be include in the SET statement
        $ExcludedParameters =
            'ServerInstance','Database','Credential','DriverSerialNo' +
            [System.Management.Automation.PSCmdlet]::CommonParameters + 
            [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

        # debug
        # $a = $PSBoundParameters

        $Set = $PSBoundParameters.Keys | Where-Object {$ExcludedParameters -notcontains $_ } | ForEach-Object {
            
            $Key = $_
            Write-Debug ("{0}: {1}" -f $Key, $PSBoundParameters[$Key])

            switch ( $Parameters[$Key].ParameterType ) {
                {$_ -eq [bool]} { 
                    "{0}={1}" -f $Key, ($PSBoundParameters[$Key] ? [int]$PSBoundParameters[$Key] : 'NULL')
                }
                {$_ -eq [System.Nullable[datetime]] } {
                    "{0}={1}" -f $Key, ($PSBoundParameters[$Key] ? "'" + $PSBoundParameters[$Key].ToString('MM/dd/yyyy') + "'" : 'NULL')
                }
                {$_ -eq [string]} { 
                    "{0}={1}" -f $Key, ($PSBoundParameters[$Key] ? "'" + $PSBoundParameters[$Key] + "'" : 'NULL')
                }
                Default {
                    "{0}={1}" -f $Key, ($PSBoundParameters[$Key] ? $PSBoundParameters[$Key] : 'NULL')
                }
            }

        }

        $Predicate = [pscustomobject]@{
            UPDATE = "UPDATE  $Database..Drivers"
            SET = "SET  {0}" -f ($Set -join ',')
            WHERE = "WHERE  DriverSerialNo=$DriverSerialNo"
        }

        $Query = $Predicate.PsObject.Properties.Value -join "`r`n"
        Write-Debug $Query

        if ($pscmdlet.ShouldProcess("DriverSerialNo: $DriverSerialNo","Update $Database..Drivers"))
        {
            Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential
        }

        $PSBoundParameters.Clear()

    }
    
    end {}

}