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
function Get-CoachManagerClient {

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName='ByClientId', Mandatory)]
        [Parameter(ParameterSetName='ByDate', Mandatory)]
        [string]$ServerInstance,

        [Parameter(ParameterSetName='ByClientId')]
        [Parameter(ParameterSetName='ByDate')]
        [string]$Database = 'Custom',

        [Parameter(ParameterSetName='ByClientId', Mandatory)]
        [Parameter(ParameterSetName='ByDate', Mandatory)]
        [pscredential]$Credential,

        [Parameter(ParameterSetName='ByClientId', Mandatory)]
        [string[]]$ClientId,

        [Parameter(ParameterSetName='ByDate')]
        [datetime]$FromDate,

        [Parameter(ParameterSetName='ByDate')]
        [datetime]$ToDate

    )

    Write-Debug $MyInvocation.MyCommand.Name

    Write-Debug "ServerInstance: $ServerInstance"
    Write-Debug "Database: $Database"
    Write-Debug "Credential.UserName: $($Credential.UserName)"

    Write-Debug "ClientId: $ClientId"

    Write-Debug "FromDate: $FromDate"
    Write-Debug "ToDate: $ToDate"

    $Predicate = [pscustomobject]@{
        SELECT = "SELECT *"
        FROM = "FROM PHCS..Clients"
        WHERE = "WHERE 1=1 AND NOT (Company IS NULL AND Surname IS NULL and FirstName IS NULL)"
        ORDER_BY = "ORDER BY ClientID"
    }

    if ( $ClientId ) { $Predicate.WHERE += "`r`nAND ClientId IN ('$( $ClientId -join "','" )')" }
    if ( $FromDate ) { $Predicate.WHERE += "`r`nAND LastUpdated >= '$FromDate'" }
    if ( $ToDate ) { $Predicate.WHERE += "`r`nAND LastUpdated <= '$ToDate'" }

    $Query = $Predicate.PsObject.Properties.Value -join "`r`n"
    Write-Debug $Query

    # execute query
    Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential | ForEach-Object {

        [pscustomobject]@{
            ClientSerialNo = $_.ClientSerialNo
            ClientID = $_.ClientID
            Company = $_.Company | nz
            Code1 = $_.Code1 | nz
            Code2 = $_.Code2 | nz
            Code3 = $_.Code3 | nz
            Code4 = $_.Code4 | nz
            Code5 = $_.Code5 | nz
            BookingType = $_.BookingType | nz
            Suspend = [bool]$_.Suspend
            Deleted = [bool]$_.Deleted
            DateCreated = $_.DateCreated
            LastUpdated = $_.LastUpdated
            Notes = $_.Notes | nz
            Contact = [pscustomobject]@{
                Title = $_.Title | nz
                FirstName = $_.FirstName | nz
                Surname = $_.Surname | nz
                TelNo1 = $_.TelNo1 | nz
                TelNo2 = $_.TelNo2 | nz
                TelNo3 = $_.TelNo3 | nz
                FaxNo = $_.FaxNo | nz
                Email = $_.Email | nz
                Address = [pscustomobject]@{
                    Address1 = $_.Address1 | nz
                    Address2 = $_.Address2 | nz
                    City = $_.Address3 | nz
                    RegionCode = $_.Address4 | nz
                    PostalCode = $_.PostCode | nz
                    CountryCode = $_.International -eq 0 ? 'US' : $null
                }
            }
        }

    }

}
