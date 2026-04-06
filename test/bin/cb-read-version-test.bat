@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-read-version-test.bat
::
:: Tests for bin\include\read-version.bat: version file parsing,
:: qualifier handling, missing file behavior.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "PASS=0"
set "FAIL=0"
set "TMPDIR=%TEMP%\cb-read-version-test-%RANDOM%%RANDOM%"
mkdir "%TMPDIR%" >nul 2>nul

echo Running cb-read-version.bat tests...
echo Using: %SRC_ROOT%\bin\include\read-version.bat
echo\

call :TEST_READ_VERSION_BASIC
call :TEST_READ_VERSION_WITH_QUALIFIER
call :TEST_READ_VERSION_WITHOUT_QUALIFIER
call :TEST_READ_VERSION_MISSING_FILE
call :TEST_READ_VERSION_REAL_FILE

if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul

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
:TEST_READ_VERSION_BASIC
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: read-version.bat parses version file
set "VF=%TMPDIR%\VERSION-basic"
(echo major.number        = 2
echo minor.number        = 3
echo revision.number     = 4
echo qualifier           =) > "%VF%"
call "%SRC_ROOT%\bin\include\read-version.bat" "%VF%" false
call :ASSERT_EQ "2" "%major.number%" "major number is 2"
call :ASSERT_EQ "3" "%minor.number%" "minor number is 3"
call :ASSERT_EQ "4" "%revision.number%" "revision number is 4"
call :ASSERT_EQ "2.3.4" "%version.number%" "version number is 2.3.4"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_READ_VERSION_WITH_QUALIFIER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: read-version.bat includes qualifier when addQualifier=true
set "VF=%TMPDIR%\VERSION-qual"
(echo major.number        = 1
echo minor.number        = 0
echo revision.number     = 0
echo qualifier           = SNAPSHOT) > "%VF%"
call "%SRC_ROOT%\bin\include\read-version.bat" "%VF%" true
call :ASSERT_EQ "1.0.0-SNAPSHOT" "%version.number%" "version includes qualifier"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_READ_VERSION_WITHOUT_QUALIFIER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: read-version.bat excludes qualifier when addQualifier=false
set "VF=%TMPDIR%\VERSION-noq"
(echo major.number        = 1
echo minor.number        = 0
echo revision.number     = 0
echo qualifier           = SNAPSHOT) > "%VF%"
call "%SRC_ROOT%\bin\include\read-version.bat" "%VF%" false
call :ASSERT_EQ "1.0.0" "%version.number%" "version excludes qualifier"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_READ_VERSION_MISSING_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: read-version.bat returns n/a for missing file
call "%SRC_ROOT%\bin\include\read-version.bat" "%TMPDIR%\nonexistent" false
call :ASSERT_EQ "n/a" "%version.number%" "version is n/a for missing file"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_READ_VERSION_REAL_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: read-version.bat parses actual VERSION file
call "%SRC_ROOT%\bin\include\read-version.bat" "%SRC_ROOT%\VERSION" false
if defined version.number (
	set /a PASS+=1
	echo   PASS: parsed real VERSION file: %version.number%
) else (
	set /a FAIL+=1
	echo   FAIL: could not parse real VERSION file
)
goto :eof
