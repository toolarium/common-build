@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-dockterm-test.bat
::
:: Tests for cb-dockterm.bat: --help, --version, argument parsing,
:: config file handling, and type resolution.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "DT=%SRC_ROOT%\bin\cb-dockterm.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%DT%" echo ERROR: %DT% not found & exit /b 1

echo Running cb-dockterm.bat tests...
echo Using: %DT%
echo\

call :TEST_HELP
call :TEST_HELP_SHORT
call :TEST_VERSION
call :TEST_VERSION_SHORT
call :TEST_KEEP_IMAGE_FLAG
call :TEST_SHELL_FLAG
call :TEST_VERBOSE_FLAG
call :TEST_COMBINED_FLAGS
call :TEST_MISSING_CONFIG

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
:TEST_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help
set "OUT=%TEMP%\cbdt-help-%RANDOM%.txt"
call "%DT%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "docker term" "%OUT%" "help mentions 'docker term'"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "help contains 'usage:'"
call :ASSERT_OUTPUT_CONTAINS "-h, --help" "%OUT%" "help lists -h/--help"
call :ASSERT_OUTPUT_CONTAINS "-v, --version" "%OUT%" "help lists -v/--version"
call :ASSERT_OUTPUT_CONTAINS "verbose" "%OUT%" "help lists --verbose"
call :ASSERT_OUTPUT_CONTAINS "-k, --keep-image" "%OUT%" "help lists -k/--keep-image"
call :ASSERT_OUTPUT_CONTAINS "-s, --shell" "%OUT%" "help lists -s/--shell"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -h
set "OUT=%TEMP%\cbdt-h-%RANDOM%.txt"
call "%DT%" -h > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "shows usage line"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --version
set "OUT=%TEMP%\cbdt-ver-%RANDOM%.txt"
call "%DT%" --version > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium dockterm" "%OUT%" "version shows 'toolarium dockterm'"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERSION_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -v
set "OUT=%TEMP%\cbdt-v-%RANDOM%.txt"
call "%DT%" -v > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium dockterm" "%OUT%" "version shows 'toolarium dockterm'"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_KEEP_IMAGE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -k/--keep-image flag accepted
set "OUT=%TEMP%\cbdt-k-%RANDOM%.txt"
call "%DT%" -k --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -k --help"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "-k does not prevent --help"
del /f /q "%OUT%" >nul 2>nul
set "OUT=%TEMP%\cbdt-ki-%RANDOM%.txt"
call "%DT%" --keep-image --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --keep-image --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SHELL_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -s/--shell flag accepted
set "OUT=%TEMP%\cbdt-s-%RANDOM%.txt"
call "%DT%" -s /bin/bash --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -s --help"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "-s does not prevent --help"
del /f /q "%OUT%" >nul 2>nul
set "OUT=%TEMP%\cbdt-sh-%RANDOM%.txt"
call "%DT%" --shell /bin/zsh --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --shell --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERBOSE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --verbose flag accepted
set "OUT=%TEMP%\cbdt-vb-%RANDOM%.txt"
call "%DT%" --verbose --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --verbose --help"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "--verbose does not prevent --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_COMBINED_FLAGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: combined flags -k -s --verbose --help
set "OUT=%TEMP%\cbdt-all-%RANDOM%.txt"
call "%DT%" -k -s /bin/bash --verbose --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with all flags combined"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "combined flags do not break --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MISSING_CONFIG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: missing config file
set "TMPDIR=%TEMP%\cbdt-cfg-%RANDOM%"
mkdir "%TMPDIR%" >nul 2>nul
mkdir "%TMPDIR%\bin" >nul 2>nul
mkdir "%TMPDIR%\conf" >nul 2>nul
copy /y "%DT%" "%TMPDIR%\bin\cb-dockterm.bat" >nul 2>nul
:: no dockterm-types.properties in conf
set "OUT=%TEMP%\cbdt-nocfg-%RANDOM%.txt"
call "%TMPDIR%\bin\cb-dockterm.bat" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!RC!" "exit code 1 for missing config"
call :ASSERT_OUTPUT_CONTAINS "Missing dockterm configuration" "%OUT%" "error about missing config"
del /f /q "%OUT%" >nul 2>nul
if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul
goto :eof
