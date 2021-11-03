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
        [System.Nullable[datetime]]$DateOfBirth,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Female','Male')]
        [string]$Gender,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Address1,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Address2,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('City')]
        [string]$Address3,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('RegionCode')]
        [string]$Address4,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('PostalCode')]
        [string]$PostCode,

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
        [Alias('LicenseNumber')]
        [string]$LicenceNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('LicenseValidFrom')]
        [System.Nullable[datetime]]$LicenceValidFrom,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('LicenseValidTo')]
        [System.Nullable[datetime]]$LicenceValidTo,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CompanyID,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [datetime]$EmploymentStarted,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Nullable[datetime]]$EmploymentFinished,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$PayrollID,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Schedule,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime]$DateCreated = (Get-Date)
    )
        
    begin {
        # parameter definitions
        $Parameters = [System.Management.Automation.CommandMetadata]::new($MyInvocation.MyCommand).Parameters

        # remove parameters that shouldn't be include in the INSERT statement
        $ExcludedParameters =
            'ServerInstance','Database','Credential' +
            [System.Management.Automation.PSCmdlet]::CommonParameters + 
            [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
    }
    
    process {

        $PSBoundParameters.Keys | Where-Object {$ExcludedParameters -notcontains $_ } | ForEach-Object -Begin {
            $Keys = @()
            $Values = @()
        } -Process {

            $Key = $_
            Write-Debug ("{0}: {1}" -f $Key, $PSBoundParameters[$Key])

            switch ( $Parameters[$Key].ParameterType ) {
                {$_ -eq [bool]} { 
                    $Keys += $Key
                    $Values += $PSBoundParameters[$Key] ? [int]$PSBoundParameters[$Key] : 'NULL'
                }
                {$_ -in [datetime],[System.Nullable[datetime]]} { 
                    $Keys += $Key
                    $Values += $PSBoundParameters[$Key] ? "'$( $PSBoundParameters[$Key].ToString('MM/dd/yyyy') )'" : 'NULL'
                }
                {$_ -eq [string]} { 
                    $Keys += $Key
                    $Values += $PSBoundParameters[$Key] ? "'$( $PSBoundParameters[$Key] )'" : 'NULL'
                }
                Default {
                    $Keys += $Key
                    $Values += $PSBoundParameters[$Key] ? $PSBoundParameters[$Key] : 'NULL'
                }
            }

        }

        $Query = 
            "INSERT INTO Drivers ( $( $Keys -join ',' ) )
            VALUES ( $( $Values -join ',' ) )"
        Write-Debug $Query

        if ($pscmdlet.ShouldProcess('Drivers','Invoke-Sqlcmd'))
        {          
            Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $Database -Credential $Credential
        }

        $PSBoundParameters.Clear()

    }
    
    end {}

}