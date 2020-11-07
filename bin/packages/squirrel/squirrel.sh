#!/bin/bash

#########################################################################
#
# squirrel.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_SQUIRREL_VERSION" ] && CB_SQUIRREL_VERSION=4.1.0
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_SQUIRREL_VERSION
#https://sourceforge.net/projects/squirrel-sql/files/1-stable/$CB_PACKAGE_VERSION-plainzip
CB_PACKAGE_BASE_URL="https://netix.dl.sourceforge.net/project/squirrel-sql/1-stable/$CB_PACKAGE_VERSION-plainzip"
CB_PACKAGE_DOWNLOAD_NAME=squirrelsql-$CB_PACKAGE_VERSION-optional.zip
CB_PACKAGE_VERSION_NAME=squirrelsql-$CB_PACKAGE_VERSION-optional.zip
export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME

