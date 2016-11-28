Author: Peter Tan  (tanp@vmware.com)
Version: 1.1 on 2016/11/18
Changes: 
	a: Add More Set Support to config files by $Lang
	b: Update Initialize-PowerCLIEnvironment.ps1 to load VI Toolkit
	c: Performance/Stablility Update

=========================
Note: this tools is to upgrade tools of specified VMs with Name or Location (Host/Resource Pool/Datastore)
      Even for the VMs which are powered off, it will auto power on, update tools and then power off them.

Dependency:
This tools is based on vSphere PowerCLI: https://www.vmware.com/support/developer/PowerCLI/

Files and Functions:
1, Initialize-PowerCLIEnvironment.ps1		It will auto load VI Toolkit / VSphere PowerCLI
2, ConnectTo-VC.ps1		It will help log on to vCenter Server
3, Get-VMToolsStatus.ps1	It is module to check VMTools Status.
4, Update-VMTools.ps1		It is script to bulk update tools
5, Update-VMTools.bat		It is batch for one click execution
6, config.csv			It is the config file to support one click login and execution
7, Readme.txt			This file for help.

Usage:
1, For one click execution with config.csv: 
A: Modify config.csv first, you need to specify correct vcServer,vcUser,vcPassword,vmLocation,vmUser,vmPassword,vmName
B: Double Click Update-VMTools.bat or execute by Administrator if error to load VSphere PowerCLI

2, To specify certain parameter during execution, such as vmName or vmLocation patten which by default is *:
A: Modify Update-VMTools.bat and comment current powershell command line and uncomment line.
   powershell -ExecutionPolicy ByPass -file %~n0.ps1 "" "" "" "" "" "" "" %1
   -->
   REM powershell -ExecutionPolicy ByPass -file %~n0.ps1 "" "" "" "" "" "" ""

   REM powershell -ExecutionPolicy ByPass -file %~n0.ps1
   -->
   powershell -ExecutionPolicy ByPass -file %~n0.ps1
B: Double Click Update-VMTools.bat or execute by Administrator if error to load VSphere PowerCLI
C: Specify certain parameters. Leave blank for the ones which already set in config file.
