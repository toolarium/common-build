@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-install.bat
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


:: define defaults
setlocal EnableDelayedExpansion
if .%CB_DEVTOOLS_NAME%==. set "CB_DEVTOOLS_NAME=devtools"
if .%CB_DEVTOOLS_DRIVE%==.  set "CB_DEVTOOLS_DRIVE=c:"
if .%CB_DEVTOOLS%==. set "CB_DEVTOOLS=%CB_DEVTOOLS_DRIVE%\%CB_DEVTOOLS_NAME%"
if .%CB_WGET_VERSION%==. set "CB_WGET_VERSION=1.20.3"
if .%CB_WGET_DOWNLOAD_URL%==. set "CB_WGET_DOWNLOAD_URL=https://eternallybored.org/misc/wget/"
if .%CB_UNZIP_DOWNLOAD_URL%==. set "CB_UNZIP_DOWNLOAD_URL=http://stahlworks.com/dev/"
if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb"
if not exist %CB_TEMP% mkdir "%CB_TEMP%" >nul 2>nul


:: define parameters
set "CB_LINEHEADER=.: "
set CB_LINE=----------------------------------------------------------------------------------------
set PN=%~nx0
set "CB_WORKING_PATH=%CD%"
set "CB_USER_DRIVE=%CD:~0,2%"
set "CB_SCRIPT_PATH=%~dp0"
set "CB_SCRIPT_DRIVE=%~d0"
set CB_FORCE_INSALL=false
set "CB_INSTALLER_VERSION=0.9.3"
set "CB_RELEASE_URL=https://api.github.com/repos/toolarium/common-build/releases"

title %PN%
SET CB_PROCESSOR_ARCHITECTURE_NUMBER=64
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:32=%" SET CB_PROCESSOR_ARCHITECTURE_NUMBER=32
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:64=%" SET CB_PROCESSOR_ARCHITECTURE_NUMBER=64

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%" & set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "DATESTAMP=%YYYY%%MM%%DD%" & set "TIMESTAMP=%HH%%Min%%Sec%" & set "FULLTIMESTAMP=%DATESTAMP%-%TIMESTAMP%"
set "USER_FRIENDLY_DATESTAMP=%DD%.%MM%.%YYYY%" & set "USER_FRIENDLY_TIMESTAMP=%HH%:%Min%:%Sec%"
set "USER_FRIENDLY_FULLTIMESTAMP=%USER_FRIENDLY_DATESTAMP% %USER_FRIENDLY_TIMESTAMP%"
set "CB_INSTALL_ONLY_STABLE=true"
set CB_VERSION=
set "CB_INSTALLER_SILENT=false"


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if %0X==X goto COMMON_BUILD_INSTALL
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.-v goto VERSION
if .%1==.--version goto VERSION
if .%1==.--silent set "CB_INSTALLER_SILENT=true" & shift
if .%1==.--force set "CB_FORCE_INSALL=true" & shift
if .%1==.--draft set CB_INSTALL_ONLY_STABLE=false & shift
if .%1==.--force set "CB_FORCE_INSALL=true" & shift
if .%1==.--silent set "CB_INSTALLER_SILENT=true" & shift
set "CB_VERSION=%CB_VERSION% %1"
shift
goto CHECK_PARAMETER


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo toolarium common build installer %CB_INSTALLER_VERSION%
echo %CB_LINE%
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COMMON_BUILD_INSTALL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_VERSION=%CB_VERSION: =%"
if [%CB_INSTALLER_SILENT%] equ [false] (
	echo %CB_LINE%
	if not .%CB_VERSION% == . echo %CB_LINEHEADER%Thank you for installing toolarium-common-build %CB_VERSION% on %COMPUTERNAME%
	if .%CB_VERSION% == . echo %CB_LINEHEADER%Thank you for installing toolarium-common-build on %COMPUTERNAME%
	echo %CB_LINEHEADER%Use %CB_DEVTOOLS% path as devtools folder, %USER_FRIENDLY_FULLTIMESTAMP%
	echo %CB_LINE%
	pause
	echo.)

