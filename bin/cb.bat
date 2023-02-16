@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb.bat
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


set "CB_HOME_PREVIOUS=%CB_HOME%"
setlocal EnableDelayedExpansion
set CB_LINE=----------------------------------------------------------------------------------------
set "CB_LINEHEADER=.: "
set PN=%~nx0
set "CB_SCRIPT_PATH=%~dp0"
set "PN_FULL=%CB_SCRIPT_PATH%%PN%"
set "CB_WORKING_PATH=%CD%"
set "CB_INSTALL_SILENT=false"
set CB_CUSTOM_SETTING_SCRIPT=
if not defined CB_CUSTOM_CONFIG_FILENAME set "CB_CUSTOM_CONFIG_FILENAME=.cb-custom-config"
set "CB_VERBOSE=false"
if .%1==.--verbose shift & set "CB_VERBOSE=true"
set errorCode=0
if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb"
if not exist %CB_TEMP% mkdir "%CB_TEMP%" >nul 2>nul
if not defined GIT_CLIENT set "GIT_CLIENT=git"

where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Please install powershell. & goto END_WITH_ERROR

call :GET_TIMESTAMP CB_START_TIMESTAMP
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Started %CB_START_TIMESTAMP%.

for %%I in (.) do set folderName=%%~nxI
set "TITLE_NAME=CB ^| %folderName% - %CB_START_TIMESTAMP:~11%"
title %TITLE_NAME%
if not defined CB_PACKAGE_URL (set "CB_PACKAGE_URL=")
if not defined CB_INSTALL_USER_COMMIT (set "CB_INSTALL_USER_COMMIT=true")
if not defined CB_USER (set "CB_USER=%USERNAME%")
if not defined CB_PACKAGE_PASSWORD (set "CB_PACKAGE_PASSWORD=")
if not defined CB_DEVTOOLS_JAVA_PREFIX (set "CB_DEVTOOLS_JAVA_PREFIX=*jdk*")
if not defined CB_INSTALL_OVERWRITE (set "CB_INSTALL_OVERWRITE=false")

set CB_INSTALL_OVERWRITE_DIST=%CB_INSTALL_OVERWRITE%
set CB_WGET_CMD=wget.exe
set CB_UNZIP_CMD=unzip.exe

set "CB_PROJECT_JAVA_VERSION_FILE=.java-version"
set "CB_JAVA_VERSION_FILE=.cb-java-version"
set CB_PARAMETERS=
if exist %CB_JAVA_VERSION_FILE% del /f /q "%CB_JAVA_VERSION_FILE%" 2>nul

if not defined CB_HOME (echo %CB_LINE% & echo %CB_LINEHEADER%Missing CB_HOME environment variable, please install with the cb-install.bat. & echo %CB_LINE% & goto END_WITH_ERROR)
cd /D %CB_HOME% 2>nul
if %ERRORLEVEL% NEQ 0 (echo %CB_LINE% & echo %CB_LINEHEADER%Invalid CB_HOME environment variable, please install with the cb-install.bat. & echo %CB_LINE% & goto END_WITH_ERROR)
cd /D %CB_WORKING_PATH%

if defined CB_DEVTOOLS goto SET_DEVTOOLS_END
cd /D %CB_HOME%\..
set "CB_DEVTOOLS=%CD%"
cd /D %CB_WORKING_PATH%

:SET_DEVTOOLS_END
set "CB_TOOL_VERSION_DEFAULT=%CB_HOME%\conf\tool-version-default.properties"
set "CB_TOOL_VERSION_INSTALLED=%CB_HOME%\conf\tool-version-installed.properties"
set "CB_TOOL_VERSION_DEFAULT_URL=https://raw.githubusercontent.com/toolarium/common-build/master/conf/tool-version-default.properties"
set CB_SET_DEFAULT=false
set "CB_CURRENT_PATH=%CB_HOME%\current" 
if not exist %CB_CURRENT_PATH% (mkdir %CB_CURRENT_PATH% >nul 2>nul)

