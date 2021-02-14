#!/bin/bash

#########################################################################
#
# lock-unlock.sh
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


[ -z "$CB_LINEHEADER" ] && CB_LINEHEADER=".: "
[ -z "$CB_INSTALL_SILENT" ] && CB_INSTALL_SILENT=false

#########################################################################
# lock
#########################################################################
lock() {
	lockFile=$1
	lockTimeout=$2
	[ -z "$lockTimeout" ] && lockTimeout=60
	
	lockTimeStamp=
	lockDifference=
	curentLockTimestamp=

	curentLockTimestamp=$(date '+%s')
	[ -r "$lockFile" ] && lockTimeStamp=$(cat $lockFile)
	[ -n "$lockTimeStamp" ] && lockDifference=$(expr $curentLockTimestamp - $lockTimeStamp)

	#echo diff $lockDifference $curentLockTimestamp $lockTimeStamp
	if [ -z "$lockDifference" ]; then
		echo "$curentLockTimestamp" > "$lockFile"
	else
		#echo check $lockDifference $lockTimeout
		[ $lockDifference -le $lockTimeout ] && [ "$CB_INSTALL_SILENT" = "false" ] && echo "${CB_LINEHEADER}Another process is already doing the update".
		[ $lockDifference -le $lockTimeout ] && exit 1
		echo "$curentLockTimestamp">"$lockFile"
	fi
}


#########################################################################
# unlock
#########################################################################
unlock() {
	[ -f "$1" ] && rm -f "$1" >/dev/null 2>&1
}


#########################################################################
# main
#########################################################################
[ $# -le 0 ] && exit

if [ -n "$1" ] && [ "$1" = "--unlock" ]; then
	shift 
	unlock $@
else
	lock $@
fi


#########################################################################
# EOF
#########################################################################