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

set "squirrelBin=%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\squirrel.bat"
echo @ECHO OFF> "%squirrelBin%"
echo :: set proper java version>> "%squirrelBin%" 
echo call cb --silent --setenv>> "%squirrelBin%" 
::echo call %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\squirrel-sql.bat>> "%squirrelBin%"
echo set CP="%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\squirrel-sql.jar;%CB_PACKAGE_VERSION_NAME%\lib\*">> "%squirrelBin%"
echo set TMP_PARMS=--log-config-file "%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\log4j.properties" --squirrel-home "%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%" %%1 %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9>> "%squirrelBin%"
echo start "SQuirreL SQL Client" /B "javaw" -Dsun.awt.nopixfmt=true -Dsun.java2d.noddraw=true -cp %%CP%% -splash:"%CB_DEVTOOLS%/%CB_PACKAGE_VERSION_NAME%/icons/splash.jpg" net.sourceforge.squirrel_sql.client.Main %TMP_PARMS%>> "%squirrelBin%"

:: create proper shortcut
set "ICON_PATH=%CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\icons\acorn.ico"
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %CB_DEVTOOLS%\%CB_PACKAGE_VERSION_NAME%\squirrel.bat --icon %ICON_PATH% %USERPROFILE%\desktop\SQuirreL.lnk"