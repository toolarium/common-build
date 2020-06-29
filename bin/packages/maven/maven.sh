#!/bin/sh

#########################################################################
#
# maven.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_MAVEN_VERSION" ] && CB_MAVEN_VERSION=3.6.3
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_MAVEN_VERSION
CB_PACKAGE_DOWNLOAD_URL=https://archive.apache.org/dist/maven/maven-3/$CB_PACKAGE_VERSION/binaries
CB_PACKAGE_DOWNLOAD_NAME=apache-maven-$CB_PACKAGE_VERSION-bin.tar.gz   
CB_PACKAGE_VERSION_NAME=maven-$CB_PACKAGE_VERSION

export CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME