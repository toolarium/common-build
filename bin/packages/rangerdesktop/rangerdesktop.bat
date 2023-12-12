@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: rangerdesktop.bat
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

if not defined CB_RANGER_VERSION set "CB_RANGER_VERSION=1.11.1"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_RANGER_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/rancher-sandbox/rancher-desktop/releases/download/v%CB_PACKAGE_VERSION%/"
set "CB_PACKAGE_DOWNLOAD_NAME=Rancher.Desktop.Setup.%CB_PACKAGE_VERSION%.msi"
set "CB_PACKAGE_VERSION_NAME=Rancher.Desktop.Setup.%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_NO_DEFAULT=true"

call %CB_HOME%\bin\cb-deltree "%CB_DEVTOOLS%\ranger"
call %CB_HOME%\bin\cb-deltree "%CB_DEVTOOLS%\ranger-%CB_PACKAGE_VERSION%"
set "CB_POST_INSTALL_ACTION=move /y %CB_DEVTOOLS%\ranger %CB_DEVTOOLS%\ranger-%CB_PACKAGE_VERSION% >nul 2>nul"
::if .%CB_INSTALL_OVERWRITE_DIST%==.false if exist "%ProgramFiles%"\Docker\Docker\resources\bin\docker.exe set "CB_PACKAGE_ALREADY_EXIST=true"
::set "CB_POST_INSTALL_ACTION=copy "c:\ProgramData\Microsoft\Windows\Start Menu\Docker Desktop.lnk" "%USERPROFILE%\desktop\" >nul 2>nul"
