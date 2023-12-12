#!/bin/bash

#########################################################################
#
# eclipse.sh
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

eclipseFilter=
[ -z "$CB_ECLIPSE_VERSION" ] && CB_ECLIPSE_VERSION="2022-12 jee-package"
#[ -z "$CB_ECLIPSE_RELEASE_VERSION" ] && CB_ECLIPSE_RELEASE_VERSION="r"
CB_PACKAGE_VERSION="$1"
[ -z "$CB_PACKAGE_VERSION" ] && CB_PACKAGE_VERSION="${CB_ECLIPSE_VERSION% *}"
CB_ECLIPSE_PACKAGE_NAME="$(echo $2 | tr -d '\r')"
[ -z "$CB_ECLIPSE_PACKAGE_NAME" ] && CB_ECLIPSE_PACKAGE_NAME="${CB_ECLIPSE_VERSION#* }"
[ -z "$CB_ECLIPSE_PACKAGE_NAME" ] && CB_ECLIPSE_PACKAGE_NAME="jee-package"

CB_ECLIPSE_INFO_DOWNLOAD_URL="https://api.eclipse.org/download/release/eclipse_packages"

# get version information
echo "${CB_LINEHEADER}Check eclipse $CB_PACKAGE_VERSION version / ${CB_ECLIPSE_PACKAGE_NAME}" | tee -a "$CB_LOGFILE"
#eclipseFilter="&release_version=${CB_PACKAGE_VERSION}"
CB_ECLIPSE_JSON_INFO=$CB_LOGS/cb-eclipseFile.json
CB_PACKAGE_SILENT_LOG="silent"
CB_PACKAGE_USERAGENT=true
CB_PACKAGE_COOKIE="$CB_LOGS/cb-eclipse-cookiejar"

downloadFiles "${CB_ECLIPSE_INFO_DOWNLOAD_URL}?release_name=${CB_PACKAGE_VERSION}$eclipseFilter" "$CB_ECLIPSE_JSON_INFO"

CB_ECLIPSE_OS="$CB_OS"
[ "$CB_ECLIPSE_OS" = "cygwin" ] && CB_ECLIPSE_OS="windows"

CB_PACKAGE_VERSION_NAME=$(cat "$CB_ECLIPSE_JSON_INFO" | $CB_BIN/cb-json --value --name release_name | tr -d '\r')
CB_PACKAGE_DOWNLOAD_URL=$(eval "cat \"$CB_ECLIPSE_JSON_INFO\" | $CB_BIN/cb-json --value --name packages.${CB_ECLIPSE_PACKAGE_NAME}.files.${CB_ECLIPSE_OS}.${CB_PROCESSOR_ARCHITECTURE_NUMBER}.url" | tr -d '\r')

CB_PACKAGE_DOWNLOAD_NAME="${CB_PACKAGE_DOWNLOAD_URL##*/}"

# change 2023/12/12 add r=1
CB_PACKAGE_DOWNLOAD_URL="${CB_PACKAGE_DOWNLOAD_URL}&r=1"

mv "$CB_ECLIPSE_JSON_INFO" "$CB_DEV_REPOSITORY/${CB_PACKAGE_DOWNLOAD_NAME}.json" >/dev/null 2>&1

CB_PACKAGE_DEST_VERSION_NAME="eclipse-$CB_PACKAGE_VERSION_NAME"
CB_PACKAGE_NO_DEFAULT=true

# there is no mirror-id and redirect anymore
if [ 1 = 2 ]; then
	CB_ECLIPSE_JSON_MIRROR_INFO="$CB_LOGS/cb-eclipseFile-mirror.html"
	CB_ECLIPSE_JSON_REDIRECT_INFO="$CB_LOGS/cb-eclipseFile-redirect.html"
	rm -f "$CB_ECLIPSE_JSON_MIRROR_INFO" >/dev/null 2>&1
	rm -f "$CB_ECLIPSE_JSON_REDIRECT_INFO" >/dev/null 2>&1

	CB_PACKAGE_SILENT_LOG="silent"
	CB_PACKAGE_USERAGENT=true
	CB_PACKAGE_COOKIE="$CB_LOGS/cb-eclipse-cookiejar"
	rm -f "$CB_PACKAGE_COOKIE" 2>/dev/null
	CB_CURL_CONTINUE=" "
	downloadFiles "$CB_PACKAGE_DOWNLOAD_URL" "$CB_ECLIPSE_JSON_MIRROR_INFO"
	mirrorId=$(cat "$CB_ECLIPSE_JSON_MIRROR_INFO" | grep File: | grep mirror_id= | sed 's/.*mirror_id=//g;s/"/ /g' | awk '{print $1}')

	if [ -n "$mirrorId" ]; then
		[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Found mirror id: $mirrorId"
		#CB_PACKAGE_SILENT_LOG="silent"
		CB_PACKAGE_USERAGENT=true
		CB_PACKAGE_COOKIE="$CB_LOGS/cb-eclipse-cookiejar"
		CB_PACKAGE_DOWNLOAD_URL="$CB_PACKAGE_DOWNLOAD_URL&mirror_id=${mirrorId}"
		CB_CURL_CONTINUE=" "
		#downloadFiles "$CB_PACKAGE_DOWNLOAD_URL" "$CB_ECLIPSE_JSON_REDIRECT_INFO"
		$HTTP_REQUEST_CLI -# -L --insecure -o "$CB_ECLIPSE_JSON_REDIRECT_INFO" "$CB_PACKAGE_DOWNLOAD_URL"
		realUrl=$(cat "$CB_ECLIPSE_JSON_REDIRECT_INFO" | grep "META HTTP-EQUIV=" | grep "CONTENT=" | grep "URL=" | sed 's/.*URL=//;s/\"/ /' | awk '{print $1}')
		rm -f "$CB_ECLIPSE_JSON_MIRROR_INFO"
		rm -f "$CB_ECLIPSE_JSON_REDIRECT_INFO"
		[ -n "$realUrl" ] && CB_PACKAGE_DOWNLOAD_URL="$realUrl"
		[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Found mirror url: $CB_PACKAGE_DOWNLOAD_URL"
	fi

	mkdir -p "$CB_DEVTOOLS/$CB_PACKAGE_DEST_VERSION_NAME/bin"
	eclipseBin="$CB_DEVTOOLS/$CB_PACKAGE_DEST_VERSION_NAME/bin/eclipse.sh"
	echo "#!/bin/bash" >> "$eclipseBin"
	echo ". cb --setenv">> "$eclipseBin"
	echo "$CB_DEVTOOLS/$CB_PACKAGE_DEST_VERSION_NAME/eclipse/eclipse">> "$eclipseBin"

	unset CB_PACKAGE_SILENT_LOG
	unset CB_PACKAGE_USERAGENT
	unset CB_PACKAGE_COOKIE
	unset CB_CURL_CONTINUE
fi

export CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME CB_PACKAGE_VERSION_NAME CB_PACKAGE_NO_DEFAULT
