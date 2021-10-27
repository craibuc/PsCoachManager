<#
.SYNPOSIS
Converts a [System.DBNull], a zero-length string, or 'white space' to a $null.  All other values returned unaltered.

.PARAMETER InputObject
The value to be tested and (potentially) converted.

.EXAMPLE
PS> [System.DBNull]::Value | nz
$null

.EXAMPLE
PS> '' | nz
$null

.EXAMPLE
PS> 'lorem ipsum' | nz
lorem ipsum

#>
function nz
{
    param(
        [Parameter(Position=0,ValueFromPipeline)]
        [object]$InputObject
    )

    switch ( $InputObject ) {
        { [System.DBNull]::Value.Equals($InputObject) } { $null }
        { $_ -is [string] -and [string]::IsNullOrWhiteSpace($_) } { $null }
        default { $InputObject }
    }

    # [System.DBNull]::Value.Equals($InputObject) ? $null : $InputObject

}