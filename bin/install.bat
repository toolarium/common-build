@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: install.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: define defaults
if not defined CB_DEVTOOLS_NAME (set "CB_DEVTOOLS_NAME=devtools")
if not defined CB_DEVTOOLS_DRIVE (set "CB_DEVTOOLS_DRIVE=c:")
if not defined CB_DEVTOOLS (set "CB_DEVTOOLS=%CB_DEVTOOLS_DRIVE%\%CB_DEVTOOLS_NAME%")
if not defined CB_WGET_VERSION (set CB_WGET_VERSION=1.20.3)
if not defined CB_WGET_DOWNLOAD_URL (set CB_WGET_DOWNLOAD_URL=https://eternallybored.org/misc/wget/)

:: define parameters
set CB_LINE=----------------------------------------------------------------------------------------
set PN=%~nx0
set "CB_CURRENT_PATH=%CD%"
set "CB_SCRIPT_PATH=%~dp0"
set "CB_SCRIPT_DRIVE=%~d0"

SET CB_PROCESSOR_ARCHITECTURE_NUMBER=64
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:32=%" SET CB_PROCESSOR_ARCHITECTURE_NUMBER=32
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:64=%" SET CB_PROCESSOR_ARCHITECTURE_NUMBER=64

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%" & set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "DATESTAMP=%YYYY%%MM%%DD%" & set "TIMESTAMP=%HH%%Min%%Sec%" & set "FULLTIMESTAMP=%DATESTAMP%-%TIMESTAMP%"
set "USER_FRIENDLY_DATESTAMP=%DD%.%MM%.%YYYY%" & set "USER_FRIENDLY_TIMESTAMP=%HH%:%Min%:%Sec%" 
set "USER_FRIENDLY_FULLTIMESTAMP=%USER_FRIENDLY_DATESTAMP% %USER_FRIENDLY_TIMESTAMP%"

echo %CB_LINE%
echo.
echo Started common-build installation on %COMPUTERNAME%, %USER_FRIENDLY_FULLTIMESTAMP%
echo -Use %CB_DEVTOOLS% path as devtools folder
echo.
echo %CB_LINE%
pause

:: check connection
ping 8.8.8.8 -n 1 -w 1000
if errorlevel 1 (echo %CB_LINE% & echo "-No internet connection detected!" & echo %CB_LINE% & goto END)

:: get the list of release from GitHub
echo -Check newest version of common-build...
powershell -Command "$releases = Invoke-RestMethod -Headers $githubHeader -Uri "https://api.github.com/repos/toolarium/common-build/releases" | Select-Object -First 1; Split-Path -Path $releases.zipball_url -Leaf" > "%cbTemp%"
set cbTemp=%TEMP%\cb-temp.txt
set /pCB_REMOTE_VERSION=<%cbTemp%
set CB_REMOTE_VERSION=%CB_REMOTE_VERSION:~1%
powershell -Command "$releases = Invoke-RestMethod -Headers $githubHeader -Uri "https://api.github.com/repos/toolarium/common-build/releases" | Select-Object -First 1; Write-Output $releases.zipball_url" > "%cbTemp%"
set /pCB_DOWNLOAD_VERSION_URL=<%cbTemp%
del %cbTemp% 2>nul

:: in case of no release, give up
if .%CB_REMOTE_VERSION%==. (echo %CB_LINE% & echo Could not found any common-build version! & echo %CB_LINE% & goto END)
set CB_VERSION_NAME="common-build-%CB_REMOTE_VERSION%"

:: create directories
if not exist %CB_DEVTOOLS% mkdir %CB_DEVTOOLS% >nul 2>nul
set "CB_DEV_REPOSITORY=%CB_DEVTOOLS%\.repository" 
if not exist %CB_DEV_REPOSITORY% mkdir %CB_DEV_REPOSITORY% >nul 2>nul

:: download common-build
if exist %CB_DEV_REPOSITORY%\%CB_VERSION_NAME% goto DOWNLOAD_CB_END
echo -Install %CB_VERSION_NAME%
powershell -Command "iwr $start_time = Get-Date;Invoke-WebRequest -Uri '%pCB_DOWNLOAD_VERSION_URL%' -OutFile '%CB_DEV_REPOSITORY%\%CB_VERSION_NAME%';Write-Output 'Time taken: $((Get-Date).Subtract($start_time).Seconds) seconds' 2>nul | iex 2>nul" 2>nul
:DOWNLOAD_CB_END

if exist %CB_DEVTOOLS%\%CB_VERSION_NAME% goto EXTRACT_CB_END
echo -Extract %CB_VERSION_NAME% in %CB_DEVTOOLS%... 
FOR /F %%i IN ('dir %CB_DEV_REPOSITORY%\%CB_VERSION_NAME% /b/s') DO (
	if not exist %%i echo -Extract package %%i>> "%CB_LOGFILE%" & powershell -command "Expand-Archive -Force '%%i' '%CB_DEVTOOLS%'")

:: download wget -> https://eternallybored.org/misc/wget/1.20.3/64/wget.exe
set CB_WGET_CMD=wget.exe
WHERE %CB_WGET_CMD% >nul 2>nul
if not %ERRORLEVEL% NEQ 0 goto DOWNLOAD_WGET_END
set "CB_WGET_PACKAGE_URL=%CB_WGET_DOWNLOAD_URL%/%CB_WGET_VERSION%/%CB_PROCESSOR_ARCHITECTURE_NUMBER%/%CB_WGET_CMD%"

if not exist %CB_HOME% mkdir %CB_HOME% >nul 2>nul
set "CB_BIN=%CB_HOME%\bin" 
if not exist %CB_BIN% mkdir %CB_BIN% >nul 2>nul
set "CB_LOGS=%CB_HOME%\logs" 
if not exist %CB_LOGS% mkdir %CB_LOGS% >nul 2>nul
echo -Install %CB_BIN%\%CB_WGET_CMD%
powershell -Command "iwr $start_time = Get-Date;Invoke-WebRequest -Uri '%CB_WGET_PACKAGE_URL%' -OutFile '%CB_BIN%\%CB_WGET_CMD%';Write-Output 'Time taken: $((Get-Date).Subtract($start_time).Seconds) seconds' 2>nul | iex 2>nul" 2>nul
:DOWNLOAD_WGET_END
	
echo -Set CB_HOME to %DEVTOOLS%\%CB_VERSION_NAME%
setx CB_HOME "%DEVTOOLS%\%CB_VERSION_NAME%" >nul 2>nul
:EXTRACT_CB_END

:: add to path
set "SystemPath=" & set "UserPath="
for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "Path" 2^>nul') do (if /I "%%N" == "Path" (set "SystemPath=%%P" & goto GET_USER_PATH_FROM_REGISTRY))
:GET_USER_PATH_FROM_REGISTRY
for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKCU\Environment" /v "Path" 2^>nul') do (if /I "%%N" == "Path" (set "UserPath=%%P" & goto GET_USER_PATH_FROM_REGISTRY_END))
:GET_USER_PATH_FROM_REGISTRY_END
if /I [%CB_DEVTOOLS_DRIVE%] NEQ [%CB_SCRIPT_DRIVE%] (%CB_DEVTOOLS_DRIVE%)
cd %CB_LOGS%
WHERE cb >nul 2>nul
if %ERRORLEVEL% NEQ 0 (echo -Set %%CB_HOME%% to path. & setx PATH "%CB_BIN%;%UserPath%" >nul 2>nul)
set "PATH=%CB_BIN%;%PATH%"
if /I [%CB_DEVTOOLS_DRIVE%] NEQ [%CB_SCRIPT_DRIVE%] (%CB_SCRIPT_DRIVE%)
cd %CB_CURRENT_PATH%

echo.
echo %CB_LINE%
echo.
echo Successfully installed common-build %CB_REMOTE_VERSION% in %CB_HOME%. The user %%PATH%% is 
echo already extended and you can start working with it with the command cb!
echo.
echo %CB_LINE%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
