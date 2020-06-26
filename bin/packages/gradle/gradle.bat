@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: gradle.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not defined CB_GRADLE_VERSION (set "CB_GRADLE_VERSION=6.5")
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_GRADLE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://downloads.gradle-dn.com/distributions"
set "CB_PACKAGE_DOWNLOAD_NAME=gradle-%CB_PACKAGE_VERSION%-bin.zip"
set "CB_PACKAGE_VERSION_NAME=gradle-%CB_PACKAGE_VERSION%"
