@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: gaiden.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_GAIDEN_VERSION set "CB_GAIDEN_VERSION=1.2"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_GAIDEN_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/kobo/gaiden/releases/download/v%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_NAME=gaiden-%CB_PACKAGE_VERSION%.zip"
set "CB_PACKAGE_VERSION_NAME=gaiden-%CB_PACKAGE_VERSION%"
