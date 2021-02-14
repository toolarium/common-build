#!/bin/bash

#########################################################################
#
# squirrel.sh
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


[ -z "$CB_SQUIRREL_VERSION" ] && CB_SQUIRREL_VERSION=4.1.0
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_SQUIRREL_VERSION
#https://sourceforge.net/projects/squirrel-sql/files/1-stable/$CB_PACKAGE_VERSION-plainzip
CB_PACKAGE_BASE_URL="https://netix.dl.sourceforge.net/project/squirrel-sql/1-stable/$CB_PACKAGE_VERSION-plainzip"
CB_PACKAGE_DOWNLOAD_NAME=squirrelsql-$CB_PACKAGE_VERSION-optional.zip
CB_PACKAGE_VERSION_NAME=squirrelsql-$CB_PACKAGE_VERSION-optional.zip
export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME

