#!/bin/bash

#########################################################################
#
# atom.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_ATOM_VERSION" ] && CB_ATOM_VERSION=1.50.0
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_ATOM_VERSION
CB_PACKAGE_BASE_URL="https://github.com/atom/atom/releases/download/v%CB_PACKAGE_VERSION%/"
CB_PACKAGE_VERSION_NAME=atom-$CB_PACKAGE_VERSION

if [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=atom-mac.zip
elif [ "$CB_OS" = "linux" ]; then
	if [ "$OS_PACKAGE" = "deb" ]; then
		CB_PACKAGE_DOWNLOAD_NAME=atom-amd64.deb
	elif [ "$OS_PACKAGE" = "rpm" ]; then
		CB_PACKAGE_DOWNLOAD_NAME=atom.x86_64.rpm
	fi
fi
[ -z "$CB_PACKAGE_DOWNLOAD_NAME" ] && CB_PACKAGE_DOWNLOAD_NAME=atom-amd64.tar.gz
export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
