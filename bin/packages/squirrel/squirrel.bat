@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: squirrel.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_SQUIRREL_VERSION set "CB_SQUIRREL_VERSION=4.1.0"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_SQUIRREL_VERSION%"
::https://sourceforge.net/projects/squirrel-sql/files/1-stable/%CB_PACKAGE_VERSION%-plainzip
set "CB_PACKAGE_BASE_URL=https://netix.dl.sourceforge.net/project/squirrel-sql/1-stable/%CB_PACKAGE_VERSION%-plainzip"
set "CB_PACKAGE_DOWNLOAD_NAME=squirrelsql-%CB_PACKAGE_VERSION%-optional.zip"
set "CB_PACKAGE_VERSION_NAME=squirrelsql-%CB_PACKAGE_VERSION%-optional"
