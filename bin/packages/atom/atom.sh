#!/bin/bash

#########################################################################
#
# atom.sh
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


[ -z "$CB_ATOM_VERSION" ] && CB_ATOM_VERSION=1.58.0
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_ATOM_VERSION
CB_PACKAGE_BASE_URL="https://github.com/atom/atom/releases/download/v%CB_PACKAGE_VERSION%/"
CB_PACKAGE_VERSION_NAME=atom-$CB_PACKAGE_VERSION

if [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_NAME=atom-mac.zip
elif [ "$CB_OS" = "linux" ]; then
	if [ "$OS_PACKAGE" = "deb" ]; then
		CB_PACKAGE_DOWNLOAD_NAME=atom-amd64.deb
	elif [ "$OS_PACKAGE" = "rpm" ]; then
		CB_PACKAGE_DOWNLOAD_NAME=atom.x86_64.rpm
	fi
fi
[ -z "$CB_PACKAGE_DOWNLOAD_NAME" ] && CB_PACKAGE_DOWNLOAD_NAME=atom-amd64.tar.gz
export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
