@echo off
setlocal
cd /d "%~dp0"
if not exist Results\project_path.txt (
  echo Run RUN_PROJECT2.cmd first.
  pause
  exit /b 1
)
set /p P2_PROJECT=<Results\project_path.txt
call "%~dp0Tools\find_vivado.cmd"
if errorlevel 1 (
  pause
  exit /b 1
)
call "%VIVADO_BAT%" -mode gui "%P2_PROJECT%"
