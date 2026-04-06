@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-install-e2e-test.bat
::
:: End-to-end test for cb-install.bat. Runs a full install against the
:: real GitHub releases API into a sandbox temp directory, then validates
:: the resulting artifacts. Requires network access.
::
:: Gated behind CB_INSTALL_TEST_E2E=1 so it is skipped by default.
:: Run with:  set CB_INSTALL_TEST_E2E=1 & test\bin\cb-install-e2e-test.bat
::
:: The test sets CB_INSTALL_NO_PERSIST=true so the installer does NOT
:: modify the real user's CB_HOME / PATH registry values.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "INST=%SRC_ROOT%\bin\cb-install.bat"
set "PASS=0"
set "FAIL=0"

if not "%CB_INSTALL_TEST_E2E%"=="1" (
	echo SKIP: cb-install-e2e-test.bat ^(set CB_INSTALL_TEST_E2E=1 to run^)
	exit /b 0
)

if not exist "%INST%" echo ERROR: %INST% not found & exit /b 1

:: sandbox dirs
set "SANDBOX=%TEMP%\cb-install-e2e-%RANDOM%%RANDOM%"
set "SANDBOX_DEVTOOLS=%SANDBOX%\devtools"
set "SANDBOX_TMP=%SANDBOX%\tmp"
mkdir "%SANDBOX%" >nul 2>nul
mkdir "%SANDBOX_DEVTOOLS%" >nul 2>nul
mkdir "%SANDBOX_TMP%" >nul 2>nul

if not exist "%SANDBOX%" echo ERROR: could not create sandbox %SANDBOX% & exit /b 1

echo Running cb-install.bat E2E test...
echo Using:    %INST%
echo Sandbox:  %SANDBOX%
echo\

echo STEP: run installer into sandbox
:: Run installer in a separate cmd.exe process to isolate setlocal/endlocal,
:: PATH length, and delayed-expansion interactions that cause exit code 255.
:: Run installer in isolated cmd.exe — set env vars inline to avoid
:: PATH overflow, delayed-expansion, and wrapper-file quoting issues.
set "ORIG_CB_HOME=%CB_HOME%"
set "ORIG_CB_DEVTOOLS=%CB_DEVTOOLS%"
set "ORIG_CB_TEMP=%CB_TEMP%"
set "CB_HOME="
set "CB_DEVTOOLS=!SANDBOX_DEVTOOLS!"
set "CB_TEMP=!SANDBOX_TMP!"
set "CB_INSTALL_NO_PERSIST=true"
cmd /V:OFF /c ""%INST%" --silent --force" > "!SANDBOX!\install.log" 2>&1
set "INSTALL_EXIT=!ERRORLEVEL!"
:: restore caller env
set "CB_HOME=%ORIG_CB_HOME%"
set "CB_DEVTOOLS=%ORIG_CB_DEVTOOLS%"
set "CB_TEMP=%ORIG_CB_TEMP%"
set "CB_INSTALL_NO_PERSIST="

call :ASSERT_EXIT_CODE "0" "!INSTALL_EXIT!" "installer exit code 0"
if not "!INSTALL_EXIT!"=="0" (
	echo\
	echo ----- install.log -----
	type "%SANDBOX%\install.log"
	echo -----------------------
)

echo\
echo STEP: verify installed artifacts

set "INSTALL_DIR="
for /d %%D in ("%SANDBOX_DEVTOOLS%\toolarium-common-build-*") do set "INSTALL_DIR=%%~fD"

if not defined INSTALL_DIR (
	set /a FAIL+=1
	echo   FAIL: no install directory found under %SANDBOX_DEVTOOLS%
) else (
	set /a PASS+=1
	echo   PASS: install directory present ^(!INSTALL_DIR!^)
	call :ASSERT_FILE_EXISTS "!INSTALL_DIR!\bin\cb"                                 "bin/cb present"
	call :ASSERT_FILE_EXISTS "!INSTALL_DIR!\bin\cb.bat"                             "bin/cb.bat present"
	call :ASSERT_FILE_EXISTS "!INSTALL_DIR!\conf\tool-version-default.properties"   "tool-version-default.properties present"
	call :ASSERT_DIR_EXISTS  "!INSTALL_DIR!\bin\packages"                           "bin/packages/ present"
	call :ASSERT_DIR_MISSING "!INSTALL_DIR!\.git"                                   ".git removed"
	call :ASSERT_DIR_MISSING "!INSTALL_DIR!\.github"                                ".github removed"
	call :ASSERT_DIR_MISSING "!INSTALL_DIR!\.claude"                                ".claude removed"
	call :ASSERT_DIR_MISSING "!INSTALL_DIR!\test"                                   "test/ removed"
	call :ASSERT_DIR_MISSING "!INSTALL_DIR!\testdata"                               "testdata/ removed"
	if exist "!INSTALL_DIR!\CLAUDE.md" (
		set /a FAIL+=1
		echo   FAIL: CLAUDE.md should have been removed
	) else (
		set /a PASS+=1
		echo   PASS: CLAUDE.md removed
	)
	:: docs\ must be KEPT - ships the release documentation
	call :ASSERT_DIR_EXISTS  "!INSTALL_DIR!\docs"                                   "docs/ kept - ships release documentation"
)

echo\
echo STEP: verify repository cache
set "REPO_ZIP="
for %%F in ("%SANDBOX_DEVTOOLS%\.repository\toolarium-common-build-*.zip") do set "REPO_ZIP=%%~fF"
if defined REPO_ZIP (
	set /a PASS+=1
	for %%A in ("!REPO_ZIP!") do echo   PASS: downloaded zip present ^(%%~nxA^)
) else (
	set /a FAIL+=1
	echo   FAIL: downloaded zip missing under %SANDBOX_DEVTOOLS%\.repository
)

echo\
echo STEP: verify installer did NOT touch real user CB_HOME
:: CB_INSTALL_NO_PERSIST=true should have prevented setx; real user HKCU\Environment
:: should be unchanged. Check that the registry value is unrelated to our sandbox.
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v CB_HOME 2^>nul ^| findstr /i "CB_HOME"') do set "REG_CB_HOME=%%B"
if defined REG_CB_HOME (
	echo !REG_CB_HOME! | findstr /c:"%SANDBOX%" >nul 2>nul
	if errorlevel 1 (
		set /a PASS+=1
		echo   PASS: real user CB_HOME untouched ^(!REG_CB_HOME!^)
	) else (
		set /a FAIL+=1
		echo   FAIL: real user CB_HOME was overwritten with sandbox path ^(!REG_CB_HOME!^)
	)
) else (
	set /a PASS+=1
	echo   PASS: real user CB_HOME not set ^(installer did not create it^)
)

echo\
echo STEP: verify installed cb.bat executes
if defined INSTALL_DIR if exist "!INSTALL_DIR!\bin\cb.bat" (
	set "VERSION_OUT=%SANDBOX%\version.txt"
	set "ORIG_CB_HOME2=%CB_HOME%"
	set "CB_HOME=!INSTALL_DIR!"
	call "!INSTALL_DIR!\bin\cb.bat" --version > "!VERSION_OUT!" 2>&1
	set "CB_HOME=!ORIG_CB_HOME2!"
	findstr /c:"toolarium" "!VERSION_OUT!" >nul 2>nul
	if !ERRORLEVEL! EQU 0 (
		set /a PASS+=1
		echo   PASS: cb.bat --version prints toolarium banner
	) else (
		set /a FAIL+=1
		echo   FAIL: cb.bat --version did not print toolarium banner
	)
)

echo\
echo STEP: cleanup sandbox
rmdir /s /q "%SANDBOX%" >nul 2>nul

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_EXIT_CODE
:: %1 = expected, %2 = actual, %3 = msg
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
:ASSERT_FILE_EXISTS
:: %1 = path, %2 = msg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%~1" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 ^(missing: %~1^)
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
	echo   FAIL: %~2 ^(dir missing: %~1^)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_DIR_MISSING
:: %1 = path, %2 = msg
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist "%~1\" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 ^(dir still exists: %~1^)
)
goto :eof
