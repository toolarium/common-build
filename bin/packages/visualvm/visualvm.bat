@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: visualvm.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_VISUAVM_VERSION set "CB_VISUAVM_VERSION=2.0.4"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_VISUAVM_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/visualvm/visualvm.src/releases/download/%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_NAME=visualvm_%CB_PACKAGE_VERSION:.=%.zip"
set "CB_PACKAGE_VERSION_NAME=visualvm_%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DEST_VERSION_NAME=visualvm-%CB_PACKAGE_VERSION%"

mkdir "%CB_DEVTOOLS%" 2>nul
mkdir "%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%" 2>nul
mkdir "%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\bin" 2>nul

set CB_VISUALVM_PACKAGEVERSION=%CB_PACKAGE_VERSION:.=%

set "visualvmBin=%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\bin\visualvm.bat"
echo @ECHO OFF> "%visualvmBin%"
echo ::call cb --silent --setenv>> "%visualvmBin%" 
echo start "Visual VM" /B "%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\visualvm_%CB_VISUALVM_PACKAGEVERSION%\bin\visualvm.exe" --jdkhome %%CB_HOME%%\current\java --console suppress>> "%visualvmBin%"

:: create proper shortcut
set ICON_PATH=%CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\visualvm_%CB_VISUALVM_PACKAGEVERSION%\bin\visualvm.exe
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_DEST_VERSION_NAME%\bin\visualvm.bat --icon %ICON_PATH% "%USERPROFILE%\desktop\VisualVM.lnk""