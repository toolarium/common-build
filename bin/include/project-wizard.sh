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
# End with error
#########################################################################
endWithError() {
	# custom setting script
	[ -n "$CB_CUSTOM_SETTING_SCRIPT" ] && eval ". $CB_CUSTOM_SETTING_SCRIPT error-end $*" 2>/dev/null
	exit 1
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
			#[ "$CB_OS" = "cygwin" ] && commonGradleBuildBasePath="$(cygpath $USERPROFILE)/.gradle/common-gradle-build" || commonGradleBuildBasePath="$HOME/.gradle/common-gradle-build"
			
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
	cat "$CB_PROJECT_CONFIGFILE" 2>/dev/null | tr -d '\15\32' | grep -v "#" | grep "=" > "$CB_PROJECT_CONFIGFILE_TMPFILE" 2>/dev/null
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
		echo "   [$count] ${line%%=*}   		${typeName}"
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
		[ "$count" = "$1" ] && key="${line%%=*}" && break
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
# Project replace parameters
#########################################################################
projectReplaceParameters() {
	actionName="$1"
	shift
	command="$*"	
	command=$(echo "$command" | sed "s/@@projectType@@/$projectType/g;s/@@projectName@@/$projectName/g;s/@@projectRootPackageName@@/$projectRootPackageName/g;s/@@projectGroupId@@/$projectGroupId/g;s/@@projectComponentId@@/$projectComponentId/g;s/@@projectDescription@@/$projectDescription/g;")
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Prepared $actionName action: $command"	
	echo $command
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
projectTypeConfigurationParameter=$projectTypeConfiguration

# select project details
if hasProjectTypeConfiguration "projectName"; then
	while ! [ -n "$projectName" ]; do
		[ -z "$1" ] && selectInput "project name" "my-project"
		[ -n "$1" ] && selectInput "project name" "my-project" "$1" && shift
		
		if [ -d "$inputResult" ]; then
			echo "${CB_LINEHEADER}Project $projectName already exist!"
		else
			projectName="$inputResult"
		fi
	done
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Selected project type [$projectType]/[$projectTypeId], configurationType: $projectTypeConfiguration, configurationParameter: $projectTypeConfigurationParameter"	
if hasProjectTypeConfiguration "projectRootPackageName"; then
	[ -z "$1" ] && selectInput "project package name" "my.rootpackage.name"
	[ -n "$1" ] && selectInput "project package name" "my.rootpackage.name" "$1" && shift
	projectRootPackageName="$inputResult"
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

if hasProjectTypeConfiguration "projectGroupId"; then
	[ -z "$1" ] && selectInput "project group id" "${projectName%%-*}"
	[ -n "$1" ] && selectInput "project group id" "${projectName%%-*}" "$1" && shift
	projectGroupId="$inputResult"
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

if hasProjectTypeConfiguration "projectComponentId"; then
	[ -z "$1" ] && selectInput "project component id" "${projectName%%-*}"
	[ -n "$1" ] && selectInput "project component id" "${projectName%%-*}" "$1" && shift
	projectComponentId="$inputResult"
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

if hasProjectTypeConfiguration "projectDescription"; then
	selectInput "project description" "The implementation of the $projectName." "$*"
	projectDescription="$inputResult"
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

if hasProjectTypeConfiguration ".*install.*=.*"; then
	echo ""
	echo "$CB_LINE"
	echo "${CB_LINEHEADER}Check package dependencies..."
	echo "$CB_LINE"
	installPackages=$(echo "$projectTypeConfigurationParameter" | head -1)
	installPackages=$(echo "${installPackages#*=}" | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g')
	
	if [ -n "$installPackages" ]; then
		[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Check package dependencies: $installPackages"
		for i in $(echo "${installPackages#*=}" | sed 's/,/\n/g' | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g'); do
			echo "${CB_LINEHEADER}Check package dependency $i"
			$PN_FULL --silent --install "$i"
			[ $? -ne 0 ] && endWithError
		done
	else
		echo "${CB_LINEHEADER}Invalid package dependency defined in $CB_PROJECT_CONFIGFILE: $installPackages"
	fi
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Set projectName:$projectName projectRootPackageName:$projectRootPackageName projectGroupId:$projectGroupId projectComponentId:$projectComponentId projectDescription:$projectDescription projectTypeConfigurationParameter:$projectTypeConfigurationParameter"
echo ""
echo "$CB_LINE"
if [ -r "$projectName" ]; then
	echo "${CB_LINEHEADER}Project $projectName already exist, abort."
	echo "$CB_LINE"
	endWithError
else
	echo "${CB_LINEHEADER}Create project $projectName..."
	echo "$CB_LINE"
	export projectStartParameter projectName projectRootPackageName projectGroupId  projectComponentId  projectDescription projectType

	if hasProjectTypeConfiguration ".*initAction.*=.*"; then
		initAction=$(echo "$projectTypeConfigurationParameter" | head -1)
		initAction=$(echo "${initAction#*=}"| sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g')

		if [ -n "$initAction" ]; then
			echo "${CB_LINEHEADER}Initialization..."
			command=$(projectReplaceParameters init "cb --silent --setenv && $initAction")
			projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
			if ! eval "$command"; then
				echo "${CB_LINEHEADER}Could not execute init action: [$command]."
				endWithError
			fi
		else
			echo "${CB_LINEHEADER}Invalid init action defined in $CB_PROJECT_CONFIGFILE: $initAction"
		fi
	fi

	if hasProjectTypeConfiguration ".*mainAction.*=.*"; then
		mainAction=$(echo "$projectTypeConfigurationParameter" | head -1)
		mainAction=$(echo "${mainAction#*=}"| sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g')
		
		if [ -n "$mainAction" ]; then
			command=$(projectReplaceParameters main "cb --silent --setenv && $mainAction")
			projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')

			if ! eval "$command"; then
				echo "${CB_LINEHEADER}Could not execute main action: [$command]."
				endWithError
			fi
		else
			echo "${CB_LINEHEADER}Invalid init action defined in $CB_PROJECT_CONFIGFILE: $initAction"
		fi
	else
		mkdir -p "$projectName" 2>/dev/null
		echo "apply from: \"https://git.io/JfDQT\"" > "$projectName/build.gradle"
		projectStartParameter="--no-daemon"	

		if ! eval "cd $projectName && $PN_FULL $projectStartParameter -PprojectType=$projectType -PprojectRootPackageName=$projectRootPackageName -PprojectGroupId=$projectGroupId -PprojectComponentId=$projectComponentId -PprojectDescription='$projectDescription'"; then
			endWithError
		fi
	fi

	if hasProjectTypeConfiguration ".*postAction.*=.*"; then
		postAction=$(echo "$projectTypeConfigurationParameter" | head -1)
		postAction=$(echo "${postAction#*=}"| sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g')
		
		if [ -n "$postAction" ]; then
			echo "$CB_LINE"
			echo "${CB_LINEHEADER}Finishing..."
			command=$(projectReplaceParameters post "cb --silent --setenv && $postAction")
			projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')

			if ! eval "$command"; then
				echo "${CB_LINEHEADER}Could not execute post action: [$command]."
				endWithError
			fi
		else
			echo "${CB_LINEHEADER}Invalid post action defined in $CB_PROJECT_CONFIGFILE: $postAction"
		fi
	fi
fi
echo "$CB_LINE"


#########################################################################
# EOF
#########################################################################