:: check connection
ping 8.8.8.8 -n 1 -w 1000 >nul 2>nul
if errorlevel 1 (set "ERROR_INFO=No internet connection detected." & goto INSTALL_FAILED)

:: get the list of release from GitHub
set CB_REMOTE_VERSION= & set CB_DOWNLOAD_VERSION_URL= & set ERROR_DETAIL_INFO= & set ERROR_INFO=
set cbInfoTemp=%CB_TEMP%\toolarium-common-build_info%RANDOM%%RANDOM%.txt & set cbErrorTemp=%CB_TEMP%\toolarium-common-build_error%RANDOM%%RANDOM%.txt
del /f /q %cbInfoTemp% 2>nul & del /f /q %cbErrorTemp% 2>nul

if [%CB_INSTALLER_SILENT%] equ [false] (if .%CB_VERSION% == . echo %CB_LINEHEADER%Check newest version of toolarium-common-build...
	if not .%CB_VERSION% == . echo %CB_LINEHEADER%Check version %CB_VERSION% of toolarium-common-build...)

if not .%CB_VERSION% == . set "CB_VERSION=v%CB_VERSION%"
if not .%CB_VERSION% == . powershell -Command "[Net.ServicePointManager]::SecurityProtocol = \"tls12, tls11, tls\" ; $releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_RELEASE_URL%"; $releases | ? { $_.name -eq $Env:CB_VERSION } | Select-Object -Property name |  select-object -First 1 -ExpandProperty name" 2>%cbErrorTemp% > %cbInfoTemp%
if not .%CB_VERSION% == . goto VERIFY_VERSION
if .%CB_INSTALL_ONLY_STABLE% == .true powershell -Command "[Net.ServicePointManager]::SecurityProtocol = \"tls12, tls11, tls\" ; $releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_RELEASE_URL%"; $releases | ? { $_.prerelease -ne 'false' } | Select-Object -Property name |  select-object -First 1 -ExpandProperty name" 2>%cbErrorTemp% > %cbInfoTemp%
if .%CB_INSTALL_ONLY_STABLE% == .false powershell -Command "[Net.ServicePointManager]::SecurityProtocol = \"tls12, tls11, tls\" ; $releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_RELEASE_URL%" | Select-Object -First 1; Split-Path -Path $releases.zipball_url -Leaf" 2>%cbErrorTemp% > %cbInfoTemp%
:VERIFY_VERSION
if exist %cbInfoTemp% (set /pCB_REMOTE_VERSION=<%cbInfoTemp%)
if .%CB_REMOTE_VERSION%==. set "ERROR_INFO=Could not get remote release information." & goto INSTALL_FAILED
set CB_REMOTE_VERSION=%CB_REMOTE_VERSION:~1%
set "CB_VERSION=v%CB_REMOTE_VERSION%"
if [%CB_INSTALLER_SILENT%] equ [false] (echo %CB_LINEHEADER%Download common-build %CB_REMOTE_VERSION%...)
del /f /q %cbInfoTemp% 2>nul & del /f /q %cbErrorTemp% 2>nul
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = \"tls12, tls11, tls\" ; $releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_RELEASE_URL%"; $releases | ? { $_.name -eq $Env:CB_VERSION } | Select-Object -Property zipball_url |  select-object -First 1 -ExpandProperty zipball_url" 2>%cbErrorTemp% > %cbInfoTemp%
::powershell -Command "$releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_RELEASE_URL%" | Select-Object -First 1; Write-Output $releases.zipball_url" 2>%cbErrorTemp% > %cbInfoTemp%
if exist %cbInfoTemp% (set /pCB_DOWNLOAD_VERSION_URL=<%cbInfoTemp%)
if .%CB_DOWNLOAD_VERSION_URL%==. set "ERROR_INFO=Could not get download url of verison %CB_REMOTE_VERSION%." & goto INSTALL_FAILED
del /f /q %cbInfoTemp% 2>nul & del /f /q %cbErrorTemp% 2>nul
set "CB_VERSION_NAME=toolarium-common-build-%CB_REMOTE_VERSION%"

:: create directories
if not exist %CB_DEVTOOLS% mkdir %CB_DEVTOOLS% >nul 2>nul & echo %CB_LINEHEADER%Create directory %CB_DEVTOOLS%
set "CB_DEV_REPOSITORY=%CB_DEVTOOLS%\.repository"
if not exist %CB_DEV_REPOSITORY% mkdir %CB_DEV_REPOSITORY% >nul 2>nul

:: download toolarium-common-build
if .%CB_FORCE_INSALL%==.true (del /f /q %CB_DEV_REPOSITORY%\%CB_VERSION_NAME%.zip 2>nul)

if [%CB_INSTALLER_SILENT%] equ [false] (if exist %CB_DEV_REPOSITORY%\%CB_VERSION_NAME%.zip echo %CB_LINEHEADER%Found already downloaded version, %CB_DEV_REPOSITORY%\%CB_VERSION_NAME%.zip & goto DOWNLOAD_CB_END)
if [%CB_INSTALLER_SILENT%] equ [false] echo %CB_LINEHEADER%Install %CB_VERSION_NAME%
powershell -Command "iwr $start_time = Get-Date; [Net.ServicePointManager]::SecurityProtocol = \"tls12, tls11, tls\" ; Invoke-WebRequest -Uri '%CB_DOWNLOAD_VERSION_URL%' -OutFile '%CB_DEV_REPOSITORY%\%CB_VERSION_NAME%.zip';Write-Output 'Time taken: $((Get-Date).Subtract($start_time).Seconds) seconds' 2>nul | iex 2>nul" 2>nul
:: in case we donwload a new version we also extract new
if .%CB_FORCE_INSALL%==.true (del /f /q /s %CB_DEVTOOLS%\%CB_VERSION_NAME%\*.* >nul 2>nul & rmdir /q /s %CB_DEVTOOLS%\%CB_VERSION_NAME%\ >nul 2>nul)
:DOWNLOAD_CB_END

if exist %CB_DEVTOOLS%\%CB_VERSION_NAME% goto EXTRACT_CB_END
if [%CB_INSTALLER_SILENT%] equ [false] echo %CB_LINEHEADER%Extract %CB_VERSION_NAME%.zip in %CB_DEVTOOLS%...
if /I [%CB_DEVTOOLS_DRIVE%] NEQ [%CB_USER_DRIVE%] (%CB_DEVTOOLS_DRIVE%)
powershell -command "Expand-Archive -Force %CB_DEV_REPOSITORY%\%CB_VERSION_NAME%.zip %CB_DEV_REPOSITORY%"
move %CB_DEV_REPOSITORY%\toolarium-common-build-???????? %CB_DEVTOOLS%\%CB_VERSION_NAME% >nul
if /I [%CB_DEVTOOLS_DRIVE%] NEQ [%CB_USER_DRIVE%] (%CB_USER_DRIVE%)

:: remove unecessary files
del /f /q %CB_DEVTOOLS%\%CB_VERSION_NAME%\.gitattributes 2>nul
del /f /q %CB_DEVTOOLS%\%CB_VERSION_NAME%\.gitignore 2>nul
del /f /q %CB_DEVTOOLS%\%CB_VERSION_NAME%\README.md 2>nul
call %CB_DEVTOOLS%\%CB_VERSION_NAME%\bin\cb-deltree "%CB_DEVTOOLS%\%CB_VERSION_NAME%\.git" 2>nul
call %CB_DEVTOOLS%\%CB_VERSION_NAME%\bin\cb-deltree "%CB_DEVTOOLS%\%CB_VERSION_NAME%\.github" 2>nul
call %CB_DEVTOOLS%\%CB_VERSION_NAME%\bin\cb-deltree "%CB_DEVTOOLS%\%CB_VERSION_NAME%\docs" 2>nul
call %CB_DEVTOOLS%\%CB_VERSION_NAME%\bin\cb-deltree "%CB_DEVTOOLS%\%CB_VERSION_NAME%\testdata" 2>nul
call %CB_DEVTOOLS%\%CB_VERSION_NAME%\bin\cb-deltree "%CB_DEVTOOLS%\%CB_VERSION_NAME%\bin\testing" 2>nul
:EXTRACT_CB_END

:: read previous version
set "CB_HOME_PREVIOUS="
set "CB_PREVIOUS_VERSION_NAME="
if not defined CB_HOME goto READ_PREVIOUS_VERSION_END
if not exist %CB_HOME% goto READ_PREVIOUS_VERSION_END
where cb >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto READ_PREVIOUS_VERSION_END
set "CB_HOME_PREVIOUS=%CB_HOME%"
for /f "tokens=4" %%i in ('cb --version 2^>nul^|findstr /C:toolarium 2^>nul') do ( set "CB_PREVIOUS_VERSION_NAME=%%i" )
if .%CB_PREVIOUS_VERSION_NAME%==. goto READ_PREVIOUS_VERSION_END
if not .%CB_PREVIOUS_VERSION_NAME%==. if [%CB_INSTALLER_SILENT%] equ [false] echo %CB_LINEHEADER%Found previous version %CB_PREVIOUS_VERSION_NAME%: %CB_HOME_PREVIOUS%
if [%CB_HOME%] equ [%CB_DEVTOOLS%\%CB_VERSION_NAME%] goto SET_CBHOME_END

:READ_PREVIOUS_VERSION_END
if [%CB_INSTALLER_SILENT%] equ [false] echo %CB_LINEHEADER%Set CB_HOME to %CB_DEVTOOLS%\%CB_VERSION_NAME%
set "CB_HOME=%CB_DEVTOOLS%\%CB_VERSION_NAME%"
setx CB_HOME "%CB_DEVTOOLS%\%CB_VERSION_NAME%" >nul 2>nul

:: take over symbol link and config
if not defined CB_HOME_PREVIOUS goto SET_CBHOME_END
if exist %CB_HOME%\bin\cb-copysymlink.bat if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Copy symbolic link...
if exist %CB_HOME%\bin\cb-copysymlink.bat call %CB_HOME%\bin\cb-copysymlink.bat --silent %CB_HOME_PREVIOUS%\current %CB_HOME%\current
if exist %CB_HOME_PREVIOUS%\conf\tool-version-installed.properties if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Copy tool-version-installed.properties...
if exist %CB_HOME_PREVIOUS%\conf\tool-version-installed.properties copy %CB_HOME_PREVIOUS%\conf\tool-version-installed.properties %CB_HOME%\conf\tool-version-installed.properties >nul 2>nul
:SET_CBHOME_END

:: upate path
if [%CB_PREVIOUS_VERSION_NAME%] equ [%CB_VERSION_NAME%] goto SET_PATH_END
:: read user path and cleanup
set USER_PATH=
if exist %CB_HOME%\bin\cb-cleanpath.bat call %CB_HOME%\bin\cb-cleanpath.bat --user toolarium 2>nul
if [%CB_INSTALLER_SILENT%] equ [false] echo %CB_LINEHEADER%Update CB_HOME in the user PATH environment
setx PATH "%CB_HOME%\bin;%USER_PATH%" >nul 2>nul
::call %CB_HOME%\bin\cb-cleanpath.bat --system toolarium
::setx -m PATH "%SYSTEM_PATH%" >nul 2>nul
:SET_PATH_END
set "PATH=%CB_HOME%\bin;%PATH%"
set "CB_BIN=%CB_HOME%\bin"
if not exist %CB_BIN% (mkdir %CB_BIN% >nul 2>nul)
set "CB_LOGS=%CB_HOME%\logs"
if not exist %CB_LOGS% (mkdir %CB_LOGS% >nul 2>nul)
set "CB_CURRENT_PATH=%CB_HOME%\current"
if not exist %CB_CURRENT_PATH% (mkdir %CB_CURRENT_PATH% >nul 2>nul)

