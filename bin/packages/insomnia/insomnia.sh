#!/bin/bash

#########################################################################
#
# insomnia.sh
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


CB_PACKAGE_VERSION=
if [ "$CB_OS" = "linux" ]; then
	CB_PACKAGE_DOWNLOAD_URL=https://updates.insomnia.rest/downloads/ubuntu/latest?ref=&app=com.insomnia.app
	CB_PACKAGE_DOWNLOAD_NAME=Insomnia.Core.deb
elif [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_URL=https://updates.insomnia.rest/downloads/mac/latest?ref=&app=com.insomnia.app
	CB_PACKAGE_DOWNLOAD_NAME=Insomnia.Core.dmg
elif [ "$CB_OS" = "cygwin" ]; then
	CB_PACKAGE_DOWNLOAD_URL=https://updates.insomnia.rest/downloads/windows/latest?ref=&app=com.insomnia.app
	CB_PACKAGE_DOWNLOAD_NAME=Insomnia.Core.exe
else
	CB_PACKAGE_DOWNLOAD_URL=https://updates.insomnia.rest/downloads/windows/latest?ref=&app=com.insomnia.app
	CB_PACKAGE_DOWNLOAD_NAME=Insomnia.Core.exe
fi

export CB_PACKAGE_VERSION CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME