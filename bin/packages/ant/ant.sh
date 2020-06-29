#!/bin/sh

#########################################################################
#
# ant.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_ANT_VERSION" ] && CB_ANT_VERSION=1.10.8
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_ANT_VERSION
CB_PACKAGE_DOWNLOAD_URL=https://downloads.apache.org/ant/binaries
CB_PACKAGE_DOWNLOAD_NAME=apache-ant-$CB_PACKAGE_VERSION-bin.tar.gz
CB_PACKAGE_VERSION_NAME=ant-$CB_PACKAGE_VERSION

export CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME