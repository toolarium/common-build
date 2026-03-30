@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: mucommander.bat
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


if not defined CB_MUCOMMANDER_VERSION set "CB_MUCOMMANDER_VERSION=1.6.0-1"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_MUCOMMANDER_VERSION%"

set "CB_PACKAGE_BASE_URL=https://github.com/mucommander/mucommander/releases/download/%CB_PACKAGE_VERSION%/"
set "CB_PACKAGE_DOWNLOAD_NAME=mucommander-%CB_PACKAGE_VERSION%-portable-x86_64.zip"
set "CB_PACKAGE_VERSION_NAME=mucommander-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=mucommander-%CB_PACKAGE_VERSION%"

mkdir "%CB_DEVTOOLS%" 2>nul
mkdir "%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%" 2>nul
set "mucommanderBin=%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\mucommander.bat"
echo @ECHO OFF> "%mucommanderBin%"
echo :: set proper java version>> "%mucommanderBin%" 
echo call cb --silent --setenv^>nul>> "%mucommanderBin%" 
echo cd /D %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%>> "%mucommanderBin%" 
::echo set HEAP=-Xms1g -Xmx1g -XX:MaxMetaspaceSize=256m>> "%mucommanderBin%" 
::echo set JM_START=start "mucommander">> "%mucommanderBin%" 
echo for /f "delims=" %%%%f in ('dir /b mucommander-*.jar') do set JAR_NAME=%%%%~nxf>> "%mucommanderBin%"
echo start javaw -jar %%JAR_NAME%% ^>nul 2^>nulcd>> "%mucommanderBin%"

:: create proper shortcut
set "ICON_PATH=%CB_BIN%\packages\mucommander\mucommander.ico"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\mucommander.bat --icon %ICON_PATH% "%USERPROFILE%\desktop\mucommander.lnk""