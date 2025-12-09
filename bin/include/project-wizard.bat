@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: project-wizard.bat
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

if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb" & mkdir "%CB_TEMP%" >nul 2>nul
echo %CB_LINE%
if exist build.gradle echo %CB_LINEHEADER%The current path is inside a project [%CD%], please start outside. & goto PROJECT_WIZARD_ERROR_END
echo %CB_LINEHEADER%Create new project, enter project basic data.
echo %CB_LINE%
set "BACKUP_CB_WORKING_PATH=%CB_WORKING_PATH%"
set CB_PROJECT_CONFIGFILE=
set CB_PRODUCT_CONFIGFILE=
set CB_PRODUCT_CONFIGFILE_TMPFILE=

if not ".%CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types.properties" set "CB_PROJECT_CONFIGFILE=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types.properties"
if not ".%CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\product-types.properties" set "CB_PRODUCT_CONFIGFILE=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\product-types.properties"

:: default
if ".%CB_PROJECT_CONFIGFILE%"=="." set "CB_PROJECT_CONFIGFILE=%CB_SCRIPT_PATH%\..\conf\project-types.properties"
if ".%CB_PRODUCT_CONFIGFILE%"=="." if exist "%CB_SCRIPT_PATH%\..\conf\product-types.properties" set "CB_PRODUCT_CONFIGFILE=%CB_SCRIPT_PATH%\..\conf\product-types.properties"

:: if we have a local common gradle build use the project types file
if not ".%CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." goto VERIFY_PROJECT_CONFIGFILE_END
dir "%USERPROFILE%\.gradle\common-gradle-build" >nul 2>nul
if not %ERRORLEVEL% EQU 0 goto VERIFY_PROJECT_CONFIGFILE_END
set "TMPFILE=%CB_TEMP%\cb-new-project-%RANDOM%%RANDOM%.tmp"
dir /o-D/b "%USERPROFILE%\.gradle\common-gradle-build\???.???.???" | findstr /C:^. 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pcommonGradleBuildVersion=<"%TMPFILE%"
del /f /q "%TMPFILE%" 2>nul
set "commonGradleBuildVersion=%commonGradleBuildVersion:~2%"
if not ".%commonGradleBuildVersion%"=="." set "LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH=%USERPROFILE%\.gradle\common-gradle-build\%commonGradleBuildVersion%\gradle"
if not ".%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types.properties" set "CB_PROJECT_CONFIGFILE=%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types.properties"
if not ".%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\product-types.properties" set "CB_PRODUCT_CONFIGFILE=%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\product-types.properties"

:VERIFY_PROJECT_CONFIGFILE_END
if not exist "%CB_PROJECT_CONFIGFILE%" (echo %CB_LINE% & echo %CB_LINEHEADER%Missing project types configuration file %CB_PROJECT_CONFIGFILE%, please install with the cb-install.bat. & echo %CB_LINE% & goto PROJECT_WIZARD_ERROR_END)

:: get file timestamp
for /f "tokens=1,2 delims= " %%i in ('dir /O:D /T:W /A:-D /4 %CB_PROJECT_CONFIGFILE% 2^>nul ^| findstr /C:project-types.properties 2^>nul') do (set "cbProjectConfigFileTimestamp=%%i %%j")
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp: =%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp::=%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp:.=%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp:/=%"
if .%cbProjectConfigFileTimestamp%==. set cbProjectConfigFileTimestamp=%RANDOM%%RANDOM%
set "CB_PROJECT_CONFIGFILE_TMPFILE=%CB_TEMP%\cb-project-types-%cbProjectConfigFileTimestamp%.tmp"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use project types file: %CB_PROJECT_CONFIGFILE%
if .%CB_VERBOSE% == .true if not exist %CB_PROJECT_CONFIGFILE_TMPFILE% echo %CB_LINEHEADER%Create project types temp file: %CB_PROJECT_CONFIGFILE_TMPFILE%
if not exist %CB_PROJECT_CONFIGFILE_TMPFILE% type "%CB_PROJECT_CONFIGFILE%" 2>nul | findstr /V "#" | findstr /C:= > "%CB_PROJECT_CONFIGFILE_TMPFILE%" 2>nul

