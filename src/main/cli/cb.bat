@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb.bat: common build 
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: constants
set LINE=----------------------------------------------------------------------------------------
::set STARLINE=****************************************************************************************
set PATH_BACKUP=%PATH%
set PN=%~nx0
set PN_FULL=%0
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "DATESTAMP=%YYYY%%MM%%DD%"
set "TIMESTAMP=%HH%%Min%%Sec%" 
set "FULLTIMESTAMP=%DATESTAMP%-%TIMESTAMP%"
set "USER_FRIENDLY_DATESTAMP=%DD%.%MM%.%YYYY%" 
set "USER_FRIENDLY_TIMESTAMP=%HH%:%Min%:%Sec%" 
set "USER_FRIENDLY_FULLTIMESTAMP=%USER_FRIENDLY_DATESTAMP% %USER_FRIENDLY_TIMESTAMP%"

:: tool version default
if not defined CB_WGET_VERSION (set CB_WGET_VERSION=1.20.3)
if not defined CB_JAVA_VERSION (set CB_JAVA_VERSION=11)
if not defined CB_GRADLE_VERSION (set CB_GRADLE_VERSION=6.3)
if not defined CB_MAVEN_VERSION (set CB_MAVEN_VERSION=3.6.3)
if not defined CB_ANT_VERSION (set CB_ANT_VERSION=1.10.8)
if not defined CB_PACKAGE_URL (set "CB_PACKAGE_URL=")
if not defined CB_INSTALL_SILENT (set "CB_INSTALL_SILENT=false")
if not defined CB_INSTALL_USER_COMMIT (set "CB_INSTALL_USER_COMMIT=true")
if not defined DEVTOOLS_NAME (set DEVTOOLS_NAME=devtools)
if not defined DEVTOOLS_DRIVE (set DEVTOOLS_DRIVE=c:)
if not defined DEVTOOLS (set "DEVTOOLS=%DEVTOOLS_DRIVE%\%DEVTOOLS_NAME%")
if not defined CB_HOME (set "CB_HOME=%DEVTOOLS%\cb")
if not defined CB_USER (set "CB_USER=%USERNAME%")
if not defined CB_PACKAGE_PASSWORD (set "CB_PACKAGE_PASSWORD=")
set "JAVA_VERSION_FILE=.java-version"
set "CB_JAVA_VERSION_FILE=.cb-java-version"
set PARAMETERS=
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
::if [%qualifier%] equ [] set CB_VERSION=%CB_VERSION%-%qualifier:~22%
:READ_VERSION_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: custom initialisation
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if [%CB_CUSTOM_SETTING%] equ [] goto CUSTOM_SETTINGS_END
if exist %CB_CUSTOM_SETTING% goto CUSTOM_SETTINGS_START
echo %LINE%
echo -Could not find custom scrpit, see %%CB_CUSTOM_SETTING%%: 
echo  %CB_CUSTOM_SETTING%
echo %LINE%
goto CUSTOM_SETTINGS_END

:CUSTOM_SETTINGS_START
::echo Custom settings %CB_CUSTOM_SETTING%
call %CB_CUSTOM_SETTING% %1 %2 %3 %4 %5 %6 %7
:CUSTOM_SETTINGS_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set OPTIONAL_PARAMETER=%2
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
set PARAMETERS=%PARAMETERS% %~1
shift
goto CHECK_PARAMETER


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %LINE%
echo common build %CB_VERSION%
echo %LINE%
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - common build v%CB_VERSION%
echo usage: %PN% [OPTION] [TARGET]
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
set "JAVA_HOME_BACKUP=%JAVA_HOME%" & set "CB_JAVA_HOME=" & set "cbJavaVersion="
set "CB_LOGS=%CB_HOME%\logs" 

:: current run jdk switch
for %%R in (%CB_JAVA_VERSION_FILE%) do if not %%~zR lss 1 set /pcbJavaVersion=<%CB_JAVA_VERSION_FILE% & del %CB_JAVA_VERSION_FILE% 2>nul
if not [%cbJavaVersion%] EQU [] echo Run jdk switch to %cbJavaVersion%
if not [%cbJavaVersion%] EQU [] goto COMMON_BUILD_VERIFY_JAVA_INSTALLATION

