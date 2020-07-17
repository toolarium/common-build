@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: visualvm.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_VISUAVM_VERSION set "CB_VISUAVM_VERSION=2.0.3"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_VISUAVM_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/visualvm/visualvm.src/releases/download/%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_NAME=visualvm_%CB_PACKAGE_VERSION:.=%.zip"
set "CB_PACKAGE_VERSION_NAME=visualvm_%CB_PACKAGE_VERSION%"
