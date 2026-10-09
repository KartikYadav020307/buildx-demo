@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
if not exist "Results" mkdir "Results"
set "NN_VIVADO="
if not "%~1"=="" set "NN_VIVADO=%~1"
if defined NN_VIVADO goto check_tool
for %%P in (
    "C:\Xilinx\Vivado\2025.1.1\bin\vivado.bat"
    "C:\Xilinx\2025.1.1\Vivado\bin\vivado.bat"
    "C:\AMDDesignTools\2025.1.1\Vivado\bin\vivado.bat"
    "C:\Xilinx\Vivado\2025.1\bin\vivado.bat"
    "C:\Xilinx\2025.1\Vivado\bin\vivado.bat"
    "C:\AMDDesignTools\2025.1\Vivado\bin\vivado.bat"
) do if not defined NN_VIVADO if exist "%%~P" set "NN_VIVADO=%%~P"
if defined NN_VIVADO goto check_tool
for /f "delims=" %%P in ('where vivado.bat 2^>nul') do if not defined NN_VIVADO set "NN_VIVADO=%%P"
:check_tool
if not defined NN_VIVADO goto missing_tool
if not exist "%NN_VIVADO%" goto missing_tool
if exist "Results\BUILD_SUCCESS.txt" del "Results\BUILD_SUCCESS.txt"
echo Project 4: simulation, synthesis, implementation and report collection.
echo Vivado: "%NN_VIVADO%"
echo Leave this window open until the build finishes.
call "%NN_VIVADO%" -mode batch -source "%~dp0Vivado\run_all.tcl" -log "%~dp0Results\vivado_batch.log" -journal "%~dp0Results\vivado_batch.jou"
set "NN_EXIT=%ERRORLEVEL%"
if not "%NN_EXIT%"=="0" goto build_failed
if not exist "Results\BUILD_SUCCESS.txt" goto build_failed
echo.
type "Results\BUILD_SUCCESS.txt"
echo Open build\NN_Inference.xpr in Vivado for the Hardware Manager demo.
pause
exit /b 0
:missing_tool
echo Could not locate Vivado 2025.1.1 or 2025.1.
echo Run this launcher with your actual vivado.bat path, for example:
echo RUN_PROJECT4.cmd "D:\AMDDesignTools\2025.1.1\Vivado\bin\vivado.bat"
pause
exit /b 1
:build_failed
echo.
echo BUILD FAILED. Read Results\vivado_batch.log.
if exist "Results\BUILD_FAILED.txt" type "Results\BUILD_FAILED.txt"
echo Keep the log so the exact failure can be diagnosed.
pause
exit /b 1
