@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-cleanpath-test.bat
::
:: Tests for cb-cleanpath.bat: --help, --path filtering, --verbose.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "CP=%SRC_ROOT%\bin\cb-cleanpath.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%CP%" echo ERROR: %CP% not found & exit /b 1

echo Running cb-cleanpath.bat tests...
echo Using: %CP%
echo\

call :TEST_HELP
call :TEST_PATH_REMOVES_MATCHING
call :TEST_PATH_KEEPS_NON_MATCHING
call :TEST_PATH_CASE_INSENSITIVE
call :TEST_PATH_MULTIPLE_MATCHES
call :TEST_VERBOSE_FLAG

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_EQ
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
if "%~1"=="%~2" (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [expected=%~1, got=%~2]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_CONTAINS
:: %1=needle, %2=haystack, %3=message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
echo %~2 | findstr /i /c:"%~1" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [missing: %~1]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_NOT_CONTAINS
:: %1=needle, %2=haystack, %3=message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
echo %~2 | findstr /i /c:"%~1" >nul 2>nul
if !ERRORLEVEL! NEQ 0 (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [unexpected: %~1]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help
set "OUT=%TEMP%\cbcp-help-%RANDOM%.txt"
call "%CP%" --help > "%OUT%" 2>&1
findstr /c:"cb-cleanpath" "%OUT%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: help mentions cb-cleanpath
) else (
	set /a FAIL+=1
	echo   FAIL: help missing cb-cleanpath
)
findstr /c:"--path" "%OUT%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: help lists --path
) else (
	set /a FAIL+=1
	echo   FAIL: help missing --path
)
findstr /c:"--user" "%OUT%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: help lists --user
) else (
	set /a FAIL+=1
	echo   FAIL: help missing --user
)
findstr /c:"--system" "%OUT%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: help lists --system
) else (
	set /a FAIL+=1
	echo   FAIL: help missing --system
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATH_REMOVES_MATCHING
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --path removes matching entries
:: Save original PATH
set "SAVE_PATH=%PATH%"
:: Set a controlled PATH with a known entry to remove
set "PATH=C:\keep1;C:\remove-toolarium-junk;C:\keep2"
call "%CP%" --path toolarium
:: PATH should no longer contain toolarium
call :ASSERT_NOT_CONTAINS "toolarium" "%PATH%" "toolarium entry removed from PATH"
call :ASSERT_CONTAINS "keep1" "%PATH%" "keep1 still in PATH"
call :ASSERT_CONTAINS "keep2" "%PATH%" "keep2 still in PATH"
:: Restore PATH
set "PATH=%SAVE_PATH%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATH_KEEPS_NON_MATCHING
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --path keeps non-matching entries
set "SAVE_PATH=%PATH%"
set "PATH=C:\alpha;C:\beta;C:\gamma"
call "%CP%" --path zzz-no-match
:: Nothing should be removed
call :ASSERT_CONTAINS "alpha" "%PATH%" "alpha still in PATH"
call :ASSERT_CONTAINS "beta" "%PATH%" "beta still in PATH"
call :ASSERT_CONTAINS "gamma" "%PATH%" "gamma still in PATH"
set "PATH=%SAVE_PATH%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATH_CASE_INSENSITIVE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --path match is case-insensitive
set "SAVE_PATH=%PATH%"
set "PATH=C:\keep;C:\MyToolarium\bin;C:\also-keep"
call "%CP%" --path TOOLARIUM
call :ASSERT_NOT_CONTAINS "Toolarium" "%PATH%" "case-insensitive removal works"
call :ASSERT_CONTAINS "keep" "%PATH%" "non-matching entries preserved"
set "PATH=%SAVE_PATH%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATH_MULTIPLE_MATCHES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --path removes multiple matching entries
set "SAVE_PATH=%PATH%"
set "PATH=C:\keep;C:\toolarium-v1;C:\middle;C:\toolarium-v2"
call "%CP%" --path toolarium
call :ASSERT_NOT_CONTAINS "toolarium" "%PATH%" "all toolarium entries removed"
call :ASSERT_CONTAINS "keep" "%PATH%" "keep entry preserved"
call :ASSERT_CONTAINS "middle" "%PATH%" "middle entry preserved"
set "PATH=%SAVE_PATH%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERBOSE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --verbose produces output
set "SAVE_PATH=%PATH%"
set "PATH=C:\a;C:\b-remove;C:\c"
set "OUT=%TEMP%\cbcp-verb-%RANDOM%.txt"
call "%CP%" --verbose --path remove > "%OUT%" 2>&1
findstr /c:"Clean path" "%OUT%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: --verbose shows clean path message
) else (
	set /a FAIL+=1
	echo   FAIL: --verbose missing clean path message
)
del /f /q "%OUT%" >nul 2>nul
set "PATH=%SAVE_PATH%"
goto :eof
