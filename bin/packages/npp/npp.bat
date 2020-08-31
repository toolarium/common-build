@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: npp.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_GRADLE_VERSION set "CB_NPP_VERSION=7.8.9"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_NPP_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v%CB_PACKAGE_VERSION%/npp.%CB_PACKAGE_VERSION%.bin.zip"
set "CB_PACKAGE_DOWNLOAD_NAME=npp.%CB_PACKAGE_VERSION%.bin.zip"
::set "CB_PACKAGE_VERSION_NAME=npp-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=npp-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_NO_DEFAULT=true"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\notepad++.exe --icon %CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\notepad++.exe "%USERPROFILE%\desktop\Notepad++.lnk""