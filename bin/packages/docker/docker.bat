@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: docker.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "CB_PACKAGE_VERSION="
set "CB_PACKAGE_DOWNLOAD_URL=https://download.docker.com/win/stable/Docker%%20Desktop%%20Installer.exe"
set "CB_PACKAGE_DOWNLOAD_NAME=Docker_Desktop_Installer.exe"
set "CB_PACKAGE_INSTALL_PARAMETER=install /quiet"
set "CB_PACKAGE_NO_DEFAULT=true"
::set "CB_DOCKER_DEST=%ProgramFiles%\Docker\Docker\resources\bin\docker.exe"

if .%CB_INSTALL_OVERWRITE_DIST%==.false if exist "%ProgramFiles%"\Docker\Docker\resources\bin\docker.exe set "CB_PACKAGE_ALREADY_EXIST=true"
