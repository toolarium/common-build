#!/bin/bash

#########################################################################
#
# flutter.sh
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


[ -z "$CB_FLUTTER_VERSION" ] && CB_FLUTTER_VERSION=1.20.2
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_FLUTTER_VERSION
CB_PACKAGE_BASE_URL=https://storage.googleapis.com/flutter_infra/releases/stable

if [ "$CB_OS" = "linux" ]; then
	CB_PACKAGE_BASE_URL=$CB_PACKAGE_BASE_URL/linux
	CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_linux_$CB_PACKAGE_VERSION-stable.tar.xz
elif [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_BASE_URL=$CB_PACKAGE_BASE_URL/macos
	CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_macos_$CB_PACKAGE_VERSION-stable.zip
elif [ "$CB_OS" = "cygwin" ]; then
	CB_PACKAGE_BASE_URL=$CB_PACKAGE_BASE_URL/windows
	CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_$CB_PACKAGE_VERSION-stable.zip
else
	CB_PACKAGE_BASE_URL=$CB_PACKAGE_BASE_URL/windows
	CB_PACKAGE_DOWNLOAD_NAME=flutter_windows_$CB_PACKAGE_VERSION-stable.zip
fi

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
