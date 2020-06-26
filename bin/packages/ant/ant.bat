@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: ant.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not defined CB_ANT_VERSION (set "CB_ANT_VERSION=1.10.8")
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_ANT_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://downloads.apache.org/ant/binaries"
set "CB_PACKAGE_DOWNLOAD_NAME=apache-ant-%CB_PACKAGE_VERSION%-bin.zip"
set "CB_PACKAGE_VERSION_NAME=ant-%CB_PACKAGE_VERSION%"
