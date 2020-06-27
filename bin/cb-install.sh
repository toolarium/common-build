#!/bin/sh

#########################################################################
#
# cb-install.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


# define defaults
[ -z "$CB_DEVTOOLS_NAME" ] && CB_DEVTOOLS_NAME=devtools
[ -z "$CB_DEVTOOLS" ] && CB_DEVTOOLS="$HOME/$CB_DEVTOOLS_NAME"
#[ -z "`echo $OSTYPE | sed 's/cygwin.*//'`" ] && CLASSSEP=";" || CLASSSEP=":"

# define parameters
CB_LINE="----------------------------------------------------------------------------------------"
PN=`basename "$0"`
REL_PROG_PATH="${0%/*}"
ABS_PROG_PATH=$(cd -- "`dirname $0`" && pwd)
PN_BASE="${PN%*.sh}"

CB_FORCE_INSALL=false
CB_INSTALLER_VERSION=1.0.0
CB_RELEASE_URL=https://api.github.com/repos/toolarium/common-build/releases
USER_FRIENDLY_FULLTIMESTAMP="date '+%d.%m.%Y %H:%M:%S'"
cbErrorTemp=/tmp/toolarium-common-build_error.txt


#########################################################################
# Usage
#########################################################################
Usage() {
	echo "$PN - toolarium common build installer v$CB_INSTALLER_VERSION"
	echo "usage: $PN [OPTION]"
	echo ""
	echo "Overview of the available OPTIONs:"
	echo " -h, --help                Show this help message."
	echo " -v, --version             Print version information."
	echo " --force                   Force to reinstall the common-build."
	echo ""
}


#########################################################################
# Version
#########################################################################
Version() {
	echo "$CB_LINE"
	echo "toolarium common build installer $CB_INSTALLER_VERSION"
	echo "$CB_LINE"
	echo ""
}


#########################################################################
# installationSuccess
#########################################################################
installationSuccess() {
	echo ""
	echo "$CB_LINE"
	echo "Successfully installed toolarium-common-build v$CB_REMOTE_VERSION"
	echo "in folder $CB_HOME. "
	echo ""
	echo "The \$PATH is already extended and you can start working with it with the command cb!"
	echo "$CB_LINE"
}


#########################################################################
# installationFailed
#########################################################################
installationFailed() {
	echo ""
	echo "$CB_LINE"
	echo "Failed installation: $1"
 	[ -r "$cbErrorTemp" ] && echo "" && cat $cbErrorTemp 2>/dev/null
	echo "$CB_LINE"
}


#########################################################################
# checkInternetConnection
#########################################################################
checkInternetConnection() {
	if [ "$OSTYPE" = "linux"* ]; then
		ping 8.8.8.8 -c 1 -w 1 >/dev/null 2>&1
	elif [ "$OSTYPE" = "cygwin" ]; then
		ping 8.8.8.8 1 1 >/dev/null 2>&1
	elif [ "$OSTYPE" = "win32" ]; then
		ping 8.8.8.8 -n 1 -w 1000 >/dev/null 2>&1
	#elif [ "$OSTYPE" = "darwin"* ]; then
	#	echo "" > /dev/null
	else
		echo "" > /dev/null
	fi
	
	if ! [ $? -eq 0 ]; then 
		installationFailed "No internet connection detected!"
		exit 1
	fi
}


#########################################################################
# checkHttpRequestCLI
#########################################################################
checkHttpRequestCLI() {
	which curl >/dev/null 2>&1
	[ $? -eq 0 ] && echo "curl" && return
	
	which wget >/dev/null 2>&1
	[ $? -eq 0 ] && echo "wget" && return
	echo ""
}


#########################################################################
# getLatestRelease
#########################################################################
getLatestRelease() {
    if [ "$HTTP_REQUEST_CLI" = "curl" ]; then	
		CMD="curl -s $CB_RELEASE_URL"
    else
		CMD="wget -q --header=\"Accept: application/json\" -O - $CB_RELEASE_URL"
    fi

	CMD="$CMD 2>$cbErrorTemp | grep \"tag_name\" | awk '{print \$2}' |  sed -n 's/\"\(.*\)\",/\1/p'"
	eval $CMD
	
	[ -r $cbErrorTemp ] && [ $(stat -c %s $cbErrorTemp) -eq 0 ] && rm -f $cbErrorTemp >/dev/null 2>&1
}


#########################################################################
# getReleaseDownloadUrl
#########################################################################
getReleaseDownloadUrl() {
    if [ "$HTTP_REQUEST_CLI" = "curl" ]; then
		CMD="curl -s $CB_RELEASE_URL"
    else
		CMD="wget -q --header=\"Accept: application/json\" -O - $CB_RELEASE_URL"
	fi

	CMD="$CMD 2>$cbErrorTemp | grep \"tarball_url\" | awk '{print \$2}' |  sed -n 's/\"\(.*\)\",/\1/p'"
	eval $CMD
	
	[ -r $cbErrorTemp ] && [ $(stat -c %s $cbErrorTemp) -eq 0 ] && rm -f $cbErrorTemp >/dev/null 2>&1
}


#########################################################################
# downloadRelease
#########################################################################
downloadRelease() {
    if [ "$HTTP_REQUEST_CLI" = "curl" ]; then
        curl -SsL "$1" -o "$2" 2>$cbErrorTemp
    else
        wget -q -O "$2" "$1" 2>$cbErrorTemp
    fi
}

