@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: java.bat
::
:: Copyright by toolarium, all rights reserved.
::
:: This file is part of the toolarium common-build.
::
:: The common-build is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: The common-build is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with Foobar. If not, see <http://www.gnu.org/licenses/>.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined CB_JAVA_VERSION set "CB_JAVA_VERSION=11"
set "CB_PACKAGE_VERSION=%1"
if not defined CB_PACKAGE_VERSION set "CB_PACKAGE_VERSION=%CB_JAVA_VERSION%"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_JAVA_VERSION%"

:: 8,9,10,11,12,13
::if not defined CB_JAVA_FEATURE_VERSION set "CB_JAVA_FEATURE_VERSION=11"
set CB_JAVA_FEATURE_VERSION=%CB_PACKAGE_VERSION%
for /f "tokens=1 delims=." %%i in ("%CB_PACKAGE_VERSION%") do (set "CB_JAVA_FEATURE_VERSION=%%i")
:: ga, ea
if not defined CB_JAVA_RELEASE_TYPE set "CB_JAVA_RELEASE_TYPE=ga"
::linux, windows, mac, solaris, aix
if not defined CB_JAVA_OS set "CB_JAVA_OS=windows"
:: x64, x32, ppc64, ppc64le, s390x, aarch64, arm, sparcv9, riscv64
if not defined CB_JAVA_ARCH  set "CB_JAVA_ARCH=x%CB_PROCESSOR_ARCHITECTURE_NUMBER%"
:: jdk, jre, testimage, debugimage, staticlibs
if not defined CB_JAVA_IMAGE_TYPE set "CB_JAVA_IMAGE_TYPE=jdk"
:: hotspot, openj9
if not defined CB_JAVA_JVM_IMPL set "CB_JAVA_JVM_IMPL=hotspot"
:: normal, large
if not defined CB_JAVA_HEAP_SIZE set "CB_JAVA_HEAP_SIZE=normal"
:: adoptopenjdk, openjdk
if not defined CB_JAVA_VENDOR set "CB_JAVA_VENDOR=openjdk"
:: see https://api.adoptopenjdk.net/v3/info/release_names
::set CB_JAVA_RELEASENAME=jdk-11.0.6+10
::  jdk, valhalla, metropolis, jfr
if not defined CB_JAVA_PROJECT set "CB_JAVA_PROJECT=jdk"

::set "CB_PACKAGE_DOWNLOAD_URL_V3=https://api.adoptopenjdk.net/v3/binary/version/%CB_JAVA_RELEASENAME%/%CB_JAVA_OS%/%CB_JAVA_ARCH%/%CB_JAVA_IMAGE_TYPE%/%CB_JAVA_JVM_IMPL%/%CB_JAVA_HEAP_SIZE%/%CB_JAVA_VENDOR%"
set "CB_PACKAGE_DOWNLOAD_URL_V3_LATEST=https://api.adoptopenjdk.net/v3/binary/latest/%CB_JAVA_FEATURE_VERSION%/%CB_JAVA_RELEASE_TYPE%/%CB_JAVA_OS%/%CB_JAVA_ARCH%/%CB_JAVA_IMAGE_TYPE%/%CB_JAVA_JVM_IMPL%/%CB_JAVA_HEAP_SIZE%/%CB_JAVA_VENDOR%"
set "CB_JAVA_INFO_DOWNLOAD_URL_V3_LATEST=https://api.adoptopenjdk.net/v3/assets/latest/%CB_JAVA_FEATURE_VERSION%/%CB_JAVA_JVM_IMPL%"
set "CB_PACKAGE_DOWNLOAD_URL_V2_LATEST=https://api.adoptopenjdk.net/v2/binary/releases/openjdk%CB_JAVA_FEATURE_VERSION%?openjdk_impl=%CB_JAVA_JVM_IMPL%&os=windows&arch=x%CB_PROCESSOR_ARCHITECTURE_NUMBER%&release=latest&type=jdk"
set "CB_JAVA_INFO_DOWNLOAD_URL_V2_LATEST=https://api.adoptopenjdk.net/v2/info/releases/openjdk%CB_JAVA_FEATURE_VERSION%?openjdk_impl=%CB_JAVA_JVM_IMPL%&os=windows&arch=x%CB_PROCESSOR_ARCHITECTURE_NUMBER%&release=latest&type=jdk"

