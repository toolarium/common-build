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
echo    [1] java-library
echo    [2] config project
echo.
set /p projectTypeId=%CB_LINEHEADER%Please choose the project type [1]: 

if .%projectTypeId% == . set projectType=java-library
if .%projectTypeId% == .1 set projectType=java-library
if .%projectTypeId% == .2 set projectType=config

echo.
echo %CB_LINE%
if exist %projectName% goto PROJECT_WIZARD_ERROR_END
echo %CB_LINEHEADER%Create project %projectName%...
mkdir %projectName% 2>nul
echo apply from: "https://git.io/JfDQT" > %projectName%\build.gradle
goto PROJECT_WIZARD_END

:PROJECT_WIZARD_ERROR_END
echo %CB_LINEHEADER%Project %projectName% already exist, abort!
echo %CB_LINE%
exit /b 1

:PROJECT_WIZARD_END
echo %CB_LINE%
exit /b 0