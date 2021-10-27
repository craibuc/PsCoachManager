function New-CoachManagerDriver {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$ServerInstance,
        
        [Parameter()]
        [string]$Database = 'PHCS',

        [Parameter(Mandatory)]
        [pscredential]$Credential,

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
        [datetime]$DateOfBirth,

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
        [string]$TelNo1,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$TelNo1Comment,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$TelNo2,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$TelNo2Comment,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$TelNo3,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$TelNo3Comment,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$FaxNo,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$FaxNoComment,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$EMail,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LicenseNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime]$LicenseValidFrom,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime]$LicenseValidTo,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CompanyID,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [datetime]$EmploymentStarted,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime]$EmploymentFinished,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$PayrollID,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Schedule
    )
        
    begin {
        $Parameters = [System.Management.Automation.CommandMetadata]::new($MyInvocation.MyCommand).Parameters
        $Parameters.Remove('ServerInstance')
        $Parameters.Remove('Database')
        $Parameters.Remove('Credential')
    }
    
    process {

        $Parameters.Keys | ForEach-Object -Begin {

            $Values=@()

        } -Process {

            $Key = $_

            switch ( $Parameters[$Key].ParameterType ) {
                'bool' { 
                    $Value = $PSBoundParameters[$Key] ? [int]$PSBoundParameters[$Key] : 'NULL'
                }
                'datetime' { 
                    $Value = $PSBoundParameters[$Key] ? "'$( $PSBoundParameters[$Key].ToString('MM/dd/yyyy') )'" : 'NULL'
                }
                'string' { 
                    $Value = $PSBoundParameters[$Key] ? "'$( $PSBoundParameters[$Key] )'" : 'NULL'
                }
                Default {
                    $Value = $PSBoundParameters[$Key] ? $PSBoundParameters[$Key] : 'NULL'
                }
            }
            $Values += $Value
        }

        $Query = 
            "INSERT INTO $Database..Drivers ( $( $Parameters.Keys -join ',' ) )
            VALUES ( $( $Values -join ',' ) )"
        Write-Debug $Query

        if ($pscmdlet.ShouldProcess('Drivers','Invoke-Sqlcmd'))
        {          
            Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential
        }

    }
    
    end {}

}