@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: groovy.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_GROOVY_VERSION set "CB_GROOVY_VERSION=3.0.4"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_GROOVY_VERSION%"
set "CB_PACKAGE_BASE_URL=https://dl.bintray.com/groovy/maven"
set "CB_PACKAGE_DOWNLOAD_NAME=apache-groovy-binary-%CB_GROOVY_VERSION%.zip"
set "CB_PACKAGE_VERSION_NAME=apache-groovy-%CB_GROOVY_VERSION%"
