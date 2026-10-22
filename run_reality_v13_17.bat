@echo off
setlocal
cd /d "%~dp0"

rem ================================================================
rem USER TOGGLE: RealityCompat.log
rem   1 = logging ENABLED  (create/append RealityCompat.log)
rem   0 = logging DISABLED (do not open, create, or append the log)
rem Change only the value below when you want to toggle logging.
rem ================================================================
set "REALITY_CREATE_LOG=1"

if "%~1"=="" (
  echo Usage: run_reality_v13_17.bat path\to\Reality.exe [bankset-folder]
  echo Example: run_reality_v13_17.bat "C:\Reality\Reality\Reality.exe" "C:\Reality\Banksets"
  exit /b 2
)

rem Clean v13.17 compatibility settings.  This adds an engine-rate guard for
rem MIDI-input changes on top of the v13.14 Reset Synth and v13.10 split-rate fixes.
rem It still excludes the experimental
rem v13.11-v13.13 Analog behavior changes.
set "REALITY_COMPAT_FORCE_ALWAYS_LOCKED=0"
set "REALITY_RZED_VIRTUALLOCK=1"
set "REALITY_VOICE_TRACE=0"
set "REALITY_SEQ_UI_MIRROR=0"

rem Required stable host/UI configuration formerly inherited from the old v9 launcher.
set "REALITY_SYNTH_BRUTEFORCE="
set "REALITY_SYNTH_PROBE="
set "REALITY_HOST_ENGINE_PUMP=1"
set "REALITY_UI_PROBE=1"
set "REALITY_UI_FORCE_ENABLE=1"
set "REALITY_UI_TRACE_VERBOSE="

if not "%~2"=="" set "REALITY_BANKSETS=%~2"

if not exist "%~dp0build\Release\RealityPortLauncher.exe" (
  echo ERROR: build\Release\RealityPortLauncher.exe was not found.
  echo Run build_vs2022.bat first.
  exit /b 3
)

echo Reality Win10 Port v13.17 - MIDI-input lifecycle preservation fix
if "%REALITY_CREATE_LOG%"=="0" (
  echo Logging: DISABLED - RealityCompat.log will not be opened or changed.
) else (
  echo Logging: ENABLED - RealityCompat.log will be created/appended.
)
echo Host engine pump enabled; split-rate + Reset Synth + MIDI-input lifecycle preservation fixs active.
if defined REALITY_BANKSETS echo REALITY_BANKSETS=%REALITY_BANKSETS%

"%~dp0build\Release\RealityPortLauncher.exe" --rehost "%~1"
exit /b %errorlevel%
