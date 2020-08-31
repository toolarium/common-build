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
if exist build.gradle echo %CB_LINEHEADER%The current path is inside a project [%CD%], please start outside. & goto PROJECT_WIZARD_ERROR_END
echo %CB_LINEHEADER%Create new project, enter project basic data.
echo %CB_LINE%
set BACKUP_CB_WORKING_PATH=%CB_WORKING_PATH%
set CB_PROJECT_CONFIGFILE=
set CB_PRODUCT_CONFIGFILE=
set CB_PRODUCT_CONFIGFILE_TMPFILE=

if not ".%CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types.properties" set "CB_PROJECT_CONFIGFILE=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types.properties"
if not ".%CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\product-types.properties" set "CB_PRODUCT_CONFIGFILE=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\product-types.properties"

:: default
if ".%CB_PROJECT_CONFIGFILE%"=="." set "CB_PROJECT_CONFIGFILE=%CB_SCRIPT_PATH%\..\conf\project-types.properties"
if ".%CB_PRODUCT_CONFIGFILE%"=="." if exist %CB_SCRIPT_PATH%\..\conf\product-types.properties set "CB_PRODUCT_CONFIGFILE=%CB_SCRIPT_PATH%\..\conf\product-types.properties"

:: if we have a local common gradle build use the project types file
if not .%CB_CUSTOM_RUNTIME_CONFIG_PATH%==. goto VERIFY_PROJECT_CONFIGFILE_END
dir "%USERPROFILE%\.gradle\common-gradle-build" >nul 2>nul
if not %ERRORLEVEL% EQU 0 goto VERIFY_PROJECT_CONFIGFILE_END
set "TMPFILE=%TEMP%\cb-new-project-%RANDOM%%RANDOM%.tmp"
dir /o-D/b "%USERPROFILE%\.gradle\common-gradle-build\???.???.???" | findstr /C:^. 2>nul | findstr/n ^^ | findstr 1:> "%TMPFILE%"
for %%R in ("%TMPFILE%") do if not %%~zR lss 1 set /pcommonGradleBuildVersion=<"%TMPFILE%"
del /f /q "%TMPFILE%" 2>nul
set "commonGradleBuildVersion=%commonGradleBuildVersion:~2%"
if not .%commonGradleBuildVersion%==. set "LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH=%USERPROFILE%\.gradle\common-gradle-build\%commonGradleBuildVersion%\gradle"
if not ".%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types.properties" set "CB_PROJECT_CONFIGFILE=%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\project-types.properties"
if not ".%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%"=="." if exist "%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\product-types.properties" set "CB_PRODUCT_CONFIGFILE=%LOCAL_CB_CUSTOM_RUNTIME_CONFIG_PATH%\conf\product-types.properties"

:VERIFY_PROJECT_CONFIGFILE_END
if not exist "%CB_PROJECT_CONFIGFILE%" (echo %CB_LINE% & echo %CB_LINEHEADER%Missing project types configuration file %CB_PROJECT_CONFIGFILE%, please install with the cb-install.bat. & echo %CB_LINE% & goto PROJECT_WIZARD_ERROR_END)
set "CB_PROJECT_CONFIGFILE_TMPFILE=%TEMP%\cb-project-types-%RANDOM%%RANDOM%.tmp"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use project types file: %CB_PROJECT_CONFIGFILE%
type %CB_PROJECT_CONFIGFILE% 2>nul | findstr /V "#" | findstr /C:= > %CB_PROJECT_CONFIGFILE_TMPFILE% 2>nul

set "productTypeId="
set "productName="
set "projectTypeId="
set "projectType="
set "projectName="
set "projectRootPackageName="
set "projectGroupId="
set "projectComponentId="
set "projectDescription="
	
if .%CB_PRODUCT_CONFIGFILE%==. goto END_PRODUCT_TYPES
if not exist %CB_PRODUCT_CONFIGFILE% goto END_PRODUCT_TYPES
set "CB_PRODUCT_CONFIGFILE_TMPFILE=%TEMP%\cb-product-types-%RANDOM%%RANDOM%.tmp"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Use product types file: %CB_PRODUCT_CONFIGFILE%
type %CB_PRODUCT_CONFIGFILE% 2>nul | findstr /V "#" | findstr /C:= > %CB_PRODUCT_CONFIGFILE_TMPFILE% 2>nul

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
	echo    [!count!] %%i    	!projectTypeName!)
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
if %ERRORLEVEL% NEQ 0 goto SET_PROJECT_NAME_END
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if not .%1==. (set "projectName=%1" & shift)
if not .%projectName% == . echo %CB_LINEHEADER%Project name [%projectName%] & goto SET_PROJECT_NAME_END

if .%projectComponentId%==. set projectName=my-project
if not .%projectComponentId%==. set projectName=%projectComponentId%-project
set /p projectName=%CB_LINEHEADER%Please enter project name, e.g. [%projectName%]: 
:SET_PROJECT_NAME_END
if exist %projectName% echo %CB_LINEHEADER%Project %projectName% already exist! & set "projectName=" & goto END_PROJECT_TYPES
::if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Selected project type [%projectType%]/[%projectTypeId%], configurationType: "%projectTypeConfiguration%", configurationParameter: "%projectTypeConfigurationParameter%"

echo "%projectTypeConfiguration%" | findstr /C:"projectRootPackageName" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto SET_PROJECT_PACKAGENAME_END
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if not .%1==. (set "projectRootPackageName=%1" & shift)
:: ask always
::if not .%projectRootPackageName% == . echo %CB_LINEHEADER%Project package name [%projectRootPackageName%] & goto SET_PROJECT_PACKAGENAME_END
if .%projectRootPackageName% == . set projectRootPackageName=my.rootpackage.name
set /p projectRootPackageName=%CB_LINEHEADER%Please enter package name, e.g. [%projectRootPackageName%]: 
:SET_PROJECT_PACKAGENAME_END

echo "%projectTypeConfiguration%" | findstr /C:"projectGroupId" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto SET_PROJECT_GROUPID_END
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if not .%1==. (set "projectGroupId=%1" & shift)
if not .%projectGroupId% == . echo %CB_LINEHEADER%Project project group id [%projectGroupId%] & goto SET_PROJECT_GROUPID_END
FOR /F "tokens=1,2 delims=-" %%i in ("%projectName%") do ( set "projectGroupId=%%i" )
set /p projectGroupId=%CB_LINEHEADER%Please enter project group id, e.g. [%projectGroupId%]:
:SET_PROJECT_GROUPID_END

echo "%projectTypeConfiguration%" | findstr /C:"projectComponentId" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto SET_PROJECT_COMPONENTID_END
if not .%1==. (set "projectComponentId=%1" & shift)
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
if not .%projectComponentId% == . echo %CB_LINEHEADER%Project project component id [%projectComponentId%] & goto SET_PROJECT_COMPONENTID_END
FOR /F "tokens=1,2 delims=-" %%i in ("%projectName%") do ( set "projectComponentId=%%i" )
set /p projectComponentId=%CB_LINEHEADER%Please enter project component id, e.g. [%projectComponentId%]: 
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

if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Set projectName:%projectName% projectRootPackageName:%projectRootPackageName% projectGroupId:%projectGroupId% projectComponentId:%projectComponentId% projectDescription:"%projectDescription%" projectTypeConfiguration:"%projectTypeConfiguration%" projectTypeConfigurationParameter:"%projectTypeConfigurationParameter%"
echo.
echo %CB_LINE%
:PROJECT_WIZARD_INIT_END
if exist %projectName% echo %CB_LINEHEADER%Project %projectName% already exist, abort. & goto PROJECT_WIZARD_ERROR_END
echo %CB_LINEHEADER%Create project %projectName%...

:: init action
echo "%projectTypeConfiguration%" | findstr /C:"initAction" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto INIT_ACTION_END
echo %CB_LINE%
set "INITACTION_CMD_TMP=%TEMP%\cb-initaction-%RANDOM%%RANDOM%.bat"
echo @ECHO OFF>"%INITACTION_CMD_TMP%"
echo call cb --silent --setenv>>"%INITACTION_CMD_TMP%"
powershell -Command "$call=($ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1); Write-Host 'call '$call" >>"%INITACTION_CMD_TMP%"
call :PROJECT_REPLACE_PARAMETERS init %INITACTION_CMD_TMP%
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
echo %CB_LINEHEADER%Initialization...
cmd /C call %INITACTION_CMD_TMP%
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not execute init action: & type %INITACTION_CMD_TMP% & goto PROJECT_WIZARD_ERROR_END
:INIT_ACTION_END
del /f /q %INITACTION_CMD_TMP% 2>nul

