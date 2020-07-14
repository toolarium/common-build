#!/bin/sh

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
echo "   [1] java-library"
echo "   [2] config project"
echo ""
read -p "${CB_LINEHEADER}Please choose the project type [1]: " input

projectType=java-library
if [ -n "$input" ]; then
	[ "$input" = "2" ] && projectType=config
fi

echo ""
echo "$CB_LINE"

if [ -r "$projectName" ]; then
	echo "${CB_LINEHEADER}Project $projectName already exist, abort!"
	echo "$CB_LINE"
	exit 1
else
	echo "${CB_LINEHEADER}Create project $projectName..."
	mkdir -p "$projectName" 2>/dev/null
	echo "apply from: \"https://git.io/JfDQT\"" > "$projectName/\build.gradle"
	echo "$CB_LINE"
fi


#########################################################################
# EOF
#########################################################################
