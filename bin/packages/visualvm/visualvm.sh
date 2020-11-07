#!/bin/bash

#########################################################################
#
# visualvm.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


[ -z "$CB_VISUAVM_VERSION" ] && CB_VISUAVM_VERSION=2.0.4
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
