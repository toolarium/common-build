@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-download-test.bat
::
:: Tests for bin/include/download.bat. Tests argument validation and
:: error handling without performing actual downloads.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "DOWNLOAD=%SRC_ROOT%\bin\include\download.bat"
set "PASS=0"
set "FAIL=0"

:: download.bat expects these env vars from the cb runtime
set "CB_SCRIPT_PATH=%SRC_ROOT%\bin"
set "CB_LINEHEADER=.: "
set "CB_VERBOSE=false"

if not exist "%DOWNLOAD%" echo ERROR: %DOWNLOAD% not found & exit /b 1

echo Running download.bat tests...
echo Using: %DOWNLOAD%
echo\

call :TEST_NO_ARGS
call :TEST_UNKNOWN_PACKAGE

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_CONTAINS
:: %1 = needle, %2 = haystack-file, %3 = msg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3 - expected to find "%~1"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NO_ARGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: no arguments exits with error
set "OUT=%TEMP%\cb-dl-noarg-%RANDOM%.txt"
call "%DOWNLOAD%" > "%OUT%" 2>&1
if !ERRORLEVEL! NEQ 0 (
	set /a PASS+=1
	echo   PASS: exit code 1 when no args
) else (
	set /a FAIL+=1
	echo   FAIL: should exit with error when no args
)
call :ASSERT_OUTPUT_CONTAINS "Missing package name" "%OUT%" "error mentions missing package name"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_UNKNOWN_PACKAGE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: unknown package exits with error
set "OUT=%TEMP%\cb-dl-unknown-%RANDOM%.txt"
call "%DOWNLOAD%" nonexistent-package-xyz > "%OUT%" 2>&1
if !ERRORLEVEL! NEQ 0 (
	set /a PASS+=1
	echo   PASS: exit code 1 for unknown package
) else (
	set /a FAIL+=1
	echo   FAIL: should exit with error for unknown package
)
call :ASSERT_OUTPUT_CONTAINS "not supported" "%OUT%" "error mentions not supported"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MISSING_ENV_VARS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: missing env vars detected
:: Call with a real package but without the required env vars
:: (CB_LINE, CB_LOGFILE, CB_DEVTOOLS etc. are unset)
set "OUT=%TEMP%\cb-dl-noenv-%RANDOM%.txt"
set "CB_LINE="
set "CB_LOGFILE="
set "CB_DEVTOOLS="
set "CB_DEV_REPOSITORY="
set "CB_WGET_CMD="
call "%DOWNLOAD%" java > "%OUT%" 2>&1
if !ERRORLEVEL! NEQ 0 (
	set /a PASS+=1
	echo   PASS: exit code 1 for missing env vars
) else (
	set /a FAIL+=1
	echo   FAIL: should exit with error for missing env vars
)
call :ASSERT_OUTPUT_CONTAINS "Could not found expected environment variable" "%OUT%" "error mentions missing env var"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VALID_PACKAGE_SETS_VARS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: valid package name calls package script
:: Set up minimal env so download.bat gets past the package call
:: but fails at the download env check — this proves the package
:: script was called and CB_PACKAGE_DOWNLOAD_NAME was set.
set "OUT=%TEMP%\cb-dl-pkg-%RANDOM%.txt"
set "CB_LINE=---"
set "CB_LOGFILE=%TEMP%\cb-dl-log-%RANDOM%.txt"
echo. > "%CB_LOGFILE%"
set "CB_DEVTOOLS=%TEMP%"
set "CB_DEV_REPOSITORY=%TEMP%"
set "CB_WGET_CMD="
call "%DOWNLOAD%" java > "%OUT%" 2>&1
:: It will fail because CB_WGET_CMD is not set, but CB_PACKAGE_DOWNLOAD_NAME
:: should have been set by java.bat — the error should mention CB_WGET_CMD
call :ASSERT_OUTPUT_CONTAINS "CB_WGET_CMD" "%OUT%" "package script ran, download.bat reached wget check"
del /f /q "%OUT%" "%CB_LOGFILE%" >nul 2>nul
goto :eof
