#!/bin/bash

#########################################################################
#
# visualvm.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_VISUAVM_VERSION" ] && CB_VISUAVM_VERSION=2.0.3
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_VISUAVM_VERSION
CB_PACKAGE_BASE_URL="https://github.com/visualvm/visualvm.src/releases/download/$CB_PACKAGE_VERSION"
CB_PACKAGE_DOWNLOAD_NAME=visualvm_$(echo $CB_PACKAGE_VERSION | sed 's/\.//g').zip
CB_PACKAGE_VERSION_NAME=visualvm_$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
