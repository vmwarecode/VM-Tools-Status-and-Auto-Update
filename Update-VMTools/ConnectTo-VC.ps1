param(
 [Parameter(Mandatory=$True, HelpMessage="Enter VC Address, support both FQDN and IP")]
 [AllowEmptyString()] [String]  $vcServer ,
 [Parameter(Mandatory=$True, HelpMessage="Enter User for VC")]
 [AllowEmptyString()] [String]  $vcUser ,
 [Parameter(Mandatory=$True, HelpMessage="Enter Password for VC")]
 [AllowEmptyString()] [String]  $vcPassword
)

.\Initialize-PowerCLIEnvironment.ps1 $true

$csvdata = import-csv .\config.csv
if ( $vcServer -eq "" ) { $vcServer= $csvdata.vcServer}
if ( $vcUser -eq "" ) { $vcUser = $csvdata.vcUser }
if ( $vcPassword -eq "" ) { $vcPassword = $csvdata.vcPassword }
# Need to escape special characters such as $ by `$

Write-Host "Connecting to VC..."
Connect-VIServer -Server $vcServer -User $vcUser -Password $vcPassword


