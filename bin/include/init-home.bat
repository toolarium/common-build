@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: init-home.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


set forceInstallation=false
if .%1==.--force shift & set forceInstallation=true
if .%1==. echo %CB_LINEHEADER%ERROR: No path defined where to init or update. & goto END_WITH_ERROR
if .%2==. echo %CB_LINEHEADER%ERROR: No url defined to init or update. & goto END_WITH_ERROR

set "CB_CUSTOM_CONFIG_PATH=%1"
set "commonGradleBuildHomeGitUrl=%2"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Prepare check upate of [%commonGradleBuildHomeGitUrl%].

:: if we don't force, just read last version and get credentials (in case of a private repo)
if .%forceInstallation%==.false (call :GIT_CREDENTIALS %commonGradleBuildHomeGitUrl% 
	call :READ_LAST_VERSION
	goto END)

:: check git installation
set "credentialCheck=false"
if not exist %CB_CURRENT_PATH%\git\bin if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Check git client
if not exist %CB_CURRENT_PATH%\git\bin (call %CB_SCRIPT_PATH%\cb --silent --install git --default)
if exist %CB_CURRENT_PATH%\git\bin set "GIT_CLIENT=%CB_CURRENT_PATH%\git\bin\git"
%GIT_CLIENT% --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find default git installation. & goto END_WITH_ERROR 
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Verify git repository[%commonGradleBuildHomeGitUrl%].
%GIT_CLIENT% ls-remote %commonGradleBuildHomeGitUrl% >nul 2>nul
if %ERRORLEVEL% EQU 128 GOTO UPDATE_ERROR
if %ERRORLEVEL% NEQ 0 GOTO UPDATE_ERROR
set "credentialCheck=true"
set "commonGradleBuildHomeUpdated=false"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Valid access to [%commonGradleBuildHomeGitUrl%].

:: work around, create an empty project for the first update
set "tempProjectName=common-gradle-build-home-update-%RANDOM%%RANDOM%"
mkdir "%TEMP%\%tempProjectName%"
set "currentWorkingPath=%CD%"
cd /d "%TEMP%\%tempProjectName%"
echo apply from: "https://git.io/JfDQT" > build.gradle

call :GIT_CREDENTIALS %commonGradleBuildHomeGitUrl%
if %errorCode% NEQ 0 goto UPDATE_ERROR
echo %CB_LINEHEADER%Check and update custom config from repository [%commonGradleBuildHomeGitUrl%].
set "commonGradleBuildHomeUpdateLog=%CB_HOME%\logs\common-gradle-build-home-update-%RANDOM%%RANDOM%.log"
::echo %CB_LINEHEADER%Execute %CB_HOME%\bin\cb in .
call %CB_HOME%\bin\cb --silent -q --no-daemon -m "-PcommonGradleBuildHomeGitUrl=%commonGradleBuildHomeGitUrl%" > %commonGradleBuildHomeUpdateLog%
if %ERRORLEVEL% EQU 0 set "commonGradleBuildHomeUpdated=true"
type %commonGradleBuildHomeUpdateLog% 2>nul | findstr /C:"Could not read remote version" > nul
if %ERRORLEVEL% EQU 0 set "commonGradleBuildHomeUpdated=false"
cd /d "%currentWorkingPath%"
::call %CB_HOME%\bin\cb-deltree --silent %TEMP%\common-gradle-build-home-update-*
set "customConfigVersionAvailable="
call :READ_LAST_VERSION
if .%commonGradleBuildHomeUpdated%==.false goto UPDATE_ERROR
if .%customConfigVersionAvailable%==. goto UPDATE_ERROR
echo %CB_LINEHEADER%Successful updated version %CB_CUSTOM_CONFIG_VERSION% in %COMMON_GRADLE_BUILD_HOME%.
goto END

:GIT_CREDENTIALS
call %CB_SCRIPT_PATH%\include\cb-credential --raw %1
if %ERRORLEVEL% NEQ 0 set errorCode=1 & goto :eof 
set "GRGIT_USER=%GIT_USERNAME%" & set "GRGIT_PASS=%GIT_PASSWORD%")
set "GIT_USERNAME=" & set "GIT_PASSWORD="
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Valid credentials for [%commonGradleBuildHomeGitUrl%], user [%GRGIT_USER%].
set "errorCode=0"
goto :eof

:READ_LAST_VERSION
set "TMPFILE=%TEMP%\cb-config-home-%RANDOM%%RANDOM%.tmp"
dir %CB_CUSTOM_CONFIG_PATH%\* /O-D/b 2>nul | findstr /v lastCheck.properties | findstr /v .tsp | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /p CB_CUSTOM_CONFIG_VERSION=<"%TMPFILE%" & set "customConfigVersionAvailable=true"
set "CB_CUSTOM_CONFIG_VERSION=%CB_CUSTOM_CONFIG_VERSION:~2%"
set "CB_CUSTOM_CONFIG_VERSION=%CB_CUSTOM_CONFIG_VERSION: =%"
del /f /q "%TMPFILE%" 2>nul
goto :eof

:UPDATE_ERROR
set "errorMsg=Could not get repository from [%commonGradleBuildHomeGitUrl%]."
if .%credentialCheck%==.true set "errorMsg=%errorMsg%, unknown reason (valid credentials)."
if .%credentialCheck%==.false set "errorMsg=%errorMsg% because of invalid credentials."
if .%commonGradleBuildHomeUpdated% == .false set "errorMsg=%errorMsg% (not found)"
echo %CB_LINEHEADER%%errorMsg%:
echo    %commonGradleBuildHomeGitUrl% 
echo.
echo Windows credentials can be managed with the commands:
echo     rundll32.exe keymgr.dll,KRShowKeyMgr
echo or 
echo     control.exe keymgr.dll
echo.

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END_WITH_ERROR
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
