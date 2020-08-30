#!/bin/bash

#########################################################################
#
# read-version.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


# first parameter defines the versin file
# secomd parameter defines if the qualifier should be added or not (default true)
! [ -r "$1" ] && exit 1
addQualifier=true
[ -n "$2" ] && [ "$2" = "true" ] && addQualifier=true
[ -n "$2" ] && [ "$2" = "false" ] && addQualifier=false

majorNumber=$(cat "$1" | tr -d '\r' | grep major.number | awk '{print $3}')
minorNumber=$(cat "$1" | tr -d '\r' | grep minor.number | awk '{print $3}')
revisionNumber=$(cat "$1" | tr -d '\r' | grep revision.number | awk '{print $3}')
qualifier=$(cat "$1" | tr -d '\r' | grep qualifier | awk '{print $3}')
versionNumber=$majorNumber.$minorNumber.$revisionNumber

[ -n "$qualifier" ] && [ "$addQualifier" = "true"  ] && versionNumber=$versionNumber-$qualifier
export majorNumber minorNumber revisionNumber versionNumber qualifier
#echo $majorNumber $minorNumber $revisionNumber $qualifier $versonNumber 


#########################################################################
# EOF
#########################################################################
