@echo off
setlocal
cd /d "%~dp0"
where vivado >nul 2>nul
if errorlevel 1 (
 echo Open the Vivado Tcl Shell from the Start menu.
 echo Then cd to this extracted folder and run:
 echo vivado -mode batch -source BUILD_REPAIRED.tcl
 pause
 exit /b 1
)
call vivado -mode batch -source BUILD_REPAIRED.tcl -log repair_build.log -journal repair_build.jou
set "repair_exit=%errorlevel%"
if not "%repair_exit%"=="0" echo BUILD FAILED. Read repair_build.log and the routed report if present.
pause
exit /b %repair_exit%
