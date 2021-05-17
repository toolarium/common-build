#!/bin/bash

#########################################################################
#
# hashCode.sh
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


#########################################################################
# Calculate the hash code of a string compatible with java hashCode
#########################################################################
hashCode() {
    o="$@"
    h="0"
    for j in $(seq 1 ${#o}); do
        a=$((j-1))
        v=$(echo -n "${o:$a:1}" | od -d)
        h=$((31 * $h + ${v:10:3} ))
        h=$(( (2**31-1) & $h ))
    done
    echo $h
}

hashCode "$@"


#########################################################################
# EOF
#########################################################################
