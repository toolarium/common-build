@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: update-cb-custom-home.bat
::
:: Copyright by toolarium, all rights reserved.
::
:: This file is part of the toolarium common-build.
::
:: The common-build is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: The common-build is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with Foobar. If not, see <http://www.gnu.org/licenses/>.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


setlocal EnableDelayedExpansion
if not defined CB_LINEHEADER set "CB_LINEHEADER=.: "
if not defined CB_VERBOSE set CB_VERBOSE=true
if not defined CB_INSTALL_SILENT set CB_INSTALL_SILENT=false
if .%1==. echo %CB_LINEHEADER%ERROR: No path defined where to init or update. & goto END_WITH_ERROR
if .%2==. echo %CB_LINEHEADER%ERROR: No url defined to init or update. & goto END_WITH_ERROR
set "CB_CUSTOM_CONFIG_PATH=%~1"
set "commonGradleBuildHomeGitUrl=%2"
set "LOCKFILE=%CB_CUSTOM_CONFIG_PATH%\.lock"

if .%CB_VERBOSE%==.true echo %CB_LINEHEADER%Check [%commonGradleBuildHomeGitUrl%] for updates.
call %CB_HOME%\bin\include\lock-unlock "%LOCKFILE%" 60 
if %ERRORLEVEL% NEQ 0 goto END_WITH_ERROR
set "setLockFile=true"

:: check git installation
if defined GIT_CLIENT goto INSTALL_GIT_CLIENT_END
if not exist %CB_HOME%\current\git\bin if .%CB_VERBOSE%==.true echo %CB_LINEHEADER%Install git client.
if not exist %CB_HOME%\current\git\bin (call %CB_HOME%\bin\cb --silent --install git --default)
if exist %CB_HOME%\current\git\bin set "GIT_CLIENT=%CB_HOME%\current\git\bin\git"
:INSTALL_GIT_CLIENT_END

:: verfiy git client
%GIT_CLIENT% --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find git client installation. & goto END_WITH_ERROR 
if exist %GIT_CLIENT% if .%CB_VERBOSE%==.true echo %CB_LINEHEADER%Found valid git client installation [%GIT_CLIENT%].

:: verfiy url
set "credentialCheck=false"
if .%CB_VERBOSE%==.true echo %CB_LINEHEADER%Verify git repository [%commonGradleBuildHomeGitUrl%].
call %CB_HOME%\bin\include\cb-credential --verifyOnly %commonGradleBuildHomeGitUrl%
if %ERRORLEVEL% NEQ 0 GOTO UPDATE_ERROR
set "credentialCheck=true"
set "commonGradleBuildHomeUpdated=false"
if .%CB_VERBOSE%==.true echo %CB_LINEHEADER%Valid access to [%commonGradleBuildHomeGitUrl%].

:: create temp path
set "UPDATE_CB_CUSTOM_PATH=%CB_CUSTOM_CONFIG_PATH%\unknown"
mkdir "%UPDATE_CB_CUSTOM_PATH%" >nul 2>nul

call %CB_HOME%\bin\cb-deltree "%UPDATE_CB_CUSTOM_PATH%" 
mkdir "%UPDATE_CB_CUSTOM_PATH%" >nul 2>nul

if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Check and update custom config from repository [%commonGradleBuildHomeGitUrl%].
::%GIT_CLIENT% clone -q %commonGradleBuildHomeGitUrl% "%UPDATE_CB_CUSTOM_PATH%"
%GIT_CLIENT% clone -q %commonGradleBuildHomeGitUrl% "%UPDATE_CB_CUSTOM_PATH%"
if %ERRORLEVEL% EQU 0 set "commonGradleBuildHomeUpdated=true" 

if .%commonGradleBuildHomeUpdated%==.false call %CB_HOME%\bin\cb-deltree "%UPDATE_CB_CUSTOM_PATH%"
if .%commonGradleBuildHomeUpdated%==.false goto UPDATE_ERROR

:: read version
call %CB_HOME%\bin\include\read-version "%UPDATE_CB_CUSTOM_PATH%\VERSION" false
set "CB_CUSTOM_CONFIG_VERSION=%version.number%"
set "CB_CUSTOM_CONFIG_VERSION=%CB_CUSTOM_CONFIG_VERSION: =%"

::if defined qualifier 
set major.number= & set minor.number= & set revision.number= & set qualifier= & set version.number=
if exist "%CB_CUSTOM_CONFIG_PATH%\%CB_CUSTOM_CONFIG_VERSION%" call %CB_HOME%\bin\cb-deltree "%UPDATE_CB_CUSTOM_PATH%"
if exist "%CB_CUSTOM_CONFIG_PATH%\%CB_CUSTOM_CONFIG_VERSION%" if .%CB_VERBOSE%==.true echo %CB_LINEHEADER%Newest version %CB_CUSTOM_CONFIG_VERSION% is already available.
if exist "%CB_CUSTOM_CONFIG_PATH%\%CB_CUSTOM_CONFIG_VERSION%" goto END

:: use newer version
call %CB_HOME%\bin\cb-deltree "%UPDATE_CB_CUSTOM_PATH%\gradle\wrapper"
if not defined CB_CUSTOM_CONFIG_IGNORE_FILES set "CB_CUSTOM_CONFIG_IGNORE_FILES=gradlew gradlew.bat .editorconfig .gitattributes .gitignore build.gradle gradle.properties settings.gradle README.md"
for %%i in (%CB_CUSTOM_CONFIG_IGNORE_FILES%) do ( del /f /q %UPDATE_CB_CUSTOM_PATH%\%%i >nul 2>nul )
move "%UPDATE_CB_CUSTOM_PATH%" "%CB_CUSTOM_CONFIG_PATH%\%CB_CUSTOM_CONFIG_VERSION%" >nul 2>nul
if .%CB_VERBOSE%==.true echo %CB_LINEHEADER%Successful updated version %CB_CUSTOM_CONFIG_VERSION% in [%CB_CUSTOM_CONFIG_PATH%].
if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Successful updated version %CB_CUSTOM_CONFIG_VERSION%.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UPDATE_ERROR
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "errorMsg=Could not get repository from [%commonGradleBuildHomeGitUrl%]."
if .%credentialCheck%==.false set "errorMsg=%errorMsg% because of invalid credentials."
if .%credentialCheck%==.true set "errorMsg=%errorMsg%, unknown reason (valid credentials)."
if .%commonGradleBuildHomeUpdated%==.false set "errorMsg=%errorMsg% (could not clone)"
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
if defined setLockFile call %CB_HOME%\bin\include\lock-unlock --unlock "%LOCKFILE%"
endlocal
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
if defined setLockFile call %CB_HOME%\bin\include\lock-unlock --unlock "%LOCKFILE%" 
endlocal & ( set CB_CUSTOM_CONFIG_VERSION=%CB_CUSTOM_CONFIG_VERSION% )
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
