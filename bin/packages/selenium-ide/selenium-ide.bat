@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: selenium-ide.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_SELENIUM_IDE_VERSION set "CB_SELENIUM_IDE_MAJOR_VERSION=3.141" & set "CB_SELENIUM_IDE_VERSION=3.141.59"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_SELENIUM_IDE_VERSION%"
set "CB_PACKAGE_BASE_URL=https://selenium-release.storage.googleapis.com/%CB_SELENIUM_IDE_MAJOR_VERSION%"
set "CB_PACKAGE_DOWNLOAD_NAME=selenium-java-%CB_PACKAGE_VERSION%.zip"
set "CB_PACKAGE_VERSION_NAME=selenium-java-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=selenium-java-%CB_PACKAGE_VERSION%"
