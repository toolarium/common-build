@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: project-wizard.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


echo %CB_LINE%
echo %CB_LINEHEADER%Create new project, enter project basic data.
echo %CB_LINE%

if not .%CB_CUSTOM_PROJECT_CONFIGFILE% == . set CB_PROJECT_CONFIGFILE=%CB_CUSTOM_PROJECT_CONFIGFILE% & goto VERIFY_PROJECT_CONFIGFILE_END

:: default
set "CB_PROJECT_CONFIGFILE=%CB_SCRIPT_PATH%\..\conf\project-types.properties"

:: if we have a local common gradle build use the project types configuration file
if not .%COMMON_GRADLE_BUILD_URL% == . goto VERIFY_COMMON_GRADLE_BUILD
dir %USERPROFILE%\.gradle\common-gradle-build >nul 2>nul
if not %ERRORLEVEL% EQU 0 goto VERIFY_PROJECT_CONFIGFILE_END
set "TMPFILE=%TEMP%\cb-new-project-%RANDOM%%RANDOM%.tmp"
dir /o-D/b %USERPROFILE%\.gradle\common-gradle-build\???.???.??? | findstr /C:^. 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pcommonGradleBuildVersion=<"%TMPFILE%"
del "%TMPFILE%" 2>nul
set "commonGradleBuildVersion=%commonGradleBuildVersion:~2%"
if not .%commonGradleBuildVersion% == . set "COMMON_GRADLE_BUILD_URL=%USERPROFILE%\.gradle\common-gradle-build\%commonGradleBuildVersion%\gradle"
:VERIFY_COMMON_GRADLE_BUILD
dir %COMMON_GRADLE_BUILD_URL%\conf\project-types.properties >nul 2>nul
if %ERRORLEVEL% EQU 0 set CB_PROJECT_CONFIGFILE=%COMMON_GRADLE_BUILD_URL%\conf\project-types.properties
:VERIFY_PROJECT_CONFIGFILE_END
if not exist %CB_PROJECT_CONFIGFILE% (echo %CB_LINE% & echo %CB_LINEHEADER%Missing project type configuration file %CB_PROJECT_CONFIGFILE%, please install with the cb-install.bat. & echo %CB_LINE% & goto PROJECT_WIZARD_ERROR_END)
::echo %CB_LINEHEADER%Use %CB_PROJECT_CONFIGFILE% as project configuration file

set "CB_PROJECT_CONFIGFILE_TMPFILE=%TEMP%\cb-project-types-%RANDOM%%RANDOM%.tmp"
type %CB_PROJECT_CONFIGFILE% 2>nul | findstr /C:= > %CB_PROJECT_CONFIGFILE_TMPFILE% 2>nul

set "projectName="
set "projectRootPackageName="
set "projectDescription="

if not .%1==. (set "projectName=%1" & shift)
if not defined projectName (set projectName=my-project)
set /p projectName=%CB_LINEHEADER%Please enter project name, e.g. [%projectName%]: 

if not .%1==. (set "projectRootPackageName=%1" & shift)
if not defined projectRootPackageName (set projectRootPackageName=my.rootpackage.name)
set /p projectRootPackageName=%CB_LINEHEADER%Please enter package name, e.g. [%projectRootPackageName%]: 

FOR /F "tokens=1,2 delims=-" %%i in ("%projectName%") do ( set "projectGroupId=%%i" )
set /p projectGroupId=%CB_LINEHEADER%Please enter project group id, e.g. [%projectGroupId%]: 

FOR /F "tokens=1,2 delims=-" %%i in ("%projectName%") do ( set "projectComponentId=%%i" )
set /p projectComponentId=%CB_LINEHEADER%Please enter project component id, e.g. [%projectComponentId%]: 

if .%0==. goto SET_PROJECT_DESCRIPTION
set "projectDescription=%1"
shift
:CHECK_PROJECT_DESCRIPTION
if .%1==. goto SET_PROJECT_DESCRIPTION
set "projectDescription=%projectDescription% %1"
shift
goto CHECK_PROJECT_DESCRIPTION
:SET_PROJECT_DESCRIPTION
if not defined projectDescription (set projectDescription=The implementation of the %projectName%.)
set /p projectDescription=%CB_LINEHEADER%Please enter project description [%projectDescription%]: 

echo.
echo %CB_LINE%
echo %CB_LINEHEADER%Project type:
echo %CB_LINE%
::echo    [1] java-library
::echo    [2] config project
::echo.
::set /p projectTypeId=%CB_LINEHEADER%Please choose the project type [1]: 
::if .%projectTypeId% == . set projectType=java-library
::if .%projectTypeId% == .1 set projectType=java-library
::if .%projectTypeId% == .2 set projectType=config
echo.

:PRINT_PROJECT_TYPES
set /a count = 0 & for /f "tokens=1,* delims== " %%i in (%CB_PROJECT_CONFIGFILE_TMPFILE%) do (set /a count += 1 & echo    [!count!] %%i    		%%j)
set projectTypeId=1
echo.
set /p projectTypeId=%CB_LINEHEADER%Please choose the project type [1]: 
if .%projectTypeId% == . set projectTypeId=1
set /a count = 0 & for /f "tokens=1,* delims== " %%i in (%CB_PROJECT_CONFIGFILE_TMPFILE%) do (set /a count += 1 & if [!projectTypeId!] == [!count!] set "projectType=%%i")
if .%projectType% == . echo %CB_LINEHEADER%Invalid input %projectTypeId% & echo. & goto PRINT_PROJECT_TYPES
::echo %projectTypeId% %projectType%
echo.
echo %CB_LINE%

if exist %projectName% goto PROJECT_WIZARD_ERROR_END
echo %CB_LINEHEADER%Create project %projectName%...
mkdir %projectName% 2>nul
echo apply from: "https://git.io/JfDQT" > %projectName%\build.gradle
set "projectStartParameter=--no-daemon"
goto PROJECT_WIZARD_END

:PROJECT_WIZARD_ERROR_END
del %CB_PROJECT_CONFIGFILE_TMPFILE% 2>nul
echo %CB_LINEHEADER%Project %projectName% already exist, abort.
echo %CB_LINE%
exit /b 1

:PROJECT_WIZARD_END
del %CB_PROJECT_CONFIGFILE_TMPFILE% 2>nul
echo %CB_LINE%
exit /b 0