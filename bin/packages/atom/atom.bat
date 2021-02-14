@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: atom.bat
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

if not defined CB_ATOM_VERSION set "CB_ATOM_VERSION=1.50.0"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_ATOM_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/atom/atom/releases/download/v%CB_PACKAGE_VERSION%/"
set "CB_PACKAGE_DOWNLOAD_NAME=atom-windows.zip"
set "CB_PACKAGE_VERSION_NAME=atom-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=atom-%CB_PACKAGE_VERSION%"


:: create proper shortcut
set "ICON_PATH=%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\Atom\atom.exe"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\Atom\atom.exe --icon %ICON_PATH% "%USERPROFILE%\desktop\Atom.lnk""