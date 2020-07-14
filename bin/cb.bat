@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


set CB_LINE=----------------------------------------------------------------------------------------
set "CB_LINEHEADER=.: "
set PN=%~nx0
set "CB_SCRIPT_PATH=%~dp0"
set "PN_FULL=%CB_SCRIPT_PATH%%PN%"
set "CB_CURRENT_PATH=%CD%"
set "CB_INSTALL_SILENT=false"
set CB_CUSTOM_SETTING_SCRIPT=

if not defined CB_HOME (echo %CB_LINE% & echo %CB_LINEHEADER%Missing CB_HOME environment variable! Please install with the cb-install.bat! & echo %CB_LINE% & goto END_WITH_ERROR)
if not defined CB_PACKAGE_URL (set "CB_PACKAGE_URL=")
if not defined CB_INSTALL_USER_COMMIT (set "CB_INSTALL_USER_COMMIT=true")
if not defined CB_USER (set "CB_USER=%USERNAME%")
if not defined CB_PACKAGE_PASSWORD (set "CB_PACKAGE_PASSWORD=")
if not defined CB_DEVTOOLS_JAVA_PREFIX (set "CB_DEVTOOLS_JAVA_PREFIX=*jdk-")
if not defined CB_INSTALL_OVERWRITE (set "CB_INSTALL_OVERWRITE=false")
set CB_WGET_CMD=wget.exe
set CB_UNZIP_CMD=unzip.exe

set "CB_PROJECT_JAVA_VERSION_FILE=.java-version"
set "CB_JAVA_VERSION_FILE=.cb-java-version"
set CB_PARAMETERS=
del %CB_JAVA_VERSION_FILE% 2>nul

if defined CB_DEVTOOLS goto SET_DEVTOOLS_END
set "WORKING_PATH=%CD%"
cd /D %CB_HOME%\..
set "CB_DEVTOOLS=%CD%"
cd /D %WORKING_PATH%
:SET_DEVTOOLS_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: read version
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist %CB_SCRIPT_PATH%\..\VERSION goto READ_VERSION_END
( set "major.number=" & set /p "major.number="
  set "minor.number=" & set /p "minor.number="
  set "revision.number=" & set /p "revision.number="
  set "qualifier=" & set /p "qualifier=" ) < %CB_SCRIPT_PATH%\..\VERSION
set CB_VERSION=%major.number:~22%.%minor.number:~22%.%revision.number:~22%
set major.number= & set minor.number= & set revision.number= & set qualifier=
::if [%qualifier%] equ [] set CB_VERSION=%CB_VERSION%-%qualifier:~22%
:READ_VERSION_END

:: be sure findstr works
findstr 2>nul
if %ERRORLEVEL% EQU 9009 (SET "PATH=%PATH%;%SystemRoot%\System32\")


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: custom initialisation
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if .%CB_CUSTOM_SETTING% == . goto CUSTOM_SETTINGS_INIT_END_CALL
if exist %CB_CUSTOM_SETTING% goto CUSTOM_SETTINGS_INIT_CALL
echo %CB_LINE%
echo %CB_LINEHEADER%Could not find custom scrpit, see %%CB_CUSTOM_SETTING%%: 
echo %CB_CUSTOM_SETTING%
echo %CB_LINE%
goto CUSTOM_SETTINGS_INIT_END_CALL

:CUSTOM_SETTINGS_INIT_CALL
set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_SETTING%"
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% start %1 %2 %3 %4 %5 %6 %7 2>nul
:CUSTOM_SETTINGS_INIT_END_CALL


set "CB_SETENV="
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set CB_OPTIONAL_PARAMETER=%2
if %0X==X goto COMMON_BUILD
if .%1==.--silent shift & set "CB_INSTALL_USER_COMMIT=false" & set "CB_INSTALL_SILENT=true"
if .%1==.--force set "CB_INSTALL_OVERWRITE=true"
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.-v goto VERSION
if .%1==.--version goto VERSION
if .%1==.-new goto PROJECT_WIZARD
if .%1==.--new goto PROJECT_WIZARD
if .%1==.-exp goto PROJECT_EXPLORE
if .%1==.--explore goto PROJECT_EXPLORE
if .%1==.--packages goto PACKAGES
if .%1==.--install goto INSTALL_CB
if .%1==.--java goto SET_JAVA_PARAM
if .%1==.--setenv (set CB_SETENV=true)
set CB_PARAMETERS=%CB_PARAMETERS% %~1
shift
goto CHECK_PARAMETER

:SET_JAVA_PARAM
echo %2 > %CB_JAVA_VERSION_FILE% 
shift 
shift 
goto CHECK_PARAMETER


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo toolarium common build %CB_VERSION%
echo %CB_LINE%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PACKAGES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo toolarium common build %CB_VERSION%
echo %CB_LINE%
dir /b %CB_HOME%\bin\packages\
echo %CB_LINE%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - common build v%CB_VERSION%
echo usage: %PN% [OPTION]
echo.
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  -v, --version        Print version information.
echo  --new                Create a new project.
echo  -exp, --explore      Starts in Windows environment a new explorer.
echo  --java [version]     Set a different java version for this run, e.g. --java 14.
echo  --silent             Suppress the console output from the common-build.
echo  --packages           Supported packages.
echo  --install            Install the common build environment.
echo  --setenv             Set all environment variable and stop execution.
echo.
echo Environment variable:
echo  CB_DEVTOOLS          Defines the devtools directory, default c:\devtools.
echo  CB_HOME              Defines the home environment, default %%CB_DEVTOOLS%%\cb.
echo  CB_JAVA_HOME         Defines the java version (it must be installed in a sub folder
echo                       of %%CB_DEVTOOLS%%, default is empty to choose the default)
echo  CB_GRADLE_HOME       Defines the gradle version (similar CB_JAVA_HOME)
echo  CB_MAVEN_HOME        Defines the maven version (similar CB_JAVA_HOME)
echo  CB_ANT_HOME          Defines ant version (similar CB_JAVA_HOME)
echo  CB_NODE_HOME         Defines node / npm version (similar CB_JAVA_HOME)
echo  CB_PACKAGE_URL       Url where additional zip packages to install are available (default, no url).
echo  CB_PACKAGE_USER      The user for the access to the CB_PACKAGE_URL.
echo  CB_PACKAGE_PASSWORD  In case the value is ask, the password can be entered securely 
echo                       on the command line.
echo  CB_CUSTOM_SETTING    Can be use to reference to an own start script.
echo  CB_INSTALL_OVERWRITE Defines if existing packages should be overwritten (default false).
echo.
echo Special files:
echo  .java-version        Can be used to reference to a specific java version (only major 
echo                       version, e.g. 11)
echo.
echo Example:
echo  -Install specific java version: cb --install java 14
echo  -Install specific gradle version: cb --install gradle 6.5
echo  -Install specific maven version: cb --install maven 3.6.3
echo  -Install specific ant version: cb --install ant 1.10.8
echo  -Install default node version: cb --install node
echo.
echo Please check the homepage for more information: https://github.com/toolarium/common-build
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COMMON_BUILD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "cbJavaVersion=" & set "cbJavaMajorVersion=" & set "cbJavaVersionFilter=*" & set "cbJavaVersionAvailable=" & set "cbSetJavaHome=" & set "CB_JAVA_HOME_RUNTIME="

:: check connection
ping 8.8.8.8 -n 1 -w 1000 >nul 2>nul
if errorlevel 1 (set "CB_OFFLINE=true") else (set "CB_OFFLINE=")

:: current run java switch
for %%R in (%CB_JAVA_VERSION_FILE%) do if not %%~zR lss 1 set /pcbJavaVersion=<%CB_JAVA_VERSION_FILE% & del %CB_JAVA_VERSION_FILE% 2>nul
if defined cbJavaVersion set cbJavaVersion=%cbJavaVersion: =%
if defined cbJavaVersion echo %CB_LINEHEADER%Set java version %cbJavaVersion% (by command line --java %cbJavaVersion%)
if defined cbJavaVersion goto COMMON_BUILD_VERIFY_JAVA_INSTALLATION

:: project specific java switch
for %%R in (%CB_PROJECT_JAVA_VERSION_FILE%) do if not %%~zR lss 1 set /pcbJavaVersion=<%CB_PROJECT_JAVA_VERSION_FILE%
if defined cbJavaVersion set cbJavaVersion=%cbJavaVersion: =%
if defined cbJavaVersion echo %CB_LINEHEADER%Set project java version %cbJavaVersion% (from .java-version)
if defined cbJavaVersion goto COMMON_BUILD_VERIFY_JAVA_INSTALLATION

:: check CB_JAVA_HOME, if java is set of CB_DEVTOOLS do nothing set!
if defined CB_JAVA_HOME set "CB_JAVA_HOME_RUNTIME=%CB_JAVA_HOME%" & goto COMMON_BUILD_VERIFY_JAVA
if not defined CB_JAVA_HOME set "cbSetJavaHome=true"

:COMMON_BUILD_VERIFY_JAVA_INSTALLATION
if defined cbJavaVersion set "cbJavaVersionFilter=%cbJavaVersion%*"
set /a "cbJavaMajorVersion=%cbJavaVersion%" 2>nul
if not .%cbJavaMajorVersion% == .%cbJavaVersion% echo %CB_LINEHEADER%Invalid java version paramter %cbJavaVersion% (only major version can be referenced, e.g. 11, 12...)
if not .%cbJavaMajorVersion% == .%cbJavaVersion% goto END_WITH_ERROR
set "TMPFILE=%CB_CURRENT_PATH%\cb-java-home.tmp"
if not defined CB_DEVTOOLS_JAVA_PREFIX set "CB_DEVTOOLS_JAVA_PREFIX=*"
if defined cbJavaVersion dir %CB_DEVTOOLS%\%CB_DEVTOOLS_JAVA_PREFIX%%cbJavaVersionFilter% /O-D/b 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
if defined cbJavaVersion for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install java %cbJavaVersion%
::if not defined cbJavaVersion call %PN_FULL% --silent --install java 
if not defined cbJavaVersion for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install java 
dir %CB_DEVTOOLS%\%CB_DEVTOOLS_JAVA_PREFIX%%cbJavaVersionFilter% /O-D/b 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pcbJavaVersion=<"%TMPFILE%" & set "cbJavaVersionAvailable=true"
del "%TMPFILE%" 2>nul
set "cbJavaVersion=%cbJavaVersion:~2%"
set "versionInformation=,"
if defined cbJavaVersion set "versionInformation=%cbJavaVersion%,"
if not defined cbJavaVersionAvailable echo %CB_LINEHEADER%Can not find common-build java version %versionInformation% give up! & goto END_WITH_ERROR
set "CB_JAVA_HOME_RUNTIME=%CB_DEVTOOLS%\%cbJavaVersion%"
if defined cbSetJavaHome echo %CB_LINEHEADER%Set CB_JAVA_HOME to %CB_JAVA_HOME_RUNTIME% as default!
if defined cbSetJavaHome setx CB_JAVA_HOME "%CB_JAVA_HOME_RUNTIME%" >nul 2>nul & set "CB_JAVA_HOME=%CB_JAVA_HOME_RUNTIME%"

:COMMON_BUILD_VERIFY_JAVA
echo %CB_JAVA_HOME_RUNTIME% | findstr /I %CB_DEVTOOLS% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_JAVA_HOME is not set to a java version in devtools (%CB_DEVTOOLS%): %CB_JAVA_HOME_RUNTIME%! & goto END_WITH_ERROR
dir %CB_JAVA_HOME_RUNTIME%\bin\javac* >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_JAVA_HOME entry could not be found: %CB_JAVA_HOME_RUNTIME%! & goto END_WITH_ERROR
set JAVA_HOME=%CB_JAVA_HOME_RUNTIME%
echo %PATH% | findstr /C:"%CB_JAVA_HOME_RUNTIME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_JAVA_HOME_RUNTIME%\bin;%PATH%"
::echo %CB_LINEHEADER%Set %CB_JAVA_HOME_RUNTIME% to path!
WHERE javac >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find java version in path! & goto END_WITH_ERROR

:: decide which build tool to use
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-start %1 %2 %3 %4 %5 %6 %7 2>nul
if exist build.gradle goto COMMON_BUILD_GRADLE
if exist pom.xml goto COMMON_BUILD_MAVEN
if exist build.xml goto COMMON_BUILD_ANT

:: gradle
:COMMON_BUILD_GRADLE
set GRADLE_EXEC=gradle
if exist gradlew.bat set "GRADLE_EXEC=gradlew" & goto COMMON_BUILD_GRADLE_EXEC
if exist gradlew set "GRADLE_EXEC=gradlew" & goto COMMON_BUILD_GRADLE_EXEC
if defined CB_GRADLE_HOME goto COMMON_BUILD_VERIFY_GRADLE
set "TMPFILE=%CB_CURRENT_PATH%\cb-gradle-home.tmp"
dir %CB_DEVTOOLS%\*gradle* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install gradle
dir %CB_DEVTOOLS%\*gradle* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pCB_GRADLE_HOME=<"%TMPFILE%"
del "%TMPFILE%" 2>nul
set "CB_GRADLE_HOME=%CB_DEVTOOLS%\%CB_GRADLE_HOME:~2%"
:COMMON_BUILD_VERIFY_GRADLE
echo %CB_GRADLE_HOME% | findstr /I %CB_DEVTOOLS% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_GRADLE_HOME is not set to a gradle version in devtools (%CB_DEVTOOLS%): %CB_GRADLE_HOME%! & goto END_WITH_ERROR
echo %PATH% | findstr /C:"%CB_GRADLE_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_GRADLE_HOME%\bin;%PATH%"
::echo %CB_LINEHEADER%Set %CB_GRADLE_HOME% to path!
WHERE %GRADLE_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find gradle version in path! & goto END_WITH_ERROR
:COMMON_BUILD_GRADLE_EXEC
if defined CB_SETENV set "CB_SETENV=gradle" & goto END_PRINT_VAIRABLE
if defined CB_OFFLINE set "CB_PARAMETERS=--offline %CB_PARAMETERS%" & echo %CB_LINEHEADER%Offline build!
cmd /C call %GRADLE_EXEC% %CB_PARAMETERS%
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END

:: maven
:COMMON_BUILD_MAVEN
set MAVEN_EXEC=mvn
if exist mvnw.bat set "MAVEN_EXEC=mvn" & goto COMMON_BUILD_MAVEN_EXEC
if defined CB_MAVEN_HOME goto COMMON_BUILD_VERIFY_MAVEN
set "TMPFILE=%CB_CURRENT_PATH%\cb-maven-home.tmp"
dir %CB_DEVTOOLS%\*maven* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install maven
dir %CB_DEVTOOLS%\*maven* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pCB_MAVEN_HOME=<"%TMPFILE%"
del "%TMPFILE%" 2>nul
set "CB_MAVEN_HOME=%CB_DEVTOOLS%\%CB_MAVEN_HOME:~2%"
:COMMON_BUILD_VERIFY_MAVEN
echo %CB_MAVEN_HOME% | findstr /I %CB_DEVTOOLS%  >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_MAVEN_HOME is not set to a maven version in devtools (%CB_DEVTOOLS%): %CB_MAVEN_HOME%! & goto END_WITH_ERROR
echo %PATH% | findstr /C:"%CB_MAVEN_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_MAVEN_HOME%\bin;%PATH%"
::echo %CB_LINEHEADER%Set %CB_MAVEN_HOME% to path!
WHERE %MAVEN_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find maven version in path! & goto END_WITH_ERROR
:COMMON_BUILD_MAVEN_EXEC
if defined CB_SETENV set "CB_SETENV=maven" & goto END_PRINT_VAIRABLE
cmd /C call %MAVEN_EXEC% %CB_PARAMETERS%
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END

:: ant
:COMMON_BUILD_ANT
set ANT_EXEC=ant
set "TMPFILE=%CB_CURRENT_PATH%\cb-ant-home.tmp"
if defined ABT_HOME goto COMMON_BUILD_VERIFY_ANT
dir %CB_DEVTOOLS%\*ant* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if %%~zR lss 1 call %PN_FULL% --silent --install ant
dir %CB_DEVTOOLS%\*ant* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pCB_ANT_HOME=<"%TMPFILE%"
del "%TMPFILE%" 2>nul
set "CB_ANT_HOME=%CB_DEVTOOLS%\%CB_ANT_HOME:~2%"
:COMMON_BUILD_VERIFY_ANT
echo %CB_ANT_HOME% | findstr /I %CB_DEVTOOLS% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%CB_ANT_HOME is not set to a maven version in devtools (%CB_DEVTOOLS%): %CB_ANT_HOME%! & goto END_WITH_ERROR
echo %PATH% | findstr /C:"%CB_ANT_HOME%\bin" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%CB_ANT_HOME%\bin;%PATH%"
::echo %CB_LINEHEADER%Set %CB_ANT_HOME% to path! 
WHERE %ANT_EXEC% >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not find ant version in path! & goto END_WITH_ERROR
:COMMON_BUILD_ANT_EXEC
if defined CB_SETENV set "CB_SETENV=ant" & goto END_PRINT_VAIRABLE
cmd /C call %ANT_EXEC% %CB_PARAMETERS%
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% build-end %1 %2 %3 %4 %5 %6 %7 2>nul
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROJECT_WIZARD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SHIFT
SET CB_WIZARD_PARAMETERS=%CB_PARAMETERS%
:CHECK_PARAMETER_WIZARD
IF %0X==X GOTO START_WIZARD
SET CB_WIZARD_PARAMETERS=%CB_WIZARD_PARAMETERS% %1
SHIFT
GOTO CHECK_PARAMETER_WIZARD

:START_WIZARD
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% new-start %CB_WIZARD_PARAMETERS% 2>nul

call %CB_SCRIPT_PATH%\include\project-wizard.bat %CB_WIZARD_PARAMETERS%
if not %ERRORLEVEL% equ 0 goto END_WITH_ERROR

cd %projectName%
set BACKUP_CB_CURRENT_PATH=%CB_CURRENT_PATH%
call %PN_FULL% "-PprojectType=%projectType%" "-PprojectRootPackageName=%projectRootPackageName%" "-PprojectGroupId=%projectGroupId%" "-PprojectComponentId=%projectComponentId%" "-PprojectDescription="%projectDescription% ""
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% new-end %CB_WIZARD_PARAMETERS% 2>nul
cd %BACKUP_CB_CURRENT_PATH%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROJECT_EXPLORE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SHIFT
explorer %CD%
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

if [%CB_INSTALL_SILENT%] equ [false] (echo %CB_LINE%
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
set CB_PKG_FILTER_WILDCARD=false

SET CB_PROCESSOR_ARCHITECTURE_NUMBER=64
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:32=%" SET CB_PROCESSOR_ARCHITECTURE_NUMBER=32
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:64=%" SET CB_PROCESSOR_ARCHITECTURE_NUMBER=64

if .%2==. goto INSTALL_DEFAULT_PACKAGES
if .%2==.pkg goto INSTALL_PACKAGES
call %CB_SCRIPT_PATH%\include\download.bat %2 %3 
if not .%CB_PACKAGE_DOWNLOAD_NAME%==. set "CB_PKG_FILTER=%CB_PACKAGE_DOWNLOAD_NAME%" 
goto CHECK_EXTRACT_ARCHIVES 

:INSTALL_DEFAULT_PACKAGES
:: TODO
set CB_PKG_FILTER=*.zip
set CB_PKG_FILTER_WILDCARD=true
goto CHECK_EXTRACT_ARCHIVES 

:: packages
:INSTALL_PACKAGES
if not defined CB_PACKAGE_URL goto CHECK_EXTRACT_ARCHIVES
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
cd /D %CB_CURRENT_PATH%
if not %ERRORLEVEL% equ 6 goto INSTALL_PACKAGES_END
echo %CB_LINEHEADER%ERROR: Invalid credentials, give up. >> "%CB_LOGFILE%"
echo %CB_LINE%
echo %CB_LINEHEADER%ERROR: Invalid credentials, give up.
echo %CB_LINE%
goto INSTALL_CB_END
:INSTALL_PACKAGES_END
echo %CB_LINE%>> "%CB_LOGFILE%"
if .%2==.pkg goto CHECK_EXTRACT_ARCHIVES	

:: extract
:CHECK_EXTRACT_ARCHIVES
::if exist %CB_BIN%\cleanup-installation.bat (echo %CB_LINEHEADER%Cleanup old packages... >> "%CB_LOGFILE%" 
::	call %CB_BIN%\cleanup-installation >> "%CB_LOGFILE%" 2>/nul)
if not defined CB_PKG_FILTER goto EXTRACT_ARCHIVES_END
if [%CB_PKG_FILTER_WILDCARD%] equ [true] (goto EXTRACT_ARCHIVES_START)
if not exist %CB_DEV_REPOSITORY%\%CB_PKG_FILTER% goto EXTRACT_ARCHIVES_FAILED

:EXTRACT_ARCHIVES_START
echo %CB_LINE%>> "%CB_LOGFILE%"
cd /D %CB_DEVTOOLS%
set "CB_UNZIP_PARAM=-n"
if .%CB_INSTALL_OVERWRITE%==.true set "CB_UNZIP_PARAM=-o"

echo %CB_LINEHEADER%Extract %CB_PKG_FILTER% in %CB_DEVTOOLS%... & echo %CB_LINEHEADER%Extract %CB_PKG_FILTER% in %CB_DEVTOOLS%... >> "%CB_LOGFILE%"
FOR /F %%i IN ('dir %CB_DEV_REPOSITORY%\%CB_PKG_FILTER% /b/s') DO (
	echo %CB_LINEHEADER%Extract package %%i>> "%CB_LOGFILE%" 
	if exist %CB_BIN%\%CB_UNZIP_CMD% %CB_BIN%\%CB_UNZIP_CMD% %CB_UNZIP_PARAM% %%i >> "%CB_LOGFILE%" 2>nul
	if not exist %CB_BIN%\%CB_UNZIP_CMD% powershell -nologo -command "Expand-Archive -Force '%%i' '%CB_DEVTOOLS%'" >> "%CB_LOGFILE%" 2>nul)
echo %CB_LINE%>> "%CB_LOGFILE%"
cd /D %CB_CURRENT_PATH%
goto EXTRACT_ARCHIVES_END

:EXTRACT_ARCHIVES_FAILED
echo %CB_LINEHEADER%No package found %CB_PACKAGE_VERSION_NAME% (%CB_PKG_FILTER%)
goto EXTRACT_ARCHIVES_END

:EXTRACT_ARCHIVES_END
goto INSTALL_CB_SUCCESS_END

:: extract
:INSTALL_ARCHIVES
echo %CB_LINE%>> "%CB_LOGFILE%"
echo %CB_LINEHEADER%Execute installer %CB_PKG_FILTER%... & echo %CB_LINEHEADER%Execute installer %CB_PKG_FILTER%... >> "%CB_LOGFILE%"
FOR /F %%i IN ('dir %CB_DEV_REPOSITORY%\%CB_PKG_FILTER% /b/s') DO (echo %CB_LINEHEADER%Extract package %%i>> "%CB_LOGFILE%" & %%i" >> "%CB_LOGFILE%" 2>nul)
echo %CB_LINE%>> "%CB_LOGFILE%"
goto INSTALL_CB_SUCCESS_END

:INSTALL_CB_SUCCESS_END
:INSTALL_CB_END

:: custom setting script
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% install-end %1 %2 %3 %4 %5 %6 %7 2>nul

if [%CB_INSTALL_SILENT%] equ [false] (echo %CB_LINE%)
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END_WITH_ERROR
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% error %1 %2 %3 %4 %5 %6 %7 2>nul
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:END_PRINT_VAIRABLE
echo %CB_LINE%
echo %CB_LINEHEADER%All environment variable are set, just stopped before executing %CB_SETENV%:
if [%CB_SETENV%] equ [gradle] echo    %%GRADLE_HOME%%: %GRADLE_HOME%
if [%CB_SETENV%] equ [maven] echo    %%MAVEN_HOME%%: %MAVEN_HOME%
if [%CB_SETENV%] equ [ant] echo    %%ANT_HOME%%: %ANT_HOME%
if [%CB_SETENV%] equ [node] echo    %%NODE_HOME%%: %NODE_HOME%
echo    %%JAVA_HOME%%: %JAVA_HOME%
:: custom setting script
if exist %CB_CUSTOM_SETTING_SCRIPT% call %CB_CUSTOM_SETTING_SCRIPT% print-variable %1 %2 %3 %4 %5 %6 %7 2>nul
echo %CB_LINE%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
