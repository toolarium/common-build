#!/bin/bash

#########################################################################
#
# visualvm.sh
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


[ -z "$CB_VISUAVM_VERSION" ] && CB_VISUAVM_VERSION=2.1.5
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_VISUAVM_VERSION
CB_PACKAGE_BASE_URL="https://github.com/visualvm/visualvm.src/releases/download/$CB_PACKAGE_VERSION"
CB_PACKAGE_DOWNLOAD_NAME=visualvm_$(echo $CB_PACKAGE_VERSION | sed 's/\.//g').zip
CB_PACKAGE_VERSION_NAME=visualvm_$CB_PACKAGE_VERSION

CB_PACKAGE_DEST_VERSION_NAME="visualvm-$CB_PACKAGE_VERSION"
mkdir -p "$CB_DEVTOOLS/$CB_PACKAGE_DEST_VERSION_NAME/bin" >/dev/null 2>&1

CB_VISUALVM_PACKAGEVERSION=$(echo $CB_PACKAGE_VERSION | sed 's/\.//g')
visualvmBin="$CB_DEVTOOLS/$CB_PACKAGE_DEST_VERSION_NAME/bin/visualvm"
echo "#!/bin/bash">> "$visualvmBin"
echo "#. cb --setenv">> "$visualvmBin" 
echo "$CB_DEVTOOLS/$CB_PACKAGE_DEST_VERSION_NAME/visualvm_$CB_VISUALVM_PACKAGEVERSION/bin/visualvm --jdkhome \$CB_HOME/current/java --console suppress">> "$visualvmBin"

export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_DEST_VERSION_NAME