set "productTypeId="
set "productName="
set "projectTypeId="
set "projectType="
set "projectName="
set "projectRootPackageName="
set "projectGroupId="
set "projectComponentId="
set "projectDescription="
	
if ".%CB_PRODUCT_CONFIGFILE%"=="." goto END_PRODUCT_TYPES
if not exist "%CB_PRODUCT_CONFIGFILE%" goto END_PRODUCT_TYPES
for /f "tokens=1,2 delims= " %%i in ('dir /O:D /T:W /A:-D /4 %CB_PRODUCT_CONFIGFILE% 2^>nul ^| findstr /C:product-types.properties 2^>nul') do (set "cbProjectConfigFileTimestamp=%%i %%j")
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp: =%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp::=%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp:.=%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp:/=%"
if .%cbProjectConfigFileTimestamp%==. set cbProjectConfigFileTimestamp=%RANDOM%%RANDOM%
set "CB_PRODUCT_CONFIGFILE_TMPFILE=%CB_TEMP%\cb-product-types-%cbProjectConfigFileTimestamp%.tmp"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use product types file: %CB_PRODUCT_CONFIGFILE%

if .%CB_VERBOSE% == .true if not exist %CB_PRODUCT_CONFIGFILE_TMPFILE% echo %CB_LINEHEADER%Create product types temp file: %CB_PRODUCT_CONFIGFILE_TMPFILE%
if not exist %CB_PRODUCT_CONFIGFILE_TMPFILE% type "%CB_PRODUCT_CONFIGFILE%" 2>nul | findstr /V "#" | findstr /C:= > %CB_PRODUCT_CONFIGFILE_TMPFILE% 2>nul


:: choose first product which it belongs to
if not .%1==. (set "productName=%1" & shift)
set /a "productTypeId=%productName%" 2>nul
if not .%productTypeId% == . goto VERIFY_PRODUCT_TYPE
echo %CB_LINEHEADER%Products:
:PRINT_PRODUCT_TYPES
set /a count = 0 & for /f "tokens=1,* delims==" %%i in (%CB_PRODUCT_CONFIGFILE_TMPFILE%) do (set /a count += 1 & echo    [!count!] %%i)
set productTypeId=1
::if %count% EQU 1 echo %CB_LINEHEADER%It belongs to [%productName%] & goto PRODUCT_SELECTED
echo.
set /p productTypeId=%CB_LINEHEADER%Please select to which product it belongs [1]: 
:VERIFY_PRODUCT_TYPE
if .%productTypeId% == . set productTypeId=1
set /a count = 0 & for /f "tokens=1,* delims==" %%i in (%CB_PRODUCT_CONFIGFILE_TMPFILE%) do (set /a count += 1 & if [!productTypeId!] == [!count!] (set "productName=%%i" & set "productConfiguration=%%j"))
if ".%productName%"=="." echo %CB_LINEHEADER%Invalid input %productTypeId% & echo. & goto PRINT_PRODUCT_TYPES
:SET_PRODUCT_TYPE_PARAMETERS
FOR /F "tokens=1,2 delims=^|" %%i in ("%productConfiguration%") do (set "productConfigItem=%%i"
	FOR /F "tokens=1,2 delims=:" %%a in ("!productConfigItem!") do (set "key=%%a" & set "value=%%b" & set "!key!=!value!"))
set "previousProductConfiguration=%productConfiguration%"
set "productConfiguration=%productConfiguration:*|=%"
if not "%previousProductConfiguration%"=="%productConfiguration%" goto SET_PRODUCT_TYPE_PARAMETERS

