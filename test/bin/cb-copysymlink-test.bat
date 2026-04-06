@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-copysymlink-test.bat
::
:: Tests for cb-copysymlink.bat.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "COPYSYM=%SRC_ROOT%\bin\cb-copysymlink.bat"
set "PASS=0"
set "FAIL=0"

if not exist "%COPYSYM%" echo ERROR: %COPYSYM% not found & exit /b 1

echo Running cb-copysymlink.bat tests...
echo Using: %COPYSYM%
echo\

call :TEST_HELP
call :TEST_MISSING_ARGS
call :TEST_NONEXISTENT_SOURCE
call :TEST_COPY_JUNCTIONS
call :TEST_SILENT_FLAG
call :TEST_OVERWRITE_EXISTING

call :CLEANUP

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEANUP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%TEMP%\cb-copysym-test-*" (
	for /d %%D in ("%TEMP%\cb-copysym-test-*") do rmdir /s /q "%%D" >nul 2>nul
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
:ASSERT_IS_JUNCTION
:: %1 = path, %2 = msg
:: Verifies a directory exists and is a junction (NTFS reparse point)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist "%~1\" (
	set /a FAIL+=1
	echo   FAIL: %~2 - does not exist: %~1
	goto :eof
)
dir /AL "%~dp1" 2>nul | findstr /c:"%~nx1" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 - not a junction: %~1
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help
set "OUT=%TEMP%\cb-copysym-help-%RANDOM%.txt"
call "%COPYSYM%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "copy a folder of symbolic links" "%OUT%" "help shows purpose"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "help shows usage"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MISSING_ARGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: no arguments shows help
set "OUT=%TEMP%\cb-copysym-noarg-%RANDOM%.txt"
call "%COPYSYM%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "no args shows usage"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NONEXISTENT_SOURCE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: nonexistent source directory
set "OUT=%TEMP%\cb-copysym-nosrc-%RANDOM%.txt"
call "%COPYSYM%" "C:\nonexistent\%RANDOM%" "%TEMP%\cb-copysym-dest-%RANDOM%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Could not found source folder" "%OUT%" "error for nonexistent source"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_COPY_JUNCTIONS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: copy junctions from source to destination
set "TD=%TEMP%\cb-copysym-test-%RANDOM%"
set "SRC=%TD%\source"
set "DST=%TD%\dest"
set "TARGET=%TD%\real-target"

:: create a real directory to be the junction target
mkdir "%TARGET%" >nul 2>nul
echo test > "%TARGET%\payload.txt"

:: create source dir with a junction inside
mkdir "%SRC%" >nul 2>nul
mklink /J "%SRC%\mylink" "%TARGET%" >nul 2>nul

:: run copysymlink
call "%COPYSYM%" "%SRC%" "%DST%" >nul 2>&1
call :ASSERT_DIR_EXISTS "%DST%" "destination directory created"
call :ASSERT_IS_JUNCTION "%DST%\mylink" "junction copied to destination"

:: verify the copied junction actually points to the right target
if exist "%DST%\mylink\payload.txt" (
	set /a PASS+=1
	echo   PASS: copied junction resolves to target content
) else (
	set /a FAIL+=1
	echo   FAIL: copied junction does not resolve to target content
)

:: cleanup
rmdir "%SRC%\mylink" >nul 2>nul
rmdir "%DST%\mylink" >nul 2>nul
rmdir /s /q "%TD%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SILENT_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --silent suppresses output
set "TD=%TEMP%\cb-copysym-test-%RANDOM%"
set "SRC=%TD%\source"
set "DST=%TD%\dest"
set "TARGET=%TD%\real-target"
set "OUT=%TEMP%\cb-copysym-silent-%RANDOM%.txt"

mkdir "%TARGET%" >nul 2>nul
echo test > "%TARGET%\payload.txt"
mkdir "%SRC%" >nul 2>nul
mklink /J "%SRC%\mylink" "%TARGET%" >nul 2>nul

call "%COPYSYM%" --silent "%SRC%" "%DST%" > "%OUT%" 2>&1

:: output should be empty in silent mode
for %%A in ("%OUT%") do set "FILESIZE=%%~zA"
if "!FILESIZE!"=="0" (
	set /a PASS+=1
	echo   PASS: --silent produces no output
) else (
	set /a FAIL+=1
	echo   FAIL: --silent produced output
)

del /f /q "%OUT%" >nul 2>nul
rmdir "%SRC%\mylink" >nul 2>nul
rmdir "%DST%\mylink" >nul 2>nul
rmdir /s /q "%TD%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_OVERWRITE_EXISTING
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: overwrites existing junction in destination
set "TD=%TEMP%\cb-copysym-test-%RANDOM%"
set "SRC=%TD%\source"
set "DST=%TD%\dest"
set "TARGET1=%TD%\target-old"
set "TARGET2=%TD%\target-new"

:: set up two different targets
mkdir "%TARGET1%" >nul 2>nul
echo old > "%TARGET1%\marker.txt"
mkdir "%TARGET2%" >nul 2>nul
echo new > "%TARGET2%\marker.txt"

:: create source with junction to new target
mkdir "%SRC%" >nul 2>nul
mklink /J "%SRC%\mylink" "%TARGET2%" >nul 2>nul

:: create dest with pre-existing junction to old target
mkdir "%DST%" >nul 2>nul
mklink /J "%DST%\mylink" "%TARGET1%" >nul 2>nul

:: run copysymlink — should overwrite old junction
call "%COPYSYM%" --silent "%SRC%" "%DST%" >nul 2>&1

:: verify the junction now points to the new target
findstr /c:"new" "%DST%\mylink\marker.txt" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: junction overwritten with new target
) else (
	set /a FAIL+=1
	echo   FAIL: junction still points to old target
)

rmdir "%SRC%\mylink" >nul 2>nul
rmdir "%DST%\mylink" >nul 2>nul
rmdir /s /q "%TD%" >nul 2>nul
goto :eof
