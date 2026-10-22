@echo off
setlocal
cd /d "%~dp0"
set "SRC=clap\build64\Release\Reality.clap"
set "DST=%LOCALAPPDATA%\Programs\Common\CLAP"
if not exist "%SRC%" (
  echo ERROR: %SRC% was not found. Run build_clap_vs2022.bat first.
  exit /b 2
)
if not exist "%DST%" mkdir "%DST%"
copy /y "%SRC%" "%DST%\Reality.clap" >nul
copy /y "clap\config\RealityCLAP.ini" "%DST%\RealityCLAP.ini" >nul
echo Installed Reality.clap and RealityCLAP.ini to:
echo   %DST%
echo Edit RealityCLAP.ini there, then rescan CLAP plugins in your DAW.
exit /b 0
