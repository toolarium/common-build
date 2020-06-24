@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-env-clean.bat: cleanup internal environment variable
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if defined JAVA_HOME_BACKUP set "JAVA_HOME=%JAVA_HOME_BACKUP%"
if defined PATH_BACKUP set "PATH=%PATH_BACKUP%"

set "TOUPPER=" & set "DEV_REPOSITORY=" & set "PROCESSOR_ARCHITECTURE_NUMBER=" & set "CURRENT_DRIVE=" & set "CURRENT_PATH="
set "CB_PKG_FILTER="
set "gradleVersion=" & set "GRADLE_DOWNLOAD_PACKAGENAME=" & set "GRADLE_DOWNLOAD_PACKAGE_URL=" & set "GRADLE_DOWNLOAD_URL="
set "mavenVersion=" & set "MAVEN_DOWNLOAD_PACKAGENAME=" & set "MAVEN_DOWNLOAD_PACKAGE_URL=" & set "MAVEN_DOWNLOAD_URL="
set "antVersion=" & set "ANT_DOWNLOAD_PACKAGENAME=" & set "ANT_DOWNLOAD_PACKAGE_URL=" & set "ANT_DOWNLOAD_URL="
set "JAVA_DOWNLOAD_URL=" & set "JAVA_INFO_DOWNLOAD_URL=" & set "JAVA_OPENJDK_IMPL=" & set "jdkFilename=" & set "jdkVersion="
set "WGET_CMD=" & set "WGET_DOWNLOAD_URL=" & set "WGET_LOG=" & set "WGET_PACKAGE_URL="
set "WGET_PARAM=" & set "WGET_PROGRESSBAR=" & set "WGET_SECURITY_CREDENTIALS="


set "PN=" & set "PN_FULL=" & set "LOGFILE=" & set "TMPFILE=" & set "LINE="
set "CB_BIN=" & set "CB_LOGS=" & set "CB_INSTALL_SILENT=" & set "CB_INSTALL_USER_COMMIT="
set "DD=" & set "MM=" & set "HH=" & set "YY=" & set "YYYY=" & set "Min=" & set "Sec=" & set "DATESTAMP=" & set "TIMESTAMP=" & set "dt="
set "FULLTIMESTAMP=" & set "USER_FRIENDLY_DATESTAMP=" & set "USER_FRIENDLY_TIMESTAMP=" & set "USER_FRIENDLY_FULLTIMESTAMP="
set "CB_WGET_VERSION=" & set "CB_JAVA_VERSION=" & set "CB_GRADLE_VERSION=" & set "CB_MAVEN_VERSION=" & set "CB_ANT_VERSION="
set "CB_JAVA_VERSION_FILE=" & set "CB_PACKAGE_URL=" & set "JAVA_VERSION_FILE="
set "DEVTOOLS_NAME=" & set "DEVTOOLS_DRIVE=" 
set "CB_USER=" & set "CB_PACKAGE_PASSWORD=" & set "CB_JAVA_HOME="
set "GRADLE_EXEC=" & set "JAVA_HOME_BACKUP=" & set "PARAMETERS=" & set "PATH_BACKUP=" & set "cbJavaVersion="
