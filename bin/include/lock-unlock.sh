#!/bin/bash

#########################################################################
#
# lock-unlock.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
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