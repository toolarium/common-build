#!/bin/sh

#########################################################################
#
# java.sh
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

[ -z "$CB_JAVA_VERSION" ] && CB_JAVA_VERSION=17
CB_PACKAGE_VERSION=$1
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION=$CB_JAVA_VERSION
# 8,9,10,11,12,13
# [ -z $CB_JAVA_FEATURE_VERSION ] && CB_JAVA_FEATURE_VERSION=11
CB_JAVA_FEATURE_VERSION=$CB_PACKAGE_VERSION
# ga, ea
[ -z "$CB_JAVA_RELEASE_TYPE" ] && CB_JAVA_RELEASE_TYPE=ga
# linux, windows, mac, solaris, aix
[ -z "$CB_JAVA_OS" ] && CB_JAVA_OS=$CB_OS
[ "$CB_JAVA_OS" = "cygwin" ] && CB_JAVA_OS=windows
# x64, x32, ppc64, ppc64le, s390x, aarch64, arm, sparcv9, riscv64
[ -z "$CB_JAVA_ARCH" ] && CB_JAVA_ARCH=x$CB_PROCESSOR_ARCHITECTURE_NUMBER
[ "$CB_JAVA_OS" = "linux" ] && [ -z "$(echo $CB_MACHINE|grep -v arm)" ] && CB_JAVA_ARCH=arm
[ "$CB_JAVA_OS" = "linux" ] && [ -z "$(echo $CB_MACHINE|grep -v s390)" ] && CB_JAVA_ARCH=s390x
[ "$CB_JAVA_OS" = "linux" ] && [ -z "$(echo $CB_MACHINE|grep -v aarch)" ] && CB_JAVA_ARCH=aarch64
[ "$CB_JAVA_OS" = "solaris" ] && CB_JAVA_ARCH=sparcv9
[ "$CB_JAVA_OS" = "aix" ] && CB_JAVA_ARCH=ppc64
[ "$CB_JAVA_OS" = "aix" ] && [ -z "$(echo $CB_MACHINE|grep -v ppc64le)" ] && CB_JAVA_ARCH=ppc64le
# jdk, jre, testimage, debugimage, staticlibs
[ -z "$CB_JAVA_IMAGE_TYPE" ] && CB_JAVA_IMAGE_TYPE=jdk
# hotspot, openj9
[ -z "$CB_JAVA_JVM_IMPL" ] && CB_JAVA_JVM_IMPL=hotspot
# normal, large
[ -z "$CB_JAVA_HEAP_SIZE" ] && CB_JAVA_HEAP_SIZE=normal
# adoptopenjdk, openjdk
[ -z "$CB_JAVA_VENDOR" ] && CB_JAVA_VENDOR=openjdk
# see https://api.adoptopenjdk.net/v3/info/release_names
# CB_JAVA_RELEASENAME=jdk-11.0.6+10
#  jdk, valhalla, metropolis, jfr
[ -z "$CB_JAVA_PROJECT" ] && CB_JAVA_PROJECT=$CB_JAVA_IMAGE_TYPE

