@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: atom.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if not defined CB_ATOM_VERSION set "CB_ATOM_VERSION=1.50.0"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_ATOM_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/atom/atom/releases/download/v%CB_PACKAGE_VERSION%/"
set "CB_PACKAGE_DOWNLOAD_NAME=atom-windows.zip"
set "CB_PACKAGE_VERSION_NAME=atom-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=atom-%CB_PACKAGE_VERSION%"


:: create proper shortcut
set "ICON_PATH=%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\Atom\atom.exe"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\Atom\atom.exe --icon %ICON_PATH% "%USERPROFILE%\desktop\Atom.lnk""