@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-version-filter-test.bat
::
:: Tests for cb-version-filter.bat.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "VFILTER=%SRC_ROOT%\bin\cb-version-filter.bat"
set "TEST_DIR=%TEMP%\cb-version-filter-test-%RANDOM%"
set "PASS=0"
set "FAIL=0"

if not exist "%VFILTER%" echo ERROR: %VFILTER% not found & exit /b 1

echo Running cb-version-filter.bat tests...
echo Using: %VFILTER%
echo\

echo === Core tests ===
call :TEST_HELP
call :TEST_INVALID_ARG
call :TEST_INVERTFILTER_NO_SWALLOW
call :TEST_PATH_OPTION
call :TEST_NONEXISTENT_PATH

echo\
echo === printUsage example tests ===
call :TEST_EXAMPLE_1
call :TEST_EXAMPLE_2
call :TEST_EXAMPLE_3
call :TEST_EXAMPLE_4_INVERT
call :TEST_MAJORMINORMAX_CAP_OVERFLOW
call :TEST_EXAMPLE_5_PATH_INVERT

call :TEARDOWN

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SETUP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%TEST_DIR%" rmdir /s /q "%TEST_DIR%" >nul 2>nul
mkdir "%TEST_DIR%" >nul 2>nul
for %%V in (2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0) do mkdir "%TEST_DIR%\%%V" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEARDOWN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%TEST_DIR%" rmdir /s /q "%TEST_DIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_EQUALS
:: %1 = expected, %2 = actual, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~1"=="%~2" (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3
	echo         expected: [%~1]
	echo         actual:   [%~2]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_CONTAINS