:: download wget -> https://eternallybored.org/misc/wget/1.20.3/64/wget.exe
set CB_WGET_CMD=wget.exe
if exist %CB_BIN%\%CB_WGET_CMD% goto DOWNLOAD_WGET_END
set "CB_WGET_PACKAGE_URL=%CB_WGET_DOWNLOAD_URL%/%CB_WGET_VERSION%/%CB_PROCESSOR_ARCHITECTURE_NUMBER%/%CB_WGET_CMD%"
if [%CB_INSTALLER_SILENT%] equ [false] echo %CB_LINEHEADER%Install %CB_BIN%\%CB_WGET_CMD%
powershell -Command "iwr $start_time = Get-Date; [Net.ServicePointManager]::SecurityProtocol = \"tls12, tls11, tls\" ; Invoke-WebRequest -Uri '%CB_WGET_PACKAGE_URL%' -OutFile %CB_BIN%\%CB_WGET_CMD%;Write-Output 'Time taken: $((Get-Date).Subtract($start_time).Seconds) seconds' 2>nul | iex 2>nul" 2>nul
if exist %CB_BIN%\%CB_WGET_CMD% goto DOWNLOAD_WGET_END
set "ERROR_INFO=Could not download %CB_WGET_CMD% from %CB_WGET_DOWNLOAD_URL%"
goto INSTALL_FAILED
:DOWNLOAD_WGET_END

set CB_UNZIP_CMD=unzip.exe
if exist %CB_BIN%\%CB_UNZIP_CMD% goto DOWNLOAD_UNZIP_END
set "CB_UNZIP_PACKAGE_URL=%CB_UNZIP_DOWNLOAD_URL%/%CB_UNZIP_CMD%"
if [%CB_INSTALLER_SILENT%] equ [false] echo %CB_LINEHEADER%Install %CB_BIN%\%CB_UNZIP_CMD%
powershell -Command "iwr $start_time = Get-Date;Invoke-WebRequest -Uri '%CB_UNZIP_PACKAGE_URL%' -OutFile %CB_BIN%\%CB_UNZIP_CMD%;Write-Output 'Time taken: $((Get-Date).Subtract($start_time).Seconds) seconds' 2>nul | iex 2>nul" 2>nul
if exist %CB_BIN%\%CB_UNZIP_CMD% goto DOWNLOAD_UNZIP_END
set "ERROR_INFO=Could not download %CB_UNZIP_CMD% from %CB_UNZIP_PACKAGE_URL%"
goto INSTALL_FAILED
:DOWNLOAD_UNZIP_END
goto INSTALL_SUCCESSFULL_END

:INSTALL_FAILED
if [%CB_INSTALLER_SILENT%] equ [false] (echo.)
echo %CB_LINE%
echo Failed installation: %ERROR_INFO%
if exist %cbErrorTemp% (echo. & type %cbErrorTemp%)
echo %CB_LINE%
goto END

:INSTALL_SUCCESSFULL_END
if [%CB_INSTALLER_SILENT%] equ [false] (
	echo %CB_LINEHEADER%Successfully installed toolarium-common-build v%CB_REMOTE_VERSION%.
	echo %CB_LINEHEADER%The %%PATH%% is extended and you can start working with the command cb. 	
	echo.
	if exist %CB_HOME%\bin\include\how-to.bat pause & call %CB_HOME%\bin\include\how-to.bat 2>nul | more)
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - toolarium common build installer v%CB_INSTALLER_VERSION%
echo usage: %PN% [OPTION]
echo.
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  -v, --version        Print the version information.
echo  --silent             Suppress the console output.
echo  --force              Force to reinstall the common-build.
echo  --draft              Also considers draft / pre-release versions.
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
del /f /q %cbInfoTemp% 2>nul
del /f /q %cbErrorTemp% 2>nul

title %CD%
endlocal & (
  set "CB_HOME=%CB_HOME%"
  set "PATH=%PATH%")
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
