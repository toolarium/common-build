@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-update-custom-home-test.bat
::
:: Tests for bin\include\update-cb-custom-home.bat. Creates a local bare
:: git repo as a mock "custom config" remote, then exercises the update
:: script against it in a sandbox.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "UPDATE_SCRIPT=%SRC_ROOT%\bin\include\update-cb-custom-home.bat"
set "PASS=0"
set "FAIL=0"

set "SANDBOX=%TEMP%\cb-uch-test-%RANDOM%%RANDOM%"
mkdir "%SANDBOX%" >nul 2>nul

:: Check git is available
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
	echo SKIP: git not available
	exit /b 0
)

:: Set git identity for commits (env vars only, no global config change)
if not defined GIT_AUTHOR_NAME set "GIT_AUTHOR_NAME=cb-test"
if not defined GIT_AUTHOR_EMAIL set "GIT_AUTHOR_EMAIL=cb-test@localhost"
if not defined GIT_COMMITTER_NAME set "GIT_COMMITTER_NAME=cb-test"
if not defined GIT_COMMITTER_EMAIL set "GIT_COMMITTER_EMAIL=cb-test@localhost"

:: Build a sandbox CB_HOME with bin\include (copy so we can stub cb-credential)
set "SANDBOX_CB_HOME=%SANDBOX%\cb-home"
mkdir "%SANDBOX_CB_HOME%\bin" >nul 2>nul
mkdir "%SANDBOX_CB_HOME%\current" >nul 2>nul
mklink /J "%SANDBOX_CB_HOME%\conf" "%SRC_ROOT%\conf" >nul 2>nul
copy /y "%SRC_ROOT%\VERSION" "%SANDBOX_CB_HOME%\VERSION" >nul 2>nul
xcopy /E /I /Q "%SRC_ROOT%\bin\include" "%SANDBOX_CB_HOME%\bin\include" >nul 2>nul
:: Copy cb-deltree which is needed by the update script
if exist "%SRC_ROOT%\bin\cb-deltree.bat" copy /y "%SRC_ROOT%\bin\cb-deltree.bat" "%SANDBOX_CB_HOME%\bin\cb-deltree.bat" >nul 2>nul
:: Stub cb-credential.bat: always succeed (local bare repos have no credentials)
(echo @ECHO OFF
echo exit /b 0) > "%SANDBOX_CB_HOME%\bin\include\cb-credential.bat"

:: We also need a stub cb.bat for the git install fallback
(echo @ECHO OFF
echo exit /b 1) > "%SANDBOX_CB_HOME%\bin\cb.bat"

set "CB_HOME=%SANDBOX_CB_HOME%"

echo Running update-cb-custom-home.bat tests...
echo Using:   %UPDATE_SCRIPT%
echo Sandbox: %SANDBOX%
echo\

call :TEST_MISSING_ARGS
call :TEST_MISSING_URL
call :TEST_FRESH_CLONE
call :TEST_SAME_VERSION_SKIPS
call :TEST_NEW_VERSION_UPDATES
call :TEST_LOCK_FILE_CLEANED_UP
call :TEST_IGNORE_FILES_REMOVED

:: cleanup
if exist "%SANDBOX_CB_HOME%\conf" rmdir "%SANDBOX_CB_HOME%\conf" >nul 2>nul
if exist "%SANDBOX%" rmdir /s /q "%SANDBOX%" >nul 2>nul

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
:ASSERT_DIR_EXISTS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%~1\*" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 ^(dir missing: %~1^)
)
goto :eof


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
:CREATE_MOCK_REMOTE
:: %1 = version (e.g. 1.0.0)
:: Sets MOCK_REMOTE_DIR to the bare repo path
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "MOCK_REMOTE_DIR=%SANDBOX%\mock-remote.git"
set "MOCK_WORK_DIR=%SANDBOX%\mock-work"
if exist "%MOCK_REMOTE_DIR%" rmdir /s /q "%MOCK_REMOTE_DIR%" >nul 2>nul
if exist "%MOCK_WORK_DIR%" rmdir /s /q "%MOCK_WORK_DIR%" >nul 2>nul

git init --bare "%MOCK_REMOTE_DIR%" >nul 2>&1
git clone "%MOCK_REMOTE_DIR%" "%MOCK_WORK_DIR%" >nul 2>&1

:: Parse version parts
for /f "tokens=1,2,3 delims=." %%a in ("%~1") do (
	set "V_MAJOR=%%a"
	set "V_MINOR=%%b"
	set "V_REV=%%c"
)
(echo major.number        = !V_MAJOR!
echo minor.number        = !V_MINOR!
echo revision.number     = !V_REV!
echo qualifier           =) > "%MOCK_WORK_DIR%\VERSION"

mkdir "%MOCK_WORK_DIR%\conf" >nul 2>nul
echo # mock config > "%MOCK_WORK_DIR%\conf\custom.properties"

pushd "%MOCK_WORK_DIR%"
git add -A >nul 2>&1
git commit -m "v%~1" >nul 2>&1
git push >nul 2>&1
popd
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UPDATE_MOCK_REMOTE
:: %1 = new version
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "MOCK_WORK_DIR=%SANDBOX%\mock-work"
for /f "tokens=1,2,3 delims=." %%a in ("%~1") do (
	set "V_MAJOR=%%a"
	set "V_MINOR=%%b"
	set "V_REV=%%c"
)
(echo major.number        = !V_MAJOR!
echo minor.number        = !V_MINOR!
echo revision.number     = !V_REV!
echo qualifier           =) > "%MOCK_WORK_DIR%\VERSION"

pushd "%MOCK_WORK_DIR%"
git add -A >nul 2>&1
git commit -m "v%~1" >nul 2>&1
git push >nul 2>&1
popd
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MISSING_ARGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: missing arguments
set "OUT=%SANDBOX%\out-noargs.txt"
call "%UPDATE_SCRIPT%" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EQ "1" "!RC!" "exit code 1 with no args"
call :ASSERT_OUTPUT_CONTAINS "No path defined" "%OUT%" "error mentions missing path"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_MISSING_URL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: missing url argument
set "CFG_DIR=%SANDBOX%\cfg-no-url"
mkdir "%CFG_DIR%" >nul 2>nul
set "OUT=%SANDBOX%\out-nourl.txt"
call "%UPDATE_SCRIPT%" "%CFG_DIR%" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EQ "1" "!RC!" "exit code 1 with no url"
call :ASSERT_OUTPUT_CONTAINS "No url defined" "%OUT%" "error mentions missing url"
del /f /q "%OUT%" >nul 2>nul
if exist "%CFG_DIR%" rmdir /s /q "%CFG_DIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FRESH_CLONE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: fresh clone from mock remote
call :CREATE_MOCK_REMOTE 1.0.0
set "CFG_PATH=%SANDBOX%\custom-config-fresh"
if exist "%CFG_PATH%" rmdir /s /q "%CFG_PATH%" >nul 2>nul
mkdir "%CFG_PATH%" >nul 2>nul

set "OUT=%SANDBOX%\out-fresh.txt"
set "CB_VERBOSE=false"
set "CB_INSTALL_SILENT=false"
call "%UPDATE_SCRIPT%" "%CFG_PATH%" "%MOCK_REMOTE_DIR%" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EQ "0" "!RC!" "exit code 0"
call :ASSERT_DIR_EXISTS "%CFG_PATH%\1.0.0" "version directory created"
call :ASSERT_FILE_EXISTS "%CFG_PATH%\1.0.0\VERSION" "VERSION file present"
call :ASSERT_FILE_EXISTS "%CFG_PATH%\1.0.0\conf\custom.properties" "config file present"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SAME_VERSION_SKIPS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: same version is not re-cloned
call :CREATE_MOCK_REMOTE 2.0.0
set "CFG_PATH=%SANDBOX%\custom-config-skip"
if exist "%CFG_PATH%" rmdir /s /q "%CFG_PATH%" >nul 2>nul
mkdir "%CFG_PATH%" >nul 2>nul

:: first clone
set "CB_VERBOSE=false"
set "CB_INSTALL_SILENT=true"
call "%UPDATE_SCRIPT%" "%CFG_PATH%" "%MOCK_REMOTE_DIR%" >nul 2>&1
call :ASSERT_DIR_EXISTS "%CFG_PATH%\2.0.0" "first clone created version dir"

