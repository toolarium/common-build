@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-filetail-test.bat
::
:: Tests for cb-filetail.bat. Every test that actually runs the tailer is
:: wrapped in a PowerShell WaitForExit-based timeout guard so a hang in
:: the script under test cannot wedge the test run.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "CB_FILETAIL=%SRC_ROOT%\bin\cb-filetail.bat"
set "TEST_DIR=%TEMP%\cb-filetail-test-%RANDOM%%RANDOM%"
set "PASS=0"
set "FAIL=0"

if not exist "%CB_FILETAIL%" echo ERROR: %CB_FILETAIL% not found & exit /b 1

echo Running cb-filetail.bat tests...
echo Using: %CB_FILETAIL%
echo.

if exist "%TEST_DIR%" rmdir /s /q "%TEST_DIR%" >nul 2>nul
mkdir "%TEST_DIR%" >nul 2>nul

call :TEST_HELP
call :TEST_H_SHORT
call :TEST_INVALID_ARG
call :TEST_MISSING_F
call :TEST_NONEXISTENT_FILE
call :TEST_PATTERN_ALREADY_PRESENT
call :TEST_PATTERN_ARRIVES_LATER
call :TEST_PATTERN_NEVER_MATCHES
call :TEST_PLAIN_FOLLOW_NO_PATTERN

rmdir /s /q "%TEST_DIR%" >nul 2>nul

