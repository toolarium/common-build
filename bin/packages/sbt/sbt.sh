#!/bin/sh

#########################################################################
#
# sbt.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_SBT_VERSION" ] && CB_SBT_VERSION=1.3.13
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_SBT_VERSION
CB_PACKAGE_BASE_URL="https://piccolo.link"
CB_PACKAGE_DOWNLOAD_NAME=sbt-$CB_PACKAGE_VERSION.zip
CB_PACKAGE_VERSION_NAME=sbt-$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
