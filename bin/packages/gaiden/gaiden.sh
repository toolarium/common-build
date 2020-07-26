#!/bin/bash

#########################################################################
#
# gaiden.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_GAIDEN_VERSION" ] && CB_GAIDEN_VERSION=1.2
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_GAIDEN_VERSION
CB_PACKAGE_BASE_URL="https://github.com/kobo/gaiden/releases/download/v$CB_PACKAGE_VERSION"
CB_PACKAGE_DOWNLOAD_NAME=gaiden-$CB_PACKAGE_VERSION.zip
CB_PACKAGE_VERSION_NAME=gaiden-$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
