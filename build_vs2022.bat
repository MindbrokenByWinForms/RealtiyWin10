@echo off
setlocal
cd /d "%~dp0"
cmake -S . -B build -A Win32
if errorlevel 1 exit /b %errorlevel%
cmake --build build --config Release
exit /b %errorlevel%
