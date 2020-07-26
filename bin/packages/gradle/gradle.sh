#!/bin/bash

#########################################################################
#
# gradle.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_GRADLE_VERSION" ] && CB_GRADLE_VERSION=6.5
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_GRADLE_VERSION
CB_PACKAGE_BASE_URL=https://services.gradle.org/distributions
#CB_PACKAGE_BASE_URL=https://gradle.org/next-steps/?version=$CB_PACKAGE_VERSION&format=bin"
CB_PACKAGE_DOWNLOAD_NAME=gradle-$CB_PACKAGE_VERSION-bin.zip
CB_PACKAGE_VERSION_NAME=gradle-$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME