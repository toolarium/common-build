@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: maven.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not defined CB_MAVEN_VERSION (set CB_MAVEN_VERSION=3.6.3)
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_MAVEN_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://archive.apache.org/dist/maven/maven-3/%CB_PACKAGE_VERSION%/binaries"
set "CB_PACKAGE_DOWNLOAD_NAME=apache-maven-%CB_PACKAGE_VERSION%-bin.zip"
set "CB_PACKAGE_VERSION_NAME=maven-%CB_PACKAGE_VERSION%"
