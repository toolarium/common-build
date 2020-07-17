#!/bin/sh

#########################################################################
#
# groovy.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_GROOVY_VERSION" ] && CB_GROOVY_VERSION=3.0.4
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_GROOVY_VERSION
CB_PACKAGE_BASE_URL=https://dl.bintray.com/groovy/maven
CB_PACKAGE_DOWNLOAD_NAME=apache-groovy-binary-$CB_GROOVY_VERSION.zip
CB_PACKAGE_VERSION_NAME=apache-groovy-$CB_GROOVY_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME