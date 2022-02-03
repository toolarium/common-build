#!/bin/bash

#########################################################################
#
# python.sh
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


[ -z "$CB_PYTHON_VERSION" ] && CB_PYTHON_VERSION=3.9.10
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_PYTHON_VERSION
CB_PACKAGE_BASE_URL="https://www.python.org/ftp/python/$CB_PACKAGE_VERSION/"
CB_PACKAGE_DOWNLOAD_NAME="Python-${CB_PACKAGE_VERSION}.tgz"
CB_PACKAGE_VERSION_NAME="Python-$CB_PACKAGE_VERSION"
CB_PACKAGE_BUILD_CMD="./configure && make"
#CB_PACKAGE_DEST_VERSION_NAME="python-$CB_PACKAGE_VERSION"

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_BUILD_CMD CB_PACKAGE_DEST_VERSION_NAME