:: second run - same version, should be skipped
set "OUT=%SANDBOX%\out-skip.txt"
set "CB_VERBOSE=true"
call "%UPDATE_SCRIPT%" "%CFG_PATH%" "%MOCK_REMOTE_DIR%" > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "already available" "%OUT%" "skips re-clone of same version"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NEW_VERSION_UPDATES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: new remote version triggers update
call :CREATE_MOCK_REMOTE 3.0.0
set "CFG_PATH=%SANDBOX%\custom-config-update"
if exist "%CFG_PATH%" rmdir /s /q "%CFG_PATH%" >nul 2>nul
mkdir "%CFG_PATH%" >nul 2>nul

:: initial clone
set "CB_VERBOSE=false"
set "CB_INSTALL_SILENT=true"
call "%UPDATE_SCRIPT%" "%CFG_PATH%" "%MOCK_REMOTE_DIR%" >nul 2>&1
call :ASSERT_DIR_EXISTS "%CFG_PATH%\3.0.0" "initial version cloned"

:: push new version to remote
call :UPDATE_MOCK_REMOTE 3.1.0

:: re-run - should detect new version
set "OUT=%SANDBOX%\out-update.txt"
set "CB_INSTALL_SILENT=false"
call "%UPDATE_SCRIPT%" "%CFG_PATH%" "%MOCK_REMOTE_DIR%" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
call :ASSERT_EQ "0" "!RC!" "exit code 0 for update"
call :ASSERT_DIR_EXISTS "%CFG_PATH%\3.1.0" "new version directory created"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LOCK_FILE_CLEANED_UP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: lock file cleaned up after run
call :CREATE_MOCK_REMOTE 4.0.0
set "CFG_PATH=%SANDBOX%\custom-config-lock"
if exist "%CFG_PATH%" rmdir /s /q "%CFG_PATH%" >nul 2>nul
mkdir "%CFG_PATH%" >nul 2>nul

set "CB_VERBOSE=false"
set "CB_INSTALL_SILENT=true"
call "%UPDATE_SCRIPT%" "%CFG_PATH%" "%MOCK_REMOTE_DIR%" >nul 2>&1
call :ASSERT_FILE_MISSING "%CFG_PATH%\.lock" "lock file removed after run"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_IGNORE_FILES_REMOVED
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: gradle/build files cleaned from cloned config
call :CREATE_MOCK_REMOTE 5.0.0

:: add files that should be ignored
pushd "%MOCK_WORK_DIR%"
echo. > gradlew
echo. > gradlew.bat
echo. > .gitignore
echo. > .gitattributes
echo. > build.gradle
echo. > settings.gradle
echo. > README.md
git add -A >nul 2>&1
git commit -m "add ignore files" >nul 2>&1
git push >nul 2>&1
popd

set "CFG_PATH=%SANDBOX%\custom-config-ignore"
if exist "%CFG_PATH%" rmdir /s /q "%CFG_PATH%" >nul 2>nul
mkdir "%CFG_PATH%" >nul 2>nul

set "CB_VERBOSE=false"
set "CB_INSTALL_SILENT=true"
call "%UPDATE_SCRIPT%" "%CFG_PATH%" "%MOCK_REMOTE_DIR%" >nul 2>&1

call :ASSERT_DIR_EXISTS "%CFG_PATH%\5.0.0" "version directory created"
:: these files should have been removed
set "ALL_CLEAN=true"
for %%f in (gradlew gradlew.bat .gitignore .gitattributes build.gradle settings.gradle README.md) do (
	if exist "%CFG_PATH%\5.0.0\%%f" (
		set /a FAIL+=1
		echo   FAIL: %%f should have been removed from cloned config
		set "ALL_CLEAN=false"
	)
)
if "!ALL_CLEAN!"=="true" (
	set /a PASS+=1
	echo   PASS: all ignorable files removed from clone
)
:: but the actual config should remain
call :ASSERT_FILE_EXISTS "%CFG_PATH%\5.0.0\conf\custom.properties" "custom config file kept"
goto :eof