:: project specific jdk switch
for %%R in (%JAVA_VERSION_FILE%) do if not %%~zR lss 1 set /pcbJavaVersion=<%JAVA_VERSION_FILE%
if not [%cbJavaVersion%] EQU [] echo Project jdk switch %cbJavaVersion%
if not [%cbJavaVersion%] EQU [] goto COMMON_BUILD_VERIFY_JAVA_INSTALLATION
goto COMMON_BUILD_VERIFY_JAVA

:COMMON_BUILD_VERIFY_JAVA_INSTALLATION
dir %DEVTOOLS%\*jdk-%cbJavaVersion%* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %CB_JAVA_VERSION_FILE%
for %%R in (%CB_JAVA_VERSION_FILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install java %cbJavaVersion%
dir %DEVTOOLS%\*jdk-%cbJavaVersion%* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %CB_JAVA_VERSION_FILE%
set "cbJavaVersionAvailable=true"
for %%R in (%CB_JAVA_VERSION_FILE%) do if %%~zR lss 1 set "cbJavaVersionAvailable=false"
del %CB_JAVA_VERSION_FILE% 2>nul
if [%cbJavaVersionAvailable%] EQU [false] echo -Can not switch to the java version %cbJavaVersion%!
if [%cbJavaVersionAvailable%] EQU [false] goto END
set "CB_JAVA_HOME=%DEVTOOLS%\%cbJavaVersion:~2%"
echo -Set java to %CB_JAVA_HOME% 
set "PATH=%CB_JAVA_HOME%\bin;%PATH%"

:COMMON_BUILD_VERIFY_JAVA
WHERE java >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_JAVA_EXEC
if not [%JAVA_HOME%] equ [] set "PATH=%JAVA_HOME%\bin;%PATH%"
WHERE java >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_JAVA_EXEC
set "TMPFILE=%CB_LOGS%\cb-java-home.tmp"
dir %DEVTOOLS%\*jdk* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install java
dir %DEVTOOLS%\*jdk* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if not %%~zR lss 1 set /pJAVA_HOME=<%TMPFILE%
del %TMPFILE% 2>nul
set "JAVA_HOME=%JAVA_HOME:~2%"
set "JAVA_HOME=%DEVTOOLS%\%JAVA_HOME%"
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
dir %DEVTOOLS%\*gradle* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install gradle
dir %DEVTOOLS%\*gradle* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if not %%~zR lss 1 set /pGRADLE_HOME=<%TMPFILE%
del %TMPFILE% 2>nul
set "GRADLE_HOME=%GRADLE_HOME:~2%"
set "GRADLE_HOME=%DEVTOOLS%\%GRADLE_HOME%"
set "PATH=%GRADLE_HOME%\bin;%PATH%"
:COMMON_BUILD_GRADLE_EXEC
::if defined JAVA_HOME_BACKUP set "JAVA_HOME=%JAVA_HOME_BACKUP%"
::if defined PATH_BACKUP set "PATH=%PATH_BACKUP%"
::if exist %CB_BIN%\cb-env-clean.bat call %CB_BIN%\cb-env-clean.bat 
cmd /C %GRADLE_EXEC% %PARAMETERS%
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
dir %DEVTOOLS%\*maven* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install maven
dir %DEVTOOLS%\*maven* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if not %%~zR lss 1 set /pMAVEN_HOME=<%TMPFILE%
del %TMPFILE% 2>nul
set "MAVEN_HOME=%MAVEN_HOME:~2%"
set "MAVEN_HOME=%DEVTOOLS%\%MAVEN_HOME%"
set "PATH=%MAVEN_HOME%\bin;%PATH%"
:COMMON_BUILD_MAVEN_EXEC
::if defined JAVA_HOME_BACKUP set "JAVA_HOME=%JAVA_HOME_BACKUP%"
::if defined PATH_BACKUP set "PATH=%PATH_BACKUP%"
::if exist %CB_BIN%\cb-env-clean.bat call %CB_BIN%\cb-env-clean.bat 
cmd /C %MAVEN_EXEC% %PARAMETERS%
goto END

:COMMON_BUILD_ANT
WHERE ant >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_ANT_EXEC
if not [%ANT_HOME%] equ [] set "PATH=%ANT_HOME%\bin;%PATH%"
WHERE ant >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto COMMON_BUILD_ANT_EXEC
set "TMPFILE=%CB_LOGS%\cb-ant-home.tmp"
dir %DEVTOOLS%\*ant* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if %%~zR lss 1 call %PN_FULL% --silent --install ant
dir %DEVTOOLS%\*ant* /O-D/b 2>nul | findstr/n ^^ | findstr 1:> %TMPFILE%
for %%R in (%TMPFILE%) do if not %%~zR lss 1 set /pANT_HOME=<%TMPFILE%
del %TMPFILE% 2>nul
set "ANT_HOME=%ANT_HOME:~2%"
set "ANT_HOME=%DEVTOOLS%\%ANT_HOME%"
set "PATH=%ANT_HOME%\bin;%PATH%"
:COMMON_BUILD_ANT_EXEC
::if defined JAVA_HOME_BACKUP set "JAVA_HOME=%JAVA_HOME_BACKUP%"
::if defined PATH_BACKUP set "PATH=%PATH_BACKUP%"
::if exist %CB_BIN%\cb-env-clean.bat call %CB_BIN%\cb-env-clean.bat 
cmd /C ant %PARAMETERS%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROJECT_WIZARD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SHIFT
SET CB_WIZARD_PARAMETERS=%PARAMETERS%

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
if [%CB_INSTALL_SILENT%] equ [false] (echo %LINE%
		echo Started common-build installation on %COMPUTERNAME%, %USER_FRIENDLY_FULLTIMESTAMP%:
		echo -Please close any open development process such as IDE's!
		echo %LINE%)
if [%CB_INSTALL_USER_COMMIT%] equ [true] (pause)

:: create directories
if [%CB_INSTALL_SILENT%] equ [false] (echo -Use %DEVTOOLS% path as devtools folder)
if not exist %DEVTOOLS% mkdir %DEVTOOLS% >nul 2>nul
setx DEVTOOLS "%DEVTOOLS%" >nul 2>nul
if [%CB_INSTALL_SILENT%] equ [false] (echo -Use %CB_HOME% path as CB_HOME folder)
if not exist %CB_HOME% mkdir %CB_HOME% >nul 2>nul
setx CB_HOME "%CB_HOME%" >nul 2>nul
set "CB_BIN=%CB_HOME%\bin" 
if not exist %CB_BIN% mkdir %CB_BIN% >nul 2>nul
set "CB_LOGS=%CB_HOME%\logs" 
if not exist %CB_LOGS% mkdir %CB_LOGS% >nul 2>nul
set "DEV_REPOSITORY=%DEVTOOLS%\.repository" 
if not exist %DEV_REPOSITORY% mkdir %DEV_REPOSITORY% >nul 2>nul

set "LOGFILE=%CB_LOGS%\%FULLTIMESTAMP%-%CB_USER%.log"
if [%CB_INSTALL_SILENT%] equ [false] (echo -The installation log file can be found here "%LOGFILE%")
echo %LINE%>> "%LOGFILE%"
echo Started common-build installation on %COMPUTERNAME%, %USER_FRIENDLY_FULLTIMESTAMP%>> "%LOGFILE%"
echo common-build: %CB_HOME%, devtools: %DEVTOOLS% (name: %DEVTOOLS_NAME%, drive:%DEVTOOLS_DRIVE%)>> "%LOGFILE%"
echo wget: %CB_WGET_VERSION%, gradle: %CB_GRADLE_VERSION%, java: %CB_JAVA_VERSION%>> "%LOGFILE%"
echo %LINE%>> "%LOGFILE%"

:: tools settings
set "TMPFILE=%CB_LOGS%\tmpfile.tmp"
set "WGET_SECURITY_CREDENTIALS=--trust-server-names --no-check-certificate"
set "WGET_PROGRESSBAR=--show-progress"
set "WGET_LOG=-a %LOGFILE%"
set "WGET_PARAM=-c"

:: be sure findstr works
findstr 2>nul
if %ERRORLEVEL% EQU 9009 (SET "PATH=%PATH%;%SystemRoot%\System32\")

:: the script itself
copy %PN_FULL% %CB_BIN% >nul 2>nul

:: to upper case
set "TOUPPER=%CB_BIN%\toupper.bat"
if exist %TOUPPER% goto TOUPPER_INSTALLED
echo -Install %TOUPPER% & echo Install %TOUPPER%>> "%LOGFILE%"
echo @ECHO OFF> %TOUPPER%
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::>> %TOUPPER%
echo :: Copyright by toolarium, all rights reserved.>> %TOUPPER%
echo :: MIT License: https://mit-license.org>> %TOUPPER%
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::>> %TOUPPER%
echo setlocal EnableDelayedExpansion>> %TOUPPER%
echo for %%%%a in (%%1) do (>> %TOUPPER%
echo    set "line=%%%%a">> %TOUPPER%
echo    for %%%%b in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (>> %TOUPPER%
echo       set "line=!line:%%%%b=%%%%b!">> %TOUPPER%
echo    )>> %TOUPPER%
echo    echo !line!>> %TOUPPER%
echo )>> %TOUPPER%
:TOUPPER_INSTALLED

set CURRENT_PATH=%CD%
set SCRIPT_PATH=%~dp0
for /f %%i in ('CALL %CB_BIN%\toupper %SCRIPT_PATH%') do set SCRIPT_PATH=%%i
set SCRIPT_DRIVE=%~d0
for /f %%i in ('CALL %CB_BIN%\toupper %SCRIPT_DRIVE%') do set SCRIPT_DRIVE=%%i

SET PROCESSOR_ARCHITECTURE_NUMBER=64
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:32=%" SET PROCESSOR_ARCHITECTURE_NUMBER=32
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:64=%" SET PROCESSOR_ARCHITECTURE_NUMBER=64

:INSTALL_WGET
:: download wget -> https://eternallybored.org/misc/wget/1.20.3/64/wget.exe
set WGET_CMD=wget.exe
WHERE %WGET_CMD% >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto INSTALL_WGET_END
set "WGET_DOWNLOAD_URL=https://eternallybored.org/misc/wget/"
set "WGET_PACKAGE_URL=%WGET_DOWNLOAD_URL%/%CB_WGET_VERSION%/%PROCESSOR_ARCHITECTURE_NUMBER%/%WGET_CMD%"
echo -Install %CB_BIN%\%WGET_CMD% & echo -Install %CB_BIN%\%WGET_CMD%>> "%LOGFILE%"
powershell -Command "iwr $start_time = Get-Date;Invoke-WebRequest -Uri '%WGET_PACKAGE_URL%' -OutFile '%CB_BIN%\%WGET_CMD%';Write-Output 'Time taken: $((Get-Date).Subtract($start_time).Seconds) seconds' 2>nul | iex 2>nul" 2>nul
:INSTALL_WGET_END

set CB_PKG_FILTER=*.zip
if .%2==.java goto INSTALL_JDK
if .%2==.gradle goto INSTALL_GRADLE
if .%2==.maven goto INSTALL_MAVEN
if .%2==.ant goto INSTALL_ANT
if .%2==.pkg goto INSTALL_PACKAGES

:: own files
echo -Install cb files... & echo -Install cb files...>> "%LOGFILE%"
echo %CB_BIN%\%WGET_CMD% -O %CB_HOME%\VERSION %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://raw.githubusercontent.com/toolarium/common-build/master/VERSION">> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O %CB_HOME%\VERSION %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://raw.githubusercontent.com/toolarium/common-build/master/VERSION"
echo %CB_BIN%\%WGET_CMD% -O %CB_HOME%\LICENSE %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://github.com/toolarium/common-build/blob/master/LICENSE">> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O %CB_HOME%\LICENSE %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://github.com/toolarium/common-build/blob/master/LICENSE"
echo %CB_BIN%\%WGET_CMD% -O %CB_BIN%\cb.bat %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://raw.githubusercontent.com/toolarium/common-build/master/src/main/cli/cb.bat">> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O %CB_BIN%\cb.bat %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://raw.githubusercontent.com/toolarium/common-build/master/src/main/cli/cb.bat"
::echo %CB_BIN%\%WGET_CMD% -O %CB_BIN%\cb %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://raw.githubusercontent.com/toolarium/common-build/master/src/main/cli/cb">> "%LOGFILE%"
::%CB_BIN%\%WGET_CMD% -O %CB_BIN%\cb %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://raw.githubusercontent.com/toolarium/common-build/master/src/main/cli/cb"
echo %CB_BIN%\%WGET_CMD% -O %CB_BIN%\cb-env-clean.bat %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://raw.githubusercontent.com/toolarium/common-build/master/src/main/cli/cb-env-clean.bat">> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O %CB_BIN%\cb-env-clean.bat %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "https://raw.githubusercontent.com/toolarium/common-build/master/src/main/cli/cb-env-clean.bat"

:: add to path
set "SystemPath=" & set "UserPath="
for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "Path" 2^>nul') do (if /I "%%N" == "Path" (set "SystemPath=%%P" & goto GET_USER_PATH_FROM_REGISTRY))
:GET_USER_PATH_FROM_REGISTRY
for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKCU\Environment" /v "Path" 2^>nul') do (if /I "%%N" == "Path" (set "UserPath=%%P" & goto GET_USER_PATH_FROM_REGISTRY_END))
:GET_USER_PATH_FROM_REGISTRY_END
echo Current user path is %UserPath% >> "%LOGFILE%"
if /I [%DEVTOOLS_DRIVE%] NEQ [%SCRIPT_DRIVE%] (%DEVTOOLS_DRIVE%)
cd %CB_LOGS%
WHERE cb >nul 2>nul
if %ERRORLEVEL% NEQ 0 (echo -Set CB_HOME to path. & setx PATH "%CB_BIN%;%UserPath%" >nul 2>nul)
set "PATH=%CB_BIN%;%PATH%"
if /I [%DEVTOOLS_DRIVE%] NEQ [%SCRIPT_DRIVE%] (%SCRIPT_DRIVE%)
cd %CURRENT_PATH%

:: java
:INSTALL_JDK
set jdkVersion=
if .%2==.java set jdkVersion=%3
if .%jdkVersion%==. set jdkVersion=%CB_JAVA_VERSION%
set JAVA_OPENJDK_IMPL=hotspot
set "JAVA_INFO_DOWNLOAD_URL=https://api.adoptopenjdk.net/v2/info/releases/openjdk%jdkVersion%?openjdk_impl=%JAVA_OPENJDK_IMPL%&os=windows&arch=x%PROCESSOR_ARCHITECTURE_NUMBER%&release=latest&type=jdk"
set "JAVA_DOWNLOAD_URL=https://api.adoptopenjdk.net/v2/binary/releases/openjdk%jdkVersion%?openjdk_impl=%JAVA_OPENJDK_IMPL%&os=windows&arch=x%PROCESSOR_ARCHITECTURE_NUMBER%&release=latest&type=jdk"
echo %LINE%>> "%LOGFILE%"
echo -Install java version %jdkVersion% & echo -Install java version %jdkVersion%>> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O %TMPFILE% %WGET_SECURITY_CREDENTIALS% -q "%JAVA_INFO_DOWNLOAD_URL%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binaries.binary_name" > %CB_LOGS%\javaFile.json
set /p jdkFilename= < %CB_LOGS%\javaFile.json
del %CB_LOGS%\javaFile.json >nul 2>nul
move %TMPFILE% %DEV_REPOSITORY%\%jdkFilename%.json >nul 2>nul
echo %CB_BIN%\%WGET_CMD% -O %DEV_REPOSITORY%\%jdkFilename% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "%JAVA_DOWNLOAD_URL%">> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O %DEV_REPOSITORY%\%jdkFilename% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "%JAVA_DOWNLOAD_URL%"
:INSTALL_JDK_END
for %%A in (%DEV_REPOSITORY%\%jdkFilename%) do if %%~zA==0 del %DEV_REPOSITORY%\%jdkFilename% >nul 2>nul
echo %LINE%>> "%LOGFILE%"
if .%2==.java (set CB_PKG_FILTER=%jdkFilename% & goto EXTRACT_ARCHIVES)

:: gradle
:INSTALL_GRADLE
set gradleVersion=
if .%2==.gradle set gradleVersion=%3
if .%gradleVersion%==. set gradleVersion=%CB_GRADLE_VERSION%
set GRADLE_DOWNLOAD_URL=https://downloads.gradle-dn.com/distributions
set GRADLE_DOWNLOAD_PACKAGENAME=gradle-%gradleVersion%-bin.zip
set GRADLE_DOWNLOAD_PACKAGE_URL=%GRADLE_DOWNLOAD_URL%/%GRADLE_DOWNLOAD_PACKAGENAME%
echo %LINE%>> "%LOGFILE%"
echo -Install gradle version %gradleVersion% & echo -Install gradle version %gradleVersion%>> "%LOGFILE%"
if exist %DEVTOOLS%\gradle-%gradleVersion% goto INSTALL_GRADLE_END
echo %CB_BIN%\%WGET_CMD% -O%DEV_REPOSITORY%\%GRADLE_DOWNLOAD_PACKAGENAME% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "%GRADLE_DOWNLOAD_PACKAGE_URL%">> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O%DEV_REPOSITORY%\%GRADLE_DOWNLOAD_PACKAGENAME% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "%GRADLE_DOWNLOAD_PACKAGE_URL%"
:INSTALL_GRADLE_END
for %%A in (%DEV_REPOSITORY%\%GRADLE_DOWNLOAD_PACKAGENAME%) do if %%~zA==0 del %DEV_REPOSITORY%\%GRADLE_DOWNLOAD_PACKAGENAME% >nul 2>nul
echo %LINE%>> "%LOGFILE%"
if .%2==.gradle (set CB_PKG_FILTER=%GRADLE_DOWNLOAD_PACKAGENAME% & goto EXTRACT_ARCHIVES)
goto INSTALL_PACKAGES

:: maven
:INSTALL_MAVEN
set mavenVersion=
if .%2==.maven set mavenVersion=%3
if .%mavenVersion%==. set mavenVersion=%CB_MAVEN_VERSION%
if exist %DEVTOOLS%\maven-%mavenVersion% goto INSTALL_MAVEN_END
set MAVEN_DOWNLOAD_URL=https://archive.apache.org/dist/maven/maven-3/%mavenVersion%/binaries
set MAVEN_DOWNLOAD_PACKAGENAME=apache-maven-%mavenVersion%-bin.zip
set MAVEN_DOWNLOAD_PACKAGE_URL=%MAVEN_DOWNLOAD_URL%/%MAVEN_DOWNLOAD_PACKAGENAME%
echo %LINE%>> "%LOGFILE%"
echo -Install maven version %mavenVersion% & echo -Install maven version %mavenVersion%>> "%LOGFILE%"
echo %CB_BIN%\%WGET_CMD% -O%DEV_REPOSITORY%\%MAVEN_DOWNLOAD_PACKAGENAME% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "%MAVEN_DOWNLOAD_PACKAGE_URL%">> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O%DEV_REPOSITORY%\%MAVEN_DOWNLOAD_PACKAGENAME% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "%MAVEN_DOWNLOAD_PACKAGE_URL%"
:INSTALL_MAVEN_END
for %%A in (%DEV_REPOSITORY%\%MAVEN_DOWNLOAD_PACKAGENAME%) do if %%~zA==0 del %DEV_REPOSITORY%\%MAVEN_DOWNLOAD_PACKAGENAME% >nul 2>nul
echo %LINE%>> "%LOGFILE%"
if .%2==.maven (set "CB_PKG_FILTER=%MAVEN_DOWNLOAD_PACKAGENAME%" & goto EXTRACT_ARCHIVES)

:: ant
:INSTALL_ANT
set antVersion=
if .%2==.ant set antVersion=%3
if .%antVersion%==. set antVersion=%CB_ANT_VERSION%
if exist %DEVTOOLS%\ant-%antVersion% goto INSTALL_ANT_END
set ANT_DOWNLOAD_URL=https://downloads.apache.org/ant/binaries
set ANT_DOWNLOAD_PACKAGENAME=apache-ant-%antVersion%-bin.zip
set ANT_DOWNLOAD_PACKAGE_URL=%ANT_DOWNLOAD_URL%/%ANT_DOWNLOAD_PACKAGENAME%
echo %LINE%>> "%LOGFILE%"
echo -Install ant version %antVersion% & echo -Install ant version %antVersion%>> "%LOGFILE%"
echo %CB_BIN%\%WGET_CMD% -O%DEV_REPOSITORY%\%ANT_DOWNLOAD_PACKAGENAME% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "%ANT_DOWNLOAD_PACKAGE_URL%">> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% -O%DEV_REPOSITORY%\%ANT_DOWNLOAD_PACKAGENAME% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_PARAM% %WGET_LOG% "%ANT_DOWNLOAD_PACKAGE_URL%"
:INSTALL_ANT_END
for %%A in (%DEV_REPOSITORY%\%ANT_DOWNLOAD_PACKAGENAME%) do if %%~zA==0 del %DEV_REPOSITORY%\%ANT_DOWNLOAD_PACKAGENAME% >nul 2>nul
echo %LINE%>> "%LOGFILE%"
if .%2==.ant (set "CB_PKG_FILTER=%ANT_DOWNLOAD_PACKAGENAME%" & goto EXTRACT_ARCHIVES)

:: packages
:INSTALL_PACKAGES
if not defined CB_PACKAGE_URL goto EXTRACT_ARCHIVES
set WGET_USER_CREDENTIALS=
if [%CB_PACKAGE_USER%] equ [] (set /p CB_PACKAGE_USER=Please enter user credentials, e.g. %CB_USER%: )
if [%CB_PACKAGE_USER%] equ [] (set "CB_PACKAGE_USER=%CB_USER%")
if [%CB_PACKAGE_PASSWORD%] equ [ask] (set WGET_USER_CREDENTIALS=--ask-password --user %CB_PACKAGE_USER%)
set WGET_RECURSIVE_PARAM=-r -np -nH --timestamping
set WGET_FILTER=--exclude-directories=_deprecated -R "index.*"
echo %LINE%>> "%LOGFILE%"
echo -Install packages from %CB_PACKAGE_URL% & echo -Install packages from %CB_PACKAGE_URL%>> "%LOGFILE%"
cd %DEV_REPOSITORY%
echo %CB_BIN%\%WGET_CMD% %CB_PACKAGE_URL% %WGET_PARAM% %WGET_RECURSIVE_PARAM% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_USER_CREDENTIALS% %WGET_FILTER% %WGET_LOG%>> "%LOGFILE%"
%CB_BIN%\%WGET_CMD% %CB_PACKAGE_URL% %WGET_PARAM% %WGET_RECURSIVE_PARAM% %WGET_SECURITY_CREDENTIALS% %WGET_PROGRESSBAR% %WGET_USER_CREDENTIALS% %WGET_FILTER% %WGET_LOG%
cd %CURRENT_PATH%
if not %ERRORLEVEL% equ 6 goto INSTALL_PACKAGES_END
echo ERROR: Invalid credentials, give up. >> "%LOGFILE%"
echo %LINE%
echo ERROR: Invalid credentials, give up.
echo %LINE%
goto INSTALL_CB_END
:INSTALL_PACKAGES_END
echo %LINE%>> "%LOGFILE%"
if .%2==.pkg goto EXTRACT_ARCHIVES	

:: extract
:EXTRACT_ARCHIVES
::if exist %CB_BIN%\cleanup-installation.bat (echo -Cleanup old packages... >> "%LOGFILE%" 
::	call %CB_BIN%\cleanup-installation >> "%LOGFILE%" 2>/nul)

echo %LINE%>> "%LOGFILE%"
echo -Extract files in %DEVTOOLS%... & echo -Extract files in %DEVTOOLS%... >> "%LOGFILE%"
::dir %DEV_REPOSITORY%\%SERVER_PATH%\%DEVTOOLS_NAME%\*.zip /b/s --> unzip
FOR /F %%i IN ('dir %DEV_REPOSITORY%\%CB_PKG_FILTER% /b/s') DO (echo -Extract package %%i>> "%LOGFILE%" & powershell -command "Expand-Archive -Force '%%i' '%DEVTOOLS%'" >> "%LOGFILE%" 2>nul)
echo %LINE%>> "%LOGFILE%"

:INSTALL_CB_SUCCESS_END
echo.
if not exist %CB_HOME%\VERSION goto READ_VERSION_END
( set "major.number=" & set /p "major.number="
  set "minor.number=" & set /p "minor.number="
  set "revision.number=" & set /p "revision.number="
  set "qualifier=" & set /p "qualifier=" ) < %CB_HOME%\VERSION
set CB_VERSION=%major.number:~22%.%minor.number:~22%.%revision.number:~22%
echo %LINE%
echo Successfully installed common-build %CB_VERSION% und %CB_HOME%. The user %%PATH%% is 
echo already extended and you can start working with it with the command cb!
echo %LINE%

:INSTALL_CB_END
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "USER_FRIENDLY_DATESTAMP=%DD%.%MM%.%YYYY%" 
set "USER_FRIENDLY_TIMESTAMP=%HH%:%Min%:%Sec%" 
set "USER_FRIENDLY_FULLTIMESTAMP=%USER_FRIENDLY_DATESTAMP% %USER_FRIENDLY_TIMESTAMP%"
echo End common-build installation on %COMPUTERNAME%, %USER_FRIENDLY_FULLTIMESTAMP%>> "%LOGFILE%"
::exit /b 1

set "TOUPPER=" & set "DEV_REPOSITORY=" & set "PROCESSOR_ARCHITECTURE_NUMBER=" & set "CURRENT_DRIVE=" & set "CURRENT_PATH="
set "CB_PKG_FILTER="
set "gradleVersion=" & set "GRADLE_DOWNLOAD_PACKAGENAME=" & set "GRADLE_DOWNLOAD_PACKAGE_URL=" & set "GRADLE_DOWNLOAD_URL="
set "mavenVersion=" & set "MAVEN_DOWNLOAD_PACKAGENAME=" & set "MAVEN_DOWNLOAD_PACKAGE_URL=" & set "MAVEN_DOWNLOAD_URL="
set "antVersion=" & set "ANT_DOWNLOAD_PACKAGENAME=" & set "ANT_DOWNLOAD_PACKAGE_URL=" & set "ANT_DOWNLOAD_URL="
set "JAVA_DOWNLOAD_URL=" & set "JAVA_INFO_DOWNLOAD_URL=" & set "JAVA_OPENJDK_IMPL=" & set "jdkFilename=" & set "jdkVersion="
set "WGET_CMD=" & set "WGET_DOWNLOAD_URL=" & set "WGET_LOG=" & set "WGET_PACKAGE_URL="
set "WGET_PARAM=" & set "WGET_PROGRESSBAR=" & set "WGET_SECURITY_CREDENTIALS="
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
::if defined JAVA_HOME_BACKUP set "JAVA_HOME=%JAVA_HOME_BACKUP%"
::if defined PATH_BACKUP set "PATH=%PATH_BACKUP%"
::if exist %CB_BIN%\cb-env-clean.bat call %CB_BIN%\cb-env-clean.bat 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
