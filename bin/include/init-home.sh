#!/bin/bash

#########################################################################
#
# init-home.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


#########################################################################
# getGitCredentials
#########################################################################
getGitCredentials() {
	eval ". ${CB_SCRIPT_PATH}/include/cb-credential.sh --raw $1"
	! [ $? -eq 0 ] && return 1	
	GRGIT_USER="${GIT_USERNAME}" 
	GRGIT_PASS="${GIT_PASSWORD}"
	GIT_USERNAME=""
	GIT_PASSWORD=""	
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Valid credentials for [$commonGradleBuildHomeGitUrl], user [$GRGIT_USER]."	
	export GRGIT_USER GRGIT_PASS
}


#########################################################################
# readLastVersion
#########################################################################
readLastVersion() {
	CB_CUSTOM_CONFIG_VERSION=$(find $CB_CUSTOM_CONFIG_PATH -maxdepth 1 -type d 2>/dev/null | tail -1 2>/dev/null | xargs -l basename 2>/dev/null)
	CB_CUSTOM_CONFIG_VERSION="${CB_CUSTOM_CONFIG_VERSION% *}"
}


#########################################################################
# updateError
#########################################################################
updateError() {
	errorMsg="Could not get repository from $commonGradleBuildHomeGitUrl"
	[ "$credentialCheck" = "true" ] && errorMsg="$errorMsg, unknown reason (valid credentials)."
	[ "$credentialCheck" = "false" ] && errorMsg="$errorMsg because of invalid crednetials."
	[ "$commonGradleBuildHomeUpdated" = "false" ] && errorMsg="$errorMsg (not found)"
	echo "$CB_LINEHEADER$errorMsg:"
	echo "   $commonGradleBuildHomeGitUrl"
	echo ""
	echo "Windows credentials can be managed with the commands:"
	echo "    rundll32.exe keymgr.dll,KRShowKeyMgr"
	echo "or "
	echo "    control.exe keymgr.dll"
	echo ""
}


#########################################################################
# main
#########################################################################
forceInstallation=false
[ $# -eq 0 ] && echo "${CB_LINEHEADER}ERROR: No parameter found." && exit 1
[ "$1" = "--force" ] && shift && forceInstallation=true
[ -z "$1" ] && echo "${CB_LINEHEADER}ERROR: No path defined where to init or update." && exit 1
[ -z "$2" ] && echo "${CB_LINEHEADER}ERROR: No url defined to init or update." && exit 1

CB_CUSTOM_CONFIG_PATH="$1"
commonGradleBuildHomeGitUrl="$2"

[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Prepare check upate of [${commonGradleBuildHomeGitUrl}]."

# if we don't force, just read last version and get credentials (in case of a private repo)
if [ "$forceInstallation" = "false" ]; then
	getGitCredentials "$commonGradleBuildHomeGitUrl"
	readLastVersion
else
	# check git installation
	credentialCheck=false
	
	if ! eval "git --version > /dev/null 2>&1"; then
		echo "$CB_LINE"
		echo "${CB_LINEHEADER}Missing package git, please install it before you continue."
		echo "$CB_LINE"
		exit 1
	fi

	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Verify git repository [$commonGradleBuildHomeGitUrl]."
	if ! eval "git ls-remote \"$commonGradleBuildHomeGitUrl\" >/dev/null 2>&1"; then
		[ $? -eq 128 ] && credentialCheck=false || credentialCheck=true
		updateError
		exit 1
	fi 
	credentialCheck=true
	commonGradleBuildHomeUpdated=false
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Valid access to [$commonGradleBuildHomeGitUrl]."

	# work around, create an empty project for the first update
	tempProjectName=$(mktemp -d /tmp/common-gradle-build-home-update.XXXXXXXXX)
	echo "apply from: \"https://git.io/JfDQT\"" > "$tempProjectName/build.gradle"

	if ! getGitCredentials "$commonGradleBuildHomeGitUrl"; then
		updateError
		exit 1
	fi
	
	echo "${CB_LINEHEADER}Check and update custom config from repository [$commonGradleBuildHomeGitUrl]."
	commonGradleBuildHomeUpdateLog="$CB_HOME/logs/common-gradle-build-home-update-$(date '+%Y%m%d%H%M%S').log"
	#echo cd $tempProjectName && $CB_HOME/bin/cb --silent -q --no-daemon -m \"-PcommonGradleBuildHomeGitUrl=$commonGradleBuildHomeGitUrl\"
	if ! eval "cd $tempProjectName && $CB_HOME/bin/cb --no-daemon -m \"-PcommonGradleBuildHomeGitUrl=$commonGradleBuildHomeGitUrl\"" > "$commonGradleBuildHomeUpdateLog"; then
		updateError
	else
		commonGradleBuildHomeUpdated=true		
		if eval "grep \"Could not read remote version\" $commonGradleBuildHomeUpdateLog" > /dev/null; then
			commonGradleBuildHomeUpdated=false
			updateError			
		fi
		
		readLastVersion
	fi
	
	cd $CB_WORKING_PATH >/dev/null 2>&1
	rm -rf "$tempProjectName" >/dev/null 2>&1
fi


#########################################################################
#  EOF
#########################################################################