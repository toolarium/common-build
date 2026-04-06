@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-clean-files-test.bat
::
:: Tests for cb-clean-files.bat.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
:: always resolve source root from the test script location (ignore any pre-set CB_HOME)
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "CLEAN_FILES=%SRC_ROOT%\bin\cb-clean-files.bat"
set "TEST_DIR=%TEMP%\cb-clean-files-test-%RANDOM%"
set "PASS=0"
set "FAIL=0"

if not exist "%CLEAN_FILES%" echo ERROR: %CLEAN_FILES% not found & exit /b 1

echo Running cb-clean-files.bat tests...
echo Using: %CLEAN_FILES%
echo\

call :TEST_HELP
call :TEST_INVALID_DAYS
call :TEST_DANGEROUS_PATH_USERPROFILE
call :TEST_DANGEROUS_PATH_DRIVE_ROOT
call :TEST_DRY_RUN_KEEPS_FILES
call :TEST_DELETE_OLDER_THAN_DAYS
call :TEST_PATTERN_FILTER
call :TEST_NONEXISTENT_PATH
call :TEST_COUNT_REPORTED

call :TEARDOWN

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SETUP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%TEST_DIR%" rmdir /s /q "%TEST_DIR%" >nul 2>nul
mkdir "%TEST_DIR%" >nul 2>nul
mkdir "%TEST_DIR%\sub" >nul 2>nul
echo test > "%TEST_DIR%\old-file.log"
echo test > "%TEST_DIR%\new-file.log"
echo test > "%TEST_DIR%\sub\nested-old.log"
:: backdate the old files by 10 days using powershell
powershell -NoProfile -Command "$d = (Get-Date).AddDays(-10); (Get-Item '%TEST_DIR%\old-file.log').LastWriteTime = $d" >nul 2>nul
powershell -NoProfile -Command "$d = (Get-Date).AddDays(-10); (Get-Item '%TEST_DIR%\sub\nested-old.log').LastWriteTime = $d" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEARDOWN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%TEST_DIR%" rmdir /s /q "%TEST_DIR%" >nul 2>nul
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
:ASSERT_FILE_MISSING
:: %1 = file, %2 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist "%~1" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 ^(file still exists: %~1^)
)
goto :eof


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
:TEST_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help
set "OUT=%TEMP%\cbt-help-%RANDOM%.txt"
call "%CLEAN_FILES%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "clean files" "%OUT%" "help output contains 'clean files'"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_DAYS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: invalid --days value
set "OUT=%TEMP%\cbt-inv-%RANDOM%.txt"
call "%CLEAN_FILES%" --path "%TEMP%" --days abc > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Invalid --days" "%OUT%" "rejects non-numeric --days"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DANGEROUS_PATH_USERPROFILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: dangerous path (%%USERPROFILE%%) refused
set "OUT=%TEMP%\cbt-usr-%RANDOM%.txt"
call "%CLEAN_FILES%" --path "%USERPROFILE%" --days 1 > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Refusing to clean dangerous path" "%OUT%" "refuses %%USERPROFILE%%"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DANGEROUS_PATH_DRIVE_ROOT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: dangerous path (drive root) refused
set "OUT=%TEMP%\cbt-drv-%RANDOM%.txt"
call "%CLEAN_FILES%" --path "C:\" --days 1 > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Refusing to clean dangerous path" "%OUT%" "refuses drive root"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DRY_RUN_KEEPS_FILES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --dry-run does not delete
call :SETUP
set "OUT=%TEMP%\cbt-dry-%RANDOM%.txt"
call "%CLEAN_FILES%" --path "%TEST_DIR%" --days 5 --dry-run > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "DRY-RUN" "%OUT%" "dry-run output contains [DRY-RUN]"
call :ASSERT_FILE_EXISTS "%TEST_DIR%\old-file.log" "old file still exists after dry-run"
del /f /q "%OUT%" >nul 2>nul
call :TEARDOWN
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DELETE_OLDER_THAN_DAYS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: delete files older than N days
call :SETUP
call "%CLEAN_FILES%" --path "%TEST_DIR%" --days 5 --silent >nul 2>&1
call :ASSERT_FILE_MISSING "%TEST_DIR%\old-file.log" "old file deleted older than 5 days"
call :ASSERT_FILE_EXISTS "%TEST_DIR%\new-file.log" "new file kept"
:: subdir file should remain since forfiles is non-recursive
call :ASSERT_FILE_EXISTS "%TEST_DIR%\sub\nested-old.log" "nested file kept - non-recursive"
call :TEARDOWN
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATTERN_FILTER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --pattern filter
call :SETUP
echo test > "%TEST_DIR%\old-file.txt"
powershell -NoProfile -Command "$d = (Get-Date).AddDays(-10); (Get-Item '%TEST_DIR%\old-file.txt').LastWriteTime = $d" >nul 2>nul
call "%CLEAN_FILES%" --path "%TEST_DIR%" --pattern "*.log" --days 5 --silent >nul 2>&1
call :ASSERT_FILE_MISSING "%TEST_DIR%\old-file.log" "*.log deleted"
call :ASSERT_FILE_EXISTS "%TEST_DIR%\old-file.txt" "*.txt kept by pattern filter"
call :TEARDOWN
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NONEXISTENT_PATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: nonexistent path handled
set "OUT=%TEMP%\cbt-nex-%RANDOM%.txt"
call "%CLEAN_FILES%" --path "C:\nonexistent\xyz\abc" --days 1 > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "don't exist" "%OUT%" "nonexistent path message"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_COUNT_REPORTED
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: deletion count reported
call :SETUP
set "OUT=%TEMP%\cbt-cnt-%RANDOM%.txt"
call "%CLEAN_FILES%" --path "%TEST_DIR%" --days 5 > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Deleted 1 file" "%OUT%" "count of 1 reported"
del /f /q "%OUT%" >nul 2>nul
call :TEARDOWN
goto :eof
