@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: jmeter.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_JMETER_VERSION set "CB_JMETER_VERSION=5.3"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_JMETER_VERSION%"
set "CB_PACKAGE_BASE_URL=https://downloads.apache.org/jmeter/binaries"
set "CB_PACKAGE_DOWNLOAD_NAME=apache-jmeter-%CB_PACKAGE_VERSION%.zip"
set "CB_PACKAGE_VERSION_NAME=jmeter-%CB_PACKAGE_VERSION%"
