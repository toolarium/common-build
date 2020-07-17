@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: download.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if .%1==. (set "CB_ERROR_INFO=Missing package name!" & goto DOWNLOAD_PACKAGE_ERROR)
set CB_PACKAGE_NAME=%1
set CB_PACKAGE_VERSION=
set CB_PACKAGE_BASE_URL=
set CB_PACKAGE_DOWNLOAD_NAME=
set CB_PACKAGE_VERSION_NAME=
set CB_PACKAGE_DEST_VERSION_NAME=
set CB_PACKAGE_DOWNLOAD_URL=

if not exist %CB_SCRIPT_PATH%\packages\%CB_PACKAGE_NAME%\%CB_PACKAGE_NAME%.bat goto DOWNLOAD_PACKAGE_NOTFOUND_ERROR
:: we expecte:
:: 1) the CB_PACKAGE_VERSION contains the version which will be installed (optional)
:: 2) the CB_PACKAGE_DOWNLOAD_NAME contains the package name which will be downloaded; at the end of the download we have this file (mandatory)
:: 3) the CB_PACKAGE_BASE_URL contains the base package url to download; if this is defined then the CB_PACKAGE_DOWNLOAD_URL can be empty
:: 4) the CB_PACKAGE_DOWNLOAD_URL contains the package url to download; in case we have the CB_PACKAGE_BASE_URL then this is not necessary

:: call package specific settings
call %CB_SCRIPT_PATH%\packages\%CB_PACKAGE_NAME%\%CB_PACKAGE_NAME%.bat %2 

:: supported environment variables from cb: CB_LINE, CB_LOGFILE, CB_DEVTOOLS, CB_DEV_REPOSITORY, CB_WGET_CALL 
if .%CB_LINE%==. (set "CB_ERROR_INFO=%%CB_LINE%%" & goto DOWNLOAD_ENVIRONMENT_ERROR)
if ".%CB_LOGFILE%"=="." (set "CB_ERROR_INFO=%%CB_LOGFILE%%" & goto DOWNLOAD_ENVIRONMENT_ERROR)
if .%CB_DEVTOOLS%==. (set "CB_ERROR_INFO=%%CB_DEVTOOLS%%" & goto DOWNLOAD_ENVIRONMENT_ERROR)
if .%CB_DEV_REPOSITORY%==. (set "CB_ERROR_INFO=%%CB_DEV_REPOSITORY%%" & goto DOWNLOAD_ENVIRONMENT_ERROR)
if .%CB_WGET_CMD%==. (set "CB_ERROR_INFO=%%CB_WGET_CMD%%" & goto DOWNLOAD_ENVIRONMENT_ERROR)
::if .%CB_PACKAGE_VERSION%==. (set "CB_ERROR_INFO=%%CB_PACKAGE_VERSION%%" & goto DOWNLOAD_ENVIRONMENT_ERROR)
if .%CB_PACKAGE_DOWNLOAD_NAME%==. (set "CB_ERROR_INFO=%%CB_PACKAGE_DOWNLOAD_NAME%%" & goto DOWNLOAD_ENVIRONMENT_ERROR)
if ".%CB_PACKAGE_DOWNLOAD_URL%"=="." goto SET_CB_PACKAGE_DOWNLOAD_URL 
goto DOWNLOAD_START

:SET_CB_PACKAGE_DOWNLOAD_URL
if .%CB_PACKAGE_BASE_URL%==. (set "CB_ERROR_INFO=%%CB_PACKAGE_BASE_URL%%" & goto DOWNLOAD_ENVIRONMENT_ERROR)
set "CB_PACKAGE_DOWNLOAD_URL=%CB_PACKAGE_BASE_URL%/%CB_PACKAGE_DOWNLOAD_NAME%"

:DOWNLOAD_START
if .%CB_PACKAGE_VERSION_NAME%==. (set "CB_PACKAGE_VERSION_NAME=%CB_PACKAGE_DOWNLOAD_NAME%")
:: if we already have it we ignore

:: overwrite
if .%CB_INSTALL_OVERWRITE_DIST% == .true del %CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME% >nul 2>nul
if exist %CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME% goto DOWNLOAD_END

:: download and log
echo %CB_LINEHEADER%Download %CB_PACKAGE_NAME% version %CB_PACKAGE_VERSION% & echo %CB_LINEHEADER%Install %CB_PACKAGE_NAME% version %CB_PACKAGE_VERSION%>> "%CB_LOGFILE%"
echo %CB_BIN%\%CB_WGET_CMD% -O%CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME% %CB_WGET_SECURITY_CREDENTIALS% %CB_WGET_PROGRESSBAR% %CB_WGET_PARAM% %CB_WGET_LOG% "%CB_PACKAGE_DOWNLOAD_URL%">> "%CB_LOGFILE%"
%CB_BIN%\%CB_WGET_CMD% -O%CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME% %CB_WGET_SECURITY_CREDENTIALS% %CB_WGET_PROGRESSBAR% %CB_WGET_PARAM% %CB_WGET_LOG% "%CB_PACKAGE_DOWNLOAD_URL%"

:: in case it is zero size we delete it
for %%A in (%CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME%) do if %%~zA==0 del %CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME% >nul 2>nul
goto DOWNLOAD_END

:DOWNLOAD_PACKAGE_ERROR
echo %CB_LINEHEADER%Error occured in download: %CB_ERROR_INFO% & echo %CB_LINEHEADER%Error occured in download: %CB_ERROR_INFO%>> "%CB_LOGFILE%"
goto DOWNLOAD_END

:DOWNLOAD_PACKAGE_NOTFOUND_ERROR
echo %CB_LINEHEADER%Package %CB_PACKAGE_NAME% is currently not supported! & echo %CB_LINEHEADER%Package %CB_PACKAGE_NAME% is currently not supported!>> "%CB_LOGFILE%"
goto DOWNLOAD_END

:DOWNLOAD_ENVIRONMENT_ERROR
echo %CB_LINEHEADER%Could not found expected environment variable %CB_ERROR_INFO% & echo %CB_LINEHEADER%Could not found expected environment variable %CB_ERROR_INFO%>> "%CB_LOGFILE%"
goto DOWNLOAD_END

:DOWNLOAD_END
