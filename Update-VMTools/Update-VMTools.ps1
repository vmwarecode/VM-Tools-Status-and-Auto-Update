
param(
 [Parameter(Mandatory=$True, HelpMessage="Enter VC Address, support both FQDN and IP")]
 [AllowEmptyString()] [String]  $vcServer ,
 [Parameter(Mandatory=$True, HelpMessage="Enter User for VC")]
 [AllowEmptyString()] [String]  $vcUser ,
 [Parameter(Mandatory=$True, HelpMessage="Enter Password for VC")]
 [AllowEmptyString()] [String]  $vcPassword ,
 [Parameter(Mandatory=$True, HelpMessage="Enter Location (Host or Resource Pool) of VM, can be such as '*' or '10.111.*.*'.")]
 [AllowEmptyString()] [String]  $vmLocation ,
 [Parameter(Mandatory=$True, HelpMessage="Enter User for VM")]
 [AllowEmptyString()] [String]  $vmUser ,
 [Parameter(Mandatory=$True, HelpMessage="Enter Password for VM")]
 [AllowEmptyString()] [String]  $vmPassword ,
 [Parameter(Mandatory=$True, HelpMessage="Enter VM Name patten such as 'Win7vm', support '*Win7*'.")]
 [AllowEmptyString()] [String]  $vmName ,
 [Parameter(Mandatory=$True, HelpMessage="Enter Language Code, support 'cn/de/en/es/fr/ja/ko/tw'.")]
 [AllowEmptyString()] [String]  $vmLang 
 
)

# Log Output
$myLog = ".\" + $lang + "\" + $MyInvocation.MyCommand.Name.split('.')[0] + $lang + ".log"
if (-Not (Test-Path $myLog)) {New-Item $myLog -itemtype file -Force}
Start-Transcript $myLog -Force

$cfgcsv = ".\config.csv"
if ( $vmLang -ne "") { $cfgcsv = $cfgcsv + $vmLang}
$csvdata = import-csv $cfgcsv
if ( $vcServer -eq "" ) { $vcServer= $csvdata.vcServer}
if ( $vcUser -eq "" ) { $vcUser = $csvdata.vcUser }
if ( $vcPassword -eq "" ) { $vcPassword = $csvdata.vcPassword }
if ( $vmLocation -eq "" ) { $vmLocation = $csvdata.vmLocation}
if ( $vmUser -eq "" ) { $vmUser = $csvdata.vmUser }
if ( $vmPassword -eq "" ) { $vmPassword = $csvdata.vmPassword }
if ( $vmName -eq "" ) { $vmName = $csvdata.vmName }
# Need to escape special characters such as $ by `$

#Write-Host "Connect to VC."
.\ConnectTo-VC.ps1 -vcServer $vcServer -vcUser $vcUser -vcPassword $vcPassword

Write-Host "Try to update tools on each VM with old tools"
Import-Module .\Get-VMToolsStatus.psm1
$allvms = Get-VM -Name $vmName -Location $vmLocation 
$myvms = Get-VMToolsStatus -vmName $vmName -vmLocation $vmLocation  -Filter NeedUpgrade

if (($myvms -eq $null) -Or ($myvms -eq "")) {
	Write-Host ("No VMs in NeedUpgrade status. For the VMs without tools, you need to perform Manual Install, checked VMs below `r`n", $allvms)
}
else {
	Write-Host "Try to update tools on each VM."
	foreach ($myvm in $myvms) {
		if ($myvm.PowerState -eq "PoweredOff") { 
			Write-Host ("Try to power on ", $myVM.VM, ", we wait for VM tools for 600s.")
			Start-VM -VM $myVM.VM
			Wait-Tools -VM $myVM.VM -TimeoutSeconds 600
		}
		Update-Tools -VM $myVM.VM -RunAsync
	}

	Write-Host "We wait for 300s in case network delay before Tool image attached for upgrading."
	Start-Sleep -s 300 
	
	foreach ($myvm in $myvms) {
		Wait-Tools -VM $myVM.VM -TimeoutSeconds 600
		if ($myvm.PowerState -eq "PoweredOff") { 
			Stop-VMGuest -VM $myvm.VM -Confirm:$false
		}
	}
	
	Write-Host ("Upgrading Done. Checked VMs below `r`n", $allvms, ".`r`nUpgraded VMs below `r`n", $myvms.VM)
}

# log End
Stop-Transcript