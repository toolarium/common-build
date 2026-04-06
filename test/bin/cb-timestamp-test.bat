@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-timestamp-test.bat
::
:: Tests for bin/include/timestamp.bat.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "TS=%SRC_ROOT%\bin\include\timestamp.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%TS%" echo ERROR: %TS% not found & exit /b 1

echo Running timestamp.bat tests...
echo Using: %TS%
echo\

call :TEST_NO_ARGS
call :TEST_DEFAULT_FORMAT
call :TEST_CUSTOM_FORMAT
call :TEST_DATE_ONLY
call :TEST_TWO_CALLS_DIFFER_OR_EQUAL

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NO_ARGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: no arguments exits with error
set "RESULT="
call "%TS%"
if !ERRORLEVEL! NEQ 0 (
	set /a PASS+=1
	echo   PASS: exit code 1 when no args
) else (
	set /a FAIL+=1
	echo   FAIL: should exit with error when no args
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DEFAULT_FORMAT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: default format produces timestamp
set "MYTS="
call "%TS%" MYTS
if defined MYTS (
	:: default format: yyyy-MM-dd HH:mm:ss.fff — should contain a dash and a colon
	echo !MYTS! | findstr /c:"-" >nul 2>nul
	if !ERRORLEVEL! EQU 0 (
		echo !MYTS! | findstr /c:":" >nul 2>nul
		if !ERRORLEVEL! EQU 0 (
			set /a PASS+=1
			echo   PASS: default timestamp has expected format: !MYTS!
		) else (
			set /a FAIL+=1
			echo   FAIL: default timestamp missing colon: !MYTS!
		)
	) else (
		set /a FAIL+=1
		echo   FAIL: default timestamp missing dash: !MYTS!
	)
) else (
	set /a FAIL+=1
	echo   FAIL: MYTS variable not set
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_CUSTOM_FORMAT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: custom format yyyyMMddHHmmss
set "MYTS="
call "%TS%" MYTS "yyyyMMddHHmmss"
if defined MYTS (
	:: should be 14 digits with no separators — no dash, no colon, no space
	echo !MYTS! | findstr /c:"-" >nul 2>nul
	if !ERRORLEVEL! NEQ 0 (
		echo !MYTS! | findstr /c:":" >nul 2>nul
		if !ERRORLEVEL! NEQ 0 (
			set /a PASS+=1
			echo   PASS: custom format has no separators: !MYTS!
		) else (
			set /a FAIL+=1
			echo   FAIL: custom format contains colon: !MYTS!
		)
	) else (
		set /a FAIL+=1
		echo   FAIL: custom format contains dash: !MYTS!
	)
) else (
	set /a FAIL+=1
	echo   FAIL: MYTS variable not set with custom format
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DATE_ONLY
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: date-only format yyyy-MM-dd
set "MYTS="
call "%TS%" MYTS "yyyy-MM-dd"
if defined MYTS (
	:: should contain dashes but no colons (date only, no time)
	echo !MYTS! | findstr /c:"-" >nul 2>nul
	if !ERRORLEVEL! EQU 0 (
		echo !MYTS! | findstr /c:":" >nul 2>nul
		if !ERRORLEVEL! NEQ 0 (
			set /a PASS+=1
			echo   PASS: date-only format correct: !MYTS!
		) else (
			set /a FAIL+=1
			echo   FAIL: date-only format contains time: !MYTS!
		)
	) else (
		set /a FAIL+=1
		echo   FAIL: date-only format missing dashes: !MYTS!
	)
) else (
	set /a FAIL+=1
	echo   FAIL: MYTS variable not set with date-only format
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_TWO_CALLS_DIFFER_OR_EQUAL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: two calls produce valid timestamps
set "TS1="
set "TS2="
call "%TS%" TS1
call "%TS%" TS2
if defined TS1 if defined TS2 (
	set /a PASS+=1
	echo   PASS: both calls produced values: !TS1! / !TS2!
) else (
	set /a FAIL+=1
	echo   FAIL: one or both calls did not produce a value
)
goto :eof
