@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-meminfo-test.bat
::
:: Tests for cb-meminfo.bat: --help, argument parsing, output formatting,
:: header suppression, timestamp column, and unit formatting.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "MI=%SRC_ROOT%\bin\cb-meminfo.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%MI%" echo ERROR: %MI% not found & exit /b 1

echo Running cb-meminfo.bat tests...
echo Using: %MI%
echo\

call :TEST_HELP
call :TEST_HELP_SHORT
call :TEST_INVALID_ARG
call :TEST_INVALID_PID
call :TEST_DEFAULT_OUTPUT
call :TEST_QUIET_SUPPRESSES_HEADER
call :TEST_TIMESTAMP_COLUMN
call :TEST_FORMAT_BYTES
call :TEST_FORMAT_KILOBYTES
call :TEST_FORMAT_MEGABYTES
call :TEST_FORMAT_GIGABYTES
call :TEST_FORMAT_TERABYTES
call :TEST_FORMAT_PETABYTES
call :TEST_JVM_WITHOUT_PID
call :TEST_QUIET_WITH_TIMESTAMP

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
:ASSERT_OUTPUT_NOT_CONTAINS
:: %1 = needle, %2 = haystack-file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3 ^(did not expect to find "%~1"^)
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
set "OUT=%TEMP%\cbmi-help-%RANDOM%.txt"
call "%MI%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "memory usage" "%OUT%" "help mentions 'memory usage'"
call :ASSERT_OUTPUT_CONTAINS "-h, --help" "%OUT%" "help lists -h/--help"
call :ASSERT_OUTPUT_CONTAINS "-q" "%OUT%" "help lists -q"
call :ASSERT_OUTPUT_CONTAINS "-ts" "%OUT%" "help lists -ts"
call :ASSERT_OUTPUT_CONTAINS "-jvm" "%OUT%" "help lists -jvm"
call :ASSERT_OUTPUT_CONTAINS "-b" "%OUT%" "help lists -b"
call :ASSERT_OUTPUT_CONTAINS "-k" "%OUT%" "help lists -k"
call :ASSERT_OUTPUT_CONTAINS "-m" "%OUT%" "help lists -m"
call :ASSERT_OUTPUT_CONTAINS "-g" "%OUT%" "help lists -g"
call :ASSERT_OUTPUT_CONTAINS "-pid" "%OUT%" "help lists -pid"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -h
set "OUT=%TEMP%\cbmi-h-%RANDOM%.txt"
call "%MI%" -h > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "memory usage" "%OUT%" "shows help text"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_ARG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: invalid argument rejected
set "OUT=%TEMP%\cbmi-inv-%RANDOM%.txt"
call "%MI%" --not-a-real-arg > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_OUTPUT_CONTAINS "Invalid parameter" "%OUT%" "error message shown"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_PID
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -pid with non-numeric value
set "OUT=%TEMP%\cbmi-pid-%RANDOM%.txt"
call "%MI%" -pid abc > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_OUTPUT_CONTAINS "Invalid pid" "%OUT%" "error for invalid pid"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DEFAULT_OUTPUT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: default output has header and data
set "OUT=%TEMP%\cbmi-def-%RANDOM%.txt"
call "%MI%" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_CONTAINS "Total" "%OUT%" "header contains Total"
call :ASSERT_OUTPUT_CONTAINS "Used" "%OUT%" "header contains Used"
call :ASSERT_OUTPUT_CONTAINS "Free" "%OUT%" "header contains Free"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_QUIET_SUPPRESSES_HEADER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -q suppresses header
set "OUT=%TEMP%\cbmi-q-%RANDOM%.txt"
call "%MI%" -q > "%OUT%" 2>&1
call :ASSERT_OUTPUT_NOT_CONTAINS "Total" "%OUT%" "-q suppresses Total header"
call :ASSERT_OUTPUT_NOT_CONTAINS "Used" "%OUT%" "-q suppresses Used header"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_TIMESTAMP_COLUMN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -ts adds timestamp column
set "OUT=%TEMP%\cbmi-ts-%RANDOM%.txt"
call "%MI%" -ts > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_CONTAINS "Timestamp" "%OUT%" "header contains Timestamp"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORMAT_KILOBYTES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -k formats in kilobytes
set "OUT=%TEMP%\cbmi-k-%RANDOM%.txt"
call "%MI%" -k > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_CONTAINS " K" "%OUT%" "output contains K unit"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORMAT_MEGABYTES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -m formats in megabytes
set "OUT=%TEMP%\cbmi-m-%RANDOM%.txt"
call "%MI%" -m > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_CONTAINS " M" "%OUT%" "output contains M unit"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORMAT_BYTES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -b formats in bytes
set "OUT=%TEMP%\cbmi-b-%RANDOM%.txt"
call "%MI%" -b > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORMAT_GIGABYTES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -g formats in gigabytes
set "OUT=%TEMP%\cbmi-g-%RANDOM%.txt"
call "%MI%" -g > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_CONTAINS " G" "%OUT%" "output contains G unit"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORMAT_TERABYTES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -t formats in terabytes
set "OUT=%TEMP%\cbmi-t-%RANDOM%.txt"
call "%MI%" -t > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_CONTAINS " T" "%OUT%" "output contains T unit"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORMAT_PETABYTES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -p formats in petabytes
set "OUT=%TEMP%\cbmi-p-%RANDOM%.txt"
call "%MI%" -p > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_CONTAINS " P" "%OUT%" "output contains P unit"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_JVM_WITHOUT_PID
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -jvm without -pid (no JVM columns)
set "OUT=%TEMP%\cbmi-jvm-%RANDOM%.txt"
call "%MI%" -jvm > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_CONTAINS "Total" "%OUT%" "header still contains Total"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_QUIET_WITH_TIMESTAMP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -q -ts combined
set "OUT=%TEMP%\cbmi-qts-%RANDOM%.txt"
call "%MI%" -q -ts > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0"
call :ASSERT_OUTPUT_NOT_CONTAINS "Timestamp" "%OUT%" "-q suppresses header even with -ts"
del /f /q "%OUT%" >nul 2>nul
goto :eof
