#!/bin/sh

#########################################################################
#
# selenium-ide.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_SELENIUM_IDE_VERSION" ] && CB_SELENIUM_IDE_VERSION=3.141.59
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_SELENIUM_IDE_VERSION
CB_PACKAGE_BASE_URL="https://selenium-release.storage.googleapis.com/${CB_SELENIUM_IDE_VERSION%.*}"
CB_PACKAGE_DOWNLOAD_NAME=selenium-java-$CB_SELENIUM_IDE_VERSION.zip
CB_PACKAGE_VERSION_NAME=selenium-java-$CB_SELENIUM_IDE_VERSION
CB_PACKAGE_DEST_VERSION_NAME=selenium-java-$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_DEST_VERSION_NAME
