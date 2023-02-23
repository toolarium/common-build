@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: jmeter.bat
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


if not defined CB_JMETER_VERSION set "CB_JMETER_VERSION=5.5"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_JMETER_VERSION%"
set "CB_PACKAGE_BASE_URL=https://downloads.apache.org/jmeter/binaries"
set "CB_PACKAGE_DOWNLOAD_NAME=apache-jmeter-%CB_PACKAGE_VERSION%.zip"
set "CB_PACKAGE_VERSION_NAME=apache-jmeter-%CB_PACKAGE_VERSION%"

mkdir "%CB_DEVTOOLS%" 2>nul
mkdir "%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%" 2>nul
mkdir "%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\bin" 2>nul
set "jmeterBin=%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\bin\jmeterCB.bat"
echo @ECHO OFF> "%jmeterBin%"
echo :: set proper java version>> "%jmeterBin%" 
echo call cb --silent --setenv>> "%jmeterBin%" 
echo cd /D %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\bin>> "%jmeterBin%" 
echo set HEAP=-Xms1g -Xmx1g -XX:MaxMetaspaceSize=256m>> "%jmeterBin%" 
echo set JM_START=start "JMeter">> "%jmeterBin%" 
echo set JM_LAUNCH=javaw.exe>> "%jmeterBin%" 
echo call "%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\bin\jmeter.bat">> "%jmeterBin%"

:: create proper shortcut
set "ICON_PATH=%CB_BIN%\packages\jmeter\jmeter.ico"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\bin\jmeterCB.bat --icon %ICON_PATH% "%USERPROFILE%\desktop\JMeter.lnk""