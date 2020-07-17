#!/bin/sh

#########################################################################
#
# postman.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_POSTMAN_VERSION" ] && CB_POSTMAN_VERSION=newest
CB_PACKAGE_DOWNLOAD_URL=https://dl.pstmn.io/download/latest

if [ "$CB_OS" = "linux" ]; then
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/linux64"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-linux-x64-$CB_POSTMAN_VERSION.tar.gz"
elif [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/osx"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-osx-$CB_POSTMAN_VERSION.zip"
elif [ "$CB_OS" = "darwin" ]; then
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/osx"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-osx-$CB_POSTMAN_VERSION.zip"
elif [ "$CB_OS" = "cygwin" ]; then
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/win$CB_PROCESSOR_ARCHITECTURE_NUMBER"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-win$CB_PROCESSOR_ARCHITECTURE_NUMBER-$CB_POSTMAN_VERSION-Setup.exe"
else
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/win$CB_PROCESSOR_ARCHITECTURE_NUMBER"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-win$CB_PROCESSOR_ARCHITECTURE_NUMBER-$CB_POSTMAN_VERSION-Setup.exe"
fi

export CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME

