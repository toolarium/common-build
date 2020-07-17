@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: flutter.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_FLUTTER_VERSION set "CB_FLUTTER_VERSION=1.17.5"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_FLUTTER_VERSION%"
set "CB_PACKAGE_BASE_URL=https://storage.googleapis.com/flutter_infra/releases/stable/windows"
set "CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_%CB_PACKAGE_VERSION%-stable.zip
set "CB_PACKAGE_VERSION_NAME=flutter_windows_%CB_PACKAGE_VERSION%-stable"
