@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: jd.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if not defined CB_JD_VERSION set "CB_JD_VERSION=1.6.6"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_JD_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/java-decompiler/jd-gui/releases/download/v%CB_PACKAGE_VERSION%/"
set "CB_PACKAGE_DOWNLOAD_NAME=jd-gui-windows-%CB_PACKAGE_VERSION%.zip"
set "CB_PACKAGE_VERSION_NAME=jd-gui-windows-%CB_PACKAGE_VERSION%"

:: create proper shortcut
set "ICON_PATH=%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\jd-gui.exe"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\jd-gui.exe --icon %ICON_PATH% "%USERPROFILE%\desktop\JD.lnk""