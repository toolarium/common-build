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

[ -n "$1" ] && projectDescription=$*
[ -z "$projectDescription" ] && projectDescription="The implementation of the $projectName"

echo ""
echo "$CB_LINE"
echo "${CB_LINEHEADER}Project type:"
echo "$CB_LINE"
echo "  [1] java-library"
echo "  [2] config project"
echo ""
read -p "${CB_LINEHEADER}Please choose the project type [1]: " input

if [ -n "$input" ]; then
	case "$input" in
		[1]) projectType=java-library
		[2]) projectType=config
		*) projectType=java-library
	esac
fi

echo ""
echo "$CB_LINE"
if ! [ -d "$projectName" ]; then
	echo "${CB_LINEHEADER}Create project $projectName..."
	mkdir -p "$projectName" 2>nul
	echo "apply from: \"https://git.io/JfDQT\"" > "$projectName/\build.gradle"
	echo "$CB_LINE"
else
	echo "${CB_LINEHEADER}Project $projectName already exist, abort!"
	echo "$CB_LINE"
	return 0
fi


#########################################################################
# EOF
#########################################################################
