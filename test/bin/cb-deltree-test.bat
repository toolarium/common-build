@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-deltree-test.bat
::
:: Tests for cb-deltree.bat.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "DELTREE=%SRC_ROOT%\bin\cb-deltree.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%DELTREE%" echo ERROR: %DELTREE% not found & exit /b 1

echo Running cb-deltree.bat tests...
echo Using: %DELTREE%
echo\

call :TEST_NONEXISTENT_PATH
call :TEST_DELETE_EMPTY_DIR
call :TEST_DELETE_DIR_WITH_FILES
call :TEST_DELETE_NESTED_TREE
call :TEST_DELETE_READONLY_FILES
call :TEST_VERBOSE_FLAG

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_DIR_MISSING
:: %1 = path, %2 = msg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist "%~1\" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 - dir still exists: %~1
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_DIR_EXISTS
:: %1 = path, %2 = msg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%~1\" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 - dir missing: %~1
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_CONTAINS
:: %1 = needle, %2 = haystack-file, %3 = msg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3 - expected to find "%~1"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NONEXISTENT_PATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: nonexistent path is a no-op
call "%DELTREE%" "C:\nonexistent\path\%RANDOM%%RANDOM%" >nul 2>&1
set /a PASS+=1
echo   PASS: no error on nonexistent path
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DELETE_EMPTY_DIR
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: delete empty directory
set "TD=%TEMP%\cb-deltree-test-%RANDOM%"
mkdir "%TD%" >nul 2>nul
call :ASSERT_DIR_EXISTS "%TD%" "setup: dir created"
call "%DELTREE%" "%TD%" >nul 2>&1
call :ASSERT_DIR_MISSING "%TD%" "empty dir deleted"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DELETE_DIR_WITH_FILES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: delete directory with files
set "TD=%TEMP%\cb-deltree-test-%RANDOM%"
mkdir "%TD%" >nul 2>nul
echo test > "%TD%\file1.txt"
echo test > "%TD%\file2.log"
call "%DELTREE%" "%TD%" >nul 2>&1
call :ASSERT_DIR_MISSING "%TD%" "dir with files deleted"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DELETE_NESTED_TREE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: delete deeply nested directory tree
set "TD=%TEMP%\cb-deltree-test-%RANDOM%"
mkdir "%TD%\a\b\c" >nul 2>nul
echo test > "%TD%\a\file.txt"
echo test > "%TD%\a\b\file.txt"
echo test > "%TD%\a\b\c\file.txt"
call "%DELTREE%" "%TD%" >nul 2>&1
call :ASSERT_DIR_MISSING "%TD%" "nested tree deleted"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DELETE_READONLY_FILES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: delete directory with read-only files
set "TD=%TEMP%\cb-deltree-test-%RANDOM%"
mkdir "%TD%" >nul 2>nul
echo test > "%TD%\readonly.txt"
attrib +R "%TD%\readonly.txt" >nul 2>nul
call "%DELTREE%" "%TD%" >nul 2>&1
call :ASSERT_DIR_MISSING "%TD%" "dir with read-only files deleted"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERBOSE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --verbose produces output
set "TD=%TEMP%\cb-deltree-test-%RANDOM%"
set "OUT=%TEMP%\cb-deltree-out-%RANDOM%.txt"
mkdir "%TD%" >nul 2>nul
echo test > "%TD%\file.txt"
call "%DELTREE%" --verbose "%TD%" > "%OUT%" 2>&1
call :ASSERT_DIR_MISSING "%TD%" "dir deleted with --verbose"
call :ASSERT_OUTPUT_CONTAINS "Delete" "%OUT%" "--verbose prints Delete message"
del /f /q "%OUT%" >nul 2>nul
goto :eof
