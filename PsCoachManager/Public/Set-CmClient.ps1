<#
.SYNOPSIS
Updates a PHCS..Clients

.PARAMETER ClientID
Retrieve the specific Client using Coach Manager's ClientID

#>
function Set-CmClient {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$ServerInstance,

        [Parameter()]
        [string]$Database = 'PHCS',

        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter(Mandatory)]
        [int]$ClientSerialNo,

        [Parameter()]
        [string]$ClientId
    )

    begin {}

    process {

        $Query = 
        "UPDATE  $Database..Clients
        SET     ClientID = $ClientId
        WHERE   ClientSerialNo = $ClientSerialNo"
        Write-Debug "Query: $Query"

        if ( $PSCmdlet.ShouldProcess( "ClientSerialNo: $ClientSerialNo", 'Invoke-Sqlcmd') )
        {
            Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential
        }

    }

    end {}

}