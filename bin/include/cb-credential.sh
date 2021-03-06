#!/bin/bash

#########################################################################
#
# cb-credential.sh
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
PRINT_CREDENTIAL=false
RAW_CREDENTIAL=false


#########################################################################
# End with error
#########################################################################
endWithError() {
	exit 1
}


#########################################################################
# Print credentials
#########################################################################
printCredentials() {
	if [ "$RAW_CREDENTIAL" = "false" ]; then
		echo "$GIT_USERNAME:$GIT_PASSWORD" | base64
	else
		echo "$CB_GIT_USERNAME_KEY=$GIT_USERNAME" 
		echo "$CB_GIT_PASSWORD_KEY=$GIT_PASSWORD"
	fi
}


#########################################################################
# Read git credentials
#########################################################################
readGitCredentials() {
	GIT_USERNAME=""
	GIT_PASSWORD=""

	requestString="\nprotocol=$1\nhost=$2\n"
	[ -n "$3" ] && requestString="${requestString}port=$3\n"
	gitCredentials=$(echo -e "$requestString" | $GIT_CLIENT credential-store get 2>/dev/null)
	[ -z "$gitCredentials" ] && return 1	
	GIT_USERNAME=$(echo "$gitCredentials" | grep username | cut -d'=' -f2-)
	GIT_PASSWORD=$(echo "$gitCredentials" | grep password | cut -d'=' -f2-)
}


#########################################################################
# Parse git credentials
#########################################################################
parseGitCredentials() {
	GIT_USERNAME=""
	GIT_PASSWORD=""
	
	! [ -r "$GIT_CREDENTIALS_FILE" ] && return 1
	fullHost="$2"
	[ -n "$3" ] && fullHost="${fullHost}%3a$3"
	gitCredentials=$(cat "$GIT_CREDENTIALS_FILE" | grep "$1://" | grep "\@$fullHost")
	[ -z "$gitCredentials" ] && return 1	
	extractedCrednetials=$(echo "$gitCredentials" | cut -d"/" -f2- | cut -d"/" -f2- | sed "s/$fullHost.*//")
	GIT_USERNAME=$(echo "${extractedCrednetials%%:*}")
	GIT_PASSWORD=$(echo "${extractedCrednetials#*:}")
}


#########################################################################
# printUsage
#########################################################################
printUsage() {
	echo "$PN - get credentials of an url."
	echo "usage: $PN [OPTION] GIT-URL"
	echo ""
	echo "Overview of the available OPTIONs:"
	echo " -h, --help           Show this help message."
	echo " --raw                Return the plaintext credentials; otherwise its a"
	echo "                      BASIC_AUTHENTICATION string."
	echo " --print              Print the credentials: either as plaintext in combination"
	echo "                      with parameter raw or the BASIC_AUTHENTICATION string."
	echo "                      In case of not print parameter the environment"
	echo "                      variable will be set GIT_USERNAME, GIT_PASSWORD or"
	echo "                      BASIC_AUTHENTICATION"
	echo " --grgit              Return the plaintext credentials compatible with grgit"
	echo " --verifyOnly         Verifies only the credentials."
	echo ""
}


#########################################################################
# url encode
#########################################################################
urlEncode() {
	#echo -e "$1" | od -An -tx1 | tr ' ' % | xargs printf "%s"
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            #*) printf '%%%02X' "'$c" ;;
			*) printf '%%%02X' "'$c"
        esac
    done

    LC_COLLATE=$old_lc_collate
}


#########################################################################
# main
#########################################################################
CB_OS="$(uname | tr '[:upper:]' '[:lower:]')"
CB_OS=$(echo "$CB_OS" | awk '{print substr($0, 0, 7)}')
case $CB_OS in
	'linux') CB_OS="linux";;
	'freebsd') CB_OS="freebsd";;
	'windows') CB_OS="windows";;
	'mac') CB_OS="mac";;
	'darwin') CB_OS="mac";;
	'sunos') CB_OS="solaris";;
	'cygwin') CB_OS="cygwin";;
	'cygwin_') CB_OS="cygwin";;
	'mingw32') CB_OS="cygwin";;
	'mingw64') CB_OS="cygwin";;
	'aix') CB_OS="aix";;
	*) ;;
esac

GIT_USERNAME=
GIT_PASSWORD=
GRGIT_USER=
GRGIT_PASSWORD=
BASIC_AUTHENTICATION=
GRGIT="false"
CB_GIT_USERNAME_KEY="GIT_USERNAME"
CB_GIT_PASSWORD_KEY="GIT_PASSWORD"

while [ $# -gt 0 ]
do
    case "$1" in
		-h)				readVersion; printUsage; exit 0;;
		--help)			readVersion; printUsage; exit 0;;
		--raw) 			RAW_CREDENTIAL=true;;
		--print)		PRINT_CREDENTIAL="true";;
		--verifyOnly) 	VERIFY_ONLY="true";;
		--grgit)		CB_GIT_USERNAME_KEY="GRGIT_USER" && CB_GIT_PASSWORD_KEY="GRGIT_PASS";;
		*)				CB_PARAMETERS="$CB_PARAMETERS $1";;
    esac
    shift
done

if [ -z "$GIT_CLIENT" ]; then
	if eval "$CB_HOME/current/git/bin/git --version" >/dev/null 2>&1; then	
		GIT_CLIENT="$CB_HOME/current/git/bin/git"
	elif eval "git --version" >/dev/null 2>&1; then
		GIT_CLIENT="git"
	fi