:: be sure findstr works
findstr 2>nul
if %ERRORLEVEL% EQU 9009 (SET "PATH=%PATH%;%SystemRoot%\System32\")


:: read version
call %CB_SCRIPT_PATH%include\read-version %CB_SCRIPT_PATH%\..\VERSION
set CB_VERSION=%version.number%

:: check connection
set "CB_OFFLINE="
ping 8.8.8.8 -n 1 -w 1000 >nul 2>nul
if errorlevel 1 set "CB_OFFLINE=true"

:: parameters without hooks
if .%1==.--verbose shift & set "CB_VERBOSE=true"
if .%1==.--force shift & set "CB_INSTALL_OVERWRITE_DIST=true"
if .%1==.--verbose shift & set "CB_VERBOSE=true"
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.-v goto VERSION
if .%1==.--version goto VERSION
if .%1==.-exp shift & goto PROJECT_EXPLORE
if .%1==.--explore shift & goto PROJECT_EXPLORE
if .%1==.--packages shift & goto PACKAGES
if .%1==.--install shift & goto INSTALL_CB
if .%1==.--setenv shift & goto SET_ENV


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: custom initialisation
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if defined CB_CUSTOM_CONFIG if not ".%CB_CUSTOM_CONFIG%"=="." goto CUSTOM_CONFIG_END
set "CB_CONFIG_HOME=%USERPROFILE%\.common-build"
if not exist "%CB_CONFIG_HOME%\conf\%CB_CUSTOM_CONFIG_FILENAME%" goto CUSTOM_CONFIG_END
set "TMPFILE=%CB_TEMP%\cb-git-%RANDOM%%RANDOM%.tmp"
if not exist %CB_WORKING_PATH%\.git goto SET_GIT_PROJECT_END
where %GIT_CLIENT% >nul 2>nul
if %ERRORLEVEL% NEQ 0 if .%CB_VERBOSE% == .true (echo %CB_LINEHEADER%No git installation found: %GIT_CLIENT% & goto SET_GIT_PROJECT_END) else (goto SET_GIT_PROJECT_END)
%GIT_CLIENT% config --local --get remote.origin.url > "%TMPFILE%" 2>nul 
if %ERRORLEVEL% NEQ 0 if .%CB_VERBOSE% == .true (echo %CB_LINEHEADER%No git installation found & goto SET_GIT_PROJECT_END) else (goto SET_GIT_PROJECT_END)
set /p CB_GIT_PROJECT_URL=<"%TMPFILE%"
if ".%CB_GIT_PROJECT_URL%"=="." if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%No git remote url found.
if not ".%CB_GIT_PROJECT_URL%"=="." if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Git remote url found: %CB_GIT_PROJECT_URL%
:SET_GIT_PROJECT_END
if exist %TMPFILE% del /f /q "%TMPFILE%" 2>nul
set CB_CUSTOM_CONFIG_LENTGH=0
for /f "tokens=1,* delims=^=" %%i in ('type "%CB_CONFIG_HOME%\conf\%CB_CUSTOM_CONFIG_FILENAME%" ^| findstr /V "^#" ^| findstr /V "^=" ^| findstr /V "^$"') do (
	set CB_CUSTOM_CONFIG_MATCH=0
	set "istr=%%i" & set "istr=!istr: =!" & call :STRLEN istr iLength
	set jstr=%%j & set "jstr=!jstr: =!" & call :STRLEN jstr jLength
	if .%CB_VERBOSE% == .true if !iLength! GTR 0 if !jLength! EQU 0 echo %CB_LINEHEADER%Found custom config entry [!istr!] with no pattern
	if .%CB_VERBOSE% == .true if !iLength! GTR 0 if !jLength! EQU 0 if !CB_CUSTOM_CONFIG_LENTGH! LEQ 0 echo %CB_LINEHEADER%Choose custom config entry [!istr!] with no pattern
	if !iLength! GTR 0 if !jLength! EQU 0 if !CB_CUSTOM_CONFIG_LENTGH! LEQ 0 set "CB_CUSTOM_CONFIG=!istr!"
	if !iLength! GTR 0 if !jLength! GTR 0 if not ".%CB_GIT_PROJECT_URL%"=="." echo %CB_GIT_PROJECT_URL% | findstr /C:"!jstr!" >nul 2>nul	
	if !iLength! GTR 0 if !jLength! GTR 0 if not ".%CB_GIT_PROJECT_URL%"=="." if !ERRORLEVEL! EQU 0 set CB_CUSTOM_CONFIG_MATCH=1
	if .%CB_VERBOSE% == .true if !CB_CUSTOM_CONFIG_MATCH! EQU 1 echo %CB_LINEHEADER%Found custom config entry [!istr!] with pattern [!jstr!] by remote url [%CB_GIT_PROJECT_URL%]
	if .%CB_VERBOSE% == .true if !CB_CUSTOM_CONFIG_MATCH! EQU 1 if !jLength! GEQ !CB_CUSTOM_CONFIG_LENTGH! echo %CB_LINEHEADER%Choose custom config entry [!istr!] with pattern [!jstr!], length: !jLength!
	if !CB_CUSTOM_CONFIG_MATCH! EQU 1 if !jLength! GEQ !CB_CUSTOM_CONFIG_LENTGH! (set "CB_CUSTOM_CONFIG=!istr!" & set CB_CUSTOM_CONFIG_LENTGH=!jLength!)
	set CB_CUSTOM_CONFIG_LENTGH=!CB_CUSTOM_CONFIG_LENTGH!
)

if ".%CB_CUSTOM_CONFIG%"=="." echo %CB_LINEHEADER%Ignore empty custom config, see %CB_CONFIG_HOME%\conf\%CB_CUSTOM_CONFIG_FILENAME% & goto CUSTOM_CONFIG_END
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Select custom config entry [%CB_CUSTOM_CONFIG%]
if not ".%CB_CUSTOM_CONFIG%"=="." call :CB_CUSTOM_CONFIG_CHECK
if %errorCode% NEQ 0 goto END_WITH_ERROR
:CUSTOM_CONFIG_END

if ".%CB_CUSTOM_SETTING%"=="." goto CUSTOM_SETTINGS_INIT_END_CALL
if exist "%CB_CUSTOM_SETTING%" goto CUSTOM_SETTINGS_INIT_CALL
echo %CB_LINE%
echo %CB_LINEHEADER%Could not find custom script, see %%CB_CUSTOM_SETTING%%: 
echo %CB_CUSTOM_SETTING%
echo %CB_LINE%
goto CUSTOM_SETTINGS_INIT_END_CALL
:CUSTOM_SETTINGS_INIT_CALL
set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_SETTING%"
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" start %1 %2 %3 %4 %5 %6 %7 2>nul
:CUSTOM_SETTINGS_INIT_END_CALL


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if %0X==X goto COMMON_BUILD
if .%1==.--verbose shift & set "CB_VERBOSE=true"
if .%1==.--silent shift & set "CB_INSTALL_USER_COMMIT=false" & set "CB_INSTALL_SILENT=true"
if .%1==.--force shift & set "CB_INSTALL_OVERWRITE_DIST=true"
if .%1==.--default shift & set CB_SET_DEFAULT=true
if .%1==.--offline shift & set "CB_OFFLINE=true"
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.-v goto VERSION
if .%1==.--version goto VERSION
if .%1==.-new shift & goto PROJECT_WIZARD
if .%1==.--new shift & goto PROJECT_WIZARD
if .%1==.-exp shift & goto PROJECT_EXPLORE
if .%1==.--explore shift & goto PROJECT_EXPLORE
if .%1==.--packages shift & goto PACKAGES
if .%1==.--setenv shift & goto SET_ENV
if .%1==.--install shift & goto INSTALL_CB
if .%1==.--java goto SET_JAVA_PARAM
if .%1==.--update goto UPDATE
set CB_PARAMETERS=%CB_PARAMETERS% %~1
::if ".%CB_PARAMETERS%"=="." (set CB_PARAMETERS=%~1) else (set CB_PARAMETERS=%CB_PARAMETERS% %~1)
shift
goto CHECK_PARAMETER

:SET_JAVA_PARAM
echo %2 > %CB_JAVA_VERSION_FILE% 
shift 
shift 
goto CHECK_PARAMETER


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - common build v%CB_VERSION%
echo usage: %PN% [OPTION]
echo.
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  -v, --version        Print the version information.
echo  --new                Create a new project. You can prefill wizard settings 
echo                       by setting the corresponding entries as parameter, e.g.
echo                       --new 1 my-project my.root.pkg my my
echo  --java [version]     Set a different java version for this run, e.g. --java 14.
echo  --silent             Suppress the console output from the common-build.
echo  --force              Flag to force new installtion.
echo  --offline            Set the offline mode; it will be detect automatically.
echo  --install [pkg]      Install the a software package. Optionally you can set the
echo                       version number (does not work for every package); otherwise
echo                       the default version number is used (from the configuration
echo                       file tool-version-default.properties)
echo                       Additionally a parameter -d or --default marks this version 
echo                       as default.
echo  --packages           Shows the supported packages.
echo  -exp, --explore      Starts the file explorer with the current path.
echo  --update             Updates the custom config and can be combined with force.
echo  --setenv             Set all internal used environment variables.
echo.
echo Environment variable:
echo  CB_DEVTOOLS          Defines the devtools directory, default c:\devtools.
echo  CB_HOME              Defines the home environment, default %%CB_DEVTOOLS%%\cb.
echo.
echo Special files:
echo  .java-version        Can be used to refer to a specific java version, e.g. 11
echo.
echo Customizing:
echo  CB_CUSTOM_SETTING    The common build is flexible. You can define a script which
echo                       that is called as a hook for all operations. You can find an
echo                       example script in %%CB_HOME%%\bin\sample\cb-custom-sample.bat
echo  CB_CUSTOM_CONFIG     For complete customizing of the common build you can create 
echo                       a custom config project. This can be done by cb --new (select 
echo                       Common Config Home project). After customizing (see further 
echo                       information on the web) and publishing it as a git project,
echo                       you can refer the git url to the CB_CUSTOM_CONFIG environment
echo                       variable. The VERSION file is mainly the reference for updates
echo                       of the project (as default daily check, can be configured).
echo                       The project is checkout in .common-buik/conf/[domain-unique
echo                       -name] inside the home folder (Windows %USERPROFILE%, others
echo                       $HOME. Alternatively, instead of the environment variable, 
echo                       a file .common-build\conf\%CB_CUSTOM_CONFIG_FILENAME% containing the
echo                       git url can be used."
echo.
echo  CB_PACKAGE_URL       To support software packages outside the common build, you 
echo                       can define an URL that covers a directory of zip files.
echo  CB_PACKAGE_USER      The user for accessing the CB_PACKAGE_URL.
echo  CB_PACKAGE_PASSWORD  In case the value is ask, the password can be entered securely 
echo                       on the command line.
call %CB_SCRIPT_PATH%include\how-to.bat 2>nul
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo toolarium common build %CB_VERSION%
echo.
echo %CB_LINEHEADER%Installed tool versions:
for /f "tokens=1,* delims=^=" %%i in ('type %CB_TOOL_VERSION_INSTALLED%') do (echo     -%%i: %%j)
echo %CB_LINE%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UPDATE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if defined CB_CUSTOM_CONFIG_VERSION echo %CB_LINEHEADER%Found custom config version %CB_CUSTOM_CONFIG_VERSION%
if not defined CB_CUSTOM_CONFIG_VERSION echo %CB_LINEHEADER%No custom config found

:: in case there is common-gradle-build remove the lastCheck.properties
if exist "%USERPROFILE%\.gradle\common-gradle-build\lastCheck.properties" del /f /q "%USERPROFILE%\.gradle\common-gradle-build\lastCheck.properties" 2>nul
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROJECT_WIZARD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET CB_WIZARD_PARAMETERS=%CB_PARAMETERS%
:CHECK_PARAMETER_WIZARD
IF %0X==X GOTO START_WIZARD
SET CB_WIZARD_PARAMETERS=%CB_WIZARD_PARAMETERS% %1
SHIFT
GOTO CHECK_PARAMETER_WIZARD

:START_WIZARD
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Start project wizard.
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" new-project-start %CB_WIZARD_PARAMETERS% 2>nul
call %CB_SCRIPT_PATH%include\project-wizard.bat %CB_WIZARD_PARAMETERS%
if not %ERRORLEVEL% equ 0 goto END_WITH_ERROR
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" new-project-end %CB_WIZARD_PARAMETERS% 2>nul
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROJECT_EXPLORE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "multiCommander=%CB_HOME%\current\multicommander\MultiCommander.exe"
if not defined CB_FILE_EXPLORER if exist %multiCommander% set "CB_FILE_EXPLORER=%multiCommander% /OPEN %CD%"
if not defined CB_FILE_EXPLORER set "CB_FILE_EXPLORER=explorer %CD%"
%CB_FILE_EXPLORER%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PACKAGES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo toolarium common build %CB_VERSION%
echo.
echo %CB_LINEHEADER%Available packages:
for /f "tokens=1" %%i in ('dir /b %CB_SCRIPT_PATH%packages\') do (echo     -%%i)
echo %CB_LINE%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SET_ENV
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
endlocal & (
  set "CB_LINEHEADER=%CB_LINEHEADER%"
  set "CB_CURRENT_PATH=%CB_CURRENT_PATH%"
  set "CB_INSTALL_SILENT=%CB_INSTALL_SILENT%"
  set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_SETTING_SCRIPT%"
)

if .%1 == .--silent shift & set CB_INSTALL_SILENT=true
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" setenv-start %1 %2 %3 %4 %5 %6 %7 2>nul

:SET_GIT
if not exist %CB_CURRENT_PATH%\git goto :SET_ENV_NODE
set "CB_GIT_HOME=%CB_CURRENT_PATH%\git"
set "GIT_HOME=%CB_GIT_HOME%"
echo %PATH% | findstr /C:"%GIT_HOME%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%GIT_HOME%;%PATH%" & if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Add git to path (%GIT_HOME%)

:SET_ENV_NODE
if not exist %CB_CURRENT_PATH%\node goto :SET_ENV_ANT
set "CB_NODE_HOME=%CB_CURRENT_PATH%\node"
set "NODE_HOME=%CB_NODE_HOME%"
echo %PATH% | findstr /C:"%NODE_HOME%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%NODE_HOME%;%PATH%" & if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Add node to path (%NODE_HOME%)

:SET_ENV_ANT
if not exist %CB_CURRENT_PATH%\ant goto :SET_ENV_MAVEN
set "CB_ANT_HOME=%CB_CURRENT_PATH%\ant"
set "ANT_HOME=%CB_ANT_HOME%"
echo %PATH% | findstr /C:"%ANT_HOME%\bin" >nul 2>nul 
if %ERRORLEVEL% NEQ 0 set "PATH=%ANT_HOME%\bin;%PATH%" & if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Add ant to path (%ANT_HOME%\bin)

:SET_ENV_MAVEN
if not exist %CB_CURRENT_PATH%\maven goto :SET_ENV_GRADLE
set "CB_MAVEN_HOME=%CB_CURRENT_PATH%\maven"
set "MAVEN_HOME=%CB_MAVEN_HOME%"
echo %PATH% | findstr /C:"%MAVEN_HOME%\bin" >nul 2>nul 
if %ERRORLEVEL% NEQ 0 set "PATH=%MAVEN_HOME%\bin;%PATH%" & if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Add maven to path (%MAVEN_HOME%\bin)

:SET_ENV_GRADLE
if not exist %CB_CURRENT_PATH%\gradle goto :SET_ENV_JAVA
set "CB_GRADLE_HOME=%CB_CURRENT_PATH%\gradle"
set "GRADLE_HOME=%CB_GRADLE_HOME%"
echo %PATH% | findstr /C:"%GRADLE_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%GRADLE_HOME%\bin;%PATH%" & if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Add gradle to path (%GRADLE_HOME%\bin)

:SET_ENV_JAVA
if not exist %CB_CURRENT_PATH%\java goto :SET_ENV_PYTHON
set "CB_JAVA_HOME=%CB_CURRENT_PATH%\java"
set "JAVA_HOME=%CB_JAVA_HOME%"
echo %PATH% | findstr /C:"%JAVA_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%JAVA_HOME%\bin;%PATH%" & if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Add java to path (%JAVA_HOME%\bin)

:SET_ENV_PYTHON
if not exist %CB_CURRENT_PATH%\python goto :SET_ENV_END
set "CB_PYTHON_HOME=%CB_CURRENT_PATH%\python"
set "PYTHON_HOME=%CB_PYTHON_HOME%"
echo %PATH% | findstr /C:"%PYTHON_HOME%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%PYTHON_HOME%;%PATH%" & if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Add python to path (%PYTHON_HOME%)

:SET_ENV_END
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" setenv-end %1 %2 %3 %4 %5 %6 %7 2>nul

set CB_LINEHEADER=
set CB_CURRENT_PATH=
set CB_INSTALL_SILENT=
set CB_CUSTOM_SETTING_SCRIPT=
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CB_CUSTOM_CONFIG_CHECK
:: CB_CUSTOM_RUNTIME_CONFIG_PATH is the variable where we can refer
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if ".%CB_CUSTOM_CONFIG%"=="." goto :eof
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Verify custom config [%CB_CUSTOM_CONFIG%].
if not exist "%CB_CONFIG_HOME%" mkdir "%CB_CONFIG_HOME%"
set "UPDATE_OFFLINE=%CB_OFFLINE%"

:: prepare home directory name from domain name
for /f "tokens=1,2,* delims=/" %%i in ("%CB_CUSTOM_CONFIG%") do (set "urlProtocol=%%i" & set "urlHost=%%j" & set "urlPath=%%k")
for /f "tokens=1,* delims=:" %%i in ("%urlHost%") do (set "baseUrlHost=%%i" & set "urlPort=%%j")
if .%urlPort%==. if .%urlProtocol%==.https: set "urlPort=443"
if .%urlPort%==. if .%urlProtocol%==.http: set "urlPort=80"
set "urlPath=%urlPath:/=_%"
for /f "tokens=1,* delims=." %%i in ("%urlPath%") do (set "urlPath=%%i")
set "CB_CUSTOM_CONFIG_PATH=%CB_CONFIG_HOME%\conf\%baseUrlHost%@%urlPort%_%urlPath%"
if not exist "%CB_CUSTOM_CONFIG_PATH%" mkdir "%CB_CUSTOM_CONFIG_PATH%"
ping %baseUrlHost% -n 1 -w 1000 >nul 2>nul
if errorlevel 1 echo %CB_LINEHEADER%Can not reach host [%urlHost%] for custom config update [%CB_CUSTOM_CONFIG%]! & set "UPDATE_OFFLINE=true" 
set "urlProtocol=" & set "urlHost=" & set "urlPath=" & set "urlPort=" & set "baseUrlHost="

:: set the common gradle build home path to checkout to proper destination
set "COMMON_GRADLE_BUILD_HOME=%CB_CUSTOM_CONFIG_PATH%"
set "CB_CUSTOM_CONFIG_VERSION="
set "lastCheckPropertiesFile=%CB_CUSTOM_CONFIG_PATH%\lastCheck.properties"

:: force to update
if .%CB_INSTALL_OVERWRITE_DIST% == .true (del /f /q "%CB_CUSTOM_CONFIG_PATH%\*.tsp" >nul 2>nul
	del /f /q "%lastCheckPropertiesFile%" >nul 2>nul)

:: if we have a timestamp wihtin same day then its fine
call :GET_TIMESTAMP LAST_CHECK_TSP "yyyy-MM-ddTHH\\:mm\\:ss.fff+0000"
call :GET_TIMESTAMP DATESTAMP "yyyyMMdd"
set DATESTAMP=%DATESTAMP: =%
if not exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" if .%UPDATE_OFFLINE%==.true dir %CB_CUSTOM_CONFIG_PATH%\*.tsp /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%CB_CUSTOM_CONFIG_PATH%\offline"
if not exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" if .%UPDATE_OFFLINE%==.true set /pLAST_DATESTAMP_NAME=<"%CB_CUSTOM_CONFIG_PATH%\offline" 
if not exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" if .%UPDATE_OFFLINE%==.true set "LAST_DATESTAMP_NAME=%LAST_DATESTAMP_NAME:~2%"
if not exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" if .%UPDATE_OFFLINE%==.true move "%CB_CUSTOM_CONFIG_PATH%\%LAST_DATESTAMP_NAME%" "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" >nul 2>nul
if exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" set /p CB_CUSTOM_CONFIG_VERSION=<"%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp"
if exist "%CB_CUSTOM_CONFIG_PATH%\offline" if ".%CB_CUSTOM_CONFIG_VERSION%" == "." (del "%CB_CUSTOM_CONFIG_PATH%\offline" 
	set "errorCode=1" 
	echo %CB_LINEHEADER%Could not find nor update custom config, please repeat as soon as you are online!.
	goto :eof)
if exist "%CB_CUSTOM_CONFIG_PATH%\offline" del "%CB_CUSTOM_CONFIG_PATH%\offline" & echo %CB_LINEHEADER%Offline, keep current version [%CB_CUSTOM_CONFIG_VERSION%].
if exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" set CB_CUSTOM_CONFIG_VERSION=%CB_CUSTOM_CONFIG_VERSION: =%
if exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" set "CB_CUSTOM_RUNTIME_CONFIG_PATH=%CB_CUSTOM_CONFIG_PATH%\%CB_CUSTOM_CONFIG_VERSION%"
if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat" set "CB_CUSTOM_SETTING=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat"
if exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use custom config version %CB_CUSTOM_CONFIG_VERSION%.
if not exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Timestamp %CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp do not exist.

:: simulate lasCheck.properties
::if exist %lastCheckPropertiesFile% for /f "tokens=2 delims==" %%i in ('type "%lastCheckPropertiesFile%"^|findstr /C:lastCheck') do ( set "lastCheckTimestamp=%%i" )
::if exist %lastCheckPropertiesFile% set lastCheckTimestamp=%lastCheckTimestamp:~0,10%
::if exist %lastCheckPropertiesFile% set lastCheckTimestamp=%lastCheckTimestamp:-=%
::if [%TS_LOCK_TSP%] neq [%lastCheckTimestamp%] if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Common gradle timestamp is differently [%TS_LOCK_TSP%] [%lastCheckTimestamp%]
if exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" if not .%CB_CUSTOM_CONFIG_VERSION%==. echo lastCheck=%LAST_CHECK_TSP%>"%lastCheckPropertiesFile%" & echo version=%CB_CUSTOM_CONFIG_VERSION%>>"%lastCheckPropertiesFile%"
if exist "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp" goto :eof

call %CB_SCRIPT_PATH%include\update-cb-custom-home.bat "%CB_CUSTOM_CONFIG_PATH%" %CB_CUSTOM_CONFIG%
if %ERRORLEVEL% NEQ 0 (set "errorCode=%ERRORLEVEL%" 
	if .%CB_VERBOSE%==.true echo %CB_LINEHEADER%Could not update custom config.
	goto :eof)
if ".%CB_CUSTOM_CONFIG_VERSION%"=="." (set "errorCode=1" 
	if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Could not get custom config version.
	goto :eof)

del /f /q "%CB_CUSTOM_CONFIG_PATH%\*.tsp" >nul 2>nul
set CB_CUSTOM_CONFIG_VERSION=%CB_CUSTOM_CONFIG_VERSION: =%
echo %CB_CUSTOM_CONFIG_VERSION%> "%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp"
echo lastCheck=%LAST_CHECK_TSP%>"%lastCheckPropertiesFile%" 
echo version=%CB_CUSTOM_CONFIG_VERSION%>>"%lastCheckPropertiesFile%"
set "CB_CUSTOM_RUNTIME_CONFIG_PATH=%CB_CUSTOM_CONFIG_PATH%\%CB_CUSTOM_CONFIG_VERSION%"
if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat" set "CB_CUSTOM_SETTING=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat"
if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat" set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_SETTING%"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use custom config version %CB_CUSTOM_CONFIG_VERSION%.
if .%CB_VERBOSE% == .true if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat" echo %CB_LINEHEADER%Found custom script %CB_CUSTOM_SETTING_SCRIPT%.
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" custom-config-update-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:VERIFY_CONFIGURATION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not defined ENABLE_CONFIGURATION set "ENABLE_CONFIGURATION=true"
echo %ENABLE_CONFIGURATION% | findstr /I /C:"true" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :eof
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Verify configuration...

:: replace MaxPermSize with MaxMetaspaceSize
set "GRADLE_PROPERTIES=gradle.properties"
if not exist %GRADLE_PROPERTIES% goto :eof
findstr /I /C:"-XX:MaxPermSize=" %GRADLE_PROPERTIES% > nul 2>nul
if %ERRORLEVEL% NEQ 1 (echo %CB_LINEHEADER%Update %GRADLE_PROPERTIES%...
	powershell -Command "(Get-Content "$Env:GRADLE_PROPERTIES") -replace '-XX:MaxPermSize=', '-XX:MaxMetaspaceSize=' | Out-File -encoding ASCII "$Env:GRADLE_PROPERTIES""
	set "CB_BUILD_UPDATE=true")
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COMMON_BUILD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "cbJavaVersion=" & set "cbJavaMajorVersion=" & set "cbJavaVersionFilter=*" & set "cbJavaVersionAvailable=" & set "CB_JAVA_HOME_RUNTIME="
set JAVAC_EXEC=javac
if .%CB_OFFLINE%==.true title %TITLE_NAME% (offline) 

:: add python to path if available
if not defined CB_PYTHON_HOME if exist %CB_CURRENT_PATH%\python set "CB_PYTHON_HOME=%CB_CURRENT_PATH%\python"
if defined CB_PYTHON_HOME echo %CB_PYTHON_HOME% | findstr /I %CB_DEVTOOLS% >nul 2>nul
::if defined CB_PYTHON_HOME if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_PYTHON_HOME is not set to a python version in devtools (%CB_DEVTOOLS%): %CB_PYTHON_HOME%. & goto END_WITH_ERROR
if defined CB_PYTHON_HOME echo %PATH% | findstr /C:"%CB_PYTHON_HOME%" >nul 2>nul
if defined CB_PYTHON_HOME if %ERRORLEVEL% NEQ 0 set "PATH=%CB_PYTHON_HOME%;%PATH%"

:: current run java switch
if exist %CB_JAVA_VERSION_FILE% (set /pcbJavaVersion=<%CB_JAVA_VERSION_FILE% & del /f /q "%CB_JAVA_VERSION_FILE%" 2>nul)
if defined cbJavaVersion set cbJavaVersion=%cbJavaVersion: =%
if defined cbJavaVersion echo %CB_LINEHEADER%Set java version %cbJavaVersion% (by command line --java)
if defined cbJavaVersion goto COMMON_BUILD_VERIFY_JAVA_INSTALLATION

:: project specific java switch
if exist %CB_PROJECT_JAVA_VERSION_FILE% (set /pcbJavaVersion=<%CB_PROJECT_JAVA_VERSION_FILE%)
if defined cbJavaVersion set cbJavaVersion=%cbJavaVersion: =%
if defined cbJavaVersion echo %CB_LINEHEADER%Set project java version %cbJavaVersion% (from .java-version)
if defined cbJavaVersion goto COMMON_BUILD_VERIFY_JAVA_INSTALLATION

:: check CB_JAVA_HOME; otherwise set default java 
if not .%CB_JAVA_HOME% == . set "CB_JAVA_HOME_RUNTIME=%CB_JAVA_HOME%" & goto COMMON_BUILD_VERIFY_JAVA
if not exist %CB_CURRENT_PATH%\java\bin (call %PN_FULL% --silent --install java --default)
set "CB_JAVA_HOME=%CB_CURRENT_PATH%\java" 
set "CB_JAVA_HOME_RUNTIME=%CB_JAVA_HOME%" 
if not exist %CB_JAVA_HOME_RUNTIME%\bin echo %CB_LINEHEADER%Could not find default java installation. & goto END_WITH_ERROR 
goto COMMON_BUILD_VERIFY_JAVA

:COMMON_BUILD_VERIFY_JAVA_INSTALLATION
if defined cbJavaVersion set "cbJavaVersionFilter=%cbJavaVersion%*"
set /a "cbJavaMajorVersion=%cbJavaVersion%" 2>nul
if not .%cbJavaMajorVersion% == .%cbJavaVersion% echo %CB_LINEHEADER%Invalid java version paramter %cbJavaVersion% (only major version can be referenced, e.g. 11, 12...) & goto END_WITH_ERROR
set "TMPFILE=%CB_TEMP%\cb-java-%RANDOM%%RANDOM%.tmp"
if not defined CB_DEVTOOLS_JAVA_PREFIX set "CB_DEVTOOLS_JAVA_PREFIX=*"
if defined cbJavaVersion dir %CB_DEVTOOLS%\%CB_DEVTOOLS_JAVA_PREFIX%%cbJavaVersionFilter% /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
if defined cbJavaVersion for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install java %cbJavaVersion%
::if not defined cbJavaVersion call %PN_FULL% --silent --install java 
if not defined cbJavaVersion for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install java 
dir %CB_DEVTOOLS%\%CB_DEVTOOLS_JAVA_PREFIX%%cbJavaVersionFilter% /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pcbJavaVersion=<"%TMPFILE%" & set "cbJavaVersionAvailable=true"
if exist %TMPFILE% del /f /q "%TMPFILE%" 2>nul
set "cbJavaVersion=%cbJavaVersion:~2%"
set "versionInformation=,"
if defined cbJavaVersion set "versionInformation=%cbJavaVersion%,"
if not defined cbJavaVersionAvailable echo %CB_LINEHEADER%Can not find common-build java version %versionInformation% give up. & goto END_WITH_ERROR
set "CB_JAVA_HOME_RUNTIME=%CB_DEVTOOLS%\%cbJavaVersion%"

:COMMON_BUILD_VERIFY_JAVA
::if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Verify java version [%CB_JAVA_HOME_RUNTIME%].
echo %CB_JAVA_HOME_RUNTIME% | findstr /I %CB_DEVTOOLS% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_JAVA_HOME is not set to a java version in devtools (%CB_DEVTOOLS%): %CB_JAVA_HOME_RUNTIME%. & goto END_WITH_ERROR
dir %CB_JAVA_HOME_RUNTIME%\bin\%JAVAC_EXEC%* >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_JAVA_HOME entry could not be found: %CB_JAVA_HOME_RUNTIME%. & goto END_WITH_ERROR
echo %PATH% | findstr /C:"%CB_JAVA_HOME_RUNTIME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_JAVA_HOME_RUNTIME%\bin;%PATH%"
:: & echo %CB_LINEHEADER%Set %CB_JAVA_HOME_RUNTIME% to path.
if not ."%JAVA_HOME%" == .%CB_JAVA_HOME_RUNTIME% set "JAVA_HOME=%CB_JAVA_HOME_RUNTIME%"
:: & echo %CB_LINEHEADER%Set JAVA_HOME to %JAVA_HOME%.
WHERE %JAVAC_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find java version in path. & goto END_WITH_ERROR

:: verify configuration
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" verify-configuration %1 %2 %3 %4 %5 %6 %7 2>nul
call :VERIFY_CONFIGURATION

:: decide which build tool to use
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" build-start %1 %2 %3 %4 %5 %6 %7 2>nul
if exist build.gradle goto COMMON_BUILD_GRADLE
if exist pom.xml goto COMMON_BUILD_MAVEN
if exist build.xml goto COMMON_BUILD_ANT
if exist package.json goto COMMON_BUILD_NODE

:: if there is no known configuration file just end
echo %CB_LINE%
echo %CB_LINEHEADER%No configuration file found for common build known build tools.
echo %CB_LINEHEADER%Change into a project or create a new project, see cb --help.
echo %CB_LINE%
goto END_WITH_ERROR


:: gradle
:COMMON_BUILD_GRADLE
set GRADLE_EXEC=gradle
if exist gradlew.bat set "GRADLE_EXEC=gradlew" & goto COMMON_BUILD_GRADLE_EXEC
if exist gradlew set "GRADLE_EXEC=gradlew" & goto COMMON_BUILD_GRADLE_EXEC
if defined CB_GRADLE_HOME goto COMMON_BUILD_VERIFY_GRADLE
if not exist %CB_CURRENT_PATH%\gradle\bin (call %PN_FULL% --silent --install gradle --default)
if exist %CB_CURRENT_PATH%\gradle\bin set "CB_GRADLE_HOME=%CB_CURRENT_PATH%\gradle"
::set "TMPFILE=%CB_TEMP%\cb-gradle-%RANDOM%%RANDOM%.tmp"
::dir %CB_DEVTOOLS%\*gradle* /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
::for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install gradle
::dir %CB_DEVTOOLS%\*gradle* /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
::for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pCB_GRADLE_HOME=<"%TMPFILE%"
::if exist %TMPFILE%  del /f /q "%TMPFILE%" 2>nul
::set "CB_GRADLE_HOME=%CB_DEVTOOLS%\%CB_GRADLE_HOME:~2%"
:COMMON_BUILD_VERIFY_GRADLE
echo %CB_GRADLE_HOME% | findstr /I %CB_DEVTOOLS% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_GRADLE_HOME is not set to a gradle version in devtools (%CB_DEVTOOLS%): %CB_GRADLE_HOME%. & goto END_WITH_ERROR
echo %PATH% | findstr /C:"%CB_GRADLE_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_GRADLE_HOME%\bin;%PATH%"
:: & echo %CB_LINEHEADER%Set %CB_GRADLE_HOME% to path.
if not .%GRADLE_HOME% == .%CB_GRADLE_HOME% set "GRADLE_HOME=%CB_GRADLE_HOME%"
:: & echo %CB_LINEHEADER%Set GRADLE_HOME to %GRADLE_HOME%.
WHERE %GRADLE_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find gradle version in path. & goto END_WITH_ERROR
:COMMON_BUILD_GRADLE_EXEC
if defined CB_OFFLINE set "CB_PARAMETERS=--offline %CB_PARAMETERS%" & echo %CB_LINEHEADER%Offline build.
if exist package.json call :PREPARE_COMMON_BUILD_NODE
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Execute gradle [%GRADLE_EXEC%], parameters: [%CB_PARAMETERS%].
cmd /C call %GRADLE_EXEC% %CB_PARAMETERS%
if %ERRORLEVEL% NEQ 0 goto END_WITH_ERROR
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END

:: maven
:COMMON_BUILD_MAVEN
set MAVEN_EXEC=mvn
if exist mvnw.bat set "MAVEN_EXEC=mvnw" & goto COMMON_BUILD_MAVEN_EXEC
if exist mvnw set "MAVEN_EXEC=mvnw" & goto COMMON_BUILD_MAVEN_EXEC
if defined CB_MAVEN_HOME goto COMMON_BUILD_VERIFY_MAVEN
if not exist %CB_CURRENT_PATH%\maven\bin (call %PN_FULL% --silent --install maven --default)
if exist %CB_CURRENT_PATH%\maven\bin set "CB_MAVEN_HOME=%CB_CURRENT_PATH%\maven"
::set "TMPFILE=%CB_TEMP%\cb-maven-%RANDOM%%RANDOM%.tmp"
::dir %CB_DEVTOOLS%\*maven* /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
::for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install maven
::dir %CB_DEVTOOLS%\*maven* /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
::for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pCB_MAVEN_HOME=<"%TMPFILE%"
::if exist %TMPFILE% del /f /q "%TMPFILE%" 2>nul
::set "CB_MAVEN_HOME=%CB_DEVTOOLS%\%CB_MAVEN_HOME:~2%"
:COMMON_BUILD_VERIFY_MAVEN
echo %CB_MAVEN_HOME% | findstr /I %CB_DEVTOOLS%  >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_MAVEN_HOME is not set to a maven version in devtools (%CB_DEVTOOLS%): %CB_MAVEN_HOME%. & goto END_WITH_ERROR
echo %PATH% | findstr /C:"%CB_MAVEN_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_MAVEN_HOME%\bin;%PATH%"
::echo %CB_LINEHEADER%Set %CB_MAVEN_HOME% to path.
if not .%MAVEN_HOME% == .%CB_MAVEN_HOME% set "MAVEN_HOME=%CB_MAVEN_HOME%"
:: & echo %CB_LINEHEADER%Set MAVEN_HOME to %MAVEN_HOME%.
WHERE %MAVEN_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find maven version in path. & goto END_WITH_ERROR
:COMMON_BUILD_MAVEN_EXEC
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Execute maven [%MAVEN_EXEC%], parameters: [%CB_PARAMETERS%].
cmd /C call %MAVEN_EXEC% %CB_PARAMETERS%
if %ERRORLEVEL% NEQ 0 goto END_WITH_ERROR
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END

:: ant
:COMMON_BUILD_ANT
set ANT_EXEC=ant
if defined CB_ANT_HOME goto COMMON_BUILD_VERIFY_ANT
if not exist %CB_CURRENT_PATH%\ant\bin (call %PN_FULL% --silent --install ant --default)
if exist %CB_CURRENT_PATH%\ant\bin set "CB_ANT_HOME=%CB_CURRENT_PATH%\ant"
::set "TMPFILE=%CB_TEMP%\cb-ant-%RANDOM%%RANDOM%.tmp"
::dir %CB_DEVTOOLS%\*ant* /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
::for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install ant
::dir %CB_DEVTOOLS%\*ant* /O-D/b 2>nul | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
::for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pCB_ANT_HOME=<"%TMPFILE%"
::if exist %TMPFILE% del /f /q "%TMPFILE%" 2>nul
::set "CB_ANT_HOME=%CB_DEVTOOLS%\%CB_ANT_HOME:~2%"
:COMMON_BUILD_VERIFY_ANT
echo %CB_ANT_HOME% | findstr /I %CB_DEVTOOLS% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_ANT_HOME is not set to a maven version in devtools (%CB_DEVTOOLS%): %CB_ANT_HOME%. & goto END_WITH_ERROR
echo %PATH% | findstr /C:"%CB_ANT_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_ANT_HOME%\bin;%PATH%"
::echo %CB_LINEHEADER%Set %CB_ANT_HOME% to path. 
if not .%ANT_HOME% == .%CB_ANT_HOME% set "ANT_HOME=%CB_ANT_HOME%"
:: & echo %CB_LINEHEADER%Set ANT_HOME to %ANT_HOME%.
WHERE %ANT_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find ant version in path. & goto END_WITH_ERROR
:COMMON_BUILD_ANT_EXEC
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Execute ant [%ANT_EXEC%], parameters: [%CB_PARAMETERS%].
cmd /C call %ANT_EXEC% %CB_PARAMETERS%
if %ERRORLEVEL% NEQ 0 goto END_WITH_ERROR
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END

:: node
:PREPARE_COMMON_BUILD_NODE
set NODE_EXEC=npm
if not defined CB_NODE_HOME ( 
	if not exist %CB_CURRENT_PATH%\node call %PN_FULL% --silent --install node --default
	if exist %CB_CURRENT_PATH%\node set "CB_NODE_HOME=%CB_CURRENT_PATH%\node")
echo %CB_NODE_HOME% | findstr /I %CB_DEVTOOLS% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_NODE_HOME is not set to a node version in devtools (%CB_DEVTOOLS%): %CB_NODE_HOME%. & goto END_WITH_ERROR
echo %PATH% | findstr /C:"%CB_NODE_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_NODE_HOME%;%PATH%"
:: & echo %CB_LINEHEADER%Set %CB_NODE_HOME% to path.
if not .%NODE_HOME% == .%CB_NODE_HOME% set "NODE_HOME=%CB_NODE_HOME%"
:: & echo %CB_LINEHEADER%Set NODE_HOME to %NODE_HOME%.
WHERE %NODE_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find node version in path. & goto END_WITH_ERROR
goto :eof
:COMMON_BUILD_NODE
call :PREPARE_COMMON_BUILD_NODE
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Execute node [%NODE_EXEC%], parameters: [%CB_PARAMETERS%].
cmd /C call %NODE_EXEC% %CB_PARAMETERS%
if %ERRORLEVEL% NEQ 0 goto END_WITH_ERROR
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INSTALL_CB
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "DATESTAMP=%YYYY%%MM%%DD%"
set "TIMESTAMP=%HH%%Min%%Sec%" 
set "FULLTIMESTAMP=%DATESTAMP%-%TIMESTAMP%"
set "USER_FRIENDLY_DATESTAMP=%DD%.%MM%.%YYYY%" 
set "USER_FRIENDLY_TIMESTAMP=%HH%:%Min%:%Sec%" 
set "USER_FRIENDLY_FULLTIMESTAMP=%USER_FRIENDLY_DATESTAMP% %USER_FRIENDLY_TIMESTAMP%"

:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" install-start %1 %2 %3 %4 %5 %6 %7 2>nul

if [%CB_VERBOSE%] equ [true] (echo %CB_LINE%
		echo %CB_LINEHEADER%Start common-build installation on %COMPUTERNAME%, %USER_FRIENDLY_FULLTIMESTAMP%
		echo %CB_LINEHEADER%Use %CB_DEVTOOLS% path as devtools folder
		echo %CB_LINE%)

:: create directories
if not exist %CB_DEVTOOLS% mkdir %CB_DEVTOOLS% >nul 2>nul 
if not exist %CB_HOME% mkdir %CB_HOME% >nul 2>nul 
set "CB_BIN=%CB_HOME%\bin" 
if not exist %CB_BIN% mkdir %CB_BIN% >nul 2>nul
set "CB_LOGS=%CB_HOME%\logs" 
if not exist %CB_LOGS% mkdir %CB_LOGS% >nul 2>nul 
set "CB_DEV_REPOSITORY=%CB_DEVTOOLS%\.repository" 
if not exist %CB_DEV_REPOSITORY% mkdir %CB_DEV_REPOSITORY% >nul 2>nul

set "CB_LOGFILE=%CB_LOGS%\%FULLTIMESTAMP%-%CB_USER%.log"
::if [%CB_INSTALL_SILENT%] equ [false] (echo %CB_LINEHEADER%The installation log file can be found here "%CB_LOGFILE%")
echo %CB_LINE%>> "%CB_LOGFILE%"
echo Start common-build installation on %COMPUTERNAME%, %USER_FRIENDLY_FULLTIMESTAMP%>> "%CB_LOGFILE%"
echo common-build: %CB_HOME%>> "%CB_LOGFILE%"
echo devtools: %CB_DEVTOOLS%>> "%CB_LOGFILE%"
::echo wget: %CB_WGET_VERSION%, gradle: %CB_GRADLE_VERSION%, java: %CB_JAVA_VERSION%>> "%CB_LOGFILE%"
echo %CB_LINE%>> "%CB_LOGFILE%"

:: tools settings
set "CB_WGET_SECURITY_CREDENTIALS=--trust-server-names --no-check-certificate"
set "CB_WGET_PROGRESSBAR=--show-progress"
set "CB_WGET_LOG=-a %CB_LOGFILE%"
set "CB_WGET_PARAM=-c"
set CB_PKG_FILTER=
set CB_PACKAGE_DOWNLOAD_NAME=
set CB_PKG_FILTER_WILDCARD=false
set CB_PACKAGE_DEST_VERSION_NAME=
set CB_PROCESSOR_ARCHITECTURE_NUMBER=64
set CB_PACKAGE_INSTALL_PARAMETER=
set CB_PACKAGE_NO_DEFAULT=false
set CB_PACKAGE_ALREADY_EXIST=false
set CB_POST_INSTALL_ACTION=
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:32=%" set CB_PROCESSOR_ARCHITECTURE_NUMBER=32
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:64=%" set CB_PROCESSOR_ARCHITECTURE_NUMBER=64

if .%1 == .--default shift & set CB_SET_DEFAULT=true
if .%1 == .-d shift & set CB_SET_DEFAULT=true
set CB_INSTALL_PKG=%1
if .%CB_INSTALL_PKG%==. echo %CB_LINEHEADER%No package found to install. & goto INSTALL_CB_END
shift
if .%1 == .--default shift & set CB_SET_DEFAULT=true
if .%1 == .-d shift & set CB_SET_DEFAULT=true
set CB_INSTALL_VERSION=%1
shift
if .%1 == .--default shift & set CB_SET_DEFAULT=true
if .%1 == .-d shift & set CB_SET_DEFAULT=true
set CB_INSTALL_VERSION_PARAM=%2
if .%1 == .--default shift & set CB_SET_DEFAULT=true
if .%1 == .-d shift & set CB_SET_DEFAULT=true
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" download-package-start %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %CB_INSTALL_VERSION_PARAM% 2>nul

if .%CB_INSTALL_PKG%==.cb goto INSTALL_CB_PACKAGE
if .%CB_INSTALL_PKG%==.pkg goto INSTALL_PACKAGES
if not .%CB_INSTALL_VERSION%==. goto TOOL_VERSION_DEFAULT_END

:TOOL_VERSION_DEFAULT_START
if not ".%CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\tool-version-default.properties" set "CB_TOOL_VERSION_DEFAULT=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\tool-version-default.properties"
if not ".%CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\tool-version-default.properties" goto READ_TOOL_VERSION_DEFAULT
if .%CB_OFFLINE% == .true goto READ_TOOL_VERSION_DEFAULT
:: read ones a day the newest tool version
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%" & set "DATETIMESTAMP=%YYYY%%MM%%DD%"
set "CB_TOOL_VERSION_DEFAULT_CHECK=%CB_TOOL_VERSION_DEFAULT%.lastCheck"
if not exist %CB_TOOL_VERSION_DEFAULT_CHECK% goto GET_TOOL_VERSION_DEFAULT
set /plastCheck=<%CB_TOOL_VERSION_DEFAULT_CHECK%
if [%lastCheck%] EQU [%DATETIMESTAMP%] goto READ_TOOL_VERSION_DEFAULT
:GET_TOOL_VERSION_DEFAULT
set "TOOL_VERSION_DEFAULT_TMP=%CB_TEMP%\tool-version-default.properties"
echo %CB_LINEHEADER%Updated tool-version-default.properties.
cd /D %CB_TEMP%
%CB_BIN%\%CB_WGET_CMD% %CB_TOOL_VERSION_DEFAULT_URL% %CB_WGET_PARAM% %CB_WGET_SECURITY_CREDENTIALS% %CB_WGET_PROGRESSBAR% %CB_WGET_LOG%
cd /D %CB_WORKING_PATH%
for %%R in ("%TOOL_VERSION_DEFAULT_TMP%") do if not %%~zR lss 1 move %TOOL_VERSION_DEFAULT_TMP% %CB_TOOL_VERSION_DEFAULT% >nul 2>nul
if exist %TOOL_VERSION_DEFAULT_TMP% del /f /q "%TOOL_VERSION_DEFAULT_TMP%" >nul 2>nul
echo %DATETIMESTAMP%> %CB_TOOL_VERSION_DEFAULT_CHECK%
goto TOOL_VERSION_DEFAULT_START
:READ_TOOL_VERSION_DEFAULT
dir %CB_TOOL_VERSION_DEFAULT% >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto TOOL_VERSION_DEFAULT_END
set "CB_TOOL_VERSION_DEFAULT_TMPFILE=%CB_TEMP%\cb-tool-version-default-%RANDOM%%RANDOM%.tmp"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use [%CB_TOOL_VERSION_DEFAULT%].
type %CB_TOOL_VERSION_DEFAULT% 2>nul | findstr /C:= > %CB_TOOL_VERSION_DEFAULT_TMPFILE% 2>nul
for /f "tokens=1,2* delims== " %%i in (%CB_TOOL_VERSION_DEFAULT_TMPFILE%) do (if .%%i == .%CB_INSTALL_PKG% set "CB_INSTALL_VERSION=%%j" & set "CB_INSTALL_VERSION_PARAM=%%k")
if exist %CB_TOOL_VERSION_DEFAULT_TMPFILE% del /f /q "%CB_TOOL_VERSION_DEFAULT_TMPFILE%" >nul 2>nul
:TOOL_VERSION_DEFAULT_END

if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Call %CB_SCRIPT_PATH%include\download.bat %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %CB_INSTALL_VERSION_PARAM%
call %CB_SCRIPT_PATH%include\download.bat %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %CB_INSTALL_VERSION_PARAM%
if %ERRORLEVEL% NEQ 0 goto INSTALL_CB_END
if not .%CB_PACKAGE_DOWNLOAD_NAME%==. set "CB_PKG_FILTER=%CB_PACKAGE_DOWNLOAD_NAME%" 

:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" download-package-end %CB_INSTALL_PKG% %CB_INSTALL_VERSION% 2>nul
echo %CB_LINE%>> "%CB_LOGFILE%"
goto CHECK_EXTRACT_ARCHIVES 


:INSTALL_CB_PACKAGE
if [%CB_INSTALL_SILENT%] equ [false] (if .%CB_INSTALL_VERSION% == . echo %CB_LINEHEADER%Install newest cb version...
	if not .%CB_INSTALL_VERSION% == . echo %CB_LINEHEADER%Install cb version %CB_INSTALL_VERSION%...)
if [%CB_INSTALL_OVERWRITE_DIST%] equ [true] (call %CB_SCRIPT_PATH%cb-install --force --silent %CB_INSTALL_VERSION%)
if [%CB_INSTALL_OVERWRITE_DIST%] equ [false] (call %CB_SCRIPT_PATH%cb-install --silent %CB_INSTALL_VERSION%)

:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" download-package-end %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %CB_INSTALL_VERSION_PARAM% 2>nul
echo %CB_LINE%>> "%CB_LOGFILE%"
goto INSTALL_CB_END


:: packages
:INSTALL_PACKAGES
:: custom setting script
set CB_PKG_FILTER=*.zip
set CB_PKG_FILTER_WILDCARD=true
if not defined CB_PACKAGE_URL echo %CB_LINEHEADER%No CB_PACKAGE_URL environment variable found. & goto INSTALL_CB_END
set CB_WGET_USER_CREDENTIALS=
if [%CB_PACKAGE_USER%] equ [] (set /p CB_PACKAGE_USER=Please enter user credentials, e.g. %CB_USER%: )
if [%CB_PACKAGE_USER%] equ [] (set "CB_PACKAGE_USER=%CB_USER%")
if [%CB_PACKAGE_PASSWORD%] equ [ask] (set CB_WGET_USER_CREDENTIALS=--ask-password --user %CB_PACKAGE_USER%)
set CB_WGET_RECURSIVE_PARAM=-r -np -nH --timestamping
set CB_WGET_FILTER=--exclude-directories=_deprecated -R "index.*"
echo %CB_LINE%>> "%CB_LOGFILE%"
echo %CB_LINEHEADER%Install packages from %CB_PACKAGE_URL% & echo %CB_LINEHEADER%Install packages from %CB_PACKAGE_URL%>> "%CB_LOGFILE%"

cd /D %CB_DEV_REPOSITORY%
echo %CB_BIN%\%CB_WGET_CMD% %CB_PACKAGE_URL% %CB_WGET_PARAM% %CB_WGET_RECURSIVE_PARAM% %CB_WGET_SECURITY_CREDENTIALS% %CB_WGET_PROGRESSBAR% %CB_WGET_USER_CREDENTIALS% %CB_WGET_FILTER% %CB_WGET_LOG%>> "%CB_LOGFILE%"
%CB_BIN%\%CB_WGET_CMD% %CB_PACKAGE_URL% %CB_WGET_PARAM% %CB_WGET_RECURSIVE_PARAM% %CB_WGET_SECURITY_CREDENTIALS% %CB_WGET_PROGRESSBAR% %CB_WGET_USER_CREDENTIALS% %CB_WGET_FILTER% %CB_WGET_LOG%
cd /D %CB_WORKING_PATH%
if not %ERRORLEVEL% equ 6 goto INSTALL_PACKAGES_END
echo %CB_LINEHEADER%ERROR: Invalid credentials, give up. >> "%CB_LOGFILE%"
echo %CB_LINE%
echo %CB_LINEHEADER%ERROR: Invalid credentials, give up.
echo %CB_LINE%
goto INSTALL_CB_END

:INSTALL_PACKAGES_END
:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" download-package-end %CB_INSTALL_PKG% %CB_INSTALL_VERSION% 2>nul
echo %CB_LINE%>> "%CB_LOGFILE%"


:: extract
:CHECK_EXTRACT_ARCHIVES
:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" extract-package-start %CB_INSTALL_PKG% %CB_INSTALL_VERSION% 2>nul
if .%CB_PACKAGE_ALREADY_EXIST%==.true (if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Package %CB_INSTALL_PKG% already exists.
	goto EXTRACT_ARCHIVES_END)

if not defined CB_PKG_FILTER goto EXTRACT_ARCHIVES_END
if [%CB_PKG_FILTER_WILDCARD%] equ [true] (goto EXTRACT_ARCHIVES_START)
if not exist %CB_DEV_REPOSITORY%\%CB_PKG_FILTER% goto EXTRACT_ARCHIVES_FAILED

:EXTRACT_ARCHIVES_START
echo %CB_LINE%>> "%CB_LOGFILE%"
set errorCode=0
cd /D %CB_DEVTOOLS%
set "CB_UNZIP_PARAM=-n"
if .%CB_INSTALL_OVERWRITE_DIST%==.true set "CB_UNZIP_PARAM=-o"
if not .%CB_PACKAGE_DEST_VERSION_NAME% == . mkdir %CB_PACKAGE_DEST_VERSION_NAME% 2>nul & set "CB_UNZIP_PARAM=%CB_UNZIP_PARAM% -d %CB_PACKAGE_DEST_VERSION_NAME%"
if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Extract %CB_PKG_FILTER% in %CB_DEVTOOLS%...
echo %CB_LINEHEADER%Extract %CB_PKG_FILTER% in %CB_DEVTOOLS%... >> "%CB_LOGFILE%"
FOR /F %%i IN ('dir %CB_DEV_REPOSITORY%\%CB_PKG_FILTER% /b/s') DO (call :EXTRACT_FILE %%i)
echo %CB_LINE%>> "%CB_LOGFILE%"
cd /D %CB_WORKING_PATH%
goto SET_INSTALLTION_DEFAULT

:EXTRACT_FILE
::powershell -nologo -command "(Get-Item '%1').VersionInfo.ProductVersion" >> "%1.txt"	
echo %1 | findstr /I /C:.exe >nul 2>nul	
if %ERRORLEVEL% EQU 0 cmd /c "%1 %CB_PACKAGE_INSTALL_PARAMETER%" & set "errorCode=%ERRORLEVEL%" & goto :eof
echo %1 | findstr /I /C:.msi >nul 2>nul	
if %ERRORLEVEL% EQU 0 cmd /c "%1 %CB_PACKAGE_INSTALL_PARAMETER%" & set "errorCode=%ERRORLEVEL%" & goto :eof
echo %1 | findstr /I /C:.msixbundle >nul 2>nul	
if %ERRORLEVEL% EQU 0 cmd /c "%1 %CB_PACKAGE_INSTALL_PARAMETER%" & set "errorCode=%ERRORLEVEL%" & goto :eof

set "TMPFILE=%CB_TEMP%\cb-extract-file-%RANDOM%%RANDOM%.tmp"
if exist %CB_BIN%\%CB_UNZIP_CMD% %CB_BIN%\%CB_UNZIP_CMD% -Z -1 %1 | findstr/n ^^ | findstr ^^1:> "%TMPFILE%"
if %ERRORLEVEL% NEQ 0 set "errorCode=%ERRORLEVEL%" & echo %CB_LINEHEADER%Could not extract package. & del /f /q "%TMPFILE%" >nul 2>nul & goto :eof
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /ptopDirectory=<"%TMPFILE%"
if exist %TMPFILE% del /f /q "%TMPFILE%" >nul 2>nul
if .%topDirectory% == . echo %CB_LINEHEADER%Could not get root directory of %1, give up. & del /f /q "%TMPFILE%" >nul 2>nul & goto :eof
set "topDirectory=%topDirectory:~2%" 
set "topDirectory=%topDirectory:/=%"
if not .%CB_PACKAGE_DEST_VERSION_NAME% == . set "topDirectory=%CB_PACKAGE_DEST_VERSION_NAME%"
if [%CB_INSTALL_SILENT%] equ [false] if exist %CB_DEVTOOLS%\%topDirectory% echo %CB_LINEHEADER%Directory %CB_DEVTOOLS%\%topDirectory% will be updated.
if exist %CB_BIN%\%CB_UNZIP_CMD% %CB_BIN%\%CB_UNZIP_CMD% %CB_UNZIP_PARAM% %1 >> "%CB_LOGFILE%" 
if %ERRORLEVEL% NEQ 0 set "errorCode=%ERRORLEVEL%" & echo %CB_LINEHEADER%Could not extract package. & goto :eof
if not exist %CB_BIN%\%CB_UNZIP_CMD% powershell -nologo -command "Expand-Archive -Force '%1' '%CB_DEVTOOLS%'" >> "%CB_LOGFILE%" 2>nul	
if exist %CB_DEVTOOLS%\%topDirectory% set "CB_PACKAGE_DIRECTORY_NAME=%CB_DEVTOOLS%\%topDirectory%"
goto :eof

:EXTRACT_ARCHIVES_FAILED
echo %CB_LINEHEADER%No package found %CB_PACKAGE_VERSION_NAME% (%CB_PKG_FILTER%)
goto EXTRACT_ARCHIVES_END

:SET_INSTALLTION_DEFAULT
if %errorCode% NEQ 0 goto EXTRACT_ARCHIVES_END
if .%2 == .--default set CB_SET_DEFAULT=true
if .%2 == .-d set CB_SET_DEFAULT=true
if .%CB_PACKAGE_NO_DEFAULT% == .true goto EXTRACT_ARCHIVES_END

set CB_INSTALLED_VERSION=%CB_INSTALL_VERSION%
set CB_INSTALLED_VERSION=%CB_INSTALLED_VERSION: =%
if not .%CB_PACKAGE_VERSION% == . set CB_INSTALLED_VERSION=%CB_PACKAGE_VERSION%
::set installedMajorNumber= & for /f "tokens=1 delims=." %%i in ("%CB_INSTALLED_VERSION%") do (set "installedMajorNumber=%%i")
set CB_INSTALLED_PKG_PREFIX= & for /f "tokens=1 delims=-" %%i in ("%CB_INSTALL_PKG%") do (set "CB_INSTALLED_PKG_PREFIX=%%i")
::if .java == .%CB_INSTALLED_PKG_PREFIX% set CB_INSTALL_PKG=%CB_INSTALLED_PKG_PREFIX%
::if .java == .%CB_INSTALL_PKG% set CB_INSTALL_PKG=%CB_INSTALL_PKG%%installedMajorNumber%
set "CB_TOOL_VERSION_INSTALLED_TMPFILE=%CB_TEMP%\cb-tool-version-installed-%RANDOM%%RANDOM%.tmp"
set "CB_TOOL_VERSION_INSTALLED_TMPFILE2=%CB_TEMP%\cb-tool-version-installed-%RANDOM%%RANDOM%.tmp"
set CB_ENTRY_FOUND=false
set CB_UPDATED=false
type %CB_TOOL_VERSION_INSTALLED% 2>nul | findstr /C:= > %CB_TOOL_VERSION_INSTALLED_TMPFILE% 2>nul
for /f "tokens=1,* delims== " %%i in (%CB_TOOL_VERSION_INSTALLED_TMPFILE%) do (
	if .%%i == .%CB_INSTALL_PKG% (
		set CB_ENTRY_FOUND=true
		if .%CB_SET_DEFAULT%==.true echo %%i = %CB_INSTALLED_VERSION%>> %CB_TOOL_VERSION_INSTALLED_TMPFILE2% & set CB_UPDATED=true
		if .%CB_SET_DEFAULT%==.false echo %%i = %%j>> %CB_TOOL_VERSION_INSTALLED_TMPFILE2%)
	if not .%%i == .%CB_INSTALL_PKG% echo %%i = %%j>> %CB_TOOL_VERSION_INSTALLED_TMPFILE2%
)
if .%CB_UPDATED% == .false if .%CB_ENTRY_FOUND%==.false echo %CB_INSTALL_PKG% = %CB_INSTALLED_VERSION% >> %CB_TOOL_VERSION_INSTALLED_TMPFILE2% & set CB_SET_DEFAULT=true
if [%CB_INSTALL_SILENT%] equ [false] if .%CB_SET_DEFAULT%==.true echo %CB_LINEHEADER%Set default for package %CB_INSTALL_PKG% to version %CB_INSTALLED_VERSION%
if .%CB_SET_DEFAULT%==.true if exist %CB_CURRENT_PATH%\%CB_INSTALL_PKG% rmdir /q %CB_CURRENT_PATH%\%CB_INSTALL_PKG% >nul 2>nul
if .%CB_PACKAGE_DIRECTORY_NAME%==. goto EXTRACT_ARCHIVES_END
if .%CB_SET_DEFAULT%==.true if exist %CB_PACKAGE_DIRECTORY_NAME% mklink /J %CB_CURRENT_PATH%\%CB_INSTALL_PKG% %CB_PACKAGE_DIRECTORY_NAME% >nul 2>nul
if .%CB_SET_DEFAULT%==.true if not exist %CB_PACKAGE_DIRECTORY_NAME% echo %CB_LINEHEADER%Could not set default for %CB_INSTALL_PKG%.
if .%CB_SET_DEFAULT%==.true move %CB_TOOL_VERSION_INSTALLED_TMPFILE2% %CB_TOOL_VERSION_INSTALLED% >nul 2>nul
if exist %CB_TOOL_VERSION_INSTALLED_TMPFILE% del /f /q "%CB_TOOL_VERSION_INSTALLED_TMPFILE%" >nul 2>nul
if exist %CB_TOOL_VERSION_INSTALLED_TMPFILE2% del /f /q "%CB_TOOL_VERSION_INSTALLED_TMPFILE2%" >nul 2>nul

:EXTRACT_ARCHIVES_END
if not defined CB_POST_INSTALL_ACTION goto EXTRACT_ARCHIVES_POSTACTION_END
echo %CB_POST_INSTALL_ACTION%>> "%CB_LOGFILE%" 2>nul	
cmd /c %CB_POST_INSTALL_ACTION%

:EXTRACT_ARCHIVES_POSTACTION_END
:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" extract-package-end %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %2>nul


:INSTALL_CB_END
:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" install-end %1 %2 %3 %4 %5 %6 %7 2>nul

if [%CB_VERBOSE%] equ [true] (echo %CB_LINE%)
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:READ_INSTALLED_TOOL_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
dir %CB_TOOL_VERSION_INSTALLED% >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :eof
for /f "tokens=1,* delims== " %%i in (%CB_TOOL_VERSION_INSTALLED%) do (if .%%i == .%1 set "CB_INSTALL_VERSION=%%j")
if not .%CB_INSTALL_VERSION% == . set "CB_INSTALL_VERSION=%CB_INSTALL_VERSION: =%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_TIMESTAMP
::"yyyy-MM-ddTHH\\:mm\\:ss.fff+0000"
::"yyyyMMdd"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "timestampFormat=yyyy-MM-dd HH:mm:ss.fff"
if not .%2==. set "timestampFormat=%2"
::for /f "tokens=1-2" %%a in ('powershell get-date -format "{%timestampFormat%}"') do ( set "%1=%%a %%b" )
set "dateSeparator=" & set "timeSeparator=" & set "currentTime=" & set "timestampSeparator=" & set "mtimeSeparator=" & set "currentTimestamp="
echo %timestampFormat% | findstr/C:"." > nul
if %ERRORLEVEL% EQU 0 set "dateSeparator=."
echo %timestampFormat% | findstr/C:"-" > nul
if %ERRORLEVEL% EQU 0 set "dateSeparator=-"
echo %timestampFormat% | findstr/C:"/" > nul
if %ERRORLEVEL% EQU 0 set "dateSeparator=/"
echo %timestampFormat% | findstr/C:":" > nul
if %ERRORLEVEL% EQU 0 (set "timeSeparator=:" & set "mtimeSeparator=.")
echo %timestampFormat% | findstr/C:"\\:" > nul
if %ERRORLEVEL% EQU 0 set "timeSeparator=\:"

set t=2&if "%date%z" LSS "A" set t=1
for /f "skip=1 tokens=2-4 delims=(-)" %%A in ('echo/^|date') do (
  for /f "tokens=%t%-4 delims=.-/ " %%J in ('date/t') do (
    set "%%A=%%J" & set "%%B=%%K" & set "%%C=%%L")
)
set "currentDate=%yy%%dateSeparator%%mm%%dateSeparator%%dd%"
::echo [%currentDate%]

for /f "tokens=1-3 delims=1234567890 " %%a in ("%time%") do set "delims=%%a%%b%%c"
for /f "tokens=1-4 delims=%delims%" %%G in ("%time%") do (set "hh=%%G" & set "min=%%H" & set "ss=%%I" & set "ms=%%J")
set "hh=%hh: =%" 
if 1%hh% LSS 20 Set "hh=0%hh%"
echo %timestampFormat% | findstr/C:"H" > nul
if %ERRORLEVEL% EQU 0 (set "currentTime=%hh%")
echo %timestampFormat% | findstr/C:"m" > nul
if %ERRORLEVEL% EQU 0 (set "currentTime=%currentTime%%timeSeparator%%min%")
echo %timestampFormat% | findstr/C:"s" > nul
if %ERRORLEVEL% EQU 0 (set "currentTime=%currentTime%%timeSeparator%%ss%")
echo %timestampFormat% | findstr/C:"f" > nul
if %ERRORLEVEL% EQU 0 (if not .%ms%==. set "currentTime=%currentTime%%mtimeSeparator%%ms%")
::echo [%currentTime%]

echo %timestampFormat% | findstr/C:" " > nul
if %ERRORLEVEL% EQU 0 set "timestampSeparator= "
echo %timestampFormat% | findstr/C:"T" > nul
if %ERRORLEVEL% EQU 0 set "timestampSeparator=T"
set "currentTimestamp=%currentDate%%timestampSeparator%%currentTime%"
echo %timestampFormat% | findstr/C:"+0000" > nul
if %ERRORLEVEL% EQU 0 set "currentTimestamp=%currentDate%%timestampSeparator%%currentTime%+0000"
set "%1=%currentTimestamp%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:STRLEN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "s=#!%~1!"
set "len=0"
for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
  if "!s:~%%N,1!" neq "" (
    set /a "len+=%%N"
    set "s=!s:~%%N!"
  )
)

if "%~2" neq "" (set %~2=%len%) else echo %len%
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CB_CLEAN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%CB_HOME%\bin\cb-clean	
%CB_HOME%\bin\cb-clean --pattern gradle-worker-*
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END_WITH_ERROR
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" error-end %1 %2 %3 %4 %5 %6 %7 2>nul
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
title %CD%
call :GET_TIMESTAMP CB_END_TIMESTAMP
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Ended %CB_END_TIMESTAMP%.

if not .%CB_HOME_PREVIOUS% == .%CB_HOME% endlocal & (
  set "CB_LINE=%CB_LINE%"
  set "CB_LINEHEADER=%CB_LINEHEADER%"
  set "CB_INSTALL_SILENT=%CB_INSTALL_SILENT%"
  set "CB_HOME=%CB_HOME%"
  set "PATH=%PATH%"
  if [%CB_VERBOSE%] equ [true] echo %CB_LINEHEADER%Updated CB_HOME and PATH & echo %CB_LINE%
)

set CB_LINEHEADER=
set CB_INSTALL_SILENT=
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
