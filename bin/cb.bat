@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
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
set "CB_VERBOSE=false"
if .%1==.--verbose shift & set "CB_VERBOSE=true"
set errorCode=0
if not defined TEMP set TEMP=%TMP%

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
if not defined CB_DEVTOOLS_JAVA_PREFIX (set "CB_DEVTOOLS_JAVA_PREFIX=*jdk-")
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


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: read version
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist %CB_SCRIPT_PATH%\..\VERSION set "CB_VERSION=n/a" & goto READ_VERSION_END
( set "major.number=" & set /p "major.number="
  set "minor.number=" & set /p "minor.number="
  set "revision.number=" & set /p "revision.number="
  set "qualifier=" & set /p "qualifier=" ) < %CB_SCRIPT_PATH%\..\VERSION
set CB_VERSION=%major.number:~22%.%minor.number:~22%.%revision.number:~22%
set major.number= & set minor.number= & set revision.number= & set qualifier=
::if [%qualifier%] equ [] set CB_VERSION=%CB_VERSION%-%qualifier:~22%
::powershell -Command "$n=(Get-Content VERSION | ConvertFrom-String -Delimiter '=' -PropertyNames k,v); $r=-join($($n[0].v),'.',$($n[1].v),'.',$($n[2].v)); if([string]::IsNullOrEmpty($($n[3].v).Trim())){$r}else{$r=-join($($r),'-',$($n[3].v).Trim());$r}"
:READ_VERSION_END

:: be sure findstr works
findstr 2>nul
if %ERRORLEVEL% EQU 9009 (SET "PATH=%PATH%;%SystemRoot%\System32\")


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: custom initialisation
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_CONFIG_HOME=%USERPROFILE%\.common-build"
if exist "%CB_CONFIG_HOME%\conf\.cb-custom-config" (set /p CB_CUSTOM_CONFIG=<"%CB_CONFIG_HOME%\conf\.cb-custom-config")
if .%CB_CUSTOM_SETTING% == . goto CUSTOM_SETTINGS_INIT_END_CALL
if exist %CB_CUSTOM_SETTING% goto CUSTOM_SETTINGS_INIT_CALL
echo %CB_LINE%
echo %CB_LINEHEADER%Could not find custom script, see %%CB_CUSTOM_SETTING%%: 
echo %CB_CUSTOM_SETTING%
echo %CB_LINE%
goto CUSTOM_SETTINGS_INIT_END_CALL

:CUSTOM_SETTINGS_INIT_CALL
set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_SETTING%"
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% start %1 %2 %3 %4 %5 %6 %7 2>nul
:CUSTOM_SETTINGS_INIT_END_CALL
if not .%CB_CUSTOM_CONFIG%==. call :CB_CUSTOM_CONFIG_CHECK
if %errorCode% NEQ 0 goto END_WITH_ERROR


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: check connection
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_OFFLINE="
ping 8.8.8.8 -n 1 -w 1000 >nul 2>nul
if errorlevel 1 set "CB_OFFLINE=true"


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
echo                       file  tool-version-default.properties)
echo                       Additionally a parameter -d or --default marks this version 
echo                       as default.
echo  --packages           Shows the supported packages.
echo  -exp, --explore      Starts the file explorer with the current path.
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
echo                       example sciipt in %%CB_HOME%%\bin\sample\cb-custom-sample.bat
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
echo                       a file .common-build\conf\.cb-custom-config containing the
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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% new-project-start %CB_WIZARD_PARAMETERS% 2>nul
call %CB_SCRIPT_PATH%\include\project-wizard.bat %CB_WIZARD_PARAMETERS%
if not %ERRORLEVEL% equ 0 goto END_WITH_ERROR
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% new-project-end %CB_WIZARD_PARAMETERS% 2>nul
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROJECT_EXPLORE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
explorer %CD%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PACKAGES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo toolarium common build %CB_VERSION%
echo.
echo %CB_LINEHEADER%Available packages:
for /f "tokens=1" %%i in ('dir /b %CB_HOME%\bin\packages\') do (echo     -%%i)
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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% setenv-start %1 %2 %3 %4 %5 %6 %7 2>nul

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
if not exist %CB_CURRENT_PATH%\java goto :SET_ENV_END
set "CB_JAVA_HOME=%CB_CURRENT_PATH%\java"
set "JAVA_HOME=%CB_JAVA_HOME%"
echo %PATH% | findstr /C:"%JAVA_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%JAVA_HOME%\bin;%PATH%" & if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Add java to path (%JAVA_HOME%\bin)

:SET_ENV_END
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% setenv-end %1 %2 %3 %4 %5 %6 %7 2>nul

set CB_LINEHEADER=
set CB_CURRENT_PATH=
set CB_INSTALL_SILENT=
set CB_CUSTOM_SETTING_SCRIPT=
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CB_CUSTOM_CONFIG_CHECK
:: runCustomConfigInstallation is kind of lock
:: CB_CUSTOM_RUNTIME_CONFIG_PATH is the variable where we can refer
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if .%CB_CUSTOM_CONFIG%==. goto :eof
set TS_LOCK_TSP=%CB_START_TIMESTAMP:-=%
set TS_LOCK_TSP=%TS_LOCK_TSP:.=%
set TS_LOCK_TSP=%TS_LOCK_TSP::=%
set TS_LOCK_TSP=%TS_LOCK_TSP: =%
set "TS_LOCK_TSP=1%TS_LOCK_TSP:~6,6%"
set lockDifference=10
if defined runCustomConfigInstallation set /a "lockDifference=%TS_LOCK_TSP%-%runCustomConfigInstallation%"
::echo %lockDifference% %TS_LOCK_TSP% %runCustomConfigInstallation%
if %lockDifference% LEQ 9 goto :eof
:: if lock is older than 1 hour we ignore it!
set runCustomConfigInstallation=%TS_LOCK_TSP%
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Verify custom config [%CB_CUSTOM_CONFIG%].
for /f "tokens=1-4 delims=. " %%a in ('date /t') do (set DATESTAMP=%%c%%b%%a)
set force=false
if not exist %CB_CONFIG_HOME% mkdir %CB_CONFIG_HOME% & set "force=true"

:: prepare home directory name from domain name
for /f "tokens=1,2,3,* delims=/" %%i in ("%CB_CUSTOM_CONFIG%") do (set "urlProtocol=%%i" & set "urlHost=%%j" & set "urlPath=%%k")
for /f "tokens=1,* delims=:" %%i in ("%urlHost%") do (set "baseUrlHost=%%i" & set "urlPort=%%j")
::for /f %%i in ('powershell -Command "$env:urlHost -replace ':', '@' -replace '\.', '-' -replace ' ', '_'"') do set "urlHostPathName=%%i"
set "CB_CUSTOM_CONFIG_PATH=%CB_CONFIG_HOME%\conf\%baseUrlHost%@%urlPort%"
if not exist %CB_CUSTOM_CONFIG_PATH% mkdir %CB_CUSTOM_CONFIG_PATH% & set "force=true"
set "urlProtocol=" & set "urlHost=" & set "urlPath=" & set "urlPort=" & set "baseUrlHost="

:: set the common gradle build home path to checkout to proper destination
set "COMMON_GRADLE_BUILD_HOME=%CB_CUSTOM_CONFIG_PATH%"

:: if we have a timestamp wihtin same day then its fine
if exist %CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp set "runCustomConfigInstallation="
if exist %CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp set /p CB_CUSTOM_CONFIG_VERSION=<"%CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp"
if exist %CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp set "CB_CUSTOM_RUNTIME_CONFIG_PATH=%CB_CUSTOM_CONFIG_PATH%\%CB_CUSTOM_CONFIG_VERSION%"
if exist %CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat"
if exist %CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use custom config version %CB_CUSTOM_CONFIG_VERSION%.
if exist %CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp goto :eof

if not exist %CB_CUSTOM_CONFIG_PATH%\lastCheck.properties set "force=true"

:: remove lastCheck.properties to force check by common-gradle-build -> TODO: in case common gradle build have access to credential manager this is not anymore necessary
::if .%force%==.true del /f /q %CB_CUSTOM_CONFIG_PATH%\lastCheck.properties >nul 2>nul
del /f /q %CB_CUSTOM_CONFIG_PATH%\lastCheck.properties >nul 2>nul

set "forceCustomConfigInstallation= "
if .%force%==.true set "forceCustomConfigInstallation=--force"
call %CB_SCRIPT_PATH%\include\init-home.bat %forceCustomConfigInstallation% %CB_CUSTOM_CONFIG_PATH% %CB_CUSTOM_CONFIG%
if %ERRORLEVEL% NEQ 0 (set "errorCode=%ERRORLEVEL%" 
	if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Could not update custom config.
	goto :eof)

if [%CB_CUSTOM_CONFIG_VERSION%] NEQ [] del /f /q %CB_CUSTOM_CONFIG_PATH%\*.tsp > nul 2>nul
echo %CB_CUSTOM_CONFIG_VERSION%> %CB_CUSTOM_CONFIG_PATH%\%DATESTAMP%.tsp
if exist %CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat"
set "CB_CUSTOM_RUNTIME_CONFIG_PATH=%CB_CUSTOM_CONFIG_PATH%\%CB_CUSTOM_CONFIG_VERSION%"
set "runCustomConfigInstallation="
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use custom config version %CB_CUSTOM_CONFIG_VERSION%.
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COMMON_BUILD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "cbJavaVersion=" & set "cbJavaMajorVersion=" & set "cbJavaVersionFilter=*" & set "cbJavaVersionAvailable=" & set "CB_JAVA_HOME_RUNTIME="
set JAVAC_EXEC=javac
if .%CB_OFFLINE%==.true title %TITLE_NAME% (offline) 

::echo [%CB_PARAMETERS%]
::for /l %%a in (1,1,31) do if "!CB_PARAMETERS:~-1!"==" " set CB_PARAMETERS=!CB_PARAMETERS:~0,-1!

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
set "TMPFILE=%TEMP%\cb-java-%RANDOM%%RANDOM%.tmp"
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
if not .%JAVA_HOME% == .%CB_JAVA_HOME_RUNTIME% set "JAVA_HOME=%CB_JAVA_HOME_RUNTIME%"
:: & echo %CB_LINEHEADER%Set JAVA_HOME to %JAVA_HOME%.
WHERE %JAVAC_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find java version in path. & goto END_WITH_ERROR

:: decide which build tool to use
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-start %1 %2 %3 %4 %5 %6 %7 2>nul
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
::set "TMPFILE=%TEMP%\cb-gradle-%RANDOM%%RANDOM%.tmp"
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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END

:: maven
:COMMON_BUILD_MAVEN
set MAVEN_EXEC=mvn
if exist mvnw.bat set "MAVEN_EXEC=mvnw" & goto COMMON_BUILD_MAVEN_EXEC
if exist mvnw set "MAVEN_EXEC=mvnw" & goto COMMON_BUILD_MAVEN_EXEC
if defined CB_MAVEN_HOME goto COMMON_BUILD_VERIFY_MAVEN
if not exist %CB_CURRENT_PATH%\maven\bin (call %PN_FULL% --silent --install maven --default)
if exist %CB_CURRENT_PATH%\maven\bin set "CB_MAVEN_HOME=%CB_CURRENT_PATH%\maven"
::set "TMPFILE=%TEMP%\cb-maven-%RANDOM%%RANDOM%.tmp"
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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END

:: ant
:COMMON_BUILD_ANT
set ANT_EXEC=ant
if defined CB_ANT_HOME goto COMMON_BUILD_VERIFY_ANT
if not exist %CB_CURRENT_PATH%\ant\bin (call %PN_FULL% --silent --install ant --default)
if exist %CB_CURRENT_PATH%\ant\bin set "CB_ANT_HOME=%CB_CURRENT_PATH%\ant"
::set "TMPFILE=%TEMP%\cb-ant-%RANDOM%%RANDOM%.tmp"
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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-end %1 %2 %3 %4 %5 %6 %7 2>nul
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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-end %1 %2 %3 %4 %5 %6 %7 2>nul
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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% install-start %1 %2 %3 %4 %5 %6 %7 2>nul

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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% download-package-start %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %CB_INSTALL_VERSION_PARAM% 2>nul

if .%CB_INSTALL_PKG%==.cb goto INSTALL_CB_PACKAGE
if .%CB_INSTALL_PKG%==.pkg goto INSTALL_PACKAGES
if not .%CB_INSTALL_VERSION%==. goto TOOL_VERSION_DEFAULT_END

:TOOL_VERSION_DEFAULT_START
if .%CB_OFFLINE% == .true goto READ_TOOL_VERSION_DEFAULT
:: read ones a day the newest tool version
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%" & set "DATETIMESTAMP=%YYYY%%MM%%DD%"
set "CB_TOOL_VERSION_DEFAULT_CHECK=%CB_TOOL_VERSION_DEFAULT%.lastCheck"
if not exist %CB_TOOL_VERSION_DEFAULT_CHECK% goto GET_TOOL_VERSION_DEFAULT
set /plastCheck=<%CB_TOOL_VERSION_DEFAULT_CHECK%
if [%lastCheck%] EQU [%DATETIMESTAMP%] goto READ_TOOL_VERSION_DEFAULT
:GET_TOOL_VERSION_DEFAULT
set "TOOL_VERSION_DEFAULT_TMP=%TEMP%\tool-version-default.properties"
echo %CB_LINEHEADER%Updated tool-version-default.properties.
cd /D %TEMP%
%CB_BIN%\%CB_WGET_CMD% %CB_TOOL_VERSION_DEFAULT_URL% %CB_WGET_PARAM% %CB_WGET_SECURITY_CREDENTIALS% %CB_WGET_PROGRESSBAR% %CB_WGET_LOG%
cd /D %CB_WORKING_PATH%
for %%R in ("%TOOL_VERSION_DEFAULT_TMP%") do if not %%~zR lss 1 move %TOOL_VERSION_DEFAULT_TMP% %CB_TOOL_VERSION_DEFAULT% >nul 2>nul
if exist %TOOL_VERSION_DEFAULT_TMP% del /f /q "%TOOL_VERSION_DEFAULT_TMP%" >nul 2>nul
echo %DATETIMESTAMP%> %CB_TOOL_VERSION_DEFAULT_CHECK%
goto TOOL_VERSION_DEFAULT_START
:READ_TOOL_VERSION_DEFAULT
dir %CB_TOOL_VERSION_DEFAULT% >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto TOOL_VERSION_DEFAULT_END
set "CB_TOOL_VERSION_DEFAULT_TMPFILE=%TEMP%\cb-tool-version-default-%RANDOM%%RANDOM%.tmp"
type %CB_TOOL_VERSION_DEFAULT% 2>nul | findstr /C:= > %CB_TOOL_VERSION_DEFAULT_TMPFILE% 2>nul
for /f "tokens=1,2* delims== " %%i in (%CB_TOOL_VERSION_DEFAULT_TMPFILE%) do (if .%%i == .%CB_INSTALL_PKG% set "CB_INSTALL_VERSION=%%j" & set "CB_INSTALL_VERSION_PARAM=%%k")
if exist %CB_TOOL_VERSION_DEFAULT_TMPFILE% del /f /q "%CB_TOOL_VERSION_DEFAULT_TMPFILE%" >nul 2>nul
:TOOL_VERSION_DEFAULT_END

call %CB_SCRIPT_PATH%\include\download.bat %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %CB_INSTALL_VERSION_PARAM%
if %ERRORLEVEL% NEQ 0 goto INSTALL_CB_END
if not .%CB_PACKAGE_DOWNLOAD_NAME%==. set "CB_PKG_FILTER=%CB_PACKAGE_DOWNLOAD_NAME%" 

:: custom setting script
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% download-package-end %CB_INSTALL_PKG% %CB_INSTALL_VERSION% 2>nul
echo %CB_LINE%>> "%CB_LOGFILE%"

goto CHECK_EXTRACT_ARCHIVES 


:INSTALL_CB_PACKAGE
if [%CB_INSTALL_SILENT%] equ [false] (if .%CB_INSTALL_VERSION% == . echo %CB_LINEHEADER%Install newest cb version...
	if not .%CB_INSTALL_VERSION% == . echo %CB_LINEHEADER%Install cb version %CB_INSTALL_VERSION%...)
if [%CB_INSTALL_OVERWRITE_DIST%] equ [true] (call %CB_SCRIPT_PATH%cb-install --force --silent %CB_INSTALL_VERSION%)
if [%CB_INSTALL_OVERWRITE_DIST%] equ [false] (call %CB_SCRIPT_PATH%cb-install --silent %CB_INSTALL_VERSION%)
if exist %CB_BIN%\cb-copysymlink.bat if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Copy symbolic link...
if exist %CB_BIN%\cb-copysymlink.bat call %CB_BIN%\cb-copysymlink.bat --silent %CB_HOME_PREVIOUS%\current %CB_HOME%\current

:: custom setting script
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% download-package-end %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %CB_INSTALL_VERSION_PARAM% 2>nul
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
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% download-package-end %CB_INSTALL_PKG% %CB_INSTALL_VERSION% 2>nul
echo %CB_LINE%>> "%CB_LOGFILE%"


:: extract
:CHECK_EXTRACT_ARCHIVES
:: custom setting script
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% extract-package-start %CB_INSTALL_PKG% %CB_INSTALL_VERSION% 2>nul
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

set "TMPFILE=%TEMP%\cb-extract-file-%RANDOM%%RANDOM%.tmp"
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
set "CB_TOOL_VERSION_INSTALLED_TMPFILE=%TEMP%\cb-tool-version-installed-%RANDOM%%RANDOM%.tmp"
set "CB_TOOL_VERSION_INSTALLED_TMPFILE2=%TEMP%\cb-tool-version-installed-%RANDOM%%RANDOM%.tmp"
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
:: custom setting script
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% extract-package-end %CB_INSTALL_PKG% %CB_INSTALL_VERSION% %2>nul


:INSTALL_CB_END
:: custom setting script
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% install-end %1 %2 %3 %4 %5 %6 %7 2>nul

if [%CB_INSTALL_SILENT%] equ [false] (echo %CB_LINE%)
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
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_TIMESTAMP_FILE=%TEMP%\cb-timestamp-%RANDOM%%RANDOM%.log"
call powershell get-date -format "{yyyy-MM-dd HH:mm:ss.fff}" > "%CB_TIMESTAMP_FILE%"
set /p %1=<"%CB_TIMESTAMP_FILE%"
if exist %CB_TIMESTAMP_FILE% del /f /q "%CB_TIMESTAMP_FILE%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CB_CLEAN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%CB_HOME%\bin\cb-clean	
%CB_HOME%\bin\cb-clean --pattern gradle-worker-*
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END_WITH_ERROR
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% error-end %1 %2 %3 %4 %5 %6 %7 2>nul
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
  if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Updated CB_HOME and PATH & echo %CB_LINE%
)

set CB_LINEHEADER=
set CB_INSTALL_SILENT=
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
