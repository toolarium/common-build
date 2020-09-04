#!/bin/bash

#########################################################################
#
# vscode.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_VSCODE_VERSION" ] && CB_VSCODE_VERSION=1.48.1
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_VSCODE_VERSION

if [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/darwin/stable"
	CB_PACKAGE_DOWNLOAD_NAME=VSCode-mac.zip
elif [ "$CB_OS" = "linux" ]; then
	if [ "$OS_PACKAGE" = "deb" ]; then
		CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/linux-deb-x64/stable"
		CB_PACKAGE_DOWNLOAD_NAME=vscode-$CB_PACKAGE_VERSION.deb
	elif [ "$OS_PACKAGE" = "rpm" ]; then
		CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/linux-rpm-x64/stable"
		CB_PACKAGE_DOWNLOAD_NAME=vscode-$CB_PACKAGE_VERSION.rpm
	elif [ "$OS_PACKAGE" = "snap" ]; then
		CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/linux-snap-x64/stable"	
		CB_PACKAGE_DOWNLOAD_NAME=vscode-$CB_PACKAGE_VERSION.snap
	fi
fi

if [ -z "$CB_PACKAGE_DOWNLOAD_NAME" ]; then
	CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/linux-x64/stable"
	CB_PACKAGE_DOWNLOAD_NAME=vscode-$CB_PACKAGE_VERSION.tar.gz
fi

CB_PACKAGE_NO_DEFAULT=true
export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_NO_DEFAULT
