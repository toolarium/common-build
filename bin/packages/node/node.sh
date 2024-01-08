#!/bin/bash

#########################################################################
#
# node.sh
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


[ -z "$CB_NODE_VERSION" ] && CB_NODE_VERSION=20.10.0
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_NODE_VERSION
CB_PACKAGE_BASE_URL=https://nodejs.org/dist/v$CB_PACKAGE_VERSION
CB_PACKAGE_PERMISSION_CMD=

if [ "$CB_OS" = "linux" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=node-v$CB_PACKAGE_VERSION-$CB_OS-x$CB_PROCESSOR_ARCHITECTURE_NUMBER.tar.xz
elif [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=node-v$CB_PACKAGE_VERSION-$CB_OS-x$CB_PROCESSOR_ARCHITECTURE_NUMBER.tar.gz
elif [ "$CB_OS" = "cygwin" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=node-v$CB_PACKAGE_VERSION-win-x$CB_PROCESSOR_ARCHITECTURE_NUMBER.zip
	CB_PACKAGE_PERMISSION_CMD="chmod 755 npx; chmod 755 npm; chmod 755 node.exe"
else
	CB_PACKAGE_DOWNLOAD_NAME=node-v$CB_PACKAGE_VERSION-win-x$CB_PROCESSOR_ARCHITECTURE_NUMBER.zip
fi

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME