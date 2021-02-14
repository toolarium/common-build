#!/bin/bash

#########################################################################
#
# cb-install-check.sh
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


PROTOCOL_LOG="/tmp/cb-install-check.log"


#########################################################################
# getTimestamp
#########################################################################
getTimestamp() {
	[ "$CB_OS" = "mac" ] && date '+%Y-%m-%d %H:%M:%S' || date '+%Y-%m-%d %H:%M:%S.%N' | cut -b1-23
}
[ -z "$CB_START_TIMESTAMP" ] && CB_START_TIMESTAMP=$(getTimestamp 2>/dev/null)
export CB_START_TIMESTAMP


#########################################################################
# protocol header
#########################################################################
protocolHeader() {
	echo "" >> "$PROTOCOL_LOG"
	echo "----------------------------------------------------------------------------------------" >> "$PROTOCOL_LOG"
	echo ".:$@"
	echo "$@" >> "$PROTOCOL_LOG"
	echo "----------------------------------------------------------------------------------------" >> "$PROTOCOL_LOG"
}


#########################################################################
# protocol
#########################################################################
protocol() {
	PARAMETERS_FILTER=""
	PARAMETERS="$@"

	[ "$1" = "ls" ] && PARAMETERS_FILTER=" | egrep -v '\.$' | egrep -v '^total.*'"
	[ "$1" = "cat" ] && PARAMETERS_FILTER=" | grep -v '#'"

	echo ".: $PARAMETERS" >> "$PROTOCOL_LOG"
	PARAMETERS="${PARAMETERS}${PARAMETERS_FILTER}"
	eval "$PARAMETERS" 2>/dev/null >> "$PROTOCOL_LOG"
	echo "" >> "$PROTOCOL_LOG"
}


#########################################################################
# main
#########################################################################
rm -f "$PROTOCOL_LOG"

# detect the platform (similar to $OSTYPE)
CB_OS=$(uname | tr '[:upper:]' '[:lower:]' | awk '{print substr($0, 0, 7)}')
CB_OS_RELEASE=$(uname -r)
CB_MACHINE="$(uname -m | tr '[:upper:]' '[:lower:]')"

protocolHeader "Protocol common build installation ($CB_OS, $CB_OS_RELEASE, $CB_MACHINE), $CB_START_TIMESTAMP"
protocolHeader "Analyse common build..."
protocol cb --version
protocol echo $CB_HOME
protocol ls -ltra $CB_HOME/../

protocolHeader "Analyse common build configuration..."
if [ -d "$HOME/.common-build" ]; then
	protocol ls -ltra $HOME/.common-build/conf/
	protocol cat $HOME/.common-build/conf/.cb-custom-config
	
	for i in $(ls -tr "$HOME/.common-build/conf/"); do
		protocol ls -ltra $HOME/.common-build/conf/$i
		protocol cat $HOME/.common-build/conf/$i/lastCheck.properties
	done
else
	echo "n/a">> "$PROTOCOL_LOG"
fi

protocolHeader "Analyse common gradle build..."
if [ -d "$HOME/.gradle/common-gradle-build" ]; then
	protocol ls -ltra $HOME/.gradle/common-gradle-build
	protocol cat $HOME/.gradle/common-gradle-build/lastCheck.properties
else
	echo "n/a">> "$PROTOCOL_LOG"
fi

protocolHeader "Protocol you find: $PROTOCOL_LOG"


#########################################################################
# EOF
#########################################################################