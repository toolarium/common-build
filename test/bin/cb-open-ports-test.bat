@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-open-ports-test.bat
::
:: Tests for cb-open-ports.bat.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
:: always resolve source root from the test script location (ignore any pre-set CB_HOME)
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "OP=%SRC_ROOT%\bin\cb-open-ports.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%OP%" echo ERROR: %OP% not found & exit /b 1

echo Running cb-open-ports.bat tests...
echo Using: %OP%
echo\

call :TEST_HELP
call :TEST_INVALID_ARG
call :TEST_HEADER_PRESENT_BY_DEFAULT
call :TEST_Q_SUPPRESSES_HEADER
call :TEST_WRITE_TO_FILE
call :TEST_WRITE_CUSTOM_FILENAME
call :TEST_NONEXISTENT_PATH
call :TEST_LOCALHOST_FLAG
call :TEST_IGNORE_LOCALHOST_FLAG

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
:ASSERT_FILE_EXISTS
:: %1 = file, %2 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%~1" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 ^(file missing: %~1^)
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
set "OUT=%TEMP%\cbop-help-%RANDOM%.txt"
call "%OP%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "script to read all open ports" "%OUT%" "help mentions purpose"
call :ASSERT_OUTPUT_CONTAINS "-h, --help" "%OUT%" "help lists -h/--help"
call :ASSERT_OUTPUT_CONTAINS "Suppress header" "%OUT%" "help lists -q"
call :ASSERT_OUTPUT_CONTAINS "-l, --localhost" "%OUT%" "help lists -l/--localhost"
call :ASSERT_OUTPUT_CONTAINS "output path" "%OUT%" "help lists -p"
call :ASSERT_OUTPUT_CONTAINS "Defines the filename" "%OUT%" "help lists -f"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_ARG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: invalid argument rejected
set "OUT=%TEMP%\cbop-inv-%RANDOM%.txt"
call "%OP%" --not-a-real-arg > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Invalid parameter" "%OUT%" "error message shown"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HEADER_PRESENT_BY_DEFAULT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: header emitted by default
set "OUT=%TEMP%\cbop-hdr-%RANDOM%.txt"
call "%OP%" > "%OUT%" 2>&1
:: header is a line starting with "PORT" and containing "PID"
findstr /b /c:"PORT" "%OUT%" | findstr /c:"PID" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: header line contains PORT and PID
) else (
	set /a FAIL+=1
	echo   FAIL: header line missing PORT/PID
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_Q_SUPPRESSES_HEADER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -q suppresses header
set "OUT=%TEMP%\cbop-q-%RANDOM%.txt"
call "%OP%" -q > "%OUT%" 2>&1
:: header starts with "PORT" at beginning of line; data lines start with port numbers
findstr /b /c:"PORT" "%OUT%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
	set /a PASS+=1
	echo   PASS: -q suppresses header
) else (
	set /a FAIL+=1
	echo   FAIL: -q should suppress header line starting with PORT
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_WRITE_TO_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -p writes to file
set "TMPDIR=%TEMP%\cbop-out-%RANDOM%"
mkdir "%TMPDIR%" >nul 2>nul
call "%OP%" -p "%TMPDIR%" -q >nul 2>&1
call :ASSERT_FILE_EXISTS "%TMPDIR%\open-ports.dat" "output file created"
if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_WRITE_CUSTOM_FILENAME
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -f custom filename
set "TMPDIR=%TEMP%\cbop-out-%RANDOM%"
mkdir "%TMPDIR%" >nul 2>nul
call "%OP%" -p "%TMPDIR%" -f "custom.txt" -q >nul 2>&1
call :ASSERT_FILE_EXISTS "%TMPDIR%\custom.txt" "custom file created"
if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NONEXISTENT_PATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -p with nonexistent path
set "OUT=%TEMP%\cbop-nex-%RANDOM%.txt"
call "%OP%" -p "C:\nonexistent\xyz\abc" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "is not accessable" "%OUT%" "error message for bad path"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LOCALHOST_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -l includes localhost
set "OUT=%TEMP%\cbop-lh-%RANDOM%.txt"
call "%OP%" -l -q > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -l flag"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_IGNORE_LOCALHOST_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -i ignores localhost (default behavior)
set "OUT=%TEMP%\cbop-il-%RANDOM%.txt"
call "%OP%" -i -q > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!RC!" "exit code 0 with -i flag"
del /f /q "%OUT%" >nul 2>nul
goto :eof
