#!/bin/bash

#########################################################################
#
# project-wizard.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


CB_PROJECT_CONFIGFILE_TMPFILE=$(mktemp /tmp/cb-project-types.XXXXXXXXX)


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
# Read the configuration file
#########################################################################
readConfigurationFile() {
	if [ -n "$CB_CUSTOM_PROJECT_CONFIGFILE" ]; then
		CB_PROJECT_CONFIGFILE="$CB_CUSTOM_PROJECT_CONFIGFILE"
	else
		# default
		CB_PROJECT_CONFIGFILE="$CB_SCRIPT_PATH/../conf/project-types.properties"

		# if we have a local common gradle build use the project types configuration file
		if [ -z "$COMMON_GRADLE_BUILD_URL" ]; then
			[ "$CB_OS" = "cygwin" ] && commonGradleBuildBasePath="$(cygpath $USERPROFILE)/.gradle/common-gradle-build" || commonGradleBuildBasePath="$HOME/.gradle/common-gradle-build"
			
			if [ -d "$commonGradleBuildBasePath" ]; then
				commonGradleBuildVersion=$(find "$commonGradleBuildBasePath" -maxdepth 1 -type d -name "*\.*\.*" -prune -exec ls -d {} \; 2>/dev/null | tail -1 2>/dev/null | xargs -l basename 2>/dev/null)
				[ -n "$commonGradleBuildVersion" ] && COMMON_GRADLE_BUILD_URL="$commonGradleBuildBasePath/$commonGradleBuildVersion/gradle"
			fi
		fi

		[ -r "$COMMON_GRADLE_BUILD_URL/conf/project-types.properties" ] && CB_PROJECT_CONFIGFILE="$COMMON_GRADLE_BUILD_URL/conf/project-types.properties"
	fi

	if ! [ -r "$CB_PROJECT_CONFIGFILE" ]; then
		echo "$CB_LINE"
		echo "${CB_LINEHEADER}Missing project type configuration file $CB_PROJECT_CONFIGFILE, please install with the cb-install.bat."
		echo "$CB_LINE"
		endWithError
	fi
	
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Used configuration file: $CB_PROJECT_CONFIGFILE"
	cat "$CB_PROJECT_CONFIGFILE" 2>/dev/null | grep -v "#" | grep "=" > "$CB_PROJECT_CONFIGFILE_TMPFILE" 2>/dev/null
}


#########################################################################
# Print project types
#########################################################################
printProjectTypes() {
	typeName=
	configValue=
	count=1
	while IFS= read -r line; do 
		configValue="${line#*=}"
		typeName="${configValue%%|*}"
		
		echo "   [$count] ${line%=*}  		${typeName}"
		count=$((count+1))
	done < "$CB_PROJECT_CONFIGFILE_TMPFILE"
}


#########################################################################
# Get project type configuration
#########################################################################
getProjectTypeConfiguration() {
	key=
	configValue=
	count=1
	while IFS= read -r line; do
		configValue="${line#*=}"
		[ "$count" = "$1" ] && key="${line%=*}" && break
		count=$((count+1))
	done < "$CB_PROJECT_CONFIGFILE_TMPFILE"
	echo "${configValue#*|}" | sed 's/|/\n/g' 2>/dev/null
}


#########################################################################
# Check if project has the configuraiton
#########################################################################
hasProjectTypeConfiguration() {
	[ -z "$(echo "$projectTypeConfiguration" | grep -E "^$1$")" ] && return 1 || return  0
}


#########################################################################
# Select the project type
#########################################################################
searchProjectType() {
	key=
	count=1
	while IFS= read -r line; do
		[ "$count" = "$1" ] && key="${line%=*}" && break
		count=$((count+1))
	done < "$CB_PROJECT_CONFIGFILE_TMPFILE"
	echo "$key" 2>/dev/null | sed 's/ //g' 2>/dev/null
}


#########################################################################
# Select the project type
#########################################################################
selectProjectType() {	
	if [ "$1" -ge 0 ] 2>/dev/null; then
		projectTypeId="$1"
		projectType=$(searchProjectType "$1")
	fi
		
	if [ -z "$projectType" ]; then
		echo "${CB_LINEHEADER}Project type:"

		[ "$1" -ge 0 ] 2>/dev/null && echo "${CB_LINEHEADER}Invalid input $input" && echo ""
		projectType=
		input=
		while [ -z "$projectType" ]; do
			printProjectTypes
			
			echo ""
			read -p "${CB_LINEHEADER}Please choose the project type [1]: " input
			[ -z "$input" ] && input=1

			projectType=$(searchProjectType "$input")
			projectTypeId="$input"
			[ -z "$projectType" ] && echo "${CB_LINEHEADER}Invalid input $input" && echo ""
		done
	else
		echo "${CB_LINEHEADER}Project type [$projectType]"
	fi
	
	export projectTypeId projectType
}


#########################################################################
# Select the project type, "project name", "my-project", "own-project"
#########################################################################
selectInput() {	
	if [ -z "$3" ]; then
		inputResult="$2"	
		read -p "${CB_LINEHEADER}Please enter $1, e.g. [$inputResult]: " input
		[ -n "$input" ] && inputResult="$input"
	else
		inputResult="$3"
		echo "${CB_LINEHEADER}${1^} [$3]"
	fi
}


#########################################################################
# main
#########################################################################
trap 'exithandler $?; exit' 0
trap 'errorhandler $?; exit' 1 2 3 15
echo "$CB_LINE"
echo "${CB_LINEHEADER}Create new project, enter project basic data."
echo "$CB_LINE"

projectTypeId=
projectType=
projectName=
projectRootPackageName=
projectDescription=

# read the configuration file
readConfigurationFile

# if first parameter is a number, then it's the project type
[ -n "$1" ] && [ "$1" -ge 0 ] 2>/dev/null && projectType=$1 && shift

# select project type
selectProjectType "$projectType"
projectTypeConfiguration=$(getProjectTypeConfiguration "$projectTypeId")

# select project details
[ -z "$1" ] && selectInput "project name" "my-project"
[ -n "$1" ] && selectInput "project name" "my-project" "$1" && shift
projectName="$inputResult"

if hasProjectTypeConfiguration "projectRootPackageName"; then
	[ -z "$1" ] && selectInput "project package name" "my.rootpackage.name"
	[ -n "$1" ] && selectInput "project package name" "my.rootpackage.name" "$1" && shift
	projectRootPackageName="$inputResult"
fi

if hasProjectTypeConfiguration "projectGroupId"; then
	[ -z "$1" ] && selectInput "project group id" "${projectName%%-*}"
	[ -n "$1" ] && selectInput "project group id" "${projectName%%-*}" "$1" && shift
	projectGroupId="$inputResult"
fi

if hasProjectTypeConfiguration "projectComponentId"; then
	[ -z "$1" ] && selectInput "project component id" "${projectName%%-*}"
	[ -n "$1" ] && selectInput "project component id" "${projectName%%-*}" "$1" && shift
	projectComponentId="$inputResult"
fi

if hasProjectTypeConfiguration "projectDescription"; then
	selectInput "project description" "The implementation of the $projectName." "$*"
	projectDescription="$inputResult"
fi

[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Set projectName:$projectName projectRootPackageName:$projectRootPackageName projectGroupId:$projectGroupId projectComponentId:$projectComponentId projectDescription:$projectDescription%"
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