# CB_PACKAGE_DOWNLOAD_URL_V3="https://api.adoptopenjdk.net/v3/binary/version/$CB_JAVA_RELEASENAME/$CB_JAVA_OS/$CB_JAVA_ARCH/$CB_JAVA_IMAGE_TYPE/$CB_JAVA_JVM_IMPL/$CB_JAVA_HEAP_SIZE/$CB_JAVA_VENDOR"
CB_PACKAGE_DOWNLOAD_URL_V3_LATEST="https://api.adoptopenjdk.net/v3/binary/latest/$CB_JAVA_FEATURE_VERSION/$CB_JAVA_RELEASE_TYPE/$CB_JAVA_OS/$CB_JAVA_ARCH/$CB_JAVA_IMAGE_TYPE/$CB_JAVA_JVM_IMPL/$CB_JAVA_HEAP_SIZE/$CB_JAVA_VENDOR"
CB_JAVA_INFO_DOWNLOAD_URL_V3_LATEST="https://api.adoptopenjdk.net/v3/assets/latest/$CB_JAVA_FEATURE_VERSION/$CB_JAVA_JVM_IMPL"
CB_PACKAGE_DOWNLOAD_URL_V2_LATEST="https://api.adoptopenjdk.net/v2/binary/releases/openjdk${CB_JAVA_FEATURE_VERSION}?openjdk_impl=${CB_JAVA_JVM_IMPL}&os=windows&arch=x${CB_PROCESSOR_ARCHITECTURE_NUMBER}&release=latest&type=$CB_JAVA_IMAGE_TYPE"
CB_JAVA_INFO_DOWNLOAD_URL_V2_LATEST="https://api.adoptopenjdk.net/v2/info/releases/openjdk${CB_JAVA_FEATURE_VERSION}?openjdk_impl=${CB_JAVA_JVM_IMPL}&os=windows&arch=x${CB_PROCESSOR_ARCHITECTURE_NUMBER}&release=latest&type=$CB_JAVA_IMAGE_TYPE"

CB_PACKAGE_BASE_URL=
CB_PACKAGE_DOWNLOAD_NAME=
CB_PACKAGE_VERSION_NAME=
CB_PACKAGE_VERSION_HASH=

# get version information
CB_JAVA_JSON_INFO=$CB_LOGS/cb-javaFile.json
CB_JAVA_INFO_DOWNLOAD_URL=$CB_JAVA_INFO_DOWNLOAD_URL_V3_LATEST

# v3
CB_PACKAGE_SILENT_LOG="silent"
echo "${CB_LINEHEADER}Check $CB_JAVA_IMAGE_TYPE $CB_PACKAGE_VERSION version" | tee -a "$CB_LOGFILE"
downloadFiles "$CB_JAVA_INFO_DOWNLOAD_URL" "$CB_JAVA_JSON_INFO"

#echo ${CB_LINEHEADER}Verify java packages | tee -a $CB_LOGFILE
cat $CB_JAVA_JSON_INFO | ${CB_BIN}/cb-json --filter architecture=$CB_JAVA_ARCH --filter jvm_impl=$CB_JAVA_JVM_IMPL --filter image_type=$CB_JAVA_IMAGE_TYPE --filter os=$CB_JAVA_OS > "${CB_JAVA_JSON_INFO}.filtered"
mv -f "${CB_JAVA_JSON_INFO}.filtered" "$CB_JAVA_JSON_INFO" >/dev/null 2>&1

CB_PACKAGE_DOWNLOAD_NAME=$(cat "$CB_JAVA_JSON_INFO" 2>/dev/null | ${CB_BIN}/cb-json --value --name package.name) 
CB_PACKAGE_DOWNLOAD_URL=$(cat "$CB_JAVA_JSON_INFO" 2>/dev/null | ${CB_BIN}/cb-json --value --name package.link) 
CB_PACKAGE_VERSION=$(grep "semver" "$CB_JAVA_JSON_INFO" 2>/dev/null | ${CB_BIN}/cb-json --value --name version.semver)
CB_PACKAGE_VERSION_HASH=$(cat "$CB_JAVA_JSON_INFO" 2>/dev/null | ${CB_BIN}/cb-json --value --name package.checksum)

if ! [ -n "$CB_PACKAGE_DOWNLOAD_NAME" ]; then 
	rm "$CB_JAVA_JSON_INFO" >/dev/null 2>&1
	echo "${CB_LINEHEADER}Could not found $CB_JAVA_IMAGE_TYPE $CB_JAVA_FEATURE_VERSION version" | tee -a "$CB_LOGFILE"
	exit 1
else
	mv "$CB_JAVA_JSON_INFO" "$CB_DEV_REPOSITORY/${CB_PACKAGE_DOWNLOAD_NAME}.json" >/dev/null 2>&1
	export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
fi