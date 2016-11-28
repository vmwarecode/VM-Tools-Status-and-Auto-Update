﻿#######################################################################################################################
# This file will be removed when PowerCLI is uninstalled. To make your own scripts run when PowerCLI starts, create a
# file named "Initialize-PowerCLIEnvironment_Custom.ps1" in the same directory as this file, and place your scripts in
# it. The "Initialize-PowerCLIEnvironment_Custom.ps1" is not automatically deleted when PowerCLI is uninstalled.
#######################################################################################################################
param([bool]$promptForCEIP = $false)

# List of modules to be loaded
$moduleList = @(
    "VMware.VimAutomation.Core",
    "VMware.VimAutomation.Vds",
    "VMware.VimAutomation.Cloud",
    "VMware.VimAutomation.PCloud",
    "VMware.VimAutomation.Cis.Core",
    "VMware.VimAutomation.Storage",
    "VMware.VimAutomation.HorizonView",
    "VMware.VimAutomation.HA",
    "VMware.VimAutomation.vROps",
    "VMware.VumAutomation",
    "VMware.DeployAutomation",
    "VMware.ImageBuilder",
    "VMware.VimAutomation.License"
    )

$productName = "PowerCLI"
$productShortName = "PowerCLI"

$loadingActivity = "Loading $productName"
$script:completedActivities = 0
$script:percentComplete = 0
$script:currentActivity = ""
$script:totalActivities = `
   $moduleList.Count + 1

function ReportStartOfActivity($activity) {
   $script:currentActivity = $activity
   Write-Progress -Activity $loadingActivity -CurrentOperation $script:currentActivity -PercentComplete $script:percentComplete
}
function ReportFinishedActivity() {
   $script:completedActivities++
   $script:percentComplete = (100.0 / $totalActivities) * $script:completedActivities
   $script:percentComplete = [Math]::Min(99, $percentComplete)
   
   Write-Progress -Activity $loadingActivity -CurrentOperation $script:currentActivity -PercentComplete $script:percentComplete
}

# Load modules
function LoadModules(){
   ReportStartOfActivity "Searching for $productShortName module components..."
   
   $loaded = Get-Module -Name $moduleList -ErrorAction Ignore | % {$_.Name}
   $registered = Get-Module -Name $moduleList -ListAvailable -ErrorAction Ignore | % {$_.Name}
   $notLoaded = $registered | ? {$loaded -notcontains $_}
   
   ReportFinishedActivity
   
   foreach ($module in $registered) {
      if ($loaded -notcontains $module) {
		 ReportStartOfActivity "Loading module $module"
         
		 Import-Module $module
		 
		 ReportFinishedActivity
      }
   }
}

LoadModules

# Update PowerCLI version after snap-in load
$powerCliFriendlyVersion = [VMware.VimAutomation.Sdk.Util10.ProductInfo]::PowerCLIFriendlyVersion
$host.ui.RawUI.WindowTitle = $powerCliFriendlyVersion

# Launch text
write-host "          Welcome to VMware $productName!"
write-host ""
write-host "Log in to a vCenter Server or ESX host:              " -NoNewLine
write-host "Connect-VIServer" -foregroundcolor yellow
write-host "To find out what commands are available, type:       " -NoNewLine
write-host "Get-VICommand" -foregroundcolor yellow
write-host "To show searchable help for all PowerCLI commands:   " -NoNewLine
write-host "Get-PowerCLIHelp" -foregroundcolor yellow  
write-host "Once you've connected, display all virtual machines: " -NoNewLine
write-host "Get-VM" -foregroundcolor yellow
write-host "If you need more help, visit the PowerCLI community: " -NoNewLine
write-host "Get-PowerCLICommunity" -foregroundcolor yellow
write-host ""
write-host "       Copyright (C) VMware, Inc. All rights reserved."
write-host ""
write-host ""

# CEIP
Try	{
	$configuration = Get-PowerCLIConfiguration -Scope Session

	if ($promptForCEIP -and
		$configuration.ParticipateInCEIP -eq $null -and `
		[VMware.VimAutomation.Sdk.Util10Ps.CommonUtil]::InInteractiveMode($Host.UI)) {

		# Prompt
		$caption = "Participate in VMware Customer Experience Improvement Program (CEIP)"
		$message = `
			"VMware's Customer Experience Improvement Program (`"CEIP`") provides VMware with information " +
			"that enables VMware to improve its products and services, to fix problems, and to advise you " +
			"on how best to deploy and use our products.  As part of the CEIP, VMware collects technical information " +
			"about your organization’s use of VMware products and services on a regular basis in association " +
			"with your organization’s VMware license key(s).  This information does not personally identify " +
			"any individual." +
			"`n`nFor more details: press Ctrl+C to exit this prompt and type `"help about_ceip`" to see the related help article." +
			"`n`nYou can join or leave the program at any time by executing: Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP `$true or `$false. "

		$acceptLabel = "&Join"
		$choices = (
			(New-Object -TypeName "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $acceptLabel,"Participate in the CEIP"),
			(New-Object -TypeName "System.Management.Automation.Host.ChoiceDescription" -ArgumentList "&Leave","Don't participate")
		)
		$userChoiceIndex = $Host.UI.PromptForChoice($caption, $message, $choices, 0)
		
		$participate = $choices[$userChoiceIndex].Label -eq $acceptLabel

		if ($participate) {
         [VMware.VimAutomation.Sdk.Interop.V1.CoreServiceFactory]::CoreService.CeipService.JoinCeipProgram();
      } else {
         Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false | Out-Null
      }
	}
} Catch {
	# Fail silently
}
# end CEIP

Write-Progress -Activity $loadingActivity -Completed




# SIG # Begin signature block
# MIIdVgYJKoZIhvcNAQcCoIIdRzCCHUMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiFvjXECgR4ldsk28XP0tOTO0
# eKigghhpMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggTRMIIDuaADAgECAhBlO8IY/xbhmnONwPCxJt5hMA0GCSqGSIb3DQEBCwUAMH8x
# CzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0G
# A1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMg
# Q2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMB4XDTE1MDcyNDAwMDAwMFoX
# DTE4MDgyMjIzNTk1OVowZDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3Ju
# aWExEjAQBgNVBAcTCVBhbG8gQWx0bzEVMBMGA1UEChQMVk13YXJlLCBJbmMuMRUw
# EwYDVQQDFAxWTXdhcmUsIEluYy4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDCmS07ZAwM9eVLBDfxw1rKIge6PZwfP8Xh2YSsyjzRUzzBouY4j7GTjM2e
# OZLiZhL+B32ps1BdfKJfSBaOein4ynaxVgCf9XuVWQKIZMzss+FJcf5gOk0dV/9t
# CHzIfoC81H1/PrnkX0uXRHcuz22m9FH9ggA3CLJPQlumTcxtqftNFSJsX0BT3Afg
# VDs/lsCEeY8VodT9AJzGGVGMz0YIB2J0gM8w9s9/1znjh4BFRp2AfrBk2Y0Ujoh2
# gaZEoLMfX1mI+QJdsKRNRt+lBerbyH93DupYJPviUavYiEg/b3+4xsYmkjq7dcNc
# ZTB93URHdg6ipSo3/R6B4PzUow5fAgMBAAGjggFiMIIBXjAJBgNVHRMEAjAAMA4G
# A1UdDwEB/wQEAwIHgDArBgNVHR8EJDAiMCCgHqAchhpodHRwOi8vc3Yuc3ltY2Iu
# Y29tL3N2LmNybDBmBgNVHSAEXzBdMFsGC2CGSAGG+EUBBxcDMEwwIwYIKwYBBQUH
# AgEWF2h0dHBzOi8vZC5zeW1jYi5jb20vY3BzMCUGCCsGAQUFBwICMBkMF2h0dHBz
# Oi8vZC5zeW1jYi5jb20vcnBhMBMGA1UdJQQMMAoGCCsGAQUFBwMDMFcGCCsGAQUF
# BwEBBEswSTAfBggrBgEFBQcwAYYTaHR0cDovL3N2LnN5bWNkLmNvbTAmBggrBgEF
# BQcwAoYaaHR0cDovL3N2LnN5bWNiLmNvbS9zdi5jcnQwHwYDVR0jBBgwFoAUljtT
# 8Hkzl699g+8uK8zKt4YecmYwHQYDVR0OBBYEFGaw3m9kanGu85olA8OJIdV3JXR/
# MA0GCSqGSIb3DQEBCwUAA4IBAQA27zm4ThfMqwr7AVYhk6efINp10t4N+ip4DxqQ
# t8Z+SSnPUeO23MmoUHFVWhJS57lgx0FVdAcUBdSmh/N7YvtoGfTOr4Q6k6Z6bjmV
# hUD3QIL77lGPGeotS8QIPeb9F5lX4Y/eiwRZ8254MFM0D2r+CgSVs123MS0zEZjF
# r7ychqVu77UXEuaQFDHkS1fEsiaRqrEnu8pNhcFVwZCzLJnn9DYOfpfgG8s8pwCF
# 2J6Cxs5MFPiO35OfZuXqRRx/7wlCIj6rcyb4sq62ksRA1On8OP6svY6AucSzTTFI
# SYrHImOnHnffhNrBogdf5uuwEuom3KoKMOt/0QqAXDt4cO9fMIIFWTCCBEGgAwIB
# AgIQPXjX+XZJYLJhffTwHsqGKjANBgkqhkiG9w0BAQsFADCByjELMAkGA1UEBhMC
# VVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBU
# cnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykgMjAwNiBWZXJpU2lnbiwgSW5jLiAt
# IEZvciBhdXRob3JpemVkIHVzZSBvbmx5MUUwQwYDVQQDEzxWZXJpU2lnbiBDbGFz
# cyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0aG9yaXR5IC0gRzUw
# HhcNMTMxMjEwMDAwMDAwWhcNMjMxMjA5MjM1OTU5WjB/MQswCQYDVQQGEwJVUzEd
# MBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVj
# IFRydXN0IE5ldHdvcmsxMDAuBgNVBAMTJ1N5bWFudGVjIENsYXNzIDMgU0hBMjU2
# IENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AJeDHgAWryyx0gjE12iTUWAecfbiR7TbWE0jYmq0v1obUfejDRh3aLvYNqsvIVDa
# nvPnXydOC8KXyAlwk6naXA1OpA2RoLTsFM6RclQuzqPbROlSGz9BPMpK5KrA6Dmr
# U8wh0MzPf5vmwsxYaoIV7j02zxzFlwckjvF7vjEtPW7ctZlCn0thlV8ccO4XfduL
# 5WGJeMdoG68ReBqYrsRVR1PZszLWoQ5GQMWXkorRU6eZW4U1V9Pqk2JhIArHMHck
# EU1ig7a6e2iCMe5lyt/51Y2yNdyMK29qclxghJzyDJRewFZSAEjM0/ilfd4v1xPk
# OKiE1Ua4E4bCG53qWjjdm9sCAwEAAaOCAYMwggF/MC8GCCsGAQUFBwEBBCMwITAf
# BggrBgEFBQcwAYYTaHR0cDovL3MyLnN5bWNiLmNvbTASBgNVHRMBAf8ECDAGAQH/
# AgEAMGwGA1UdIARlMGMwYQYLYIZIAYb4RQEHFwMwUjAmBggrBgEFBQcCARYaaHR0
# cDovL3d3dy5zeW1hdXRoLmNvbS9jcHMwKAYIKwYBBQUHAgIwHBoaaHR0cDovL3d3
# dy5zeW1hdXRoLmNvbS9ycGEwMAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL3MxLnN5
# bWNiLmNvbS9wY2EzLWc1LmNybDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUH
# AwMwDgYDVR0PAQH/BAQDAgEGMCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFTeW1h
# bnRlY1BLSS0xLTU2NzAdBgNVHQ4EFgQUljtT8Hkzl699g+8uK8zKt4YecmYwHwYD
# VR0jBBgwFoAUf9Nlp8Ld7LvwMAnzQzn6Aq8zMTMwDQYJKoZIhvcNAQELBQADggEB
# ABOFGh5pqTf3oL2kr34dYVP+nYxeDKZ1HngXI9397BoDVTn7cZXHZVqnjjDSRFph
# 23Bv2iEFwi5zuknx0ZP+XcnNXgPgiZ4/dB7X9ziLqdbPuzUvM1ioklbRyE07guZ5
# hBb8KLCxR/Mdoj7uh9mmf6RWpT+thC4p3ny8qKqjPQQB6rqTog5QIikXTIfkOhFf
# 1qQliZsFay+0yQFMJ3sLrBkFIqBgFT/ayftNTI/7cmd3/SeUx7o1DohJ/o39KK9K
# Er0Ns5cF3kQMFfo2KwPcwVAB8aERXRTl4r0nS1S+K4ReD6bDdAUK75fDiSKxH3fz
# vc1D1PFMqT+1i4SvZPLQFCEwggWaMIIDgqADAgECAgphGZPkAAAAAAAcMA0GCSqG
# SIb3DQEBBQUAMH8xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# KTAnBgNVBAMTIE1pY3Jvc29mdCBDb2RlIFZlcmlmaWNhdGlvbiBSb290MB4XDTEx
# MDIyMjE5MjUxN1oXDTIxMDIyMjE5MzUxN1owgcoxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0
# d29yazE6MDgGA1UECxMxKGMpIDIwMDYgVmVyaVNpZ24sIEluYy4gLSBGb3IgYXV0
# aG9yaXplZCB1c2Ugb25seTFFMEMGA1UEAxM8VmVyaVNpZ24gQ2xhc3MgMyBQdWJs
# aWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAtIEc1MIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAryQICCl6NZ5gDKrnSztO3Hy8PEUcuyvg
# /ikC+VcIo2SFFSf18a3IMYldIugqqqZCs4/4uVW3sbdLs/6PfgdX7O9D22ZiFWHP
# YA2k2N744MNiCD1UE+tJyllUhSblK48bn+v1oZHCM0nYQ2NqUkvSj+hwUU3RiWl7
# x3D2s9wSdNt7XUtW05a/FXehsPSiJfKvHJJnGOX0BgTvkLnkAOTdOrUZ/wK69Dzu
# 4IvrN4vs9Nes8vbwPa/ddZEzGR0cQMt0JBkhk9kU/qwqUseP1QRJ5I1jR4g8aYPL
# /ke9K35PxZWuDp3U0UPAZ3PjFAh+5T+fc7gzCs9dPzSHloruU+glFQIDAQABo4HL
# MIHIMBEGA1UdIAQKMAgwBgYEVR0gADAPBgNVHRMBAf8EBTADAQH/MAsGA1UdDwQE
# AwIBhjAdBgNVHQ4EFgQUf9Nlp8Ld7LvwMAnzQzn6Aq8zMTMwHwYDVR0jBBgwFoAU
# YvsKIVt/Q24R2glUUGv10pZx8Z4wVQYDVR0fBE4wTDBKoEigRoZEaHR0cDovL2Ny
# bC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljcm9zb2Z0Q29kZVZl
# cmlmUm9vdC5jcmwwDQYJKoZIhvcNAQEFBQADggIBAIEqghaMNGcr5QPrNHuMoqNQ
# ivRVhvEejI6ufe4DGc5ylRhIrWIR/SD9P0cGAVri4G+MFSxOPGpQbAs2o896DZxC
# vFz4GdVg42nm4iNBZ4xog3Yrj5OjKrV/vln7qcmyJo/KovOCG5g+kZUnl4Zh7ltd
# B2vNhqjiZYCo4hXisr4jBWq6DPNHk02spIwHeTnAYRI6BQ2Jo+yfV4mE++zKfEdm
# FJHYtg8ZXea4Sqy8R8hxQ5bmMiCl3HeG/Tzji3Hbe5sD/LcdMmTrFlKgQ6P6Lq1Z
# kk58x/IzQkg4UTp8OMcbJCIoQB4aRh8X2xj38Cc1bLhj2c25ZF0rpV7vxim08sf4
# IcwEulf9Abarxmf559OZf/T1Ivpy9f3/OhxCOqH5gBil7o0c1GaeRQH+qu7/+xeP
# MPfxzSnFney11UkAPYW4y7uTOidqScAwrmbJ9yMoMnb5pINWyEjOWpaqoMwMxH+0
# jpevbeNUJ8OfhsDW5HMIlwXb0FRiXgNIwtWff6dmjNCdsE/U05hfS3rJf7IpUtAS
# gMcPVLYeZ83GoGwRA4TTSHXnKv6wO24KOqZrdpkFo/F3aGEzFEcG/FN/Ur2SFFxK
# JGpnjK+NkKrQ9nkhG5MmfMPOHr2IOJKuRcYZaklQswX4rlk3imolA5SxWYFQ6LqD
# gLcjNfR2uWcdWRitII2UMYIEVzCCBFMCAQEwgZMwfzELMAkGA1UEBhMCVVMxHTAb
# BgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBU
# cnVzdCBOZXR3b3JrMTAwLgYDVQQDEydTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBD
# b2RlIFNpZ25pbmcgQ0ECEGU7whj/FuGac43A8LEm3mEwCQYFKw4DAhoFAKCBijAZ
# BgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYB
# BAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUR0eRMtpzL1P4NIKMD9ceTahG6XkwKgYK
# KwYBBAGCNwIBDDEcMBqhGIAWaHR0cDovL3d3dy52bXdhcmUuY29tLzANBgkqhkiG
# 9w0BAQEFAASCAQA4zN2wZqoR2TH+XtZdBfMePaaXAw33iZLj7Plr7E+zs7SaLV9x
# CK3ikVAvLsOP4MsTb1SS6V8LaXRhAfnAApV8pdq/cN/zYai61stl4Z5rkUAzaxxf
# rA7yrYb9yo/LczkfMiV8humy0G4ukjC0HbdmMcj4JzmUfQRgbjK38H+pBiIjBoRk
# 31inqkCpCmMMJxpwRac5CYVtA/sqIq/KbZsgyZ911fkpe8x3uH5sWzdn6xvKmltA
# htr86cq5dzbW4MjBEgmaHp7/lRMsTYQd4p5id7ITFlB68zK00zHQZXyHsQrQFN1u
# UG/1RE9ibkWF9JH9JROvobriiI8dwmc0d+ACoYICCzCCAgcGCSqGSIb3DQEJBjGC
# AfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENv
# cnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZp
# Y2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2MTEwNTAyMTEy
# NFowIwYJKoZIhvcNAQkEMRYEFPy1ZwpWpFCsbJirPmKIk7+xqHCVMA0GCSqGSIb3
# DQEBAQUABIIBAI2Hcdj3Y6a00rn5LHP2X58yYyMtV/0o9rSI3283HTic5C8ukJrX
# bMD9PCX97fpIcLzpZF9HgvLq245XOOUKp44J2uEQBm7KaSlyi28lJgy9yENz2YGH
# t+aCa4kDQ2uEQ5oGOV9sGNs6X4re4zThGJQnkajbzBzysOl3CHz0ZFjoE4TOVaYx
# Fv/JBaWZBoCWbA0K+qBiWNMDFH2oC4zbrfNhNfEqDq1AmY8l7sU/necfqTix1S8w
# 9D2ocS1kkn6PPAlxDQOe6U063+cMSNcl35ye+52FUbORmlbSXZynPwDnCg12SBSk
# WaGj4Gg9NpFkejn5JNunxyclZq8qLB8pALc=
# SIG # End signature block
