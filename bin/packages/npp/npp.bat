@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: npp.bat
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


if not defined CB_GRADLE_VERSION set "CB_NPP_VERSION=8.6"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_NPP_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v%CB_PACKAGE_VERSION%/npp.%CB_PACKAGE_VERSION%.portable.x64.zip"
::https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.9/npp.8.4.9.portable.zip
::https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.9/npp.8.4.9.portable.x64.zip

set "CB_PACKAGE_DOWNLOAD_NAME=npp.%CB_PACKAGE_VERSION%.portable.x64.zip"
::set "CB_PACKAGE_VERSION_NAME=npp-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=npp-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_NO_DEFAULT=true"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\notepad++.exe --icon %CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\notepad++.exe "%USERPROFILE%\desktop\Notepad++.lnk""