@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: docker.bat
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

set "CB_PACKAGE_VERSION="                             
set "CB_PACKAGE_DOWNLOAD_URL=https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe"
set "CB_PACKAGE_DOWNLOAD_NAME=Docker_Desktop_Installer.exe"
set "CB_PACKAGE_INSTALL_PARAMETER=install /quiet"
set "CB_PACKAGE_NO_DEFAULT=true"
::set "CB_DOCKER_DEST=%ProgramFiles%\Docker\Docker\resources\bin\docker.exe"

if .%CB_INSTALL_OVERWRITE_DIST%==.false if exist "%ProgramFiles%"\Docker\Docker\resources\bin\docker.exe set "CB_PACKAGE_ALREADY_EXIST=true"
set "CB_POST_INSTALL_ACTION=copy "c:\ProgramData\Microsoft\Windows\Start Menu\Docker Desktop.lnk" "%USERPROFILE%\desktop\" >nul 2>nul"
