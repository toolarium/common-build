#!/bin/sh

#########################################################################
#
# micronaut.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_MICRONAUT_VERSION" ] && CB_MICRONAUT_VERSION=2.0.0
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_MICRONAUT_VERSION
CB_PACKAGE_BASE_URL="https://github.com/micronaut-projects/micronaut-starter/releases/download/v$CB_PACKAGE_VERSION"
CB_PACKAGE_DOWNLOAD_NAME=micronaut-cli-$CB_PACKAGE_VERSION.zip
CB_PACKAGE_VERSION_NAME=micronaut-cli-$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
