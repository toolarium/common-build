@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-install-test.bat
::
:: Tests for cb-install.bat. Only tests the arg-parsing paths (--help,
:: --version) that exit before any network/filesystem operations.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
:: always resolve source root from the test script location (ignore any pre-set CB_HOME)
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "INST=%SRC_ROOT%\bin\cb-install.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%INST%" echo ERROR: %INST% not found & exit /b 1

echo Running cb-install.bat tests...
echo Using: %INST%
echo\

call :TEST_HELP_LONG
call :TEST_HELP_SHORT
call :TEST_VERSION_LONG
call :TEST_VERSION_SHORT
call :TEST_SILENT_WITH_HELP
call :TEST_FORCE_WITH_HELP
call :TEST_DRAFT_WITH_HELP
call :TEST_COMBINED_FLAGS_WITH_HELP
call :TEST_FORCE_WITH_VERSION
call :TEST_DRAFT_WITH_VERSION

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_CONTAINS
:: %1 = needle, %2 = haystack-file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3 ^(expected to find "%~1"^)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_EXIT_CODE
:: %1 = expected, %2 = actual, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~1"=="%~2" (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3 ^(expected [%~1], got [%~2]^)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_LONG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help
set "OUT=%TEMP%\cbi-help-%RANDOM%.txt"
call "%INST%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium common build installer" "%OUT%" "shows installer banner"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "shows usage line"
call :ASSERT_OUTPUT_CONTAINS "-h, --help" "%OUT%" "lists -h/--help"
call :ASSERT_OUTPUT_CONTAINS "-v, --version" "%OUT%" "lists -v/--version"
call :ASSERT_OUTPUT_CONTAINS "--silent" "%OUT%" "lists --silent"
call :ASSERT_OUTPUT_CONTAINS "--force" "%OUT%" "lists --force"
call :ASSERT_OUTPUT_CONTAINS "--draft" "%OUT%" "lists --draft"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -h
set "OUT=%TEMP%\cbi-h-%RANDOM%.txt"
call "%INST%" -h > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "shows usage line"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERSION_LONG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --version
set "OUT=%TEMP%\cbi-ver-%RANDOM%.txt"
call "%INST%" --version > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium common build installer" "%OUT%" "shows version banner"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERSION_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -v
set "OUT=%TEMP%\cbi-v-%RANDOM%.txt"
call "%INST%" -v > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium common build installer" "%OUT%" "shows version banner"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SILENT_WITH_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --silent --help
set "OUT=%TEMP%\cbi-sh-%RANDOM%.txt"
call "%INST%" --silent --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "--silent does not prevent --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORCE_WITH_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --force --help
set "OUT=%TEMP%\cbi-fh-%RANDOM%.txt"
call "%INST%" --force --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "--force does not prevent --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DRAFT_WITH_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --draft --help
set "OUT=%TEMP%\cbi-dh-%RANDOM%.txt"
call "%INST%" --draft --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "--draft does not prevent --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_COMBINED_FLAGS_WITH_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --silent --force --draft --help
set "OUT=%TEMP%\cbi-all-%RANDOM%.txt"
call "%INST%" --silent --force --draft --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "all flags combined do not break --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORCE_WITH_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --force --version
set "OUT=%TEMP%\cbi-fv-%RANDOM%.txt"
call "%INST%" --force --version > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium common build installer" "%OUT%" "--force does not break --version"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DRAFT_WITH_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --draft --version
set "OUT=%TEMP%\cbi-dv-%RANDOM%.txt"
call "%INST%" --draft --version > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium common build installer" "%OUT%" "--draft does not break --version"
del /f /q "%OUT%" >nul 2>nul
goto :eof
