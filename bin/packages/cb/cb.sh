#!/bin/sh

#########################################################################
#
# cb.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_VERSION" ] && CB_VERSION=0.4.0
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_VERSION
CB_PACKAGE_BASE_URL=https://github.com/toolarium/common-build/archive/
CB_PACKAGE_DOWNLOAD_NAME=v$CB_PACKAGE_VERSION.zip
#CB_PACKAGE_VERSION_NAME=v$CB_PACKAGE_DOWNLOAD_NAME

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME