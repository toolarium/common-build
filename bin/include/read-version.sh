#!/bin/bash

#########################################################################
#
# read-version.sh
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
