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
