<#
.SYNOPSIS
Test the database's connectivity.

#>
function Test-SqlConnection 
{

    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$Database,

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $SavedErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    try 
    {
        $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName, $DatabaseName, $Credential.UserName, ( $Credential.Password | ConvertFrom-SecureString -AsPlainText )

        $sqlConnection = [System.Data.SqlClient.SqlConnection]::new($ConnectionString)
        $sqlConnection.Open()

        $true
    } 
    catch 
    {
        $false
    } 
    finally 
    {
        $ErrorActionPreference = $SavedErrorActionPreference
        $sqlConnection.Close()
    }
}