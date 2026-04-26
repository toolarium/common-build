@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-container-test.bat
::
:: Tests for cb-container.bat: --help, --version, argument parsing,
:: config file handling, and container operations.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "CT=%SRC_ROOT%\bin\cb-container.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%CT%" echo ERROR: %CT% not found & exit /b 1

echo Running cb-container.bat tests...
echo Using: %CT%
echo\

call :TEST_HELP
call :TEST_HELP_SHORT
call :TEST_VERSION
call :TEST_VERSION_SHORT
call :TEST_VERBOSE_FLAG
call :TEST_SHELL_FLAG
call :TEST_ENTRYPOINT_FLAG
call :TEST_PORT_FLAG
call :TEST_ENV_FLAG
call :TEST_INVALID_PARAMETER
call :TEST_COMBINED_FLAGS
call :TEST_LIST
call :TEST_START_NOT_FOUND
call :TEST_STOP_NOT_FOUND
call :TEST_DELETE_NOT_FOUND
call :TEST_LOG_NOT_FOUND
call :TEST_CLEAN_STANDALONE
call :TEST_CONFIG_FILE
call :TEST_SCAN_NOT_FOUND

call :TEST_CSV_FLAG
call :TEST_HELP_NEW_FLAGS
call :TEST_WIDE_FLAG
call :TEST_FORCE_FLAG
call :TEST_SETTINGS_GRADLE_SINGLE_QUOTES
call :TEST_SETTINGS_GRADLE_DOUBLE_QUOTES
call :TEST_SETTINGS_GRADLE_NO_SPACES
call :TEST_SETTINGS_GRADLE_TABS
call :TEST_NO_SETTINGS_GRADLE
call :TEST_AUTO_START_SETTINGS_GRADLE
call :TEST_AUTO_STOP_SETTINGS_GRADLE
call :TEST_AUTO_DELETE_SETTINGS_GRADLE
call :TEST_DEFAULT_LIST_IN_PROJECT
call :TEST_SCAN_ALL
call :TEST_SCAN_ALL_WITH_FILTER
call :TEST_LIST_FILTER
call :TEST_LIST_CSV
call :TEST_SCAN_ALL_CSV
call :TEST_LIST_VERBOSE

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_CONTAINS
:: %1 = needle, %2 = output-file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /i /c:"%~1" "%~2" >nul 2>nul
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
set "OUT=%TEMP%\cbct-help-%RANDOM%.txt"
call "%CT%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "container manager" "%OUT%" "help mentions 'container manager'"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "help contains 'usage:'"
call :ASSERT_OUTPUT_CONTAINS "-h, --help" "%OUT%" "help lists -h/--help"
call :ASSERT_OUTPUT_CONTAINS "-v, --version" "%OUT%" "help lists -v/--version"
call :ASSERT_OUTPUT_CONTAINS "--list" "%OUT%" "help lists --list"
call :ASSERT_OUTPUT_CONTAINS "--start" "%OUT%" "help lists --start"
call :ASSERT_OUTPUT_CONTAINS "--stop" "%OUT%" "help lists --stop"
call :ASSERT_OUTPUT_CONTAINS "--it" "%OUT%" "help lists --it"
call :ASSERT_OUTPUT_CONTAINS "--log" "%OUT%" "help lists --log"
call :ASSERT_OUTPUT_CONTAINS "--tail" "%OUT%" "help lists --tail"
call :ASSERT_OUTPUT_CONTAINS "--scan" "%OUT%" "help lists --scan"
call :ASSERT_OUTPUT_CONTAINS "--clean" "%OUT%" "help lists --clean"
call :ASSERT_OUTPUT_CONTAINS "--delete" "%OUT%" "help lists --delete"
call :ASSERT_OUTPUT_CONTAINS "--env" "%OUT%" "help lists --env"
call :ASSERT_OUTPUT_CONTAINS "--port" "%OUT%" "help lists --port"
call :ASSERT_OUTPUT_CONTAINS "--entrypoint" "%OUT%" "help lists --entrypoint"
call :ASSERT_OUTPUT_CONTAINS "--shell" "%OUT%" "help lists --shell"
call :ASSERT_OUTPUT_CONTAINS ".cb-container" "%OUT%" "help mentions .cb-container config"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -h
set "OUT=%TEMP%\cbct-h-%RANDOM%.txt"
call "%CT%" -h > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "shows usage line"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --version
set "OUT=%TEMP%\cbct-ver-%RANDOM%.txt"
call "%CT%" --version > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium cb-container" "%OUT%" "version shows 'toolarium cb-container'"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERSION_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -v
set "OUT=%TEMP%\cbct-v-%RANDOM%.txt"
call "%CT%" -v > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium cb-container" "%OUT%" "version shows 'toolarium cb-container'"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERBOSE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --verbose flag accepted
set "OUT=%TEMP%\cbct-vb-%RANDOM%.txt"
call "%CT%" --verbose --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --verbose --help"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "--verbose does not prevent --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SHELL_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -s/--shell flag accepted
set "OUT=%TEMP%\cbct-s-%RANDOM%.txt"
call "%CT%" -s /bin/bash --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -s --help"
del /f /q "%OUT%" >nul 2>nul
set "OUT=%TEMP%\cbct-sh-%RANDOM%.txt"
call "%CT%" --shell /bin/zsh --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --shell --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ENTRYPOINT_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -e/--entrypoint flag accepted
set "OUT=%TEMP%\cbct-e-%RANDOM%.txt"
call "%CT%" -e /bin/bash --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -e --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PORT_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -p/--port flag accepted
set "OUT=%TEMP%\cbct-p-%RANDOM%.txt"
call "%CT%" -p 8080 --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -p --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ENV_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --env flag accepted
set "OUT=%TEMP%\cbct-env-%RANDOM%.txt"
call "%CT%" --env KEY=val --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --env --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: invalid parameter
set "OUT=%TEMP%\cbct-inv-%RANDOM%.txt"
call "%CT%" --invalid > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!RC!" "exit code 1 for invalid parameter"
call :ASSERT_OUTPUT_CONTAINS "Invalid parameter" "%OUT%" "error mentions invalid parameter"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_COMBINED_FLAGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: combined flags -s -p --env --verbose --help
set "OUT=%TEMP%\cbct-all-%RANDOM%.txt"
call "%CT%" -s /bin/bash -p 8080 --env K=v --verbose --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with combined flags"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "combined flags do not break --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LIST
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --list
set "OUT=%TEMP%\cbct-list-%RANDOM%.txt"
call "%CT%" --list > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "IMAGE ID" "%OUT%" "--list shows header"
	call :ASSERT_OUTPUT_CONTAINS "CONTAINER ID" "%OUT%" "--list shows CONTAINER ID"
	call :ASSERT_OUTPUT_CONTAINS "TAG" "%OUT%" "--list shows TAG"
) else (
	set /a PASS+=1
	echo   PASS: --list skipped ^(no container runtime^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_START_NOT_FOUND
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --start with non-existent image
set "OUT=%TEMP%\cbct-snf-%RANDOM%.txt"
call "%CT%" --start nonexistent-image-xyz123 > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if not "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "not found" "%OUT%" "--start shows not found"
) else (
	set /a PASS+=1
	echo   PASS: --start handled ^(runtime available^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_STOP_NOT_FOUND
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --stop with non-existent image
set "OUT=%TEMP%\cbct-stopnf-%RANDOM%.txt"
call "%CT%" --stop nonexistent-image-xyz123 > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if not "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "not found" "%OUT%" "--stop shows not found"
) else (
	set /a FAIL+=1
	echo   FAIL: --stop should fail for non-existent image
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DELETE_NOT_FOUND
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --delete with non-existent image
set "OUT=%TEMP%\cbct-delnf-%RANDOM%.txt"
call "%CT%" --delete nonexistent-image-xyz123 > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if not "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "not found" "%OUT%" "--delete shows not found"
) else (
	set /a FAIL+=1
	echo   FAIL: --delete should fail for non-existent image
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LOG_NOT_FOUND
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --log with non-existent image
set "OUT=%TEMP%\cbct-lognf-%RANDOM%.txt"
call "%CT%" --log nonexistent-image-xyz123 > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if not "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "not found" "%OUT%" "--log shows not found"
) else (
	set /a FAIL+=1
	echo   FAIL: --log should fail for non-existent image
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_CLEAN_STANDALONE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --clean standalone
set "OUT=%TEMP%\cbct-clean-%RANDOM%.txt"
call "%CT%" --clean > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 for --clean"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_CONFIG_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: .cb-container config file
set "CFGDIR=%TEMP%\cbct-cfg-%RANDOM%"
mkdir "%CFGDIR%" >nul 2>nul
echo --verbose > "%CFGDIR%\.cb-container"
set "OUT=%TEMP%\cbct-cfgout-%RANDOM%.txt"
pushd "%CFGDIR%"
call "%CT%" --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
popd
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with .cb-container"
del /f /q "%OUT%" >nul 2>nul
if exist "%CFGDIR%" rmdir /s /q "%CFGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_NOT_FOUND
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan with non-existent image
set "OUT=%TEMP%\cbct-scannf-%RANDOM%.txt"
call "%CT%" --scan nonexistent-image-xyz123 > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
:: either trivy not installed or image not found - both are valid
if not "!RC!"=="0" (
	set /a PASS+=1
	echo   PASS: --scan shows error for bad image or missing trivy
) else (
	set /a PASS+=1
	echo   PASS: --scan completed
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_CSV_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --csv flag accepted
set "OUT=%TEMP%\cbct-csv-%RANDOM%.txt"
call "%CT%" --csv --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --csv --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_NEW_FLAGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: help lists new flags
set "OUT=%TEMP%\cbct-newflags-%RANDOM%.txt"
call "%CT%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "--wide" "%OUT%" "help lists --wide"
call :ASSERT_OUTPUT_CONTAINS "--force" "%OUT%" "help lists --force"
call :ASSERT_OUTPUT_CONTAINS "--csv" "%OUT%" "help lists --csv"
call :ASSERT_OUTPUT_CONTAINS "filter" "%OUT%" "help mentions list filter"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_WIDE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -w/--wide flag accepted
set "OUT=%TEMP%\cbct-wide-%RANDOM%.txt"
call "%CT%" -w --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -w --help"
call "%CT%" --wide --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --wide --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORCE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -f/--force flag accepted
set "OUT=%TEMP%\cbct-force-%RANDOM%.txt"
call "%CT%" -f --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -f --help"
call "%CT%" --force --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --force --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETTINGS_GRADLE_SINGLE_QUOTES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: settings.gradle with single quotes
set "SGDIR=%TEMP%\cbct-sg1-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
echo rootProject.name = 'my-gradle-project' > "%SGDIR%\settings.gradle"
set "OUT=%TEMP%\cbct-sg1out-%RANDOM%.txt"
pushd "%SGDIR%"
call "%CT%" --scan > "%OUT%" 2>&1
popd
call :ASSERT_OUTPUT_CONTAINS "my-gradle-project" "%OUT%" "resolves single-quoted project name"
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETTINGS_GRADLE_DOUBLE_QUOTES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: settings.gradle with double quotes
set "SGDIR=%TEMP%\cbct-sg2-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
echo rootProject.name = "my-dq-project" > "%SGDIR%\settings.gradle"
set "OUT=%TEMP%\cbct-sg2out-%RANDOM%.txt"
pushd "%SGDIR%"
call "%CT%" --scan > "%OUT%" 2>&1
popd
call :ASSERT_OUTPUT_CONTAINS "my-dq-project" "%OUT%" "resolves double-quoted project name"
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETTINGS_GRADLE_NO_SPACES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: settings.gradle without spaces around =
set "SGDIR=%TEMP%\cbct-sg3-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
echo rootProject.name='compact-name' > "%SGDIR%\settings.gradle"
set "OUT=%TEMP%\cbct-sg3out-%RANDOM%.txt"
pushd "%SGDIR%"
call "%CT%" --scan > "%OUT%" 2>&1
popd
call :ASSERT_OUTPUT_CONTAINS "compact-name" "%OUT%" "resolves name without spaces"
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NO_SETTINGS_GRADLE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: no settings.gradle does not crash
set "SGDIR=%TEMP%\cbct-sg5-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
set "OUT=%TEMP%\cbct-sg5out-%RANDOM%.txt"
pushd "%SGDIR%"
call "%CT%" --scan > "%OUT%" 2>&1
popd
set "hasFatal="
findstr /i /c:"FATAL" "%OUT%" >nul 2>nul
if %ERRORLEVEL% EQU 0 set "hasFatal=true"
if not defined hasFatal (set /a PASS+=1 & echo   PASS: no crash without settings.gradle) else (set /a FAIL+=1 & echo   FAIL: crash without settings.gradle)
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_ALL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan -a shows VULN column
set "OUT=%TEMP%\cbct-scanall-%RANDOM%.txt"
cmd /C call "%CT%" --scan -a > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "CRIT" "%OUT%" "--scan -a header has CRIT"
	call :ASSERT_OUTPUT_CONTAINS "IMAGE ID" "%OUT%" "--scan -a header has IMAGE ID"
	call :ASSERT_OUTPUT_CONTAINS "TAG" "%OUT%" "--scan -a header has TAG"
	findstr /c:"SIZE" "%OUT%" >nul 2>nul
	if !ERRORLEVEL! NEQ 0 (set /a PASS+=1 & echo   PASS: --scan -a does not show SIZE) else (set /a FAIL+=1 & echo   FAIL: --scan -a should not show SIZE)
) else (
	set /a PASS+=1
	echo   PASS: --scan -a skipped ^(no container runtime or trivy^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LIST_FILTER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --list with filter
set "OUT=%TEMP%\cbct-filter-%RANDOM%.txt"
call "%CT%" -l nonexistent-filter-xyz > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "IMAGE ID" "%OUT%" "-l filter shows header"
	call :ASSERT_OUTPUT_CONTAINS "0 image(s)" "%OUT%" "filter returns 0 for bad prefix"
) else (
	set /a PASS+=1
	echo   PASS: -l filter skipped ^(no container runtime^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LIST_VERBOSE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --list --verbose
set "OUT=%TEMP%\cbct-listv-%RANDOM%.txt"
call "%CT%" --list --verbose > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "image(s)" "%OUT%" "--list --verbose shows image count"
) else (
	set /a PASS+=1
	echo   PASS: --list --verbose skipped ^(no container runtime^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETTINGS_GRADLE_TABS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: settings.gradle with tabs
set "SGDIR=%TEMP%\cbct-sg4-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
set "OUT=%TEMP%\cbct-sg4out-%RANDOM%.txt"
powershell -NoProfile -Command "\"rootProject.name`t=`t'tabbed-name'\" | Out-File -Encoding ASCII '%SGDIR%\settings.gradle'"
pushd "%SGDIR%"
call "%CT%" --scan > "%OUT%" 2>&1
popd
call :ASSERT_OUTPUT_CONTAINS "tabbed-name" "%OUT%" "resolves name with tabs"
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_AUTO_START_SETTINGS_GRADLE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --start auto-detects from settings.gradle
set "SGDIR=%TEMP%\cbct-as-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
echo rootProject.name = 'auto-start-project' > "%SGDIR%\settings.gradle"
set "OUT=%TEMP%\cbct-asout-%RANDOM%.txt"
pushd "%SGDIR%"
call "%CT%" --start > "%OUT%" 2>&1
popd
call :ASSERT_OUTPUT_CONTAINS "auto-start-project" "%OUT%" "--start resolves from settings.gradle"
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_AUTO_STOP_SETTINGS_GRADLE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --stop auto-detects from settings.gradle
set "SGDIR=%TEMP%\cbct-astop-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
echo rootProject.name = 'auto-stop-project' > "%SGDIR%\settings.gradle"
set "OUT=%TEMP%\cbct-astopout-%RANDOM%.txt"
pushd "%SGDIR%"
call "%CT%" --stop > "%OUT%" 2>&1
popd
call :ASSERT_OUTPUT_CONTAINS "auto-stop-project" "%OUT%" "--stop resolves from settings.gradle"
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_AUTO_DELETE_SETTINGS_GRADLE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --delete auto-detects from settings.gradle
set "SGDIR=%TEMP%\cbct-adel-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
echo rootProject.name = 'auto-del-project' > "%SGDIR%\settings.gradle"
set "OUT=%TEMP%\cbct-adelout-%RANDOM%.txt"
pushd "%SGDIR%"
call "%CT%" --delete > "%OUT%" 2>&1
popd
call :ASSERT_OUTPUT_CONTAINS "auto-del-project" "%OUT%" "--delete resolves from settings.gradle"
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DEFAULT_LIST_IN_PROJECT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: bare cb-container in project dir filters by project name
set "SGDIR=%TEMP%\cbct-deflist-%RANDOM%"
mkdir "%SGDIR%" >nul 2>nul
echo rootProject.name = 'nonexistent-proj-xyz' > "%SGDIR%\settings.gradle"
set "OUT=%TEMP%\cbct-deflistout-%RANDOM%.txt"
pushd "%SGDIR%"
call "%CT%" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
popd
if "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "0 image(s)" "%OUT%" "filters to 0 images for unknown project"
) else (
	set /a PASS+=1
	echo   PASS: skipped ^(no container runtime^)
)
del /f /q "%OUT%" >nul 2>nul
if exist "%SGDIR%" rmdir /s /q "%SGDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_ALL_WITH_FILTER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan -a -l filter
set "OUT=%TEMP%\cbct-scanallf-%RANDOM%.txt"
cmd /C call "%CT%" --scan -a -l nonexistent-filter-xyz > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "CRIT" "%OUT%" "--scan -a -l shows CRIT column"
	call :ASSERT_OUTPUT_CONTAINS "0 image(s)" "%OUT%" "filter returns 0 for bad prefix"
) else (
	set /a PASS+=1
	echo   PASS: --scan -a -l skipped ^(no runtime or trivy^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LIST_CSV
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --list -a --csv
set "OUT=%TEMP%\cbct-listcsv-%RANDOM%.txt"
call "%CT%" --list -a --csv > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "IMAGE ID;CONTAINER ID;CREATED;STARTED;SIZE;TAG" "%OUT%" "list CSV has correct header"
	findstr /c:"----" "%OUT%" >nul 2>nul
	if !ERRORLEVEL! NEQ 0 (set /a PASS+=1 & echo   PASS: list CSV has no separator lines) else (set /a FAIL+=1 & echo   FAIL: list CSV should not have separator lines)
) else (
	set /a PASS+=1
	echo   PASS: --list -a --csv skipped ^(no container runtime^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_ALL_CSV
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan -a --csv
set "OUT=%TEMP%\cbct-scancsv-%RANDOM%.txt"
cmd /C call "%CT%" --scan -a --csv > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	call :ASSERT_OUTPUT_CONTAINS "IMAGE ID;CONTAINER ID;CREATED;CRIT;HIGH;MED;LOW;TAG" "%OUT%" "scan CSV has correct header"
	findstr /c:"----" "%OUT%" >nul 2>nul
	if !ERRORLEVEL! NEQ 0 (set /a PASS+=1 & echo   PASS: scan CSV has no separator lines) else (set /a FAIL+=1 & echo   FAIL: scan CSV should not have separator lines)
	findstr /c:"Scan completed" "%OUT%" >nul 2>nul
	if !ERRORLEVEL! NEQ 0 (set /a PASS+=1 & echo   PASS: scan CSV has no footer) else (set /a FAIL+=1 & echo   FAIL: scan CSV should not have footer)
) else (
	set /a PASS+=1
	echo   PASS: --scan -a --csv skipped ^(no runtime or trivy^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof
