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
set PATH_BACKUP=%PATH%
set PN=%~nx0
set PN_FULL=%0

if not defined CB_PACKAGE_URL (set "CB_PACKAGE_URL=")
if not defined CB_INSTALL_SILENT (set "CB_INSTALL_SILENT=false")
if not defined CB_INSTALL_USER_COMMIT (set "CB_INSTALL_USER_COMMIT=true")
if not defined CB_USER (set "CB_USER=%USERNAME%")
if not defined CB_PACKAGE_PASSWORD (set "CB_PACKAGE_PASSWORD=")
set "CB_JAVA_VERSION_FILE=.java-version"
set "CB_JAVA_VERSION_FILE=.cb-java-version"
set CB_PARAMETERS=
del %CB_JAVA_VERSION_FILE% 2>nul


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: read version
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist %CB_HOME%\VERSION goto READ_VERSION_END
( set "major.number=" & set /p "major.number="
  set "minor.number=" & set /p "minor.number="
  set "revision.number=" & set /p "revision.number="
  set "qualifier=" & set /p "qualifier=" ) < %CB_HOME%\VERSION
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
if [%CB_CUSTOM_SETTING%] equ [] goto CUSTOM_SETTINGS_END
if exist %CB_CUSTOM_SETTING% goto CUSTOM_SETTINGS_START
echo %CB_LINE%
echo -Could not find custom scrpit, see %%CB_CUSTOM_SETTING%%: 
echo  %CB_CUSTOM_SETTING%
echo %CB_LINE%
goto CUSTOM_SETTINGS_END

:CUSTOM_SETTINGS_START
::echo Custom settings %CB_CUSTOM_SETTING%
call %CB_CUSTOM_SETTING% %1 %2 %3 %4 %5 %6 %7 2>nul
:CUSTOM_SETTINGS_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set CB_OPTIONAL_PARAMETER=%2
if %0X==X goto COMMON_BUILD
if .%1==.--silent shift & set "CB_INSTALL_USER_COMMIT=false" & set "CB_INSTALL_SILENT=true"
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.-v goto VERSION
if .%1==.--version goto VERSION
if .%1==.-new goto PROJECT_WIZARD
if .%1==.--new goto PROJECT_WIZARD
if .%1==.-exp goto PROJECT_EXPLORE
if .%1==.--explore goto PROJECT_EXPLORE
if .%1==.--install goto INSTALL_CB
if .%1==.--jdk (echo %2> %CB_JAVA_VERSION_FILE% & shift)
set CB_PARAMETERS=%CB_PARAMETERS% %~1
shift
goto CHECK_PARAMETER


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo common build %CB_VERSION%
echo %CB_LINE%
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - common build v%CB_VERSION%
echo usage: %PN% [OPTION]
echo.
echo Overview of the available OPTIONs:
echo  -h, --help                Show this help message.
echo  -v, --version             Print version information.
echo  --new                     Create a new project.
echo  -exp, --explore           Starts in Windows environment a new explorer.
echo  --jdk [version]           Set a different jdk for this run, e.g. --jdk 14.
echo  --silent                  Suppress the console output from the common-build.
echo  --install                 Install the common build environment.
echo.
echo Environment variable:
echo  DEVTOOLS                  Defines the devtools directory, default c:\devtools.
echo  CB_HOME                   Defines the common build home environment, default %%DEVTOOLS%%\cb.
echo  CB_PACKAGE_URL            Url where additional zip packages are available to download (default, no url).
echo  CB_PACKAGE_USER           The user for the access to the CB_PACKAGE_URL.
echo  CB_PACKAGE_PASSWORD       In case it is set to ask, the password can be entered securely on the command line.
echo  CB_CUSTOM_SETTING         Can be use to reference to an own start script.
echo.
echo Special files:
echo  .java-version             Can be used to reference to a specific jdk version.
echo.
echo Example:
echo  -Install specific jdk version: cb --install java 14
echo  -Install specific gradle version: cb --install gradle 6.5
echo  -Install specific maven version: cb --install maven 3.6.3
echo  -Install specific ant version: cb --install ant 1.10.8
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COMMON_BUILD_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - common build
echo.
echo ERROR: There seems to be an installation failure. Some tools and environment variable
echo        are not properly available. Please call the following command to install properly: 
echo.
echo        %PN_FULL% --install 
echo.
echo Additional help can be found by the --help command. Otherwise please check
echo the homepage for more information: https://github.com/toolarium/common-build
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COMMON_BUILD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_JAVA_HOME_BACKUP=%JAVA_HOME%" & set "CB_JAVA_HOME=" & set "cbJavaVersion="
set "CB_LOGS=%CB_HOME%\logs" 

