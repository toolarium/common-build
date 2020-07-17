#!/bin/sh

#########################################################################
#
# btrace.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_BTRACE_VERSION" ] && CB_BTRACE_VERSION=2.0.2
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_BTRACE_VERSION
CB_PACKAGE_BASE_URL="https://github.com/btraceio/btrace/releases/download/v$CB_PACKAGE_VERSION"
CB_PACKAGE_DOWNLOAD_NAME=btrace-$CB_PACKAGE_VERSION-bin.tar.gz
CB_PACKAGE_VERSION_NAME=btrace-$CB_PACKAGE_VERSION
CB_PACKAGE_DEST_VERSION_NAME=btrace-$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_DEST_VERSION_NAME
