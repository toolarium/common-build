@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: docker.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_MAVEN_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://download.docker.com/win/stable"
set "CB_PACKAGE_DOWNLOAD_NAME=Docker%%20Desktop%%20Installer.exe"
::set "CB_PACKAGE_VERSION_NAME="
