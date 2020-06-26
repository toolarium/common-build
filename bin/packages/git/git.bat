@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: git.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not defined CB_GIT_VERSION (set CB_GIT_VERSION=2.27.0)
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_GIT_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://github.com/git-for-windows/git/releases/download/v%CB_PACKAGE_VERSION%.windows.1"
set "CB_PACKAGE_DOWNLOAD_NAME=Git-%CB_PACKAGE_VERSION%-%CB_PROCESSOR_ARCHITECTURE_NUMBER%-bit.exe"
::set "CB_PACKAGE_VERSION_NAME="
