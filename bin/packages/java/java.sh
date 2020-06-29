#!/bin/sh

#########################################################################
#
# java.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_JAVA_VERSION" ] && CB_JAVA_VERSION=11
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_JAVA_VERSION
[ -z "$CB_JAVA_OPENJDK_IMPL" ] && CB_JAVA_OPENJDK_IMPL=hotspot
CB_DOWNLOAD_PACKAGE_URL=https://api.adoptopenjdk.net/v2/binary/releases/openjdk$CB_PACKAGE_VERSION?openjdk_impl=$CB_JAVA_OPENJDK_IMPL&os=$CB_OS&arch=x$CB_PROCESSOR_ARCHITECTURE_NUMBER&release=latest&type=jdk
CB_PACKAGE_DOWNLOAD_URL=
CB_PACKAGE_DOWNLOAD_NAME=
CB_PACKAGE_VERSION_NAME=
CB_PACKAGE_VERSION_HASH=

# get version information
if [ -n "$CB_JAVA_VERSION" ]; then
	CB_JAVA_JSON_INFO=$CB_LOGS\cb-javaFile.json
	CB_JAVA_INFO_DOWNLOAD_URL=https://api.adoptopenjdk.net/v2/info/releases/openjdk$CB_PACKAGE_VERSION?openjdk_impl=$CB_JAVA_OPENJDK_IMPL&os=$CB_OS&arch=x$CB_PROCESSOR_ARCHITECTURE_NUMBER&release=latest&type=jdk
	# echo %CB_BIN%\%CB_WGET_CMD% -O%TMPFILE% %CB_WGET_SECURITY_CREDENTIALS% -q "%CB_JAVA_INFO_DOWNLOAD_URL%"
	$CB_BIN\$CB_WGET_CMD -O$TMPFILE $CB_WGET_SECURITY_CREDENTIALS -q "$CB_JAVA_INFO_DOWNLOAD_URL"
	
	CB_PACKAGE_DOWNLOAD_NAME=$(cat $TMPFILE | grep "binaries.binary_name")
	CB_JAVA_JSON_INFO=$(cat $TMPFILE | grep "binaries.version_data.semver")

	CB_PACKAGE_VERSION_NAME=jdk-$CB_PACKAGE_VERSION_NAME
	rm -f $CB_JAVA_JSON_INFO >nul 2>nul
	mv $TMPFILE $CB_DEV_REPOSITORY\$CB_PACKAGE_DOWNLOAD_NAME.json >/dev/null 2>&1
fi

export CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME