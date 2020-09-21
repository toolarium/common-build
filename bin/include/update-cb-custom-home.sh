#!/bin/bash

#########################################################################
#
# update-cb-custom-home.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################



#########################################################################
# updateError
#########################################################################
updateError() {
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
		
	errorMsg="Could not get repository from $commonGradleBuildHomeGitUrl"
	[ "$credentialCheck" = "true" ] && errorMsg="$errorMsg, unknown reason (valid credentials)."
	[ "$credentialCheck" = "false" ] && errorMsg="$errorMsg because of invalid crednetials."
	[ "$commonGradleBuildHomeUpdated" = "false" ] && errorMsg="$errorMsg (not found)"
	echo "$CB_LINEHEADER$errorMsg:"
	echo "   $commonGradleBuildHomeGitUrl"
	echo ""
	
	if [ "$CB_OS" = "cygwin" ]; then
		echo "Windows credentials can be managed with the commands:"
		echo "    rundll32.exe keymgr.dll,KRShowKeyMgr"
		echo "or "
		echo "    control.exe keymgr.dll"
		echo ""
	fi
}


#########################################################################
# main
#########################################################################
[ -z "$CB_LINEHEADER" ] && CB_LINEHEADER=".: "
[ -z "$CB_VERBOSE" ] && CB_VERBOSE=true
[ -z "$CB_INSTALL_SILENT" ] && CB_INSTALL_SILENT=false
[ -z "$1" ] && echo "${CB_LINEHEADER}ERROR: No path defined where to init or update." && exit 1
[ -z "$2" ] && echo "${CB_LINEHEADER}ERROR: No url defined to init or update." && exit 1

CB_CUSTOM_CONFIG_PATH="$1"
commonGradleBuildHomeGitUrl="$2"
LOCKFILE="$CB_CUSTOM_CONFIG_PATH/.lock"

[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Check [${commonGradleBuildHomeGitUrl}] for updates."

if ! eval "$CB_HOME/bin/include/lock-unlock.sh" "$LOCKFILE" 60; then
	exit 1
fi
setLockFile=true

if ! eval "git --version > /dev/null 2>&1"; then
	echo "$CB_LINE"
	echo "${CB_LINEHEADER}Missing package git, please install it before you continue."
	echo "$CB_LINE"
	eval "$CB_HOME/bin/include/lock-unlock.sh" --unlock "$LOCKFILE"
	exit 1
fi

#[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Found valid git client installation."

# verfiy url
credentialCheck=false
[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Verify git repository [$commonGradleBuildHomeGitUrl]."
if ! eval "$CB_HOME/bin/include/cb-credential.sh \"$commonGradleBuildHomeGitUrl\""; then
	updateError
	eval "$CB_HOME/bin/include/lock-unlock.sh" --unlock "$LOCKFILE"
	exit 1
fi 

credentialCheck=true
commonGradleBuildHomeUpdated=false
[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Valid access to [$commonGradleBuildHomeGitUrl]."

# create temp path
UPDATE_CB_CUSTOM_PATH="$CB_CUSTOM_CONFIG_PATH/unknown"
mkdir -p "$CB_CUSTOM_CONFIG_PATH" >/dev/null 2>&1
rm -rf "$UPDATE_CB_CUSTOM_PATH" >/dev/null 2>&1

[ "$CB_INSTALL_SILENT" = "false" ] && echo "${CB_LINEHEADER}Check and update custom config from repository [$commonGradleBuildHomeGitUrl]."
GIT_CB_CUSTOM_PATH="$UPDATE_CB_CUSTOM_PATH"
[ "$CB_OS" = "cygwin" ] && GIT_CB_CUSTOM_PATH=$(cygpath.exe -w $GIT_CB_CUSTOM_PATH)
if git clone -q "$commonGradleBuildHomeGitUrl" "$GIT_CB_CUSTOM_PATH"; then
	commonGradleBuildHomeUpdated=true
else
	updateError
	eval "$CB_HOME/bin/include/lock-unlock.sh" --unlock "$LOCKFILE"
	exit 1
fi

if [ "$commonGradleBuildHomeUpdated" = "false" ]; then
	rm -rf "$UPDATE_CB_CUSTOM_PATH" 
	updateError
	eval "$CB_HOME/bin/include/lock-unlock.sh" --unlock "$LOCKFILE"
	exit 1
fi

# read version
eval ". \"$CB_HOME/bin/include/read-version.sh\" ${UPDATE_CB_CUSTOM_PATH}/VERSION false"
CB_CUSTOM_CONFIG_VERSION="$versionNumber"

# if defined qualifier 
if [ -d "$CB_CUSTOM_CONFIG_PATH/$CB_CUSTOM_CONFIG_VERSION" ]; then
	rm -rf "$UPDATE_CB_CUSTOM_PATH"
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Newest version $CB_CUSTOM_CONFIG_VERSION is already available."
else
	# use newer version
	rm -rf "$UPDATE_CB_CUSTOM_PATH/gradle/wrapper" >/dev/null 2>&1
	[ -z "$CB_CUSTOM_CONFIG_IGNORE_FILES" ] && CB_CUSTOM_CONFIG_IGNORE_FILES="gradlew gradlew.bat .editorconfig .gitattributes .gitignore build.gradle gradle.properties settings.gradle README.md"
	for i in $CB_CUSTOM_CONFIG_IGNORE_FILES; do
		[ -r "$UPDATE_CB_CUSTOM_PATH/$i" ] && rm -f "$UPDATE_CB_CUSTOM_PATH/$i" >/dev/null 2>&1 
	done
	mv "$UPDATE_CB_CUSTOM_PATH" "$CB_CUSTOM_CONFIG_PATH/$CB_CUSTOM_CONFIG_VERSION" >/dev/null 2>&1 
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Successful updated version $CB_CUSTOM_CONFIG_VERSION in [$CB_CUSTOM_CONFIG_PATH]."
	[ "$CB_INSTALL_SILENT" = "false" ] && echo "${CB_LINEHEADER}Successful updated version $CB_CUSTOM_CONFIG_VERSION."
fi

eval "$CB_HOME/bin/include/lock-unlock.sh" --unlock "$LOCKFILE"


#########################################################################
#  EOF
#########################################################################