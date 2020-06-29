#!/bin/sh

#########################################################################
#
# node.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_NODE_VERSION" ] && CB_NODE_VERSION=12.18.1
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_NODE_VERSION
CB_PACKAGE_DOWNLOAD_URL=https://nodejs.org/dist/v$CB_PACKAGE_VERSION

if [ "CB_OS" = "linux" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=node-v$CB_PACKAGE_VERSION-$CB_OS-x$CB_PROCESSOR_ARCHITECTURE_NUMBER.tar.xz
elif [ "CB_OS" = "darwin" ]; then
	# mac
	CB_PACKAGE_DOWNLOAD_NAME=node-v$CB_PACKAGE_VERSION-$CB_OS-x$CB_PROCESSOR_ARCHITECTURE_NUMBER.tar.gz
else
	CB_PACKAGE_DOWNLOAD_NAME=node-v$CB_PACKAGE_VERSION-$CB_OS-x$CB_PROCESSOR_ARCHITECTURE_NUMBER.zip
fi

export CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME