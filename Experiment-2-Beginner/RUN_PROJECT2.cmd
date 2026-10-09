@echo off
setlocal
cd /d "%~dp0"
if not exist Build mkdir Build
call "%~dp0Tools\find_vivado.cmd"
if errorlevel 1 goto failed
echo Using: %VIVADO_BAT%
echo Running simulation, synthesis, routing, timing checks, and bitstream generation...
call "%VIVADO_BAT%" -mode batch -source "%~dp0Vivado\build_project.tcl" -log "%~dp0Build\vivado_build.log" -journal "%~dp0Build\vivado_build.jou"
if errorlevel 1 goto failed
if not exist "%~dp0Results\BUILD_SUCCESS.txt" goto failed
echo.
echo PROJECT 2 BUILD SUCCESS. Read START_HERE.md for board programming.
pause
exit /b 0
:failed
echo.
echo BUILD DID NOT COMPLETE. Send Results\BUILD_FAILED.txt and Build\vivado_build.log.
pause
exit /b 1