:: check product individuel project configuration
call :PRODUCT_PROJECT_CONFIGFILE %productName%
if not ".%CB_PRODUCT_PROJECT_CONFIGFILE_TMPFILE%"=="." set "CB_PROJECT_CONFIGFILE_TMPFILE=%CB_PRODUCT_PROJECT_CONFIGFILE_TMPFILE%"

:END_PRODUCT_TYPES

:SET_PROJECT_TYPE
if not .%1==. (set "projectName=%1" & shift)
set /a "projectTypeId=%projectName%" 2>nul
if not .%projectTypeId% == . goto VERIFY_PROJECT_TYPE

echo %CB_LINEHEADER%Project type:
:PRINT_PROJECT_TYPES
set /a count = 0 & for /f "tokens=1,* delims== " %%i in (%CB_PROJECT_CONFIGFILE_TMPFILE%) do (
	set /a count += 1 
	for /f "tokens=1,* delims=|" %%a in ("%%j") do set projectTypeName=%%a
::	echo    [!count!] %%i    	!projectTypeName!)
	echo    [!count!] !projectTypeName!)
set projectTypeId=1
echo.
set /p projectTypeId=%CB_LINEHEADER%Please choose the project type [1]: 
:VERIFY_PROJECT_TYPE
if .%projectTypeId% == . set projectTypeId=1
set /a count = 0 & for /f "tokens=1,* delims== " %%i in (%CB_PROJECT_CONFIGFILE_TMPFILE%) do (set /a count += 1 & if [!projectTypeId!] == [!count!] set "projectType=%%i")
set /a count = 0 & for /f "tokens=1,* delims== " %%i in (%CB_PROJECT_CONFIGFILE_TMPFILE%) do (
	set /a count += 1
	if [!projectTypeId!] == [!count!] for /f "tokens=1,* delims=|" %%a in ("%%j") do set "projectTypeConfiguration=%%b")
	
if not .%projectType% == . if not .%projectName% == . set "projectName=" & echo %CB_LINEHEADER%Project type [%projectType%] & goto END_PROJECT_TYPES
if .%projectType% == . echo %CB_LINEHEADER%Invalid input %projectTypeId% & echo. & goto PRINT_PROJECT_TYPES
::echo %projectTypeId% %projectType% "%projectTypeConfiguration%"
set "projectTypeConfiguration=|%projectTypeConfiguration%"
:END_PROJECT_TYPES
set "projectTypeConfigurationParameter=%projectTypeConfiguration%"
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Selected project type [%projectType%]/[%projectTypeId%], configurationType: "%projectTypeConfiguration%", configurationParameter: "%projectTypeConfigurationParameter%"

echo "%projectTypeConfiguration%" | findstr /C:"projectName" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto VALIDATE_PROJECT_NAME
:: get project name optional parameters
FOR /F "tokens=1,* delims=^|" %%i in ("%projectTypeConfiguration%") do (set "projectNameEndingParameter=%%i")
if ".%projectNameEndingParameter%" == ".projectName" set "projectNameEndingParameter="
if not ".%projectNameEndingParameter%" == "." FOR /F "tokens=1,* delims==" %%i in ("%projectNameEndingParameter%") do (set "projectNameEndingParameter=%%j")
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if not .%1==. (set "projectName=%1" & shift)
if ".%projectNameEndingParameter%" == "." if not .%projectName% == . echo %CB_LINEHEADER%Project name [%projectName%] & goto VALIDATE_PROJECT_NAME
if not ".%projectNameEndingParameter%" == "." if not .%projectName% == . (echo %projectName% | findstr /C:"%projectNameEndingParameter%" >nul 2>nul
	if %ERRORLEVEL% EQU 0 goto VALIDATE_PROJECT_NAME)
if .%projectComponentId%==. set "projectName=my-project%projectNameEndingParameter%"
if not .%projectComponentId%==. set "projectName=%projectComponentId%-project%projectNameEndingParameter%"
set "projectNameProposal=%projectName%" 
:SET_PROJECT_NAME_START
set /p projectName=%CB_LINEHEADER%Please enter project name, e.g. [%projectName%]: 
:VALIDATE_PROJECT_NAME
if ".%projectComponentId%" == "." if ".%projectNameEndingParameter%" == "." goto SET_PROJECT_NAME_END
if not ".%projectComponentId%" == "." echo [%projectName%] | findstr /C:"[%projectComponentId%-" >nul 2>nul
if not ".%projectComponentId%" == "." if %ERRORLEVEL% NEQ 0 ( echo %CB_LINEHEADER%Invalid name it must start with %projectComponentId%-. & goto SET_PROJECT_NAME_START )
if not ".%projectNameEndingParameter%" == "." echo [%projectName%] | findstr /C:"%projectNameEndingParameter%]" >nul 2>nul
if not ".%projectNameEndingParameter%" == "." if %ERRORLEVEL% NEQ 0 ( echo %CB_LINEHEADER%Invalid name it must end with %projectNameEndingParameter%. & goto SET_PROJECT_NAME_START )
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" new-project-validate-name %projectName% 2>nul
if exist "%CB_CUSTOM_SETTING_SCRIPT%" if %ERRORLEVEL% NEQ 0 ( echo %CB_LINEHEADER%Invalid name %projectName% & goto SET_PROJECT_NAME_START )
:SET_PROJECT_NAME_END
if exist %projectName% echo %CB_LINEHEADER%Project %projectName% already exist! & goto SET_PROJECT_NAME_START
::if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Selected project type [%projectType%]/[%projectTypeId%], configurationType: "%projectTypeConfiguration%", configurationParameter: "%projectTypeConfigurationParameter%"

echo "%projectTypeConfiguration%" | findstr /C:"projectRootPackageName" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto SET_PROJECT_PACKAGENAME_END
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if not .%1==. echo %CB_LINEHEADER%Project package name [%1]
if not .%1==. (set "projectRootPackageName=%1" & set "parentProjectRootPackageName=%projectRootPackageName%" & shift & goto VERIFY_PROJECT_PACKAGENAME)
:: ask always
::if not .%projectRootPackageName% == . echo %CB_LINEHEADER%Project package name [%projectRootPackageName%] & goto SET_PROJECT_PACKAGENAME_END
if .%parentProjectRootPackageName% == . set "parentProjectRootPackageName=%projectRootPackageName%"
set "projectRootPackageNameSuggestion="%parentProjectRootPackageName%
if .%projectRootPackageName% == . set projectRootPackageName=my.rootpackage.name
if .%projectRootPackageNameSuggestion% == . set projectRootPackageNameSuggestion=%projectRootPackageName%
:SET_PROJECT_PACKAGENAME_START
if .%projectRootPackageName% == . set "projectRootPackageName=%parentProjectRootPackageName%"
set /p projectRootPackageName=%CB_LINEHEADER%Please enter package name, e.g. [%projectRootPackageNameSuggestion%]: 
:VERIFY_PROJECT_PACKAGENAME
if .%parentProjectRootPackageName% == . cmd /c "exit /b 0"
if not .%parentProjectRootPackageName% == . echo %projectRootPackageName% | findstr /C:%parentProjectRootPackageName% >nul 2>nul
if %ERRORLEVEL% NEQ 0 ( echo %CB_LINEHEADER%Invalid package name %projectRootPackageName% starts not with %parentProjectRootPackageName% & set "projectRootPackageName=" & goto SET_PROJECT_PACKAGENAME_START )
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" new-project-validate-rootpackagename %projectRootPackageName% 2>nul
if exist "%CB_CUSTOM_SETTING_SCRIPT%" if %ERRORLEVEL% NEQ 0 ( echo %CB_LINEHEADER%Invalid package name %projectRootPackageName% & set "projectRootPackageName=" & goto SET_PROJECT_PACKAGENAME_START )
:SET_PROJECT_PACKAGENAME_END

