@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not defined CB_VERSION (set "CB_VERSION=0.4.0")
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://github.com/toolarium/common-build/archive/"
set "CB_PACKAGE_DOWNLOAD_NAME=v%CB_PACKAGE_VERSION%.zip"
::set "CB_PACKAGE_VERSION_NAME=%CB_PACKAGE_DOWNLOAD_NAME%"