:: main action
echo %CB_LINE%
echo "%projectTypeConfiguration%" | findstr /C:"mainAction" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto DEFAULT_MAIN_ACTION
set "MAINACTION_CMD_TMP=%TEMP%\cb-mainaction-%RANDOM%%RANDOM%.bat"
echo @ECHO OFF>"%MAINACTION_CMD_TMP%"
echo call cb --silent --setenv>>"%MAINACTION_CMD_TMP%"
powershell -Command "$call=($ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1); Write-Host 'call '$call" >>"%MAINACTION_CMD_TMP%"
::powershell -Command "$ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1 | Out-File -append -encoding ASCII $Env:MAINACTION_CMD_TMP"
call :PROJECT_REPLACE_PARAMETERS main %MAINACTION_CMD_TMP%
set "projectTypeConfigurationParameter=%projectTypeConfigurationParameter:*|=%"
cmd /C call %MAINACTION_CMD_TMP%
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not execute main action: & type %MAINACTION_CMD_TMP% & goto PROJECT_WIZARD_ERROR_END
del /f /q %MAINACTION_CMD_TMP% 2>nul
goto MAIN_ACTION_END

:DEFAULT_MAIN_ACTION
:: common gradle build support
mkdir %projectName% 2>nul
echo apply from: "https://git.io/JfDQT" > %projectName%\build.gradle
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
set "POSTACTION_CMD_TMP=%TEMP%\cb-postaction-%RANDOM%%RANDOM%.bat"
echo @ECHO OFF>"%POSTACTION_CMD_TMP%"
echo call cb --silent --setenv>>"%POSTACTION_CMD_TMP%"
powershell -Command "$call=($ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1); Write-Host 'call '$call" >>"%POSTACTION_CMD_TMP%"
::powershell -Command "$ENV:projectTypeConfigurationParameter -split '\|' -split '=' | select-object -skip 1 -first 1 | Out-File -append -encoding ASCII $Env:POSTACTION_CMD_TMP"
call :PROJECT_REPLACE_PARAMETERS post %POSTACTION_CMD_TMP%
echo %CB_LINEHEADER%Finishing...
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Execute post action: %POSTACTION_CMD_TMP% & type %POSTACTION_CMD_TMP%
CMD /C call %POSTACTION_CMD_TMP%
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%Could not execute post action: & type %POSTACTION_CMD_TMP% & goto PROJECT_WIZARD_ERROR_END
del /f /q "%POSTACTION_CMD_TMP%" 2>nul
:PREAPRE_POST_ACTION_END

:PROJECT_WIZARD_END
del %CB_PROJECT_CONFIGFILE_TMPFILE% 2>nul
cd %BACKUP_CB_WORKING_PATH% >nul 2>nul
echo %CB_LINE%
exit /b 0

:PROJECT_WIZARD_ERROR_END
del /f /q %CB_PROJECT_CONFIGFILE_TMPFILE% 2>nul
del /f /q %INITACTION_CMD_TMP% 2>nul
del /f /q %MAINACTION_CMD_TMP% 2>nul
del /f /q %POSTACTION_CMD_TMP% 2>nul
cd %BACKUP_CB_WORKING_PATH% >nul 2>nul
echo %CB_LINE%
exit /b 1

:PROJECT_REPLACE_PARAMETERS
set "PROJECT_WIZARD_TEMP_FILENAME=%2"
powershell -Command "(Get-Content $Env:PROJECT_WIZARD_TEMP_FILENAME) -replace '@@projectType@@', "$Env:projectType" | Out-File -encoding ASCII $Env:PROJECT_WIZARD_TEMP_FILENAME"
powershell -Command "(Get-Content $Env:PROJECT_WIZARD_TEMP_FILENAME) -replace '@@projectName@@', "$Env:projectName" | Out-File -encoding ASCII $Env:PROJECT_WIZARD_TEMP_FILENAME"
powershell -Command "(Get-Content $Env:PROJECT_WIZARD_TEMP_FILENAME) -replace '@@projectRootPackageName@@', "$Env:projectRootPackageName" | Out-File -encoding ASCII $Env:PROJECT_WIZARD_TEMP_FILENAME"
powershell -Command "(Get-Content $Env:PROJECT_WIZARD_TEMP_FILENAME) -replace '@@projectGroupId@@', "$Env:projectGroupId" | Out-File -encoding ASCII $Env:PROJECT_WIZARD_TEMP_FILENAME"
powershell -Command "(Get-Content $Env:PROJECT_WIZARD_TEMP_FILENAME) -replace '@@projectComponentId@@', "$Env:projectComponentId" | Out-File -encoding ASCII $Env:PROJECT_WIZARD_TEMP_FILENAME"
powershell -Command "(Get-Content $Env:PROJECT_WIZARD_TEMP_FILENAME) -replace '@@projectDescription@@', "$Env:projectDescription" | Out-File -encoding ASCII $Env:PROJECT_WIZARD_TEMP_FILENAME"
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Prepared %1 action %PROJECT_WIZARD_TEMP_FILENAME%: & type %PROJECT_WIZARD_TEMP_FILENAME%
goto :eof