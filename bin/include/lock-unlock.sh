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
	lockFile="$1"
	[ -z "$lockFile" ] && lockFile="lockfile"
	lockTimeout=$2
	[ -z "$lockTimeout" ] && lockTimeout=60
	processId=$3
	[ -z "$processId" ] && processId=$PPID

	lockTimeStamp=
	lockDifference=
	lockProcessId=0
	curentLockTimestamp=$(date '+%s')

	if [ -r "$lockFile" ]; then
		lockTimeStamp=$(cat $lockFile | awk -F= '{print $1}')
		lockProcessId=$(cat $lockFile | awk -F= '{print $2}')
	fi
	[ -n "$lockTimeStamp" ] && lockDifference=$(expr $curentLockTimestamp - $lockTimeStamp)

	#echo diff $lockDifference $curentLockTimestamp $lockTimeStamp
	if [ -z "$lockDifference" ]; then
		echo "$curentLockTimestamp=$processId" > "$lockFile"
	else
		lockFilePath="${lockFile%/*}"
		lockFileName="${lockFile##*/}"
		
		[ "$lockFilePath" == "$lockFileName" ] && lockFilePath="."
		#echo "${CB_LINEHEADER}[$lockFilePath][${lockFileName}], $lockTimeStamp, id: $lockProcessId - current:$curentLockTimestamp, id: $processId - diff: $lockDifference"
	
		#echo check $lockDifference $lockTimeout
		if [ "$lockProcessId" -eq "$processId" ]; then
			deleteLock "$lockFile" 
			lockDifference=$curentLockTimestamp
		fi
		
		[ $lockDifference -le $lockTimeout ] && [ "$CB_INSTALL_SILENT" = "false" ] && echo "${CB_LINEHEADER}Another process is already doing the update, pid:$lockProcessId."
		[ $lockDifference -le $lockTimeout ] && exit 1
		echo "$curentLockTimestamp=$processId">"$lockFile"
	fi
}


#########################################################################
# unlock
#########################################################################
unlock() {
	lockFile="$1"
	[ -z "$lockFile" ] && lockFile="lockfile"

	deleteLock "$lockFile"
}


#########################################################################
# deleteLock
#########################################################################
deleteLock() {
	[ -f "$1" ] && rm -f "$1" >/dev/null 2>&1
}


#########################################################################
# main
#########################################################################
[ $# -le 0 ] && exit

if [ -n "$1" ] && [ "$1" = "--unlock" ]; then
	shift 
	unlock $@
elif [ -n "$1" ] && [ "$1" = "--lock" ]; then
	shift 
	lock $@
else
	lock $@
fi


#########################################################################
# EOF
#########################################################################