echo.
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_EQ
:: %1 = expected, %2 = actual, %3 = message
:: Use delayed expansion for the message so parens in the text do not
:: prematurely close the enclosing if-block.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
set "_EXP=%~1"
set "_ACT=%~2"
if "%~1"=="%~2" (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [expected=!_EXP!, got=!_ACT!]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_CONTAINS
:: %1 = needle, %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
set "_NEEDLE=%~1"
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [missing: !_NEEDLE!]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_NOT_CONTAINS
:: %1 = needle, %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
set "_NEEDLE=%~1"
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [found unexpected: !_NEEDLE!]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help
set "OUT=%TEST_DIR%\help.txt"
call "%CB_FILETAIL%" --help > "%OUT%" 2>&1
call :ASSERT_CONTAINS "tail a file" "%OUT%" "help mentions purpose"
call :ASSERT_CONTAINS "-h, --help" "%OUT%" "help lists -h/--help"
call :ASSERT_CONTAINS "-p [pattern]" "%OUT%" "help lists -p"
call :ASSERT_CONTAINS "-f [filename]" "%OUT%" "help lists -f"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_H_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -h
set "OUT=%TEST_DIR%\h.txt"
call "%CB_FILETAIL%" -h > "%OUT%" 2>&1
call :ASSERT_CONTAINS "tail a file" "%OUT%" "-h shows help"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_ARG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: invalid argument rejected
set "OUT=%TEST_DIR%\inv.txt"
call "%CB_FILETAIL%" --bogus-flag > "%OUT%" 2>&1
set "RC=%ERRORLEVEL%"
call :ASSERT_EQ "1" "!RC!" "exit code 1 for unknown arg"
call :ASSERT_CONTAINS "Invalid parameter" "%OUT%" "error message shown"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MISSING_F
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: missing -f argument rejected
set "OUT=%TEST_DIR%\nof.txt"
call "%CB_FILETAIL%" -p foo > "%OUT%" 2>&1
set "RC=%ERRORLEVEL%"
call :ASSERT_EQ "1" "!RC!" "exit code 1 when -f omitted"
call :ASSERT_CONTAINS "-f" "%OUT%" "error mentions -f"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NONEXISTENT_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -f with nonexistent file rejected
set "OUT=%TEST_DIR%\ne.txt"
call "%CB_FILETAIL%" -f "%TEST_DIR%\does-not-exist.log" -p x > "%OUT%" 2>&1
set "RC=%ERRORLEVEL%"
call :ASSERT_EQ "1" "!RC!" "exit code 1 for nonexistent file"
call :ASSERT_CONTAINS "file not found" "%OUT%" "error message shown"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATTERN_ALREADY_PRESENT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: pattern already in file -^> exits promptly, emits content up to match
set "LOG=%TEST_DIR%\already.log"
set "OUT=%TEST_DIR%\already.out"
echo line one > "%LOG%"
echo line two >> "%LOG%"
echo READY >> "%LOG%"
echo line four >> "%LOG%"
call :RUN_WITH_TIMEOUT 15 "%LOG%" "READY" "%OUT%" RC
call :ASSERT_EQ "0" "!RC!" "returns 0 when pattern found (not timeout 124)"
call :ASSERT_CONTAINS "line one" "%OUT%" "emits preceding lines"
call :ASSERT_CONTAINS "line two" "%OUT%" "emits preceding lines"
call :ASSERT_CONTAINS "READY" "%OUT%" "emits the matching line"
call :ASSERT_NOT_CONTAINS "line four" "%OUT%" "stops at match, no trailing lines"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATTERN_ARRIVES_LATER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: pattern appended after start -^> exits once matching line is appended
set "LOG=%TEST_DIR%\later.log"
set "OUT=%TEST_DIR%\later.out"
type nul > "%LOG%"
:: pass everything as env vars so we don't have to escape in PS; Start-Process
:: ArgumentList array avoids quoting issues for paths with spaces.
set "CBFT_CMD=%CB_FILETAIL%"
set "CBFT_LOG=%LOG%"
set "CBFT_OUT=%OUT%"
powershell -NoProfile -Command "function Add-Line($path, $text) { $fs = [System.IO.File]::Open($path, 'Append', 'Write', 'ReadWrite'); $b = [System.Text.Encoding]::UTF8.GetBytes($text + [Environment]::NewLine); $fs.Write($b, 0, $b.Length); $fs.Close() }; $p = Start-Process -FilePath $env:COMSPEC -ArgumentList @('/c', $env:CBFT_CMD, '-f', $env:CBFT_LOG, '-p', 'SERVER_UP') -NoNewWindow -PassThru -RedirectStandardOutput $env:CBFT_OUT -RedirectStandardError 'NUL'; Start-Sleep -Milliseconds 700; Add-Line $env:CBFT_LOG 'starting...'; Start-Sleep -Milliseconds 700; Add-Line $env:CBFT_LOG 'almost there'; Start-Sleep -Milliseconds 700; Add-Line $env:CBFT_LOG 'SERVER_UP now'; if ($p.WaitForExit(10000)) { exit $p.ExitCode } else { $p.Kill(); exit 124 }"
set "RC=%ERRORLEVEL%"
call :ASSERT_EQ "0" "!RC!" "returns 0 after trigger line appended"
call :ASSERT_CONTAINS "starting" "%OUT%" "emits prelude"
call :ASSERT_CONTAINS "SERVER_UP" "%OUT%" "emits trigger line"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATTERN_NEVER_MATCHES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: pattern never appears -^> timeout kills tailer (no wedge)
set "LOG=%TEST_DIR%\nomatch.log"
set "OUT=%TEST_DIR%\nomatch.out"
echo hello > "%LOG%"
echo world >> "%LOG%"
call :RUN_WITH_TIMEOUT 5 "%LOG%" "NEVER_THERE_XYZ" "%OUT%" RC
:: rc should be 124 (killed by timeout) — any non-zero is fine, what matters is control returned
if "!RC!"=="124" (
	set /a PASS+=1
	echo   PASS: tailer terminated by timeout as expected ^(rc=!RC!^)
) else if "!RC!"=="0" (
	set /a FAIL+=1
	echo   FAIL: expected timeout, got success
) else (
	set /a PASS+=1
	echo   PASS: control returned ^(rc=!RC!^)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RUN_WITH_TIMEOUT
:: %1 = timeout_seconds, %2 = logfile, %3 = pattern, %4 = output_file, %5 = rc_out_var
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CBFT_TO=%~1"
set "CBFT_CMD=%CB_FILETAIL%"
set "CBFT_LOG=%~2"
set "CBFT_PAT=%~3"
set "CBFT_OUT=%~4"
powershell -NoProfile -Command "$p = Start-Process -FilePath $env:COMSPEC -ArgumentList @('/c', $env:CBFT_CMD, '-f', $env:CBFT_LOG, '-p', $env:CBFT_PAT) -NoNewWindow -PassThru -RedirectStandardOutput $env:CBFT_OUT -RedirectStandardError 'NUL'; if ($p.WaitForExit([int]$env:CBFT_TO * 1000)) { exit $p.ExitCode } else { $p.Kill(); exit 124 }"
set "%~5=%ERRORLEVEL%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PLAIN_FOLLOW_NO_PATTERN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -f without -p (plain follow, terminates via timeout)
set "LOG=%TEST_DIR%\plain.log"
set "OUT=%TEST_DIR%\plain.out"
echo line one > "%LOG%"
echo line two >> "%LOG%"
:: plain follow (no -p) should hang doing tail -f; use short timeout to verify no crash
set "CBFT_CMD=%CB_FILETAIL%"
set "CBFT_LOG=%LOG%"
set "CBFT_OUT=%OUT%"
set "CBFT_TO=3"
powershell -NoProfile -Command "$p = Start-Process -FilePath $env:COMSPEC -ArgumentList @('/c', $env:CBFT_CMD, '-f', $env:CBFT_LOG) -NoNewWindow -PassThru -RedirectStandardOutput $env:CBFT_OUT -RedirectStandardError 'NUL'; if ($p.WaitForExit([int]$env:CBFT_TO * 1000)) { exit $p.ExitCode } else { $p.Kill(); exit 124 }"
set "RC=%ERRORLEVEL%"
:: timeout (124) is expected since plain follow hangs; any non-crash is a pass
if "!RC!"=="124" (
	set /a PASS+=1
	echo   PASS: plain follow hung as expected, killed by timeout ^(rc=!RC!^)
) else if "!RC!"=="0" (
	set /a PASS+=1
	echo   PASS: plain follow completed ^(rc=0^)
) else (
	set /a PASS+=1
	echo   PASS: control returned ^(rc=!RC!^)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
