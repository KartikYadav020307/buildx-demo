@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
if not exist "Results" mkdir "Results"
set "P5_VIVADO="
if not "%~1"=="" set "P5_VIVADO=%~1"
if defined P5_VIVADO goto check_tool
for %%P in (
    "C:\Xilinx\Vivado\2025.1.1\bin\vivado.bat"
    "C:\Xilinx\2025.1.1\Vivado\bin\vivado.bat"
    "C:\AMDDesignTools\2025.1.1\Vivado\bin\vivado.bat"
    "C:\Xilinx\Vivado\2025.1\bin\vivado.bat"
    "C:\Xilinx\2025.1\Vivado\bin\vivado.bat"
    "C:\AMDDesignTools\2025.1\Vivado\bin\vivado.bat"
) do if not defined P5_VIVADO if exist "%%~P" set "P5_VIVADO=%%~P"
if defined P5_VIVADO goto check_tool
for /f "delims=" %%P in ('where vivado.bat 2^>nul') do if not defined P5_VIVADO set "P5_VIVADO=%%P"
:check_tool
if not defined P5_VIVADO goto missing_tool
if not exist "%P5_VIVADO%" goto missing_tool
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Vivado\preflight.ps1" -Root "%~dp0."
if errorlevel 1 goto preflight_failed
for /f "delims=" %%T in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss_fff"') do set "P5_STAMP=%%T"
if not defined P5_STAMP goto preflight_failed
set "P5_RESULTS=%~dp0Results\run_%P5_STAMP%"
if exist "%P5_RESULTS%" goto preflight_failed
mkdir "%P5_RESULTS%"
echo Project 5: simulation, synthesis, implementation and report collection.
echo Vivado: "%P5_VIVADO%"
echo Leave this window open until the build finishes.
call "%P5_VIVADO%" -mode batch -source "%~dp0Vivado\run_all.tcl" -log "%P5_RESULTS%\vivado_batch.log" -journal "%P5_RESULTS%\vivado_batch.jou" -tclargs "%P5_RESULTS%"
set "P5_EXIT=%ERRORLEVEL%"
if not "%P5_EXIT%"=="0" goto build_failed
if not exist "%P5_RESULTS%\BUILD_SUCCESS.txt" goto build_failed
echo.
type "%P5_RESULTS%\BUILD_SUCCESS.txt"
echo Open build\BNN_Safety.xpr in Vivado for the Hardware Manager demo.
pause
exit /b 0
:missing_tool
echo Could not locate Vivado 2025.1.1 or 2025.1.
echo Run this launcher with your actual vivado.bat path, for example:
echo RUN_PROJECT5.cmd "D:\AMDDesignTools\2025.1.1\Vivado\bin\vivado.bat"
pause
exit /b 1
:build_failed
echo.
echo BUILD FAILED. Read "%P5_RESULTS%\vivado_batch.log".
if exist "%P5_RESULTS%\BUILD_FAILED.txt" type "%P5_RESULTS%\BUILD_FAILED.txt"
echo Keep the log so the exact failure can be diagnosed.
pause
exit /b 1

:preflight_failed
echo Package preflight failed. Extract the complete ZIP again in a new folder.
pause
exit /b 1
