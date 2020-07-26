#!/bin/bash

#########################################################################
#
# project-wizard.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


echo "$CB_LINE"
echo "${CB_LINEHEADER}Create new project, enter project basic data."
echo "$CB_LINE"

if [ -n "$CB_CUSTOM_PROJECT_CONFIGFILE" ]; then
	CB_PROJECT_CONFIGFILE=$CB_CUSTOM_PROJECT_CONFIGFILE
else
	# default
	CB_PROJECT_CONFIGFILE=$CB_SCRIPT_PATH/../conf/project-types.properties

	# if we have a local common gradle build use the project types configuration file
	if [ -z "$COMMON_GRADLE_BUILD_URL" ]; then
		[ "$CB_OS" = "cygwin" ] && commonGradleBuildBasePath="$(cygpath $USERPROFILE)/.gradle/common-gradle-build" || commonGradleBuildBasePath="$HOME/.gradle/common-gradle-build"
		
		if [ -d "$commonGradleBuildBasePath" ]; then
			commonGradleBuildVersion=$(find "$commonGradleBuildBasePath" -maxdepth 1 -type d -name "*\.*\.*" -prune -exec ls -d {} \; 2>/dev/null | tail -1 2>/dev/null | xargs -l basename 2>/dev/null)
			[ -n "$commonGradleBuildVersion" ] && COMMON_GRADLE_BUILD_URL=$commonGradleBuildBasePath/$commonGradleBuildVersion/gradle
		fi
	fi

	[ -r "$COMMON_GRADLE_BUILD_URL/conf/project-types.properties" ] && CB_PROJECT_CONFIGFILE=$COMMON_GRADLE_BUILD_URL/conf/project-types.properties
fi

if ! [ -r "$CB_PROJECT_CONFIGFILE" ]; then
	echo "$CB_LINE"
	echo "${CB_LINEHEADER}Missing project type configuration file $CB_PROJECT_CONFIGFILE, please install with the cb-install.bat."
	echo "$CB_LINE"
	endWithError
fi
echo "${CB_LINEHEADER}Use $CB_PROJECT_CONFIGFILE as project configuration file"
CB_PROJECT_CONFIGFILE_TMPFILE=$(mktemp /tmp/cb-project-types.XXXXXXXXX)
cat $CB_PROJECT_CONFIGFILE 2>/dev/null | grep -v "#" | grep "=" > $CB_PROJECT_CONFIGFILE_TMPFILE 2>/dev/null


projectName=
projectRootPackageName=
projectDescription=

[ -n "$1" ] && projectName=$1 && shift
[ -z "$projectName" ] && projectName=my-project
read -p "${CB_LINEHEADER}Please enter project name, e.g. [$projectName]: " input
[ -n "$input" ] && projectName=$input

[ -n "$1" ] && projectRootPackageName=$1 && shift
[ -z "$projectRootPackageName" ] && projectRootPackageName=my.rootpackage.name
read -p "${CB_LINEHEADER}Please enter package name, e.g. [$projectRootPackageName]: " input
[ -n "$input" ] && projectRootPackageName=$input

projectGroupId=${projectName%%-*}
read -p "${CB_LINEHEADER}Please enter project group id, e.g. [$projectGroupId]: " input
[ -n "$input" ] && projectGroupId=$input

projectComponentId=${projectName%%-*}
read -p "${CB_LINEHEADER}Please enter project component id, e.g. [$projectComponentId]: " input
[ -n "$input" ] && projectComponentId=$input

[ -n "$*" ] && projectDescription="$*"
[ -z "$projectDescription" ] && projectDescription="The implementation of the $projectName."
read -p "${CB_LINEHEADER}Please enter project description [$projectDescription]: " input
[ -n "$input" ] && projectComponentId=$input

echo ""
echo "$CB_LINE"
echo "${CB_LINEHEADER}Project type:"
echo "$CB_LINE"
echo ""
#echo "   [1] java-library"
#echo "   [2] config project"
#echo ""
#read -p "${CB_LINEHEADER}Please choose the project type [1]: " input

projectType=
while [ -z "$projectType" ]; do
	count=1
	while IFS= read -r line; do 
		echo "   [$count] ${line%=*}  		${line#*=}"
		count=$((count+1))
	done <  $CB_PROJECT_CONFIGFILE_TMPFILE
	
	echo ""
	read -p "${CB_LINEHEADER}Please choose the project type [1]: " input
	
	[ -z "$input" ] && input=1
	
	count=1
	while IFS= read -r line; do 
		[ "$count" = "$input" ] && projectType="${line%=*}" && break
		count=$((count+1))
	done <  $CB_PROJECT_CONFIGFILE_TMPFILE
	projectType="$(echo $projectType 2>/dev/null | sed 's/ //g' 2>/dev/null)"
	[ -z "$projectType" ] && echo "${CB_LINEHEADER}Invalid input $input" && echo ""
done
	
rm -f "$CB_PROJECT_CONFIGFILE_TMPFILE" >/dev/null 2>&1
echo ""
echo "$CB_LINE"

if [ -r "$projectName" ]; then
	echo "${CB_LINEHEADER}Project $projectName already exist, abort."
	echo "$CB_LINE"
	endWithError
else
	echo "${CB_LINEHEADER}Create project $projectName..."
	mkdir -p "$projectName" 2>/dev/null
	echo "apply from: \"https://git.io/JfDQT\"" > "$projectName/build.gradle"
	projectStartParameter="--no-daemon"	
	echo "$CB_LINE"
	 
	export projectStartParameter projectName projectRootPackageName projectGroupId  projectComponentId  projectDescription projectType
fi


#########################################################################
# EOF
#########################################################################
