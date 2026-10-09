@echo off
if defined VIVADO_BAT if exist "%VIVADO_BAT%" exit /b 0
set "VIVADO_BAT="
for /f "delims=" %%I in ('where vivado.bat 2^>nul') do if not defined VIVADO_BAT set "VIVADO_BAT=%%I"
for %%R in ("C:\AMDDesignTools" "C:\Xilinx" "D:\AMDDesignTools" "D:\Xilinx" "C:\Program Files\AMDDesignTools") do (
  for /d %%V in ("%%~R\2025.1*" "%%~R\Vivado\2025.1*") do (
    if not defined VIVADO_BAT if exist "%%~V\Vivado\bin\vivado.bat" set "VIVADO_BAT=%%~V\Vivado\bin\vivado.bat"
    if not defined VIVADO_BAT if exist "%%~V\bin\vivado.bat" set "VIVADO_BAT=%%~V\bin\vivado.bat"
  )
)
if not defined VIVADO_BAT (
  echo Vivado was not found. Open the Vivado 2025.1.1 Tcl Console and use the source command in START_HERE.md.
  exit /b 1
)
exit /b 0
