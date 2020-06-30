@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: node.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_NODE_VERSION set "CB_NODE_VERSION=12.18.1"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_NODE_VERSION%"
set "CB_PACKAGE_BASE_URL=https://nodejs.org/dist/v%CB_PACKAGE_VERSION%/"
set "CB_PACKAGE_DOWNLOAD_NAME=node-v%CB_PACKAGE_VERSION%-win-x%CB_PROCESSOR_ARCHITECTURE_NUMBER%.zip"
set "CB_PACKAGE_VERSION_NAME=node-v%CB_PACKAGE_VERSION%-win-x%CB_PROCESSOR_ARCHITECTURE_NUMBER%"
