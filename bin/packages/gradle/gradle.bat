@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: gradle.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_GRADLE_VERSION set "CB_GRADLE_VERSION=6.6"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_GRADLE_VERSION%"
set "CB_PACKAGE_BASE_URL=https://services.gradle.org/distributions"
::set "CB_PACKAGE_DOWNLOAD_URL=https://gradle.org/next-steps/?version=%CB_PACKAGE_VERSION%&format=bin"
set "CB_PACKAGE_DOWNLOAD_NAME=gradle-%CB_PACKAGE_VERSION%-bin.zip"
set "CB_PACKAGE_VERSION_NAME=gradle-%CB_PACKAGE_VERSION%"