:: current run jdk switch
for %%R in (%CB_JAVA_VERSION_FILE%) do if not %%~zR lss 1 set /pcbJavaVersion=<%CB_JAVA_VERSION_FILE% & del %CB_JAVA_VERSION_FILE% 2>nul
if not [%cbJavaVersion%] EQU [] echo Run jdk switch to %cbJavaVersion%
if not [%cbJavaVersion%] EQU [] goto COMMON_BUILD_VERIFY_JAVA_INSTALLATION

:: project specific jdk switch
for %%R in (%CB_JAVA_VERSION_FILE%) do if not %%~zR lss 1 set /pcbJavaVersion=<%CB_JAVA_VERSION_FILE%
if not [%cbJavaVersion%] EQU [] echo Project jdk switch %cbJavaVersion%
if not [%cbJavaVersion%] EQU [] goto COMMON_BUILD_VERIFY_JAVA_INSTALLATION
goto COMMON_BUILD_VERIFY_JAVA

:COMMON_BUILD_VERIFY_JAVA_INSTALLATION
dir %CB_DEVTOOLS%\*jdk-%cbJavaVersion%* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %CB_JAVA_VERSION_FILE%
for %%R in (%CB_JAVA_VERSION_FILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install java %cbJavaVersion%
dir %CB_DEVTOOLS%\*jdk-%cbJavaVersion%* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %CB_JAVA_VERSION_FILE%
set "cbJavaVersionAvailable=true"
for %%R in (%CB_JAVA_VERSION_FILE%) do if %%~zR lss 1 set "cbJavaVersionAvailable=false"
del %CB_JAVA_VERSION_FILE% 2>nul
if [%cbJavaVersionAvailable%] EQU [false] echo -Can not switch to the java version %cbJavaVersion%!
if [%cbJavaVersionAvailable%] EQU [false] goto END
set "CB_JAVA_HOME=%CB_DEVTOOLS%\%cbJavaVersion:~2%"
echo -Set java to %CB_JAVA_HOME% 
set "PATH=%CB_JAVA_HOME%\bin;%PATH%"

:COMMON_BUILD_VERIFY_JAVA
WHERE java >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_JAVA_EXEC
if not [%JAVA_HOME%] equ [] set "PATH=%JAVA_HOME%\bin;%PATH%"
WHERE java >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_JAVA_EXEC
set "TMPFILE=%CB_LOGS%\cb-java-home.tmp"
dir %CB_DEVTOOLS%\*jdk* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install java
dir %CB_DEVTOOLS%\*jdk* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if not %%~zR lss 1 set /pJAVA_HOME=<%TMPFILE%
del %TMPFILE% 2>nul
set "JAVA_HOME=%JAVA_HOME:~2%"
set "JAVA_HOME=%CB_DEVTOOLS%\%JAVA_HOME%"
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo -Set java version to %JAVA_HOME%
:COMMON_BUILD_JAVA_EXEC

if exist build.gradle goto COMMON_BUILD_GRADLE
if exist pom.xml goto COMMON_BUILD_MAVEN
if exist build.xml goto COMMON_BUILD_ANT

:COMMON_BUILD_GRADLE
set GRADLE_EXEC=gradle
if exist gradlew.bat set "GRADLE_EXEC=gradlew" & goto COMMON_BUILD_GRADLE_EXEC
WHERE gradle >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_GRADLE_EXEC
if not [%GRADLE_HOME%] equ [] set "PATH=%GRADLE_HOME%\bin;%PATH%"
WHERE gradle >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_GRADLE_EXEC
set "TMPFILE=%CB_LOGS%\cb-gradle-home.tmp"
dir %CB_DEVTOOLS%\*gradle* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install gradle
dir %CB_DEVTOOLS%\*gradle* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if not %%~zR lss 1 set /pGRADLE_HOME=<%TMPFILE%
del %TMPFILE% 2>nul
set "GRADLE_HOME=%GRADLE_HOME:~2%"
set "GRADLE_HOME=%DEVTOOLS%\%GRADLE_HOME%"
set "PATH=%GRADLE_HOME%\bin;%PATH%"
:COMMON_BUILD_GRADLE_EXEC
::if defined CB_JAVA_HOME_BACKUP set "JAVA_HOME=%CB_JAVA_HOME_BACKUP%"
::if defined PATH_BACKUP set "PATH=%PATH_BACKUP%"
::if exist %CB_BIN%\cb-env-clean.bat call %CB_BIN%\cb-env-clean.bat 
cmd /C %GRADLE_EXEC% %CB_PARAMETERS%
goto END

:COMMON_BUILD_MAVEN
set MAVEN_EXEC=mvn
if exist mvnw.bat set "MAVEN_EXEC=mvn" & goto COMMON_BUILD_MAVEN_EXEC
WHERE mvn >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_MAVEN_EXEC
if not [%MAVEN_HOME%] equ [] set "PATH=%MAVEN_HOME%\bin;%PATH%"
WHERE mvn >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_MAVEN_EXEC
set "TMPFILE=%CB_LOGS%\cb-maven-home.tmp"
dir %CB_DEVTOOLS%\*maven* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install maven
dir %CB_DEVTOOLS%\*maven* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if not %%~zR lss 1 set /pMAVEN_HOME=<%TMPFILE%
del %TMPFILE% 2>nul
set "MAVEN_HOME=%MAVEN_HOME:~2%"
set "MAVEN_HOME=%DEVTOOLS%\%MAVEN_HOME%"
set "PATH=%MAVEN_HOME%\bin;%PATH%"
:COMMON_BUILD_MAVEN_EXEC
::if defined JAVA_HOME_BACKUP set "JAVA_HOME=%JAVA_HOME_BACKUP%"
::if defined PATH_BACKUP set "PATH=%PATH_BACKUP%"
::if exist %CB_BIN%\cb-env-clean.bat call %CB_BIN%\cb-env-clean.bat 
cmd /C %MAVEN_EXEC% %CB_PARAMETERS%
goto END

:COMMON_BUILD_ANT
WHERE ant >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_ANT_EXEC
if not [%ANT_HOME%] equ [] set "PATH=%ANT_HOME%\bin;%PATH%"
WHERE ant >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_ANT_EXEC
set "TMPFILE=%CB_LOGS%\cb-ant-home.tmp"
dir %CB_DEVTOOLS%\*ant* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install ant
dir %CB_DEVTOOLS%\*ant* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if not %%~zR lss 1 set /pANT_HOME=<%TMPFILE%
del %TMPFILE% 2>nul
set "ANT_HOME=%ANT_HOME:~2%"
set "ANT_HOME=%DEVTOOLS%\%ANT_HOME%"
set "PATH=%ANT_HOME%\bin;%PATH%"
:COMMON_BUILD_ANT_EXEC
::if defined JAVA_HOME_BACKUP set "JAVA_HOME=%CB_JAVA_HOME_BACKUP%"
::if defined PATH_BACKUP set "PATH=%PATH_BACKUP%"
::if exist %CB_BIN%\cb-env-clean.bat call %CB_BIN%\cb-env-clean.bat 
cmd /C ant %CB_PARAMETERS%
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
if not defined projectName (set projectName=my-project)
set /p projectName=Please enter project name, e.g. [%projectName%]: 

if not defined projectRootPackageName (set projectRootPackageName=my.package.name)
set /p projectRootPackageName=Please enter package name, e.g. [%projectRootPackageName%]: 

FOR /F "tokens=1,2 delims=-" %%i in ("%projectName%") do ( set "projectGroupId=%%i" )
set /p projectGroupId=Please enter project group id, e.g. [%projectGroupId%]: 

FOR /F "tokens=1,2 delims=-" %%i in ("%projectName%") do ( set "projectComponentId=%%i" )
set /p projectComponentId=Please enter project component id, e.g. [%projectComponentId%]: 

if not defined projectDescription (set projectDescription=The implementation of the %projectName%)
set /p projectDescription=Please enter project description [%projectDescription%]: 

echo.
echo Project types:
echo [1] java-library
echo [2] config project
set /p projectTypeId=Please choose the project type [1]: 

if [%projectTypeId%] equ [] set projectType=java-library
if [%projectTypeId%] equ [1] set projectType=java-library
if [%projectTypeId%] equ [2] set projectType=config

mkdir %projectName% 2>nul
cd %projectName%
echo apply from: "https://git.io/JfDQT" > build.gradle
::%PN_FULL% "-PprojectType=%projectType%" "-PprojectRootPackageName=%projectRootPackageName%" "-PprojectGroupId=%projectGroupId%" "-PprojectComponentId=%projectComponentId%" "-PprojectDescription=%projectDescription%"
%PN_FULL% "-PprojectType=%projectType%" "-PprojectRootPackageName=%projectRootPackageName%" "-PprojectGroupId=%projectGroupId%" "-PprojectComponentId=%projectComponentId%" "-PprojectDescription="%projectDescription% ""
cd ..
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
set CB_NEW_INSTALLATION=false

if [%CB_INSTALL_SILENT%] equ [false] (echo %CB_LINE%
		echo Started common-build installation on %COMPUTERNAME%, %USER_FRIENDLY_FULLTIMESTAMP%:
		echo -Use %CB_DEVTOOLS% path as devtools folder
		echo %CB_LINE%)

:: create directories
if not exist %CB_DEVTOOLS% mkdir %CB_DEVTOOLS% >nul 2>nul && set CB_NEW_INSTALLATION=true
if not exist %CB_HOME% mkdir %CB_HOME% >nul 2>nul && set CB_NEW_INSTALLATION=true
set "CB_BIN=%CB_HOME%\bin" 
if not exist %CB_BIN% mkdir %CB_BIN% >nul 2>nul && set CB_NEW_INSTALLATION=true
set "CB_LOGS=%CB_HOME%\logs" 
if not exist %CB_LOGS% mkdir %CB_LOGS% >nul 2>nul && set CB_NEW_INSTALLATION=true
set "CB_DEV_REPOSITORY=%CB_DEVTOOLS%\.repository" 
if not exist %CB_DEV_REPOSITORY% mkdir %CB_DEV_REPOSITORY% >nul 2>nul && set CB_NEW_INSTALLATION=true

set "CB_LOGFILE=%CB_LOGS%\%FULLTIMESTAMP%-%CB_USER%.log"
::if [%CB_INSTALL_SILENT%] equ [false] (echo -The installation log file can be found here "%CB_LOGFILE%")
echo %CB_LINE%>> "%CB_LOGFILE%"
echo Started common-build installation on %COMPUTERNAME%, %USER_FRIENDLY_FULLTIMESTAMP%>> "%CB_LOGFILE%"
echo common-build: %CB_HOME%, devtools: %CB_DEVTOOLS% (name: %CB_DEVTOOLS_NAME%, drive:%CB_DEVTOOLS_DRIVE%)>> "%CB_LOGFILE%"
::echo wget: %CB_WGET_VERSION%, gradle: %CB_GRADLE_VERSION%, java: %CB_JAVA_VERSION%>> "%CB_LOGFILE%"
echo %CB_LINE%>> "%CB_LOGFILE%"

:: tools settings
set "TMPFILE=%CB_LOGS%\tmpfile.tmp"
set "CB_WGET_SECURITY_CREDENTIALS=--trust-server-names --no-check-certificate"
set "CB_WGET_PROGRESSBAR=--show-progress"
set "CB_WGET_LOG=-a %CB_LOGFILE%"
set "CB_WGET_PARAM=-c"
set "CB_SCRIPT_PATH=%~dp0"
set "CB_SCRIPT_DRIVE=%~d0"
set CB_PKG_FILTER=

SET CB_PROCESSOR_ARCHITECTURE_NUMBER=64
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:32=%" SET CB_PROCESSOR_ARCHITECTURE_NUMBER=32
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:64=%" SET CB_PROCESSOR_ARCHITECTURE_NUMBER=64

if .%2==. goto INSTALL_DEFAULT_PACKAGES
if .%2==.pkg goto INSTALL_PACKAGES
call %CB_SCRIPT_PATH%\include\download.bat %2 %3 
if not .%CB_PACKAGE_DOWNLOAD_NAME%==. set "CB_PKG_FILTER=%CB_PACKAGE_DOWNLOAD_NAME%" 
goto EXTRACT_ARCHIVES 

:INSTALL_DEFAULT_PACKAGES
:: TODO
goto EXTRACT_ARCHIVES 

:: packages
:INSTALL_PACKAGES
if not defined CB_PACKAGE_URL goto EXTRACT_ARCHIVES
set CB_WGET_USER_CREDENTIALS=
if [%CB_PACKAGE_USER%] equ [] (set /p CB_PACKAGE_USER=Please enter user credentials, e.g. %CB_USER%: )
if [%CB_PACKAGE_USER%] equ [] (set "CB_PACKAGE_USER=%CB_USER%")
if [%CB_PACKAGE_PASSWORD%] equ [ask] (set CB_WGET_USER_CREDENTIALS=--ask-password --user %CB_PACKAGE_USER%)
set CB_WGET_RECURSIVE_PARAM=-r -np -nH --timestamping
set CB_WGET_FILTER=--exclude-directories=_deprecated -R "index.*"
echo %CB_LINE%>> "%CB_LOGFILE%"
echo -Install packages from %CB_PACKAGE_URL% & echo -Install packages from %CB_PACKAGE_URL%>> "%CB_LOGFILE%"

set "CB_CURRENT_PATH=%CD%"
cd %CB_DEV_REPOSITORY%
echo %CB_BIN%\%CB_WGET_CMD% %CB_PACKAGE_URL% %CB_WGET_PARAM% %CB_WGET_RECURSIVE_PARAM% %CB_WGET_SECURITY_CREDENTIALS% %CB_WGET_PROGRESSBAR% %CB_WGET_USER_CREDENTIALS% %CB_WGET_FILTER% %CB_WGET_LOG%>> "%CB_LOGFILE%"
%CB_BIN%\%CB_WGET_CMD% %CB_PACKAGE_URL% %CB_WGET_PARAM% %CB_WGET_RECURSIVE_PARAM% %CB_WGET_SECURITY_CREDENTIALS% %CB_WGET_PROGRESSBAR% %CB_WGET_USER_CREDENTIALS% %CB_WGET_FILTER% %CB_WGET_LOG%
cd %CB_CURRENT_PATH%
if not %ERRORLEVEL% equ 6 goto INSTALL_PACKAGES_END
echo ERROR: Invalid credentials, give up. >> "%CB_LOGFILE%"
echo %CB_LINE%
echo ERROR: Invalid credentials, give up.
echo %CB_LINE%
goto INSTALL_CB_END
:INSTALL_PACKAGES_END
echo %CB_LINE%>> "%CB_LOGFILE%"
if .%2==.pkg goto EXTRACT_ARCHIVES	

:: extract
:EXTRACT_ARCHIVES
::if exist %CB_BIN%\cleanup-installation.bat (echo -Cleanup old packages... >> "%CB_LOGFILE%" 
::	call %CB_BIN%\cleanup-installation >> "%CB_LOGFILE%" 2>/nul)
::echo -FITLER %CB_PKG_FILTER%
if .%CB_PKG_FILTER%==. set CB_PKG_FILTER=*.zip
echo %CB_LINE%>> "%CB_LOGFILE%"
echo -Extract %CB_PKG_FILTER% in %CB_DEVTOOLS%... & echo -Extract %CB_PKG_FILTER% in %CB_DEVTOOLS%... >> "%CB_LOGFILE%"
FOR /F %%i IN ('dir %CB_DEV_REPOSITORY%\%CB_PKG_FILTER% /b/s') DO (
	echo -Extract package %%i>> "%CB_LOGFILE%" & powershell -command "Expand-Archive -Force '%%i' '%CB_DEVTOOLS%'" >> "%CB_LOGFILE%" 2>nul)
echo %CB_LINE%>> "%CB_LOGFILE%"
goto INSTALL_CB_SUCCESS_END

:: extract
:INSTALL_ARCHIVES
echo %CB_LINE%>> "%CB_LOGFILE%"
echo -Execute installer %CB_PKG_FILTER%... & echo -Execute installer %CB_PKG_FILTER%... >> "%CB_LOGFILE%"
FOR /F %%i IN ('dir %CB_DEV_REPOSITORY%\%CB_PKG_FILTER% /b/s') DO (echo -Extract package %%i>> "%CB_LOGFILE%" & %%i" >> "%CB_LOGFILE%" 2>nul)
echo %CB_LINE%>> "%CB_LOGFILE%"
goto INSTALL_CB_SUCCESS_END

:INSTALL_CB_SUCCESS_END

:INSTALL_CB_END
echo %CB_LINE%
::exit /b 1

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::