echo "%projectTypeConfiguration%" | findstr /C:"projectGroupId" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto SET_PROJECT_GROUPID_END
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if .%projectGroupId% == . if not .%1==. (set "projectGroupId=%1" & shift)
if not .%projectGroupId% == . echo %CB_LINEHEADER%Project project group id [%projectGroupId%] & goto SET_PROJECT_GROUPID_END
:SET_PROJECT_GROUPID_START
FOR /F "tokens=1,2 delims=-" %%i in ("%projectName%") do ( set "projectGroupId=%%i" )
set /p projectGroupId=%CB_LINEHEADER%Please enter project group id, e.g. [%projectGroupId%]:
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" new-project-validate-groupid %projectGroupId% 2>nul
if exist "%CB_CUSTOM_SETTING_SCRIPT%" if %ERRORLEVEL% NEQ 0 ( echo %CB_LINEHEADER%Invalid group id %projectGroupId%. & goto SET_PROJECT_GROUPID_START )
:SET_PROJECT_GROUPID_END

echo "%projectTypeConfiguration%" | findstr /C:"projectComponentId" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto SET_PROJECT_COMPONENTID_END
if .%projectComponentId% == . if not .%1==. (set "projectComponentId=%1" & shift)
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if not .%projectComponentId% == . echo %CB_LINEHEADER%Project project component id [%projectComponentId%] & goto SET_PROJECT_COMPONENTID_END
:SET_PROJECT_COMPONENTID_START
FOR /F "tokens=1,2 delims=-" %%i in ("%projectName%") do ( set "projectComponentId=%%i" )
set /p projectComponentId=%CB_LINEHEADER%Please enter project component id, e.g. [%projectComponentId%]: 
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" new-project-validate-componentid %projectGroupId% 2>nul
if exist "%CB_CUSTOM_SETTING_SCRIPT%" if %ERRORLEVEL% NEQ 0 ( echo %CB_LINEHEADER%Invalid component id %projectGroupId%. & goto SET_PROJECT_COMPONENTID_START )
:SET_PROJECT_COMPONENTID_END
::if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Selected project type [%projectType%]/[%projectTypeId%], configuration: "%projectTypeConfigurationParameter%"

echo "%projectTypeConfiguration%" | findstr /C:"projectDescription" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto SET_PROJECT_DESCRIPTION_END
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if .%0==. goto SET_PROJECT_DESCRIPTION
set "projectDescription=%1" & shift
:CHECK_PROJECT_DESCRIPTION
if .%1==. goto SET_PROJECT_DESCRIPTION
set "projectDescription=%projectDescription% %1" & shift
goto CHECK_PROJECT_DESCRIPTION
:SET_PROJECT_DESCRIPTION
if not ".%projectDescription%" == "." echo %CB_LINEHEADER%Project project description [%projectDescription%] & goto SET_PROJECT_DESCRIPTION_END
set "projectDescription=The implementation of the %projectName%."
set /p projectDescription=%CB_LINEHEADER%Please enter project description, e.g. [%projectDescription%]: 
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" new-project-validate-description %projectDescription% 2>nul
if exist "%CB_CUSTOM_SETTING_SCRIPT%" if %ERRORLEVEL% NEQ 0 ( echo %CB_LINEHEADER%Invalid description. & set "projectDescription=" & goto SET_PROJECT_DESCRIPTION )
:SET_PROJECT_DESCRIPTION_END

