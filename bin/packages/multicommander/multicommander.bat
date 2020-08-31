@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: multicommander.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_GRADLE_VERSION set "CB_MULTICOMMANDER_VERSION=9.7.0.2590"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_MULTICOMMANDER_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=http://multicommander.com/files/updates/MultiCommander_x%CB_PROCESSOR_ARCHITECTURE_NUMBER%_Portable_(%CB_PACKAGE_VERSION%).zip"
set "CB_PACKAGE_DOWNLOAD_NAME=MultiCommander_x%CB_PROCESSOR_ARCHITECTURE_NUMBER%-%CB_PACKAGE_VERSION%.zip"
::set "CB_PACKAGE_VERSION_NAME=multicommander-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=multicommander-%CB_PACKAGE_VERSION%"
::set "CB_PACKAGE_NO_DEFAULT=true"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\MultiCommander.exe --icon %CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\MultiCommander.exe "%USERPROFILE%\desktop\MultiCommander.lnk""