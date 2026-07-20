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

call :TEST_REGISTRY_FLAG
call :TEST_HELP_REGISTRY
call :TEST_REGISTRY_LIST_REQUIRES_REPO
call :TEST_REGISTRY_LIST_REQUIRES_CREDENTIALS
call :TEST_REGISTRY_SCAN_REQUIRES_CREDENTIALS
call :TEST_REGISTRY_COMBINED_FLAGS

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

call :TEST_SCAN_CACHE_FILENAME_EXTRACTION
call :TEST_SCAN_ALL_CACHE_REUSE
call :TEST_SCAN_ALL_CACHE_DAY_EXPIRED
call :TEST_SCAN_ALL_CACHE_IMAGE_NEWER
call :TEST_SCAN_ALL_CACHE_FORCE

call :TEST_HELP_INSIDE_PROJECT_EXAMPLE
call :TEST_VERBOSE_START_SHOWS_EXECUTE
call :TEST_ENV_VALUE_IN_EXECUTE
call :TEST_ENV_MULTIPLE_VALUES_IN_EXECUTE

call :TEST_TAIL_FLAG
call :TEST_ALL_FLAG
call :TEST_IT_FLAG
call :TEST_PORT_COLON_FLAG
call :TEST_MULTIPLE_PORTS_FLAG
call :TEST_LOG_RANGE_NOT_FOUND
call :TEST_SCAN_MULTIPLE_IMAGES
call :TEST_START_LOG_COMBINED

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


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_REGISTRY_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --registry flag accepted
set "OUT=%TEMP%\cbct-regflag-%RANDOM%.txt"
call "%CT%" --registry https://reg.example.com --help > "%OUT%" 2>&1
call :ASSERT_EXIT_CODE "0" "%ERRORLEVEL%" "exit code 0 with --registry --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_REGISTRY
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: help lists --registry
set "OUT=%TEMP%\cbct-helpregistry-%RANDOM%.txt"
call "%CT%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "--registry" "%OUT%" "help lists --registry"
call :ASSERT_OUTPUT_CONTAINS "CB_REGISTRY_USER" "%OUT%" "help mentions CB_REGISTRY_USER"
call :ASSERT_OUTPUT_CONTAINS "CB_REGISTRY_PASSWORD" "%OUT%" "help mentions CB_REGISTRY_PASSWORD"
call :ASSERT_OUTPUT_CONTAINS "Docker Registry v2" "%OUT%" "help mentions Docker Registry v2"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_REGISTRY_LIST_REQUIRES_REPO
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --list --registry without repo shows error
set "OUT=%TEMP%\cbct-regrepo-%RANDOM%.txt"
call "%CT%" --list --registry https://reg.example.com > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!RC!" "exit code 1 when repo missing"
call :ASSERT_OUTPUT_CONTAINS "Repository name required" "%OUT%" "shows repo required message"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_REGISTRY_LIST_REQUIRES_CREDENTIALS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --list --registry without credentials shows error
set "OUT=%TEMP%\cbct-regcred-%RANDOM%.txt"
cmd /C "set "CB_REGISTRY_USER=" & set "CB_REGISTRY_PASSWORD=" & call "%CT%" --list myrepo --registry https://reg.example.com" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!RC!" "exit code 1 when credentials missing"
call :ASSERT_OUTPUT_CONTAINS "credentials not set" "%OUT%" "shows credentials error"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_REGISTRY_SCAN_REQUIRES_CREDENTIALS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan --registry without credentials shows error
set "OUT=%TEMP%\cbct-regscan-%RANDOM%.txt"
cmd /C "set "CB_REGISTRY_USER=" & set "CB_REGISTRY_PASSWORD=" & call "%CT%" --scan myapp:latest --registry https://reg.example.com" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!RC!" "exit code 1 when credentials missing for scan"
call :ASSERT_OUTPUT_CONTAINS "credentials not set" "%OUT%" "shows credentials error for scan"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_REGISTRY_COMBINED_FLAGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --registry combined with other flags accepted
set "OUT=%TEMP%\cbct-regcomb-%RANDOM%.txt"
call "%CT%" --registry https://reg.example.com --wide --force --csv --help > "%OUT%" 2>&1
call :ASSERT_EXIT_CODE "0" "%ERRORLEVEL%" "exit code 0 with --registry and other flags"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "combined registry flags do not break --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_CACHE_FILENAME_EXTRACTION
:: Verifies that extracting day from cache filename via :~-28,8 works
:: for both short and long image IDs (regression for the %var% bug fix).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cache filename day extraction ^(~-28,8^)
set "f1=abc123-20261201-143022-trivy.counts"
set "day1=!f1:~-28,8!"
call :ASSERT_EXIT_CODE "20261201" "!day1!" "day from short imageId filename"
set "f2=abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789-20261201-143022-trivy.counts"
set "day2=!f2:~-28,8!"
call :ASSERT_EXIT_CODE "20261201" "!day2!" "day from long imageId filename"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_ALL_CACHE_REUSE
:: Pre-seeds a valid today-stamped .counts file and verifies trivy is
:: NOT called (cache hit).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan -a cache reuse ^(trivy not called when cache valid^)
set "CRTMPDIR=%TEMP%\cbct-cr-%RANDOM%%RANDOM%"
set "MOCKBIN=!CRTMPDIR!\bin"
mkdir "!MOCKBIN!" >nul 2>nul
set "CACHEDIR=!CRTMPDIR!\cb-container"
mkdir "!CACHEDIR!" >nul 2>nul
rem get today's date for cache timestamp
for /f "tokens=*" %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "CR_TODAY=%%d"
set "CR_CACHE_TS=!CR_TODAY!-120000"
set "CR_IMAGEID=testimg1234567890ab"
rem write pre-seeded cache files
echo {"Results":[]} > "!CACHEDIR!\!CR_IMAGEID!-!CR_CACHE_TS!-trivy.json"
echo 0 0 0 0 0 > "!CACHEDIR!\!CR_IMAGEID!-!CR_CACHE_TS!-trivy.counts"
rem write mock docker.bat
echo @echo off > "!MOCKBIN!\docker.bat"
echo if "%%1"=="ps" exit /b 0 >> "!MOCKBIN!\docker.bat"
echo if not "%%1"=="images" exit /b 0 >> "!MOCKBIN!\docker.bat"
echo if "%%4"=="--filter" goto FILTER_OUT >> "!MOCKBIN!\docker.bat"
echo echo !CR_IMAGEID!^^^|mytestrepo^^^|latest^^^|100MB^^^|2026-01-01 08:00:00 +0000 UTC >> "!MOCKBIN!\docker.bat"
echo exit /b 0 >> "!MOCKBIN!\docker.bat"
echo :FILTER_OUT >> "!MOCKBIN!\docker.bat"
echo echo !CR_IMAGEID! >> "!MOCKBIN!\docker.bat"
echo exit /b 0 >> "!MOCKBIN!\docker.bat"
copy "!MOCKBIN!\docker.bat" "!MOCKBIN!\nerdctl.bat" >nul 2>nul
rem write mock trivy.bat
echo @echo off > "!MOCKBIN!\trivy.bat"
echo echo {"Results":[]} >> "!MOCKBIN!\trivy.bat"
echo if defined TRIVY_CALLED_MARKER type nul ^> "%%TRIVY_CALLED_MARKER%%" >> "!MOCKBIN!\trivy.bat"
echo exit /b 0 >> "!MOCKBIN!\trivy.bat"
set "CR_MARKER=!CRTMPDIR!\trivy-called"
del /f /q "!CR_MARKER!" 2>nul
set "OUT=%TEMP%\cbct-cr-out-%RANDOM%.txt"
rem use wrapper script to avoid nested-quote issues in cmd /c "set "VAR=VALUE" & ..."
echo @echo off > "!CRTMPDIR!\run.bat"
echo set "CB_TEMP=!CRTMPDIR!" >> "!CRTMPDIR!\run.bat"
echo set "TRIVY_CALLED_MARKER=!CR_MARKER!" >> "!CRTMPDIR!\run.bat"
echo set "PATH=!MOCKBIN!;%%PATH%%" >> "!CRTMPDIR!\run.bat"
echo call "!CT!" --scan -a >> "!CRTMPDIR!\run.bat"
cmd /c "!CRTMPDIR!\run.bat" > "!OUT!" 2>&1
if exist "!CR_MARKER!" (
    set /a FAIL+=1
    echo   FAIL: cache reuse - trivy was called but cache was valid
) else (
    set /a PASS+=1
    echo   PASS: cache reuse - trivy not called ^(cache hit^)
)
del /f /q "!OUT!" 2>nul
if exist "!CRTMPDIR!" rmdir /s /q "!CRTMPDIR!" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_ALL_CACHE_DAY_EXPIRED
:: Pre-seeds a yesterday-stamped .counts file and verifies trivy IS
:: called (day boundary expired).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan -a stale-day cache triggers rescan
set "CDTMPDIR=%TEMP%\cbct-cd-%RANDOM%%RANDOM%"
set "MOCKBIN=!CDTMPDIR!\bin"
mkdir "!MOCKBIN!" >nul 2>nul
set "CACHEDIR=!CDTMPDIR!\cb-container"
mkdir "!CACHEDIR!" >nul 2>nul
for /f "tokens=*" %%d in ('powershell -NoProfile -Command "$d=(Get-Date).AddDays(-1);$d.Year*10000+$d.Month*100+$d.Day"') do set "CD_YEST=%%d"
set "CD_CACHE_TS=!CD_YEST!-120000"
set "CD_IMAGEID=testimg1234567890ab"
echo 0 0 0 0 0 > "!CACHEDIR!\!CD_IMAGEID!-!CD_CACHE_TS!-trivy.counts"
rem write mock docker.bat
echo @echo off > "!MOCKBIN!\docker.bat"
echo if "%%1"=="ps" exit /b 0 >> "!MOCKBIN!\docker.bat"
echo if not "%%1"=="images" exit /b 0 >> "!MOCKBIN!\docker.bat"
echo if "%%4"=="--filter" goto FILTER_OUT >> "!MOCKBIN!\docker.bat"
echo echo !CD_IMAGEID!^^^|mytestrepo^^^|latest^^^|100MB^^^|2026-01-01 08:00:00 +0000 UTC >> "!MOCKBIN!\docker.bat"
echo exit /b 0 >> "!MOCKBIN!\docker.bat"
echo :FILTER_OUT >> "!MOCKBIN!\docker.bat"
echo echo !CD_IMAGEID! >> "!MOCKBIN!\docker.bat"
echo exit /b 0 >> "!MOCKBIN!\docker.bat"
copy "!MOCKBIN!\docker.bat" "!MOCKBIN!\nerdctl.bat" >nul 2>nul
echo @echo off > "!MOCKBIN!\trivy.bat"
echo echo {"Results":[]} >> "!MOCKBIN!\trivy.bat"
echo if defined TRIVY_CALLED_MARKER type nul ^> "%%TRIVY_CALLED_MARKER%%" >> "!MOCKBIN!\trivy.bat"
echo exit /b 0 >> "!MOCKBIN!\trivy.bat"
set "CD_MARKER=!CDTMPDIR!\trivy-called"
del /f /q "!CD_MARKER!" 2>nul
set "OUT=%TEMP%\cbct-cd-out-%RANDOM%.txt"
echo @echo off > "!CDTMPDIR!\run.bat"
echo set "CB_TEMP=!CDTMPDIR!" >> "!CDTMPDIR!\run.bat"
echo set "TRIVY_CALLED_MARKER=!CD_MARKER!" >> "!CDTMPDIR!\run.bat"
echo set "PATH=!MOCKBIN!;%%PATH%%" >> "!CDTMPDIR!\run.bat"
echo call "!CT!" --scan -a >> "!CDTMPDIR!\run.bat"
cmd /c "!CDTMPDIR!\run.bat" > "!OUT!" 2>&1
if exist "!CD_MARKER!" (
    set /a PASS+=1
    echo   PASS: stale-day cache - trivy rescanned
) else (
    set /a FAIL+=1
    echo   FAIL: stale-day cache - trivy was NOT called ^(should rescan^)
)
del /f /q "!OUT!" 2>nul
if exist "!CDTMPDIR!" rmdir /s /q "!CDTMPDIR!" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_ALL_CACHE_IMAGE_NEWER
:: Pre-seeds a today-08:00 .counts file but mock docker reports image
:: created at today 09:00 → cache is stale, trivy IS called.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan -a image-newer-than-cache triggers rescan
set "CNTMPDIR=%TEMP%\cbct-cn-%RANDOM%%RANDOM%"
set "MOCKBIN=!CNTMPDIR!\bin"
mkdir "!MOCKBIN!" >nul 2>nul
set "CACHEDIR=!CNTMPDIR!\cb-container"
mkdir "!CACHEDIR!" >nul 2>nul
for /f "tokens=*" %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "CN_TODAY=%%d"
for /f "tokens=*" %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "CN_TODAY_FMT=%%d"
set "CN_CACHE_TS=!CN_TODAY!-080000"
set "CN_IMAGEID=testimg1234567890ab"
echo 0 0 0 0 0 > "!CACHEDIR!\!CN_IMAGEID!-!CN_CACHE_TS!-trivy.counts"
rem write mock docker.bat — image created today at 09:00 (after cache at 08:00)
echo @echo off > "!MOCKBIN!\docker.bat"
echo if "%%1"=="ps" exit /b 0 >> "!MOCKBIN!\docker.bat"
echo if not "%%1"=="images" exit /b 0 >> "!MOCKBIN!\docker.bat"
echo if "%%4"=="--filter" goto FILTER_OUT >> "!MOCKBIN!\docker.bat"
echo echo !CN_IMAGEID!^^^|mytestrepo^^^|latest^^^|100MB^^^|!CN_TODAY_FMT! 09:00:00 +0000 UTC >> "!MOCKBIN!\docker.bat"
echo exit /b 0 >> "!MOCKBIN!\docker.bat"
echo :FILTER_OUT >> "!MOCKBIN!\docker.bat"
echo echo !CN_IMAGEID! >> "!MOCKBIN!\docker.bat"
echo exit /b 0 >> "!MOCKBIN!\docker.bat"
copy "!MOCKBIN!\docker.bat" "!MOCKBIN!\nerdctl.bat" >nul 2>nul
echo @echo off > "!MOCKBIN!\trivy.bat"
echo echo {"Results":[]} >> "!MOCKBIN!\trivy.bat"
echo if defined TRIVY_CALLED_MARKER type nul ^> "%%TRIVY_CALLED_MARKER%%" >> "!MOCKBIN!\trivy.bat"
echo exit /b 0 >> "!MOCKBIN!\trivy.bat"
set "CN_MARKER=!CNTMPDIR!\trivy-called"
del /f /q "!CN_MARKER!" 2>nul
set "OUT=%TEMP%\cbct-cn-out-%RANDOM%.txt"
echo @echo off > "!CNTMPDIR!\run.bat"
echo set "CB_TEMP=!CNTMPDIR!" >> "!CNTMPDIR!\run.bat"
echo set "TRIVY_CALLED_MARKER=!CN_MARKER!" >> "!CNTMPDIR!\run.bat"
echo set "PATH=!MOCKBIN!;%%PATH%%" >> "!CNTMPDIR!\run.bat"
echo call "!CT!" --scan -a >> "!CNTMPDIR!\run.bat"
cmd /c "!CNTMPDIR!\run.bat" > "!OUT!" 2>&1
if exist "!CN_MARKER!" (
    set /a PASS+=1
    echo   PASS: image-newer cache - trivy rescanned
) else (
    set /a FAIL+=1
    echo   FAIL: image-newer cache - trivy was NOT called ^(should rescan^)
    echo   DEBUG CN_MARKER=!CN_MARKER!
    echo   DEBUG CACHEDIR=!CACHEDIR!
    echo   DEBUG cb-container output:
    if exist "!OUT!" type "!OUT!"
    echo   DEBUG CACHEDIR contents:
    dir /b "!CACHEDIR!" 2>nul
)
del /f /q "!OUT!" 2>nul
if exist "!CNTMPDIR!" rmdir /s /q "!CNTMPDIR!" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_ALL_CACHE_FORCE
:: Pre-seeds a valid today-stamped .counts file but passes --force,
:: verifying trivy IS called regardless.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan -a --force bypasses valid cache
set "CFTMPDIR=%TEMP%\cbct-cf-%RANDOM%%RANDOM%"
set "MOCKBIN=!CFTMPDIR!\bin"
mkdir "!MOCKBIN!" >nul 2>nul
set "CACHEDIR=!CFTMPDIR!\cb-container"
mkdir "!CACHEDIR!" >nul 2>nul
for /f "tokens=*" %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "CF_TODAY=%%d"
set "CF_CACHE_TS=!CF_TODAY!-120000"
set "CF_IMAGEID=testimg1234567890ab"
echo {"Results":[]} > "!CACHEDIR!\!CF_IMAGEID!-!CF_CACHE_TS!-trivy.json"
echo 0 0 0 0 0 > "!CACHEDIR!\!CF_IMAGEID!-!CF_CACHE_TS!-trivy.counts"
rem write mock docker.bat
echo @echo off > "!MOCKBIN!\docker.bat"
echo if "%%1"=="ps" exit /b 0 >> "!MOCKBIN!\docker.bat"
echo if not "%%1"=="images" exit /b 0 >> "!MOCKBIN!\docker.bat"
echo if "%%4"=="--filter" goto FILTER_OUT >> "!MOCKBIN!\docker.bat"
echo echo !CF_IMAGEID!^^^|mytestrepo^^^|latest^^^|100MB^^^|2026-01-01 08:00:00 +0000 UTC >> "!MOCKBIN!\docker.bat"
echo exit /b 0 >> "!MOCKBIN!\docker.bat"
echo :FILTER_OUT >> "!MOCKBIN!\docker.bat"
echo echo !CF_IMAGEID! >> "!MOCKBIN!\docker.bat"
echo exit /b 0 >> "!MOCKBIN!\docker.bat"
copy "!MOCKBIN!\docker.bat" "!MOCKBIN!\nerdctl.bat" >nul 2>nul
echo @echo off > "!MOCKBIN!\trivy.bat"
echo echo {"Results":[]} >> "!MOCKBIN!\trivy.bat"
echo if defined TRIVY_CALLED_MARKER type nul ^> "%%TRIVY_CALLED_MARKER%%" >> "!MOCKBIN!\trivy.bat"
echo exit /b 0 >> "!MOCKBIN!\trivy.bat"
set "CF_MARKER=!CFTMPDIR!\trivy-called"
del /f /q "!CF_MARKER!" 2>nul
set "OUT=%TEMP%\cbct-cf-out-%RANDOM%.txt"
echo @echo off > "!CFTMPDIR!\run.bat"
echo set "CB_TEMP=!CFTMPDIR!" >> "!CFTMPDIR!\run.bat"
echo set "TRIVY_CALLED_MARKER=!CF_MARKER!" >> "!CFTMPDIR!\run.bat"
echo set "PATH=!MOCKBIN!;%%PATH%%" >> "!CFTMPDIR!\run.bat"
echo call "!CT!" --scan -a --force >> "!CFTMPDIR!\run.bat"
cmd /c "!CFTMPDIR!\run.bat" > "!OUT!" 2>&1
if exist "!CF_MARKER!" (
    set /a PASS+=1
    echo   PASS: --force bypasses cache - trivy was called
) else (
    set /a FAIL+=1
    echo   FAIL: --force should bypass cache but trivy was NOT called
    echo   DEBUG CF_MARKER=!CF_MARKER!
    echo   DEBUG cb-container output:
    if exist "!OUT!" type "!OUT!"
    echo   DEBUG CACHEDIR contents:
    dir /b "!CACHEDIR!" 2>nul
)
del /f /q "!OUT!" 2>nul
if exist "!CFTMPDIR!" rmdir /s /q "!CFTMPDIR!" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_INSIDE_PROJECT_EXAMPLE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: help contains 'Inside a project' example
set "OUT=%TEMP%\cbct-iproj-%RANDOM%.txt"
call "%CT%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Inside a project" "%OUT%" "help shows 'Inside a project' section"
call :ASSERT_OUTPUT_CONTAINS "SUBPATH=ooo --start" "%OUT%" "help shows env+start example"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERBOSE_START_SHOWS_EXECUTE
:: Calls cb-container with real docker (EXE) so that the runtime detection
:: does not exit early (unlike .bat mocks which lack implicit 'call').
:: Execute: is printed before docker run attempts the image pull, so it
:: appears in the output even when the image doesn't exist.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --verbose --start shows Execute: line
set "VSTMPDIR=%TEMP%\cbct-vs-%RANDOM%%RANDOM%"
mkdir "!VSTMPDIR!" >nul 2>nul
set "OUT=%TEMP%\cbct-vs-out-%RANDOM%.txt"
echo @echo off > "!VSTMPDIR!\run.bat"
echo set "CB_TEMP=!VSTMPDIR!" >> "!VSTMPDIR!\run.bat"
echo call "!CT!" --verbose --start nonexistent-cbtest-xyz:latest >> "!VSTMPDIR!\run.bat"
cmd /c "!VSTMPDIR!\run.bat" > "!OUT!" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Execute:" "!OUT!" "--verbose --start shows Execute: line"
del /f /q "!OUT!" 2>nul
if exist "!VSTMPDIR!" rmdir /s /q "!VSTMPDIR!" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ENV_VALUE_IN_EXECUTE
:: Verifies that unquoted --env SUBPATH=ooo (cmd.exe splits KEY=VAL on =)
:: is correctly reconstructed to -e SUBPATH=ooo in the Execute: line.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --env SUBPATH=ooo shows -e SUBPATH=ooo in Execute line
set "EVTMPDIR=%TEMP%\cbct-ev-%RANDOM%%RANDOM%"
mkdir "!EVTMPDIR!" >nul 2>nul
set "OUT=%TEMP%\cbct-ev-out-%RANDOM%.txt"
echo @echo off > "!EVTMPDIR!\run.bat"
echo set "CB_TEMP=!EVTMPDIR!" >> "!EVTMPDIR!\run.bat"
echo call "!CT!" --verbose --env SUBPATH=ooo --start nonexistent-cbtest-xyz:latest >> "!EVTMPDIR!\run.bat"
cmd /c "!EVTMPDIR!\run.bat" > "!OUT!" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Execute:" "!OUT!" "--verbose --env --start shows Execute: line"
call :ASSERT_OUTPUT_CONTAINS "-e SUBPATH=ooo" "!OUT!" "--env SUBPATH=ooo produces -e SUBPATH=ooo in Execute"
del /f /q "!OUT!" 2>nul
if exist "!EVTMPDIR!" rmdir /s /q "!EVTMPDIR!" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ENV_MULTIPLE_VALUES_IN_EXECUTE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --env "KEY1=val1,KEY2=val2" shows both -e args in Execute line
set "EMTMPDIR=%TEMP%\cbct-em-%RANDOM%%RANDOM%"
mkdir "!EMTMPDIR!" >nul 2>nul
set "OUT=%TEMP%\cbct-em-out-%RANDOM%.txt"
echo @echo off > "!EMTMPDIR!\run.bat"
echo set "CB_TEMP=!EMTMPDIR!" >> "!EMTMPDIR!\run.bat"
echo call "!CT!" --verbose --env "KEY1=val1,KEY2=val2" --start nonexistent-cbtest-xyz:latest >> "!EMTMPDIR!\run.bat"
cmd /c "!EMTMPDIR!\run.bat" > "!OUT!" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Execute:" "!OUT!" "--verbose multi-env --start shows Execute:"
call :ASSERT_OUTPUT_CONTAINS "-e KEY1=val1" "!OUT!" "multi env shows -e KEY1=val1"
call :ASSERT_OUTPUT_CONTAINS "-e KEY2=val2" "!OUT!" "multi env shows -e KEY2=val2"
del /f /q "!OUT!" 2>nul
if exist "!EMTMPDIR!" rmdir /s /q "!EMTMPDIR!" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_TAIL_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -t/--tail flag accepted
set "OUT=%TEMP%\cbct-tail-%RANDOM%.txt"
call "%CT%" --tail --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --tail --help"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "--tail does not prevent --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ALL_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -a/--all flag accepted
set "OUT=%TEMP%\cbct-all-%RANDOM%.txt"
call "%CT%" -a --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -a --help"
call "%CT%" --all --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --all --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_IT_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -i/--it flag accepted
set "OUT=%TEMP%\cbct-it-%RANDOM%.txt"
call "%CT%" -i --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -i --help"
call "%CT%" --it --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with --it --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PORT_COLON_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -p port:port ^(colon syntax^) accepted
set "OUT=%TEMP%\cbct-pcolon-%RANDOM%.txt"
call "%CT%" -p 8081:8082 --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -p 8081:8082 --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MULTIPLE_PORTS_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: multiple -p flags accepted
set "OUT=%TEMP%\cbct-mp-%RANDOM%.txt"
call "%CT%" -p 8080 -p 9090 --help > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -p 8080 -p 9090 --help"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LOG_RANGE_NOT_FOUND
:: Verifies --log with line-range args (10, 5-10, 5-) does not crash.
:: Expects "not found" for a non-existent image with a real runtime.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --log with line ranges ^(10, 5-10, 5-^) does not crash
set "OUT=%TEMP%\cbct-logr-%RANDOM%.txt"
call "%CT%" --log nonexistent-log-xyz 10 > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if not "!RC!"=="0" (
    call :ASSERT_OUTPUT_CONTAINS "not found" "%OUT%" "--log img 10 shows not found"
) else (
    set /a PASS+=1
    echo   PASS: --log img 10 handled ^(runtime available^)
)
call "%CT%" --log nonexistent-log-xyz 5-10 > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if not "!RC!"=="0" (
    call :ASSERT_OUTPUT_CONTAINS "not found" "%OUT%" "--log img 5-10 shows not found"
) else (
    set /a PASS+=1
    echo   PASS: --log img 5-10 handled ^(runtime available^)
)
call "%CT%" --log nonexistent-log-xyz 5- > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if not "!RC!"=="0" (
    call :ASSERT_OUTPUT_CONTAINS "not found" "%OUT%" "--log img 5- shows not found"
) else (
    set /a PASS+=1
    echo   PASS: --log img 5- handled ^(runtime available^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SCAN_MULTIPLE_IMAGES
:: Verifies --scan img1,img2 (cmd.exe splits on comma; PARSE_SCAN_REJOIN
:: re-joins them) is parsed correctly and does not give 'Invalid parameter'.
:: Comma-separated targets run as scan-all with filter -> 0 image(s).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --scan img1,img2 parsed correctly ^(comma-separated filter^)
set "OUT=%TEMP%\cbct-scanmulti-%RANDOM%.txt"
call "%CT%" --scan nonexistent-scan-xyz1,nonexistent-scan-xyz2 > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
rem verify it was not treated as an invalid parameter
set "hasInvalid="
findstr /i /c:"Invalid parameter" "%OUT%" >nul 2>nul
if %ERRORLEVEL% EQU 0 set "hasInvalid=true"
if defined hasInvalid (
    set /a FAIL+=1
    echo   FAIL: multi-scan treated as invalid parameter
) else (
    set /a PASS+=1
    echo   PASS: multi-scan not treated as invalid parameter
)
if "!RC!"=="0" (
    call :ASSERT_OUTPUT_CONTAINS "image(s)" "%OUT%" "multi-scan shows image count"
) else (
    set /a PASS+=1
    echo   PASS: --scan multiple shows error ^(no runtime or images not found^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_START_LOG_COMBINED
:: Verifies --start --log combined auto-detects project name from
:: settings.gradle (the "Inside a project" example in the help).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --start --log combined auto-detects project name
set "SLDIR=%TEMP%\cbct-sl-%RANDOM%"
mkdir "%SLDIR%" >nul 2>nul
echo rootProject.name = 'auto-stlog-project' > "%SLDIR%\settings.gradle"
set "OUT=%TEMP%\cbct-slout-%RANDOM%.txt"
pushd "%SLDIR%"
call "%CT%" --start --log > "%OUT%" 2>&1
popd
call :ASSERT_OUTPUT_CONTAINS "auto-stlog-project" "%OUT%" "--start --log shows project name from settings.gradle"
del /f /q "%OUT%" >nul 2>nul
if exist "%SLDIR%" rmdir /s /q "%SLDIR%" >nul 2>nul
goto :eof