fi

if ! eval $GIT_CLIENT --version >/dev/null 2>&1; then
	echo "" 
	echo ".: ERROR: No git client found."
	echo "" 
	endWithError
fi


if ! [ -n "$CB_PARAMETERS" ]; then
	[ -r "$PWD/.git/config" ] && CB_PARAMETERS=$(cat "$PWD/.git/config" | grep url | grep http | awk -F= '{print $2}')
fi

CB_PARAMETERS=$(echo $CB_PARAMETERS | sed 's/ //g')
! [ -n "$CB_PARAMETERS" ] && echo "" && echo ".: ERROR: No url found. Please provide external git url." && echo "" && endWithError
urlProtocol=$(echo $CB_PARAMETERS | awk -F/ '{print $1}') && urlProtocol="${urlProtocol%*:}"
! [ -n "$urlProtocol" ] && echo ".: ERROR: No protocol found." && endWithError
urlHost=$(echo $CB_PARAMETERS | awk -F/ '{print $3}')
urlPort=$(echo $urlHost | cut -d":" -f2-)
[ "$urlPort" = "$urlHost" ] && urlPort="" || urlHost=$(echo $urlHost | cut -d":" -f1)
! [ -n "$urlHost" ] && echo ".: ERROR: No host found." && endWithError

initStoreFile=false
defaultLocation=false
credentialHelper=$($GIT_CLIENT config --global credential.helper | awk '{print $2}')
[ -z "$credentialHelper" ] && initStoreFile=true
[ "store" = "$credentialHelper" ] && initStoreFile=true && GIT_CREDENTIALS_FILE=$(echo $credentialHelper | awk '{print $3}')

if [ "$initStoreFile" = "true" ]; then
	[ -z "$GIT_CREDENTIALS_FILE" ] && GIT_CREDENTIALS_FILE="$HOME/.git-credentials" && defaultLocation=true
	! [ -r "$GIT_CREDENTIALS_FILE" ] && touch "$GIT_CREDENTIALS_FILE" >/dev/null 2>&1 && chmod 600 "$GIT_CREDENTIALS_FILE" >/dev/null 2>&1
	! [ -r "$GIT_CREDENTIALS_FILE" ] && echo ".: ERROR: Could not initialize $GIT_CREDENTIALS_FILE" && echo "" && endWithError
	if [ -z "$($GIT_CLIENT config --global credential.helper)" ]; then
		[ "$VERIFY_ONLY" = "true" ] && echo ".: Set git credential store"	
		if [ "$defaultLocation" = "true" ]; then
			eval "$GIT_CLIENT config --global credential.helper store"
		else
			eval "$GIT_CLIENT config --global credential.helper 'store --file $GIT_CREDENTIALS_FILE'"
		fi
	fi
	
	parseGitCredentials "$urlProtocol" "$urlHost" "$urlPort"
else
	readGitCredentials "$urlProtocol" "$urlHost" "$urlPort"
fi

errorCode=0
if [ -n "$GIT_USERNAME" ]; then
	$GIT_CLIENT ls-remote "$CB_PARAMETERS" >/dev/null 2>&1	
	errorCode=$?	
	[ "$VERIFY_ONLY" = "true" ] && exit $errorCode
	if [ $errorCode -eq 0 ]; then
		[ "$PRINT_CREDENTIAL" = "true" ] && printCredentials
		exit 0
	fi
else
	[ "$VERIFY_ONLY" = "true" ] && exit 1
fi

if [ "$initStoreFile" = "true" ]; then
	echo ".: Please enter credentials to access [$CB_PARAMETERS]. It will be stored in [$GIT_CREDENTIALS_FILE]."
	read -p ".: Username: " GIT_USERNAME
	read -s -p ".: Passord: " GIT_PASSWORD
	echo ""
	requestString="$requestString\nusernam=$GIT_USERNAME\npassword=$GIT_PASSWORD\n"
	#GIT_PASSWORD=$(urlEncode $GIT_PASSWORD)

	if [ -z "$urlPort" ]; then
		fileContent=$(cat "$GIT_CREDENTIALS_FILE" | grep -v "@$urlHost" | grep -v "")
		[ -n "$fileContent" ] && echo "$fileContent" > "$GIT_CREDENTIALS_FILE" || echo -n "" > "$GIT_CREDENTIALS_FILE"
		echo "$urlProtocol://$GIT_USERNAME:$GIT_PASSWORD@$urlHost" >> "$GIT_CREDENTIALS_FILE"
	else
		fileContent=$(cat "$GIT_CREDENTIALS_FILE" | grep -v "@${urlHost}%3a$urlPort" | grep -v "")
		[ -n "$fileContent" ] && echo "$fileContent" > "$GIT_CREDENTIALS_FILE" || echo -n "" > "$GIT_CREDENTIALS_FILE"
		echo "$urlProtocol://$GIT_USERNAME:$GIT_PASSWORD@${urlHost}%3a$urlPort" >> "$GIT_CREDENTIALS_FILE"
	fi
fi

# try again
$GIT_CLIENT ls-remote "$CB_PARAMETERS" >/dev/null 2>&1
if [ $? -eq 0 ]; then
	[ "$PRINT_CREDENTIAL" = "true" ] && printCredentials
	exit 0
fi

echo "" 
echo ".: ERROR: Could not access [$CB_PARAMETERS] with given credentials ($GIT_USERNAME)!" 
echo "" 
endWithError


#########################################################################
# EOF
#########################################################################