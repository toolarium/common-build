#!/bin/bash

#########################################################################
#
# btrace.sh
#
# Copyright by toolarium, all rights reserved.
#
# This file is part of the toolarium common-build.
#
# The common-build is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# The common-build is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar. If not, see <http://www.gnu.org/licenses/>.
#
#########################################################################


[ -z "$CB_BTRACE_VERSION" ] && CB_BTRACE_VERSION=2.2.3
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_BTRACE_VERSION
CB_PACKAGE_BASE_URL="https://github.com/btraceio/btrace/releases/download/v$CB_PACKAGE_VERSION"
CB_PACKAGE_DOWNLOAD_NAME=btrace-v$CB_PACKAGE_VERSION-bin.tar.gz
CB_PACKAGE_VERSION_NAME=btrace-v$CB_PACKAGE_VERSION
CB_PACKAGE_DEST_VERSION_NAME=btrace-$CB_PACKAGE_VERSION

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_DEST_VERSION_NAME