::if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Selected project type [%projectType%]/[%projectTypeId%], configuration: "%projectTypeConfigurationParameter%"
echo "%projectTypeConfiguration%" | findstr /C:"install" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto INSTALL_DEPENDENCY_END
FOR /F "tokens=1,2 delims=^|" %%i in ("%projectTypeConfigurationParameter%") do (set "installPackages=%%i" )
FOR /F "tokens=1,2 delims=^=" %%i in ("%installPackages%") do ( set "installPackages=%%j" )
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if ".%installPackages%" == "." echo %CB_LINEHEADER%Invalid package dependency defined in %CB_PROJECT_CONFIGFILE%: %installPackages% & goto INSTALL_DEPENDENCY_END
echo.
echo %CB_LINE%
echo %CB_LINEHEADER%Check package dependencies...
echo %CB_LINE%
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Check package dependencies: "%installPackages%"
:INSTALL_DEPENDENCY
FOR /F "tokens=1,* delims=," %%i in ("%installPackages%") do ( echo %CB_LINEHEADER%Check package dependency %%i
	cmd /C call %PN_FULL% --silent --install %%i
	set "installPackages=%%j"
	goto INSTALL_DEPENDENCY)
:INSTALL_DEPENDENCY_END
call %PN_FULL% --setenv --silent

if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Set projectName:%projectName% projectRootPackageName:%projectRootPackageName% projectGroupId:%projectGroupId% projectComponentId:%projectComponentId% projectDescription:"%projectDescription%" projectTypeConfiguration:"%projectTypeConfiguration%" projectTypeConfigurationParameter:"%projectTypeConfigurationParameter%"
echo/
echo %CB_LINE%
:PROJECT_WIZARD_INIT_END
if exist %projectName% echo %CB_LINEHEADER%Project %projectName% already exist, abort. & goto PROJECT_WIZARD_ERROR_END
echo %CB_LINEHEADER%Create project %projectName%...

:: init action
echo "%projectTypeConfiguration%" | findstr /C:"initAction" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto INIT_ACTION_END
echo %CB_LINE%
set "INITACTION_CMD_TMP=%CB_TEMP%\cb-initaction-%RANDOM%%RANDOM%.bat"
echo @ECHO OFF>"%INITACTION_CMD_TMP%"
echo call cb --silent --setenv>>"%INITACTION_CMD_TMP%"
powershell -Command "$call=($ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1); Write-Host 'call '$call" >>"%INITACTION_CMD_TMP%"
call :PROJECT_REPLACE_PARAMETERS init %INITACTION_CMD_TMP%
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
echo %CB_LINEHEADER%Initialization...
cmd /C call "%INITACTION_CMD_TMP%"
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not execute init action[%INITACTION_CMD_TMP%]: & type "%INITACTION_CMD_TMP%" & goto PROJECT_WIZARD_ERROR_END
:INIT_ACTION_END
if not ".%INITACTION_CMD_TMP%"=="." if exist "%INITACTION_CMD_TMP%" del /f /q "%INITACTION_CMD_TMP%" 2>nul

:: main action
echo %CB_LINE%
echo "%projectTypeConfiguration%" | findstr /C:"mainAction" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto DEFAULT_MAIN_ACTION
set "MAINACTION_CMD_TMP=%CB_TEMP%\cb-mainaction-%RANDOM%%RANDOM%.bat"
echo @ECHO OFF>"%MAINACTION_CMD_TMP%"
echo call cb --silent --setenv>>"%MAINACTION_CMD_TMP%"
powershell -Command "$call=($ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1); Write-Host 'call '$call" >>"%MAINACTION_CMD_TMP%"
::powershell -Command "$ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1 | Out-File -append -encoding ASCII $Env:MAINACTION_CMD_TMP"
call :PROJECT_REPLACE_PARAMETERS main %MAINACTION_CMD_TMP%
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
cmd /C call "%MAINACTION_CMD_TMP%"
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not execute main action [%MAINACTION_CMD_TMP%]: & type "%MAINACTION_CMD_TMP%" & goto PROJECT_WIZARD_ERROR_END
if not ".%MAINACTION_CMD_TMP%"=="." if exist "%MAINACTION_CMD_TMP%" del /f /q "%MAINACTION_CMD_TMP%" 2>nul
goto MAIN_ACTION_END

:DEFAULT_MAIN_ACTION
:: common gradle build support
mkdir %projectName% 2>nul
echo apply from: "https://raw.githubusercontent.com/toolarium/common-gradle-build/master/gradle/common.gradle" > %projectName%\build.gradle
set "projectStartParameter=--no-daemon"
cd %projectName% >nul 2>nul
::echo call %PN_FULL% %projectStartParameter% "-PprojectType=%projectType%" "-PprojectRootPackageName=%projectRootPackageName%" "-PprojectGroupId=%projectGroupId%" "-PprojectComponentId=%projectComponentId%" "-PprojectDescription="%projectDescription% ""
call %PN_FULL% %projectStartParameter% "-PprojectType=%projectType%" "-PprojectRootPackageName=%projectRootPackageName%" "-PprojectGroupId=%projectGroupId%" "-PprojectComponentId=%projectComponentId%" "-PprojectDescription="%projectDescription% ""
if %ERRORLEVEL% NEQ 0 goto PROJECT_WIZARD_ERROR_END
:MAIN_ACTION_END

:: post action
echo "%projectTypeConfiguration%" | findstr /C:"postAction" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto PREAPRE_POST_ACTION_END
echo %CB_LINE%
set "POSTACTION_CMD_TMP=%CB_TEMP%\cb-postaction-%RANDOM%%RANDOM%.bat"
echo @ECHO OFF>"%POSTACTION_CMD_TMP%"
echo call cb --silent --setenv>>"%POSTACTION_CMD_TMP%"
powershell -Command "$call=($ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1); Write-Host 'call '$call" >>"%POSTACTION_CMD_TMP%"
::powershell -Command "$ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1 | Out-File -append -encoding ASCII $Env:POSTACTION_CMD_TMP"
call :PROJECT_REPLACE_PARAMETERS post %POSTACTION_CMD_TMP%
echo %CB_LINEHEADER%Finishing...
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Execute post action: %POSTACTION_CMD_TMP% & type "%POSTACTION_CMD_TMP%"
CMD /C call "%POSTACTION_CMD_TMP%"
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not execute post action [%POSTACTION_CMD_TMP%]: & type %POSTACTION_CMD_TMP% & goto PROJECT_WIZARD_ERROR_END
if not ".%POSTACTION_CMD_TMP%"=="." if exist "%POSTACTION_CMD_TMP%" del /f /q "%POSTACTION_CMD_TMP%" 2>nul
:PREAPRE_POST_ACTION_END

:PROJECT_WIZARD_END
cd "%BACKUP_CB_WORKING_PATH%" >nul 2>nul
echo %CB_LINE%
exit /b 0

:PROJECT_WIZARD_ERROR_END
if not ".%INITACTION_CMD_TMP%"=="." if exist "%INITACTION_CMD_TMP%" del /f /q "%INITACTION_CMD_TMP%" 2>nul
if not ".%MAINACTION_CMD_TMP%"=="." if exist "%MAINACTION_CMD_TMP%" del /f /q "%MAINACTION_CMD_TMP%" 2>nul
if not ".%POSTACTION_CMD_TMP%"=="." if exist "%POSTACTION_CMD_TMP%" del /f /q "%POSTACTION_CMD_TMP%" 2>nul
cd "%BACKUP_CB_WORKING_PATH%" >nul 2>nul
echo %CB_LINE%
exit /b 1

