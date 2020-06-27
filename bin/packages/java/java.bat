@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: java.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_JAVA_VERSION (set CB_JAVA_VERSION=11)
if not defined CB_JAVA_OPENJDK_IMPL (set CB_JAVA_OPENJDK_IMPL=hotspot)
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_JAVA_VERSION%"
set "CB_DOWNLOAD_PACKAGE_URL=https://api.adoptopenjdk.net/v2/binary/releases/openjdk%CB_PACKAGE_VERSION%?openjdk_impl=%CB_JAVA_OPENJDK_IMPL%&os=windows&arch=x%CB_PROCESSOR_ARCHITECTURE_NUMBER%&release=latest&type=jdk"
set CB_PACKAGE_DOWNLOAD_URL=
set CB_PACKAGE_DOWNLOAD_NAME=
set CB_PACKAGE_VERSION_NAME=
set CB_PACKAGE_VERSION_HASH=

:: get version information
if exist %CB_JAVA_INFO% goto DOWNLOAD_JAVA_END
set "CB_JAVA_JSON_INFO=%CB_LOGS%\cb-javaFile.json"
set "CB_JAVA_INFO_DOWNLOAD_URL=https://api.adoptopenjdk.net/v2/info/releases/openjdk%CB_PACKAGE_VERSION%?openjdk_impl=%CB_JAVA_OPENJDK_IMPL%&os=windows&arch=x%CB_PROCESSOR_ARCHITECTURE_NUMBER%&release=latest&type=jdk"
::echo %CB_BIN%\%CB_WGET_CMD% -O%TMPFILE% %CB_WGET_SECURITY_CREDENTIALS% -q "%CB_JAVA_INFO_DOWNLOAD_URL%"
%CB_BIN%\%CB_WGET_CMD% -O%TMPFILE% %CB_WGET_SECURITY_CREDENTIALS% -q "%CB_JAVA_INFO_DOWNLOAD_URL%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binaries.binary_name" > "%CB_JAVA_JSON_INFO%"
set /p CB_PACKAGE_DOWNLOAD_NAME= < "%CB_JAVA_JSON_INFO%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binaries.version_data.semver" > "%CB_JAVA_JSON_INFO%"
set /p CB_PACKAGE_VERSION_NAME= < "%CB_JAVA_JSON_INFO%"
set "CB_PACKAGE_VERSION_NAME=jdk-%CB_PACKAGE_VERSION_NAME%"
::powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binaries.installer_checksum_link" > "%CB_JAVA_JSON_INFO%"
::set /p CB_PACKAGE_VERSION_HASH= < "%CB_JAVA_JSON_INFO%"
del "%CB_JAVA_JSON_INFO%" >nul 2>nul
move %TMPFILE% %CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME%.json >nul 2>nul

:DOWNLOAD_JAVA_END
