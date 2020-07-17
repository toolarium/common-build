@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: sbt.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_SBT_VERSION set "CB_SBT_VERSION=1.3.13"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_SBT_VERSION%"
set "CB_PACKAGE_BASE_URL=https://piccolo.link"
set "CB_PACKAGE_DOWNLOAD_NAME=sbt-%CB_PACKAGE_VERSION%.zip"
set "CB_PACKAGE_VERSION_NAME=sbt-%CB_PACKAGE_VERSION%"
