cd %~dp0

REM Use this command if you already modified config file: config.csv
powershell -ExecutionPolicy ByPass -file %~n0.ps1 "" "" "" "" "" "" ""

REM Use this command if you want to specify the parameters
REM powershell -ExecutionPolicy ByPass -file %~n0.ps1

exit
