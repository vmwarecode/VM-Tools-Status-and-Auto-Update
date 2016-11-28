REM Use this command if you want to specify the parameters
REM Use this command if you already modified config file: config.csv
REM powershell -ExecutionPolicy ByPass -file %~n0.ps1
cd %~dp0
powershell -ExecutionPolicy ByPass -file %~n0.ps1 "" "" "" "" "" "" "" %1
exit

