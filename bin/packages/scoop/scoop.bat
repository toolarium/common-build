@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: scoop.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "CB_PACKAGE_VERSION="
set "CB_PACKAGE_DOWNLOAD_URL=NA"
set "CB_PACKAGE_DOWNLOAD_NAME="
set "CB_PACKAGE_INSTALL_PARAMETER="
set "CB_PACKAGE_NO_DEFAULT=true"
set "CB_PKG_FILTER="

powershell -nologo -command "Set-ExecutionPolicy RemoteSigned -scope CurrentUser" >nul 2>nul	
set "CB_PACKAGE_ALREADY_EXIST=false"
set "CB_POST_INSTALL_ACTION=powershell -nologo -command "iwr -useb get.scoop.sh ^| iex"
