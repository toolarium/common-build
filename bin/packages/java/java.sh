#!/bin/sh

#########################################################################
#
# java.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################

[ -z "$CB_JAVA_VERSION" ] && CB_JAVA_VERSION=11
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
[ -z "$CB_JAVA_PROJECT" ] && CB_JAVA_PROJECT=jdk

# CB_PACKAGE_DOWNLOAD_URL_V3="https://api.adoptopenjdk.net/v3/binary/version/$CB_JAVA_RELEASENAME/$CB_JAVA_OS/$CB_JAVA_ARCH/$CB_JAVA_IMAGE_TYPE/$CB_JAVA_JVM_IMPL/$CB_JAVA_HEAP_SIZE/$CB_JAVA_VENDOR"
CB_PACKAGE_DOWNLOAD_URL_V3_LATEST="https://api.adoptopenjdk.net/v3/binary/latest/$CB_JAVA_FEATURE_VERSION/$CB_JAVA_RELEASE_TYPE/$CB_JAVA_OS/$CB_JAVA_ARCH/$CB_JAVA_IMAGE_TYPE/$CB_JAVA_JVM_IMPL/$CB_JAVA_HEAP_SIZE/$CB_JAVA_VENDOR"
CB_JAVA_INFO_DOWNLOAD_URL_V3_LATEST="https://api.adoptopenjdk.net/v3/assets/latest/$CB_JAVA_FEATURE_VERSION/$CB_JAVA_JVM_IMPL"
CB_PACKAGE_DOWNLOAD_URL_V2_LATEST="https://api.adoptopenjdk.net/v2/binary/releases/openjdk${CB_JAVA_FEATURE_VERSION}?openjdk_impl=${CB_JAVA_JVM_IMPL}&os=windows&arch=x${CB_PROCESSOR_ARCHITECTURE_NUMBER}&release=latest&type=jdk"
CB_JAVA_INFO_DOWNLOAD_URL_V2_LATEST="https://api.adoptopenjdk.net/v2/info/releases/openjdk${CB_JAVA_FEATURE_VERSION}?openjdk_impl=${CB_JAVA_JVM_IMPL}&os=windows&arch=x${CB_PROCESSOR_ARCHITECTURE_NUMBER}&release=latest&type=jdk"

CB_PACKAGE_BASE_URL=
CB_PACKAGE_DOWNLOAD_NAME=
CB_PACKAGE_VERSION_NAME=
CB_PACKAGE_VERSION_HASH=

# get version information
CB_JAVA_JSON_INFO=$CB_LOGS/cb-javaFile.json
CB_JAVA_INFO_DOWNLOAD_URL=$CB_JAVA_INFO_DOWNLOAD_URL_V3_LATEST

# v3
CB_CURL_PARAM=" "
CB_CURL_PROGRESSBAR=" "

echo "${CB_LINEHEADER}Check java $CB_PACKAGE_VERSION version" | tee -a "$CB_LOGFILE"
downloadFiles "$CB_JAVA_INFO_DOWNLOAD_URL" "$CB_JAVA_JSON_INFO"

#echo ${CB_LINEHEADER}Verify java packages | tee -a $CB_LOGFILE
sed -e 's/[}"]*\(.\)[{"]*/\1/g;y/,/\n/' < "$CB_JAVA_JSON_INFO" \
	| sed 's/binary:/\n{/g' \
	| grep -E -v "(\[|\]|download_count|version|package:|scm_ref|updated_at|build:|major:|minor:|severity:|security:|checksum:|adopt_build_number:|release_name:|size:|installer:)" \
	| grep -E -v "^[[:space:]]*$" \
	| sed -e ':a' -e 'N;$!ba' -e 's/\n/,/g' \
	| sed 's/,{ ,/\n{/g;s/{//g;s/ //g;s/^,//g;s/,}//g;s/,/ /g' \
	| grep "architecture:$CB_JAVA_ARCH" | grep "jvm_impl:$CB_JAVA_JVM_IMPL" | grep "image_type:$CB_JAVA_IMAGE_TYPE" | grep "os:$CB_JAVA_OS" \
	| sed 's/ /\n/g' \
	| awk '{if ($0 ~ /.msi|.pkg/) {print "installer_"$0} else {print $0}}' \
	| sed 's/:/: /g;s/: \//:\//g' > "${CB_JAVA_JSON_INFO}.filtered"
mv -f "${CB_JAVA_JSON_INFO}.filtered" "$CB_JAVA_JSON_INFO" >/dev/null 2>&1

CB_PACKAGE_DOWNLOAD_NAME=$(cat "$CB_JAVA_JSON_INFO" 2>/dev/null | grep -v installer | grep "name" | awk '{print $2}') 
CB_PACKAGE_DOWNLOAD_URL=$(cat "$CB_JAVA_JSON_INFO" 2>/dev/null | grep -v installer | grep -v checksum_link | grep "link" | awk '{print $2}') 
CB_PACKAGE_VERSION=$(grep "semver" "$CB_JAVA_JSON_INFO" 2>/dev/null | awk '{print $2}')
CB_PACKAGE_VERSION_HASH=$(cat "$CB_JAVA_JSON_INFO" 2>/dev/null | grep -v installer | grep "checksum_link" 2>/dev/null | awk '{print $2}')

mv "$CB_JAVA_JSON_INFO" "$CB_DEV_REPOSITORY/${CB_PACKAGE_DOWNLOAD_NAME}.json" >/dev/null 2>&1
CB_CURL_PARAM= && CB_CURL_PROGRESSBAR=
export CB_PACKAGE_BASE_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME
