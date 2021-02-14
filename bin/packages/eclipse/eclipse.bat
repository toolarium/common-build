@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: eclipse.bat
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


set eclipseFilter=
if not defined CB_ECLIPSE_VERSION set "CB_ECLIPSE_VERSION=2020-06 jee-package"
set "CB_PACKAGE_VERSION=%1"
set "CB_ECLIPSE_PACKAGE_NAME=%2"
if .%CB_PACKAGE_VERSION% == . FOR /F "tokens=1,2 delims= " %%i in ("%CB_ECLIPSE_VERSION%") do ( set "CB_PACKAGE_VERSION=%%i" )
if .%CB_ECLIPSE_PACKAGE_NAME% == . set "CB_ECLIPSE_PACKAGE_NAME=%CB_ECLIPSE_VERSION:* =%"
if .%CB_ECLIPSE_PACKAGE_NAME% == . set "CB_ECLIPSE_PACKAGE_NAME=jee-package"
set "CB_ECLIPSE_INFO_DOWNLOAD_URL=https://api.eclipse.org/download/release/eclipse_packages"

set CB_PACKAGE_BASE_URL=
set CB_PACKAGE_DOWNLOAD_NAME=
set CB_PACKAGE_VERSION_NAME=
set CB_PACKAGE_VERSION_HASH=
set "CB_PACKAGE_NO_DEFAULT=true"

:: get version information
echo %CB_LINEHEADER%Check eclipse %CB_PACKAGE_VERSION% version / %CB_ECLIPSE_PACKAGE_NAME% & echo %CB_LINEHEADER%Check eclipse %CB_PACKAGE_VERSION% version / %CB_ECLIPSE_PACKAGE_NAME%>> "%CB_LOGFILE%"
::set "eclipseFilter=&release_version=%CB_PACKAGE_VERSION%"
set "CB_ECLIPSE_JSON_INFO=%CB_LOGS%\cb-eclipseFile.json"
set "CB_PACKAGE_SILENT_LOG=silent"
set "CB_PACKAGE_USERAGENT=true"
set "CB_PACKAGE_COOKIE=%CB_LOGS%\cb-eclipse-cookiejar"
%CB_BIN%\%CB_WGET_CMD% -O%TMPFILE% %CB_WGET_SECURITY_CREDENTIALS% -q "%CB_ECLIPSE_INFO_DOWNLOAD_URL%?release_name=%CB_PACKAGE_VERSION%%eclipseFilter%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.release_name" > "%CB_ECLIPSE_JSON_INFO%"
set /p CB_PACKAGE_VERSION_NAME= < "%CB_ECLIPSE_JSON_INFO%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.release_version" > "%CB_ECLIPSE_JSON_INFO%"
set /p CB_ECLIPSE_RELEASE_VERSION= < "%CB_ECLIPSE_JSON_INFO%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.packages.$Env:CB_ECLIPSE_PACKAGE_NAME.files.windows.$Env:CB_PROCESSOR_ARCHITECTURE_NUMBER.url" > "%CB_ECLIPSE_JSON_INFO%"
set /p CB_PACKAGE_DOWNLOAD_URL= < "%CB_ECLIPSE_JSON_INFO%"

set "CB_PACKAGE_DOWNLOAD_NAME=%CB_PACKAGE_DOWNLOAD_URL%"
:PREPARE_PACKAGE_NAME
for /f "tokens=1 delims=/" %%G in ("%CB_PACKAGE_DOWNLOAD_NAME%") do (set "CB_PACKAGE_DOWNLOAD_NAME=%CB_PACKAGE_DOWNLOAD_NAME:*/=%")
echo %CB_PACKAGE_DOWNLOAD_NAME% | findstr /C:"/" >NUL && (goto :PREPARE_PACKAGE_NAME) 

set CB_PACKAGE_DEST_VERSION_NAME=eclipse-%CB_PACKAGE_VERSION_NAME%
::echo %CB_ECLIPSE_RELEASE_VERSION%
::echo %CB_PACKAGE_VERSION_NAME%
::echo %CB_PACKAGE_DOWNLOAD_NAME%
::echo %CB_PACKAGE_DOWNLOAD_URL%

del "%CB_ECLIPSE_JSON_INFO%" >nul 2>nul
move %TMPFILE% %CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME%.json >nul 2>nul

set "CB_ECLIPSE_JSON_MIRROR_INFO=%CB_LOGS%\cb-eclipseFile-mirror.html"
set "CB_ECLIPSE_JSON_REDIRECT_INFO=%CB_LOGS%\cb-eclipseFile-redirect.html"
set "CB_PACKAGE_COOKIE=%CB_LOGS%\cb-eclipse-cookiejar"
del "%CB_ECLIPSE_JSON_MIRROR_INFO%" >nul 2>nul
del "%CB_ECLIPSE_JSON_REDIRECT_INFO%" >nul 2>nul
del "%CB_PACKAGE_COOKIE%" >nul 2>nul

:: get mirror id
set "USER_AGENT=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36"
%CB_BIN%\%CB_WGET_CMD% -O%CB_ECLIPSE_JSON_MIRROR_INFO% %CB_WGET_SECURITY_CREDENTIALS% --keep-session-cookies --save-cookies=%CB_PACKAGE_COOKIE% --user-agent "%USER_AGENT%" -q "%CB_PACKAGE_DOWNLOAD_URL%"
:: find proper line
findstr /R /C:"File:" /C:mirror_id= %CB_ECLIPSE_JSON_MIRROR_INFO% | findstr/n ^^ | findstr ^^1: >%CB_ECLIPSE_JSON_INFO%
set "MIRROR_ID="
for /f "tokens=1,2,3,4 delims==" %%G in ('type %CB_ECLIPSE_JSON_INFO%') do (set "MIRROR_ID=%%J")
del "%CB_ECLIPSE_JSON_INFO%" >nul 2>nul
set "MIRROR_ID=%MIRROR_ID:" =/%"
for /f "tokens=1* delims=/" %%G in ("%MIRROR_ID%") do (set "MIRROR_ID=%%G")
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Found mirror id: %MIRROR_ID%
%CB_BIN%\%CB_WGET_CMD% -O%CB_ECLIPSE_JSON_REDIRECT_INFO% %CB_WGET_SECURITY_CREDENTIALS% --keep-session-cookies --load-cookies=%CB_PACKAGE_COOKIE% --user-agent "%USER_AGENT%" -q "%CB_PACKAGE_DOWNLOAD_URL%&mirror_id=%MIRROR_ID%"
:: find proper line
findstr /R /C:"META HTTP-EQUIV=" /C:CONTENT= /C:URL= %CB_ECLIPSE_JSON_REDIRECT_INFO% | findstr/n ^^ | findstr ^^1: >%CB_ECLIPSE_JSON_INFO%
set "CB_PACKAGE_DOWNLOAD_URL="
for /f "tokens=1,2,3,4,5,6,7,8,9,10 delims==" %%A in ('type %CB_ECLIPSE_JSON_INFO%') do (echo "%%J" > %TMPFILE%)
for /f "tokens=1 delims=>" %%N in ('type %TMPFILE%') do (set "CB_PACKAGE_DOWNLOAD_URL=%%N")
del "%CB_ECLIPSE_JSON_INFO%" >nul 2>nul
del "%TMPFILE%" >nul 2>nul
CALL :dequote CB_PACKAGE_DOWNLOAD_URL
if .%CB_VERBOSE% == .true echo %CB_LINEHEADER%Found mirror url: %CB_PACKAGE_DOWNLOAD_URL%
del "%CB_ECLIPSE_JSON_MIRROR_INFO%" >nul 2>nul
del "%CB_ECLIPSE_JSON_REDIRECT_INFO%" >nul 2>nul
del "%CB_PACKAGE_COOKIE%" >nul 2>nul
goto DOWNLOAD_ECLIPSE_END

:DeQuote
for /f "delims=" %%A in ('echo %%%1%%') do set %1=%%~A
goto :eof

:DOWNLOAD_ECLIPSE_END
mkdir "%CB_DEVTOOLS%" 2>nul
mkdir "%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%" 2>nul
mkdir "%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\bin" 2>nul
set "eclipseBin=%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\bin\eclipse.bat"
echo @ECHO OFF> "%eclipseBin%"
echo :: set proper java version>> "%eclipseBin%" 
echo call cb --silent --setenv>> "%eclipseBin%" 
echo start "Eclipse" /B "%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\eclipse\eclipse.exe">> "%eclipseBin%"

:: create proper shortcut
set "ICON_PATH=%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\eclipse\eclipse.exe"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\bin\eclipse.bat --icon %ICON_PATH% "%USERPROFILE%\desktop\Eclipse.lnk""