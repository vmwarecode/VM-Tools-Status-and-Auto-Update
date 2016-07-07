Set-Variable powercli_snapin_name "VMware.VimAutomation.Core" -scope Private
Set-Variable powercli_product_name "VI Toolkit / VSphere PowerCLI" -scope Private

# Load VI Toolkit/PowerCLI if available
$VimAutomationInstalled = Get-PSSnapin -Registered | Where { $_.Name -eq $powercli_snapin_name }
if($VimAutomationInstalled){
	$VimAutomationLoaded = Get-PSSnapin | Where { $_.Name -eq $powercli_snapin_name }
	if(!$VimAutomationLoaded){
		write-host "Loading $powercli_product_name"
		add-PSSnapin $powercli_snapin_name
	} else {
		write-host "$powercli_product_name already loaded"
	}
}

Remove-Variable powercli_snapin_name -scope Private
Remove-Variable powercli_product_name -scope Private
