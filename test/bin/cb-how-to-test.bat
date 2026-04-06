@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-how-to-test.bat
::
:: Tests for bin/include/how-to.bat.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "HOWTO=%SRC_ROOT%\bin\include\how-to.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%HOWTO%" echo ERROR: %HOWTO% not found & exit /b 1

echo Running how-to.bat tests...
echo Using: %HOWTO%
echo\

call :TEST_EXITS_ZERO
call :TEST_PRODUCES_OUTPUT
call :TEST_MENTIONS_CREATE_PROJECT
call :TEST_MENTIONS_INSTALL
call :TEST_MENTIONS_PACKAGES
call :TEST_MENTIONS_SETENV
call :TEST_MENTIONS_GITHUB
call :TEST_MENTIONS_CB_HOME

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_CONTAINS
:: %1 = needle, %2 = haystack-file, %3 = msg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /i /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3 - expected to find "%~1"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_EXITS_ZERO
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: exits with code 0
call "%HOWTO%" >nul 2>&1
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: exit code 0
) else (
	set /a FAIL+=1
	echo   FAIL: exit code !ERRORLEVEL!
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PRODUCES_OUTPUT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: produces non-empty output
set "OUT=%TEMP%\cb-howto-out-%RANDOM%.txt"
call "%HOWTO%" > "%OUT%" 2>&1
for %%A in ("%OUT%") do set "FSIZE=%%~zA"
if !FSIZE! GTR 0 (
	set /a PASS+=1
	echo   PASS: output is non-empty
) else (
	set /a FAIL+=1
	echo   FAIL: output is empty
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MENTIONS_CREATE_PROJECT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: mentions creating a new project
set "OUT=%TEMP%\cb-howto-%RANDOM%.txt"
call "%HOWTO%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "cb --new" "%OUT%" "mentions cb --new"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MENTIONS_INSTALL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: mentions installing software
set "OUT=%TEMP%\cb-howto-%RANDOM%.txt"
call "%HOWTO%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "cb --install" "%OUT%" "mentions cb --install"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MENTIONS_PACKAGES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: mentions listing packages
set "OUT=%TEMP%\cb-howto-%RANDOM%.txt"
call "%HOWTO%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "cb --packages" "%OUT%" "mentions cb --packages"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MENTIONS_SETENV
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: mentions setenv
set "OUT=%TEMP%\cb-howto-%RANDOM%.txt"
call "%HOWTO%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "cb --setenv" "%OUT%" "mentions cb --setenv"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MENTIONS_GITHUB
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: mentions GitHub URL
set "OUT=%TEMP%\cb-howto-%RANDOM%.txt"
call "%HOWTO%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "github.com/toolarium/common-build" "%OUT%" "mentions GitHub URL"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MENTIONS_CB_HOME
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: mentions CB_HOME
set "OUT=%TEMP%\cb-howto-%RANDOM%.txt"
call "%HOWTO%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "CB_HOME" "%OUT%" "mentions CB_HOME"
del /f /q "%OUT%" >nul 2>nul
goto :eof
