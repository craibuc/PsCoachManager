<#
.SYNOPSIS
Return records from PHCS..PrivateHireMovements table and its associated entities.

#>
function Get-CoachManagerPrivateHireMovement {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ServerInstance,
        
        [Parameter()]
        [string]$Database = 'PHCS',

        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter(ParameterSetName='BySerialNo',Mandatory)]
        [int]$ID,

        [Parameter(ParameterSetName='ByQuery')]
        [string]$BookingType,
        [Parameter(ParameterSetName='ByQuery')]
        [datetime]$StartingDateTime,
        [Parameter(ParameterSetName='ByQuery')]
        [datetime]$EndingDateTime
    )
    
    begin {}
    
    process {
        
        $Predicate = [pscustomobject]@{
            SELECT =
                "SELECT  *
                FROM
                (
                    SELECT  d.DriverSerialNo, d.DriverID, d.Surname, d.FirstName, d.EMail, d.TelNo1
                            ,ph.PrivateHireID, ph.BookingType
                            ,phm.PrivateHireMovementID, phm.StartDateTime, phm.Pickup
                    FROM    PrivateHireMovements phm
                    INNER JOIN PrivateHires ph ON phm.PrivateHireID=ph.PrivateHireID
                    INNER JOIN PrivateHireVehicles phv ON phm.PrivateHireMovementID=phv.PrivateHireMovementID
                    LEFT OUTER JOIN vehicles v ON phv.VehicleID=v.VehicleID
                    INNER JOIN PrivateHireDrivers phd ON phv.PrivateHireVehicleID=phd.PrivateHireVehicleID
                    INNER JOIN Drivers d ON phd.DriverID=d.DriverID
                    WHERE   ph.Cancelled = 0
                    AND     ph.Status = 'Firm'
                    AND     phm.cancelled = 0
                ) v"
            WHERE = "WHERE 1=1"
            ORDER = 'ORDER BY DriverID, StartDateTime'
        }
    
        if ( $BookingType ) { $Predicate.WHERE += ("`r`nAND BookingType IN ('{0}')" -f $BookingType -join "','") }
        if ( $StartingDateTime ) { $Predicate.WHERE += "`r`nAND StartDateTime >= '$StartingDateTime'" }
        if ( $EndingDateTime ) { $Predicate.WHERE += "`r`nAND StartDateTime <= '$EndingDateTime'" }

        $Query = $Predicate.PsObject.Properties.Value -join "`r`n"
        Write-Debug $Query

        Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential | ForEach-Object {

            @{
                # 
                PrivateHireMovementID = $_.PrivateHireMovementID
                StartDateTime = $_.StartDateTime
                Pickup = $_.Pickup
                # driverx
                DriverID = $_.DriverID
                DriverSerialNo = $_.DriverSerialNo
                FirstName = $_.FirstName #| nz
                Surname = $_.Surname #| nz
                # contact
                TelNo1 = $_.TelNo1 #| nz
                Email = $_.Email #| nz
            }

        }
    }
    
    end {}

}