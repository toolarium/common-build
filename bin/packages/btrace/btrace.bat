@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: btrace.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_BTRACE_VERSION set "CB_BTRACE_VERSION=2.0.2"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_BTRACE_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/btraceio/btrace/releases/download/v%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_NAME=btrace-%CB_PACKAGE_VERSION%-bin.zip"
set "CB_PACKAGE_VERSION_NAME=btrace-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=btrace-%CB_PACKAGE_VERSION%"