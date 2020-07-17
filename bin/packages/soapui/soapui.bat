@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: soapui.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_SOAPUI_VERSION set "CB_SOAPUI_VERSION=5.6.0"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_SOAPUI_VERSION%"
set "CB_PACKAGE_BASE_URL=https://s3.amazonaws.com/downloads.eviware/soapuios/%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_NAME=SoapUI-x64-%CB_PACKAGE_VERSION%.exe"
set "CB_PACKAGE_VERSION_NAME=SoapUI-x64-%CB_PACKAGE_VERSION%"
