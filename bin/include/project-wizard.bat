@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: project-wizard.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


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