:PROJECT_REPLACE_PARAMETERS
set "PROJECT_WIZARD_TEMP_FILENAME=%2"
powershell -Command "(Get-Content "$Env:PROJECT_WIZARD_TEMP_FILENAME") -replace '@@projectType@@', "$Env:projectType" | Out-File -encoding ASCII "$Env:PROJECT_WIZARD_TEMP_FILENAME""
powershell -Command "(Get-Content "$Env:PROJECT_WIZARD_TEMP_FILENAME") -replace '@@projectName@@', "$Env:projectName" | Out-File -encoding ASCII "$Env:PROJECT_WIZARD_TEMP_FILENAME""
powershell -Command "(Get-Content "$Env:PROJECT_WIZARD_TEMP_FILENAME") -replace '@@projectRootPackageName@@', "$Env:projectRootPackageName" | Out-File -encoding ASCII "$Env:PROJECT_WIZARD_TEMP_FILENAME""
powershell -Command "(Get-Content "$Env:PROJECT_WIZARD_TEMP_FILENAME") -replace '@@projectGroupId@@', "$Env:projectGroupId" | Out-File -encoding ASCII "$Env:PROJECT_WIZARD_TEMP_FILENAME""
powershell -Command "(Get-Content "$Env:PROJECT_WIZARD_TEMP_FILENAME") -replace '@@projectComponentId@@', "$Env:projectComponentId" | Out-File -encoding ASCII "$Env:PROJECT_WIZARD_TEMP_FILENAME""
powershell -Command "(Get-Content "$Env:PROJECT_WIZARD_TEMP_FILENAME") -replace '@@projectDescription@@', "$Env:projectDescription" | Out-File -encoding ASCII "$Env:PROJECT_WIZARD_TEMP_FILENAME""
powershell -Command "(Get-Content "$Env:PROJECT_WIZARD_TEMP_FILENAME") -replace '@@delete@@', 'cb-deltree' | Out-File -encoding ASCII "$Env:PROJECT_WIZARD_TEMP_FILENAME""
set "nullExpression=nul"
powershell -Command "(Get-Content "$Env:PROJECT_WIZARD_TEMP_FILENAME") -replace '@@logFile@@', "$Env:nullExpression" | Out-File -encoding ASCII "$Env:PROJECT_WIZARD_TEMP_FILENAME""
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Prepared %1 action %PROJECT_WIZARD_TEMP_FILENAME%: & type "%PROJECT_WIZARD_TEMP_FILENAME%"
goto :eof

:PRODUCT_PROJECT_CONFIGFILE
if ".%CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." goto :eof
if not exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types-%1.properties" goto :eof
set "CB_PRODUCT_PROJECT_CONFIGFILE=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types-%1.properties"

:: get file timestamp
for /f "tokens=1,2 delims= " %%i in ('dir /O:D /T:W /A:-D /4 %CB_PRODUCT_PROJECT_CONFIGFILE% 2^>nul ^| findstr /C:project-types-%1.properties 2^>nul') do (set "cbProjectConfigFileTimestamp=%%i %%j")
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp: =%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp::=%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp:.=%"
set "cbProjectConfigFileTimestamp=%cbProjectConfigFileTimestamp:/=%"
if .%cbProjectConfigFileTimestamp%==. set cbProjectConfigFileTimestamp=%RANDOM%%RANDOM%
set "CB_PRODUCT_PROJECT_CONFIGFILE_TMPFILE=%CB_TEMP%\cb-project-types-%1-%cbProjectConfigFileTimestamp%.tmp"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use %1 project types file: %CB_PRODUCT_PROJECT_CONFIGFILE%
if .%CB_VERBOSE% == .true if not exist %CB_PRODUCT_PROJECT_CONFIGFILE_TMPFILE% echo %CB_LINEHEADER%Create %1 project types temp file: %CB_PRODUCT_PROJECT_CONFIGFILE_TMPFILE%
if not exist %CB_PRODUCT_PROJECT_CONFIGFILE_TMPFILE% type "%CB_PRODUCT_PROJECT_CONFIGFILE%" 2>nul | findstr /V "#" | findstr /C:= > "%CB_PRODUCT_PROJECT_CONFIGFILE_TMPFILE%" 2>nul
goto :eof
