@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-lock-unlock-test.bat
::
:: Tests for bin\include\lock-unlock.bat: lock creation, unlock removal,
:: nonexistent file handling.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "PASS=0"
set "FAIL=0"
set "TMPDIR=%TEMP%\cb-lock-unlock-test-%RANDOM%%RANDOM%"
mkdir "%TMPDIR%" >nul 2>nul

echo Running cb-lock-unlock.bat tests...
echo Using: %SRC_ROOT%\bin\include\lock-unlock.bat
echo\

call :TEST_LOCK_CREATES_FILE
call :TEST_UNLOCK_REMOVES_FILE
call :TEST_UNLOCK_NONEXISTENT

if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_FILE_EXISTS
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
:ASSERT_FILE_MISSING
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist "%~1" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 ^(file exists: %~1^)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LOCK_CREATES_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: lock creates lock file
set "LF=%TMPDIR%\test.lock"
if exist "%LF%" del /f /q "%LF%" >nul 2>nul
set "CB_INSTALL_SILENT=true"
call "%SRC_ROOT%\bin\include\lock-unlock.bat" "%LF%" 60
call :ASSERT_FILE_EXISTS "%LF%" "lock file created"
if exist "%LF%" del /f /q "%LF%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_UNLOCK_REMOVES_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: unlock removes lock file
set "LF=%TMPDIR%\test-unlock.lock"
echo 12345=9999 > "%LF%"
set "CB_INSTALL_SILENT=true"
call "%SRC_ROOT%\bin\include\lock-unlock.bat" --unlock "%LF%"
call :ASSERT_FILE_MISSING "%LF%" "lock file removed"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_UNLOCK_NONEXISTENT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: unlock on nonexistent file does not error
set "LF=%TMPDIR%\nonexistent.lock"
if exist "%LF%" del /f /q "%LF%" >nul 2>nul
set "CB_INSTALL_SILENT=true"
call "%SRC_ROOT%\bin\include\lock-unlock.bat" --unlock "%LF%"
set /a PASS+=1
echo   PASS: unlock on missing file did not crash
goto :eof
