<#
.SYNOPSIS
Remove trailing space from PHCS..Clients.ClientId

#>
function Repair-CmClientId {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$ServerInstance,

        [Parameter()]
        [string]$Database = 'PHCS',

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $Query = 
        "UPDATE  $Database..Clients
        SET     ClientID = LTRIM(RTRIM( ClientID ))
        WHERE   RIGHT(ClientID,1)=' '"
    Write-Debug "Query: $Query"

    if ( $PSCmdlet.ShouldProcess('Clients.ClientID', "Invoke-Sqlcmd") )
    {
        Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential
    }
    
}
