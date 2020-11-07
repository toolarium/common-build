#!/bin/bash

#########################################################################
#
# jmeter.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_JMETER_VERSION" ] && CB_JMETER_VERSION=5.3
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_JMETER_VERSION
CB_PACKAGE_BASE_URL="https://downloads.apache.org/jmeter/binaries"
CB_PACKAGE_DOWNLOAD_NAME=apache-jmeter-$CB_PACKAGE_VERSION.tgz
CB_PACKAGE_VERSION_NAME=jmeter-$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
