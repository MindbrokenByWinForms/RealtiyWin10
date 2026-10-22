@echo off
setlocal
cd /d "%~dp0"

where cmake >nul 2>nul
if errorlevel 1 (
  echo ERROR: CMake was not found in PATH.
  exit /b 2
)
where git >nul 2>nul
if errorlevel 1 (
  echo ERROR: Git was not found in PATH. The build fetches the official CLAP headers.
  exit /b 3
)

cmake -S clap -B clap\build64 -A x64
if errorlevel 1 exit /b %errorlevel%
cmake --build clap\build64 --config Release
if errorlevel 1 exit /b %errorlevel%

echo.
echo Built: clap\build64\Release\Reality.clap
echo Copy RealityCLAP.ini beside Reality.clap and edit the paths before scanning it in your DAW.
exit /b 0