#########################################################################
# error handler
#########################################################################
errorhandler() {
    [ -n "$DEBUG" ] && echo "ERROR on line #$LINENO, last command: $BASH_COMMAND"
    exithandler
}


#########################################################################
# exit handler
#########################################################################
exithandler() {
	rm -f $cbErrorTemp >/dev/null 2>&1
}


#########################################################################
# main
#########################################################################
trap 'exithandler $?; exit' 0
trap 'errorhandler $?; exit' 1 2 3 15

# check curl
while [ $# -gt 0 ]
do
    case "$1" in
	-h)	Usage; exit 0;;
	--help)	Usage; exit 0;;
	-v)	Version; exit 0;;
	--version)	Version; exit 0;;
	--force)	CB_FORCE_INSALL=true;;	
	*)	break;;
    esac
    shift
done

echo "$CB_LINE"
echo "Started toolarium-common-build installation on `hostname`, `eval $USER_FRIENDLY_FULLTIMESTAMP`"
echo "-Use $CB_DEVTOOLS path as devtools folder"
echo "$CB_LINE"
read -p "Press any key to continue..." input
echo ""

HTTP_REQUEST_CLI=$(checkHttpRequestCLI)
[ -n "$releaseVersion" ] && installationFailed "Either curl or wget is required.!\nPlease install curl package (e.g. sudo apt install curl)" && exit 1

checkInternetConnection
echo "-Check newest version of toolarium-common-build..."
releaseVersion=$(getLatestRelease)
[ -z "$releaseVersion" ] && installationFailed "Could not get remote release information!" && exit 1
echo "-Latest version of common-build is $releaseVersion, select download link"
downloadUrl=$(getReleaseDownloadUrl)
[ -z "$downloadUrl" ] && installationFailed "Could not get download url of verison $releaseVersion!" && exit 1
rm -f $cbErrorTemp >/dev/null 2>&1
CB_VERSION_NAME="toolarium-common-build-$releaseVersion"

# create directories
! [ -d $CB_DEVTOOLS ] && mkdir $CB_DEVTOOLS >/dev/null 2>&1 && echo "-Create directory $CB_DEVTOOLS"
CB_DEV_REPOSITORY="$CB_DEVTOOLS/.repository" 
! [ -d $CB_DEV_REPOSITORY ] && mkdir $CB_DEV_REPOSITORY >/dev/null 2>&1

# download toolarium-common-build
[ "$CB_FORCE_INSALL" = "true" ] && rm -f $CB_DEV_REPOSITORY/$CB_VERSION_NAME.tgz >/dev/null 2>&1
if [ -r $CB_DEV_REPOSITORY/$CB_VERSION_NAME.tgz ]; then
	echo "-Found already downloaded version, $CB_DEV_REPOSITORY/$CB_VERSION_NAME.tgz" 
else
	echo "-Install $CB_VERSION_NAME"
	downloadRelease $downloadUrl $CB_DEV_REPOSITORY/$CB_VERSION_NAME.tgz

	# in case we donwload a new version we also extract new!
	! [ -r $CB_DEV_REPOSITORY/$CB_VERSION_NAME.tgz ] && installationFailed "Could not download v$releaseVersion!"
	[ $(stat -c %s $CB_DEV_REPOSITORY/$CB_VERSION_NAME.tgz) -le 0 ] && rm -rf $CB_DEVTOOLS/$CB_VERSION_NAME >/dev/null 2>&1
fi

if ! [ -r "$CB_DEVTOOLS/$CB_VERSION_NAME" ]; then 
	tar -zxf $CB_DEV_REPOSITORY/$CB_VERSION_NAME.tgz -C $CB_DEV_REPOSITORY/
	tarContentName=$(find $CB_DEV_REPOSITORY/* -type d -name toolarium-common-build-* -print 2>/dev/null)
	mv  $tarContentName $CB_DEVTOOLS/$CB_VERSION_NAME
		
	# remove unecessary files
	rm $CB_DEVTOOLS/$CB_VERSION_NAME/.gitattributes >/dev/null 2>&1
	rm $CB_DEVTOOLS/$CB_VERSION_NAME/.gitignore >/dev/null 2>&1
	rm $CB_DEVTOOLS/$CB_VERSION_NAME/README.md >/dev/null 2>&1

	# keep backward compatibility
	if [ -d $CB_DEVTOOLS/$CB_VERSION_NAME/src ]; then
		mkdir $CB_DEVTOOLS/$CB_VERSION_NAME/bin
		cp $CB_DEVTOOLS/$CB_VERSION_NAME/src/main/cli/* $CB_DEVTOOLS/$CB_VERSION_NAME/bin/ >/dev/null 2>&1
		rm -rf $CB_DEVTOOLS/$CB_VERSION_NAME/src >/dev/null 2>&1
	fi
fi

if ! [ "$CB_HOME" = "$CB_DEVTOOLS/$CB_VERSION_NAME" ]; then
	echo "-Set CB_HOME to $CB_DEVTOOLS/$CB_VERSION_NAME"
	CB_HOME="$CB_DEVTOOLS/$CB_VERSION_NAME"

	shellProfile="$HOME/.bashrc"
	if [ -w $shellProfile ]; then
		echo "" >> $shellProfile
		echo "# toolarium-common-build support" >> $shellProfile
		echo "export CB_HOME=$CB_HOME && export PATH=\"\$CB_HOME/bin:\$PATH\"" >> $shellProfile
	fi
fi

installationSuccess


#########################################################################
# EOF
#########################################################################