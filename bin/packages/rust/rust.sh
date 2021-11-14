#!/bin/bash

#########################################################################
#
# rust.sh
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


CB_PKG_FILTER=""
CB_PACKAGE_DOWNLOAD_URL=https://sh.rustup.rs
CB_PACKAGE_DOWNLOAD_NAME=rustup-init.sh
CB_PACKAGE_NO_DEFAULT=true
CB_PACKAGE_INSTALL_PARAMETER="-q -y"

export CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_NO_DEFAULT CB_PACKAGE_INSTALL_PARAMETER CB_PKG_FILTER
