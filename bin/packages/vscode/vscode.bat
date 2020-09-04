@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: vscode.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if not defined CB_VSCODE_VERSION set "CB_VSCODE_VERSION=1.48.2"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_VSCODE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_URL=https://update.code.visualstudio.com/%CB_PACKAGE_VERSION%/win32-x64-user/stable"
set "CB_PACKAGE_DOWNLOAD_NAME=VSCodeUserSetup-x64-%CB_PACKAGE_VERSION%.exe"
set "CB_PACKAGE_NO_DEFAULT=true"
