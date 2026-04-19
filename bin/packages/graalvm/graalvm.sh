#!/usr/bin/env bash

#########################################################################
#
# graalvm.sh
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

[ -z "$CB_GRAALVM_VERSION" ] && CB_GRAALVM_VERSION=21.0.2
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_GRAALVM_VERSION
CB_PACKAGE_BASE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-$CB_PACKAGE_VERSION

if [ "$CB_OS" = "linux" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=graalvm-community-jdk-${CB_PACKAGE_VERSION}_linux-x${CB_PROCESSOR_ARCHITECTURE_NUMBER}_bin.tar.gz
elif [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=graalvm-community-jdk-${CB_PACKAGE_VERSION}_macos-x${CB_PROCESSOR_ARCHITECTURE_NUMBER}_bin.tar.gz
elif [ "$CB_OS" = "cygwin" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=graalvm-community-jdk-${CB_PACKAGE_VERSION}_windows-x${CB_PROCESSOR_ARCHITECTURE_NUMBER}_bin.zip
else
	CB_PACKAGE_DOWNLOAD_NAME=graalvm-community-jdk-${CB_PACKAGE_VERSION}_linux-x${CB_PROCESSOR_ARCHITECTURE_NUMBER}_bin.tar.gz
fi

CB_PACKAGE_DEST_VERSION_NAME="graalvm-${CB_PACKAGE_VERSION}"

# The archive contains a top-level directory with + in the name (e.g. graalvm-community-openjdk-21.0.2+13.1).
# CB_PACKAGE_DEST_VERSION_NAME extracts into graalvm-<version>/, creating a nested structure.
# CB_PACKAGE_BUILD_CMD moves the inner contents up and removes the nested directory.
CB_PACKAGE_BUILD_CMD="mv graalvm-community-*/* . 2>/dev/null; mv graalvm-community-*/.* . 2>/dev/null; rmdir graalvm-community-* 2>/dev/null"

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_DEST_VERSION_NAME CB_PACKAGE_BUILD_CMD