set CB_PACKAGE_BASE_URL=
set CB_PACKAGE_DOWNLOAD_NAME=
set CB_PACKAGE_VERSION_NAME=
set CB_PACKAGE_VERSION_HASH=

:: get version information
set "CB_JAVA_JSON_INFO=%CB_LOGS%\cb-javaFile.json"
set "CB_JAVA_INFO_DOWNLOAD_URL=%CB_JAVA_INFO_DOWNLOAD_URL_V3_LATEST%"

:: v2
::echo %CB_BIN%\%CB_WGET_CMD% -O%TMPFILE% %CB_WGET_SECURITY_CREDENTIALS% -q "%CB_JAVA_INFO_DOWNLOAD_URL%"
::%CB_BIN%\%CB_WGET_CMD% -O%TMPFILE% %CB_WGET_SECURITY_CREDENTIALS% -q "%CB_JAVA_INFO_DOWNLOAD_URL%"
::powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binaries.binary_name" > "%CB_JAVA_JSON_INFO%"
::set /p CB_PACKAGE_DOWNLOAD_NAME= < "%CB_JAVA_JSON_INFO%"
::powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binaries.version_data.semver" > "%CB_JAVA_JSON_INFO%"
::set /p CB_PACKAGE_VERSION_NAME= < "%CB_JAVA_JSON_INFO%"
::set "CB_PACKAGE_VERSION_NAME=jdk-%CB_PACKAGE_VERSION_NAME%"
::::powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binaries.installer_checksum_link" > "%CB_JAVA_JSON_INFO%"
::::set /p CB_PACKAGE_VERSION_HASH= < "%CB_JAVA_JSON_INFO%"

:: v3
::echo %CB_BIN%\%CB_WGET_CMD% -O%TMPFILE% %CB_WGET_SECURITY_CREDENTIALS% -q "%CB_JAVA_INFO_DOWNLOAD_URL%"
echo %CB_LINEHEADER%Check java %CB_PACKAGE_VERSION% version & echo %CB_LINEHEADER%Check java %CB_PACKAGE_VERSION% version>> "%CB_LOGFILE%"
%CB_BIN%\%CB_WGET_CMD% -O%TMPFILE% %CB_WGET_SECURITY_CREDENTIALS% -q "%CB_JAVA_INFO_DOWNLOAD_URL%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json | ? { $_.binary.image_type -eq $Env:CB_JAVA_PROJECT } | ? { $_.binary.architecture -eq $Env:CB_JAVA_ARCH } | ? {$_.binary.os -eq $Env:CB_JAVA_OS} | ConvertTo-Json" > "%CB_JAVA_JSON_INFO%"
move /y %CB_JAVA_JSON_INFO% %TMPFILE% >nul 2>nul
::powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.release_name" > "%CB_JAVA_JSON_INFO%"
::set /p CB_PACKAGE_VERSION_NAME= < "%CB_JAVA_JSON_INFO%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.version.semver" > "%CB_JAVA_JSON_INFO%"
set /p CB_PACKAGE_VERSION= < "%CB_JAVA_JSON_INFO%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binary.package.name" > "%CB_JAVA_JSON_INFO%"
set /p CB_PACKAGE_DOWNLOAD_NAME= < "%CB_JAVA_JSON_INFO%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binary.package.link" > "%CB_JAVA_JSON_INFO%"
set /p CB_PACKAGE_DOWNLOAD_URL= < "%CB_JAVA_JSON_INFO%"
powershell -command "$json = (Get-Content "%TMPFILE%" -Raw) | ConvertFrom-Json; $json.binary.package.checksum_link" > "%CB_JAVA_JSON_INFO%"
set /p CB_PACKAGE_VERSION_HASH= < "%CB_JAVA_JSON_INFO%"

del "%CB_JAVA_JSON_INFO%" >nul 2>nul
move %TMPFILE% %CB_DEV_REPOSITORY%\%CB_PACKAGE_DOWNLOAD_NAME%.json >nul 2>nul

:DOWNLOAD_JAVA_END
