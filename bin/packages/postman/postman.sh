#!/bin/bash

#########################################################################
#
# postman.sh
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


[ -z "$CB_POSTMAN_VERSION" ] && CB_POSTMAN_VERSION=newest
CB_PACKAGE_DOWNLOAD_URL=https://dl.pstmn.io/download/latest

if [ "$CB_OS" = "linux" ]; then
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/linux64"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-linux-x64-$CB_POSTMAN_VERSION.tar.gz"
elif [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/osx"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-osx-$CB_POSTMAN_VERSION.zip"
elif [ "$CB_OS" = "darwin" ]; then
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/osx"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-osx-$CB_POSTMAN_VERSION.zip"
elif [ "$CB_OS" = "cygwin" ]; then
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/win$CB_PROCESSOR_ARCHITECTURE_NUMBER"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-win$CB_PROCESSOR_ARCHITECTURE_NUMBER-$CB_POSTMAN_VERSION-Setup.exe"
else
	CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL/win$CB_PROCESSOR_ARCHITECTURE_NUMBER"
	CB_PACKAGE_DOWNLOAD_NAME="Postman-win$CB_PROCESSOR_ARCHITECTURE_NUMBER-$CB_POSTMAN_VERSION-Setup.exe"
fi

export CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME

