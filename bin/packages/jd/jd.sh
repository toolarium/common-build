#!/bin/bash

#########################################################################
#
# jd.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_JD_VERSION" ] && CB_JD_VERSION=1.6.6
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_JD_VERSION
CB_PACKAGE_BASE_URL="https://github.com/java-decompiler/jd-gui/releases/download/v%CB_PACKAGE_VERSION%/"
CB_PACKAGE_VERSION_NAME=jd-gui-$CB_PACKAGE_VERSION

if [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=jd-gui-osx-$CB_PACKAGE_VERSION.tar
elif [ "$CB_OS" = "linux" ]; then
	if [ "$OS_PACKAGE" = "deb" ]; then
		CB_PACKAGE_DOWNLOAD_NAME=jd-gui-$CB_PACKAGE_VERSION.deb
	elif [ "$OS_PACKAGE" = "rpm" ]; then
		CB_PACKAGE_DOWNLOAD_NAME=jd-gui-$CB_PACKAGE_VERSION.rpm
	fi
fi
[ -z "$CB_PACKAGE_DOWNLOAD_NAME" ] && CB_PACKAGE_DOWNLOAD_NAME=jd-gui-$CB_PACKAGE_VERSION.jar

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
