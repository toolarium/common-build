@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: micronaut.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_MICRONAUT_VERSION set "CB_MICRONAUT_VERSION=2.0.0"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_MICRONAUT_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/micronaut-projects/micronaut-starter/releases/download/v%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_NAME=micronaut-cli-%CB_PACKAGE_VERSION%.zip"
set "CB_PACKAGE_VERSION_NAME=micronaut-cli-%CB_PACKAGE_VERSION%"