:: %1 = needle, %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3 - missing: %~1
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_FILE_EQUALS
:: %1 = expected lines (space-separated), %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "GOT="
for /f "usebackq delims=" %%L in ("%~2") do set "GOT=!GOT! %%L"
:: trim leading space
if defined GOT if "!GOT:~0,1!"==" " set "GOT=!GOT:~1!"
call :ASSERT_EQUALS "%~1" "!GOT!" "%~3"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help
set "OUT=%TEMP%\cbvft-help-%RANDOM%.txt"
call "%VFILTER%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "filter version numbers" "%OUT%" "help mentions purpose"
call :ASSERT_OUTPUT_CONTAINS "--majorThreshold" "%OUT%" "help lists --majorThreshold"
call :ASSERT_OUTPUT_CONTAINS "--invertFilter" "%OUT%" "help lists --invertFilter"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_ARG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: invalid argument rejected
set "OUT=%TEMP%\cbvft-inv-%RANDOM%.txt"
call "%VFILTER%" --unknown-arg > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Invalid parameter" "%OUT%" "error message shown"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVERTFILTER_NO_SWALLOW
:: regression: --invertFilter must not consume next argument
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --invertFilter does not swallow next arg
set "O1=%TEMP%\cbvft-ns1-%RANDOM%.txt"
set "O2=%TEMP%\cbvft-ns2-%RANDOM%.txt"
echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 | call "%VFILTER%" --invertFilter --majorThreshold 2 --previousMajorPatchThreshold 2 > "%O1%"
echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 | call "%VFILTER%" --majorThreshold 2 --invertFilter --previousMajorPatchThreshold 2 > "%O2%"
fc "%O1%" "%O2%" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: same output regardless of --invertFilter position
) else (
	set /a FAIL+=1
	echo   FAIL: output differs based on --invertFilter position
)
del /f /q "%O1%" "%O2%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATH_OPTION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --path reads directory names as versions
call :SETUP
set "OUT=%TEMP%\cbvft-po-%RANDOM%.txt"
call "%VFILTER%" --path "%TEST_DIR%" --majorThreshold 2 --previousMajorPatchThreshold 2 > "%OUT%"
call :ASSERT_OUTPUT_CONTAINS "2.2.1" "%OUT%" "--path returns 2.2.1"
call :ASSERT_OUTPUT_CONTAINS "1.3.4" "%OUT%" "--path returns 1.3.4"
del /f /q "%OUT%" >nul 2>nul
call :TEARDOWN
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NONEXISTENT_PATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: nonexistent --path
call "%VFILTER%" --path "C:\nonexistent\xyz\abc" --majorThreshold 2 >nul 2>nul
if %ERRORLEVEL% EQU 1 (
	set /a PASS+=1
	echo   PASS: exit 1 on missing path
) else (
	set /a FAIL+=1
	echo   FAIL: expected exit 1, got %ERRORLEVEL%
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_EXAMPLE_1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: example 1 - --majorThreshold 2
set "OUT=%TEMP%\cbvft-e1-%RANDOM%.txt"
echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 | call "%VFILTER%" --majorThreshold 2 > "%OUT%"
call :ASSERT_FILE_EQUALS "2.2.1 2.1.2 1.3.4 1.2.1" "%OUT%" "example 1 output matches"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_EXAMPLE_2
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: example 2 - --majorThreshold 2 --previousMajorPatchThreshold 2
set "OUT=%TEMP%\cbvft-e2-%RANDOM%.txt"
echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 | call "%VFILTER%" --majorThreshold 2 --previousMajorPatchThreshold 2 > "%OUT%"
call :ASSERT_FILE_EQUALS "2.2.1 2.1.2 1.3.4 1.3.3 1.2.1 1.2.0" "%OUT%" "example 2 output matches"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_EXAMPLE_3
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: example 3 - explicit echo input
set "OUT=%TEMP%\cbvft-e3-%RANDOM%.txt"
echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 | call "%VFILTER%" --majorThreshold 2 --previousMajorPatchThreshold 2 > "%OUT%"
call :ASSERT_FILE_EQUALS "2.2.1 2.1.2 1.3.4 1.3.3 1.2.1 1.2.0" "%OUT%" "example 3 output matches"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_EXAMPLE_4_INVERT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: example 4 - --invertFilter returns versions to skip
set "OUT=%TEMP%\cbvft-e4-%RANDOM%.txt"
echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 | call "%VFILTER%" --majorThreshold 2 --previousMajorPatchThreshold 2 --invertFilter > "%OUT%"
call :ASSERT_FILE_EQUALS "2.2.0 2.1.1 2.1.0" "%OUT%" "example 4 invert output matches"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MAJORMINORMAX_CAP_OVERFLOW
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --majorMinorMax cap and --invertFilter overflow
set "O1=%TEMP%\cbvft-cap1-%RANDOM%.txt"
set "O2=%TEMP%\cbvft-cap2-%RANDOM%.txt"
echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 | call "%VFILTER%" --majorThreshold 2 --minorThreshold 2 --patchThreshold 2 --majorMinorMax 3 > "%O1%"
echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 | call "%VFILTER%" --majorThreshold 2 --minorThreshold 2 --patchThreshold 2 --majorMinorMax 3 --invertFilter > "%O2%"
call :ASSERT_FILE_EQUALS "2.2.1 2.2.0 2.1.2 2.1.1 1.3.4 1.3.3" "%O1%" "cap kept set"
call :ASSERT_FILE_EQUALS "2.1.0 1.2.1 1.2.0" "%O2%" "cap dropped set - inverted includes overflow"
del /f /q "%O1%" "%O2%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_EXAMPLE_5_PATH_INVERT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: example 5 - --path with --invertFilter
call :SETUP
set "OUT=%TEMP%\cbvft-e5-%RANDOM%.txt"
call "%VFILTER%" --path "%TEST_DIR%" --majorThreshold 2 --previousMajorPatchThreshold 2 --invertFilter > "%OUT%"
call :ASSERT_FILE_EQUALS "2.2.0 2.1.1 2.1.0" "%OUT%" "example 5 path+invert output matches"
del /f /q "%OUT%" >nul 2>nul
call :TEARDOWN
goto :eof
