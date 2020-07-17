#!/bin/sh

#########################################################################
#
# soapui.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_SQUIRREL_VERSION" ] && CB_SQUIRREL_VERSION=5.6.0
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_SQUIRREL_VERSION
CB_PACKAGE_BASE_URL="https://s3.amazonaws.com/downloads.eviware/soapuios/$CB_PACKAGE_VERSION"

if [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=SoapUI-$CB_PACKAGE_VERSION.dmg
	CB_PACKAGE_VERSION_NAME=SoapUI-$CB_PACKAGE_VERSION
else
	CB_PACKAGE_DOWNLOAD_NAME=SoapUI-x64-$CB_PACKAGE_VERSION.sh
	CB_PACKAGE_VERSION_NAME=SoapUI-x64-$CB_PACKAGE_VERSION
fi

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
