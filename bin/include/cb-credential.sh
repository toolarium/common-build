#!/bin/bash

#########################################################################
#
# cb-credential.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


#########################################################################
# error handler
#########################################################################
errorhandler() {
    [ -n "$DEBUG" ] && echo "${CB_LINEHEADER}ERROR on line #$LINENO, last command: $BASH_COMMAND"
    exithandler
}


#########################################################################
# exit handler
#########################################################################
exithandler() {
	rm "$CB_PROJECT_CONFIGFILE_TMPFILE" >/dev/null 2>&1
}


#########################################################################
# End with error
#########################################################################
endWithError() {
	# custom setting script
	[ -n "$CB_CUSTOM_SETTING_SCRIPT" ] && eval ". $CB_CUSTOM_SETTING_SCRIPT error-end $*" 2>/dev/null
	exit 1
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
	echo " --verifyOnly         Verifies only the credentials."
	echo ""
}


#########################################################################
# main
#########################################################################
trap 'exithandler $?; exit' 0
trap 'errorhandler $?; exit' 1 2 3 15

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
	'aix') CB_OS="aix";;
	*) ;;
esac

GIT_USERNAME=
GIT_PASSWORD=
BASIC_AUTHENTICATION=
PRINT_CREDENTIAL=false
RAW_CREDENTIAL=false

while [ $# -gt 0 ]
do
    case "$1" in
		-h)				readVersion; printUsage; exit 0;;
		--help)			readVersion; printUsage; exit 0;;
		--raw) 			RAW_CREDENTIAL=true;;
		--print)		PRINT_CREDENTIAL="true";;
		--verifyOnly) 	VERIFY_ONLY="true";;
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

! [ -n "$CB_PARAMETERS" ] && echo "" && echo ".: ERROR: No url found. Please provide external git url." && echo "" && endWithError
urlProtocol=$(echo $CB_PARAMETERS | awk -F/ '{print $1}')
urlProtocol="${urlProtocol%*:}"
urlHost=$(echo $CB_PARAMETERS | awk -F/ '{print $3}')
! [ -n "$urlProtocol" ] && echo ".: ERROR: No protocol found." && endWithError
! [ -n "$urlHost" ] && echo ".: ERROR: No host found." && endWithError

if [ "$VERIFY_ONLY" = "true" ]; then
	if [ "$CB_OS" = "cygwin" ]; then
		printf "protocol=$urlProtocol\nhost=$urlHost\n" | git credential-manager get >/dev/null 2>&1
		[ $? -eq 0 ] && exit 0	
	else
		git ls-remote "$CB_PARAMETERS" >/dev/null 2>&1
		[ $? -eq 0 ] && exit 0
	fi
	exit 1
else
	credentials=$(printf "protocol=$urlProtocol\nhost=$urlHost\n" | git credential-manager get)
	GIT_USERNAME=$(echo "$credentials" | grep username= | sed 's/.*=//g')
	GIT_PASSWORD=$(echo "$credentials" | grep password=  | sed 's/.*=//g')

	if [ "$RAW_CREDENTIAL" = "false" ]; then
		BASIC_AUTHENTICATION=$(echo "${GIT_USERNAME}:${GIT_PASSWORD}" | base64)
		
		if [ "$PRINT_CREDENTIAL" = "true" ]; then
			echo "$BASIC_AUTHENTICATION" 
		else
			export BASIC_AUTHENTICATION
		fi
	else
		if [ "$PRINT_CREDENTIAL" = "true" ]; then
			echo "GIT_USERNAME=$GIT_USERNAME"
			echo "GIT_PASSWORD=$GIT_PASSWORD"
		else
			export GIT_USERNAME GIT_PASSWORD			
		fi
	fi
fi


#########################################################################
# EOF
#########################################################################