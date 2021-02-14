#!/bin/bash

#########################################################################
#
# vscode.sh
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


[ -z "$CB_VSCODE_VERSION" ] && CB_VSCODE_VERSION=1.48.1
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_VSCODE_VERSION

if [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/darwin/stable"
	CB_PACKAGE_DOWNLOAD_NAME=VSCode-mac.zip
elif [ "$CB_OS" = "linux" ]; then
	if [ "$OS_PACKAGE" = "deb" ]; then
		CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/linux-deb-x64/stable"
		CB_PACKAGE_DOWNLOAD_NAME=vscode-$CB_PACKAGE_VERSION.deb
	elif [ "$OS_PACKAGE" = "rpm" ]; then
		CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/linux-rpm-x64/stable"
		CB_PACKAGE_DOWNLOAD_NAME=vscode-$CB_PACKAGE_VERSION.rpm
	elif [ "$OS_PACKAGE" = "snap" ]; then
		CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/linux-snap-x64/stable"	
		CB_PACKAGE_DOWNLOAD_NAME=vscode-$CB_PACKAGE_VERSION.snap
	fi
fi

if [ -z "$CB_PACKAGE_DOWNLOAD_NAME" ]; then
	CB_PACKAGE_DOWNLOAD_URL="https://update.code.visualstudio.com/$CB_PACKAGE_VERSION/linux-x64/stable"
	CB_PACKAGE_DOWNLOAD_NAME=vscode-$CB_PACKAGE_VERSION.tar.gz
fi

CB_PACKAGE_NO_DEFAULT=true
export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_NO_DEFAULT
