#!/bin/sh

#########################################################################
#
# flutter.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_FLUTTER_VERSION" ] && CB_FLUTTER_VERSION=1.17.5
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_FLUTTER_VERSION
CB_PACKAGE_BASE_URL=https://storage.googleapis.com/flutter_infra/releases/stable

if [ "$CB_OS" = "linux" ]; then
	CB_PACKAGE_BASE_URL=$CB_PACKAGE_BASE_URL/linux
	CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_linux_$CB_PACKAGE_VERSION-stable.tar.xz
elif [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_BASE_URL=$CB_PACKAGE_BASE_URL/macos
	CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_macos_$CB_PACKAGE_VERSION-stable.zip
elif [ "$CB_OS" = "cygwin" ]; then
	CB_PACKAGE_BASE_URL=$CB_PACKAGE_BASE_URL/windows
	CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_$CB_PACKAGE_VERSION-stable.zip
else
	CB_PACKAGE_BASE_URL=$CB_PACKAGE_BASE_URL/windows
	CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_$CB_PACKAGE_VERSION-stable.zip
fi

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
