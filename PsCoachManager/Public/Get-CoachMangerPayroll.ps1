<#
.SYNOPSIS
Retrieves PHCS..Clients data and converts it to a PsCustomObject graph

.PARAMETER ClientID
Retrieve the specific Client using Coach Manager's ClientID

.PARAMETER FromDate
Retrieve Clients that have been created or modified after this date

.PARAMETER ToDate
Retrieve Clients that have been created or modified prior to this date

#>
function Get-CoachManagerPayroll {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ServerInstance,

        [Parameter()]
        [string]$Database = 'PHCS',

        [Parameter()]
        [pscredential]$Credential,

        [Parameter()]
        [datetime]$FromDate,

        [Parameter()]
        [datetime]$ToDate,

        [Parameter()]
        [string[]]$Company,

        [Parameter()]
        [string[]]$Driver
    )

    Write-Debug $MyInvocation.MyCommand.Name

    Write-Debug "ServerInstance: $ServerInstance"
    Write-Debug "Database: $Database"
    Write-Debug "Credential.UserName: $($Credential.UserName)"

    Write-Debug "FromDate: $FromDate"
    Write-Debug "ToDate: $ToDate"
    Write-Debug "Company: $Company"
    Write-Debug "Driver: $Driver"

    $Predicate = [pscustomobject]@{
        SELECT = "
            SELECT  *
            FROM
            (
                SELECT  v.DriverID, v.Surname, v.FirstName, d.EMail
                        ,v.PayrollID, v.PayrollCompanyID, PayrollProductionStartDate, PayrollProductionFinishDate, GrossPay
                        ,PayrollProductionDetailStartDateTime,PayrollProductionDetailFinishDateTime
                        ,BookingID, PayrollScheme, PayrollProductionDetailDescription
                        ,PayrollRateTitle, Quantity, Units, PayRate, Amount
                FROM    vwPayrollProductionCalculations01 v 
                INNER JOIN Drivers d on v.DriverID=d.DriverID
                WHERE   v.Total = 1
                AND     v.Suspend = 0
            ) v"
        WHERE = "WHERE   1=1"
        ORDER = "ORDER BY Surname, FirstName, PayrollProductionDetailStartDateTime"
    }

    if ( $FromDate ) { $Predicate.WHERE += "`r`nAND PayrollProductionStartDate = '$FromDate'" }
    if ( $ToDate ) { $Predicate.WHERE += "`r`nAND PayrollProductionFinishDate = '$ToDate'" }
    if ( $Driver ) { $Predicate.WHERE += "`r`nAND DriverID IN ('$( $Driver -join "','" )')" }
    if ( $Company ) { $Predicate.WHERE += "`r`nAND PayrollCompanyID IN ('$( $Company -join "','" )')" }

    $Query = $Predicate.PsObject.Properties.Value -join "`r`n"
    Write-Debug $Query

    # execute query
    Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential | Group-Object -Property { "{0}, {1}" -f $_.Surname, $_.FirstName } | ForEach-Object {

        $Payroll = @{
            FirstName = $_.Group[0].FirstName
            Surname = $_.Group[0].Surname
            EMail = $_.Group[0].EMail
            DriverID = $_.Group[0].DriverID
            PayrollID = $_.Group[0].PayrollID
            PayrollCompanyID = $_.Group[0].PayrollCompanyID
            PayrollProductionStartDate = $_.Group[0].PayrollProductionStartDate
            PayrollProductionFinishDate = $_.Group[0].PayrollProductionFinishDate
            GrossPay = $_.Group[0].GrossPay
            PayrollItem = @()
        }

        $_.Group | ForEach-Object {

            $Payroll.PayrollItem += [pscustomobject]@{
                BookingID = $_.BookingID
                PayrollScheme = $_.PayrollScheme
                PayrollProductionDetailDescription = $_.PayrollProductionDetailDescription
                PayrollRateTitle = $_.PayrollRateTitle
                Quantity = $_.Quantity
                Units = $_.Units
                PayRate = $_.PayRate
                Amount = $_.Amount
            }

        }

        [pscustomobject]$Payroll

    }

}
