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
CB_PRODUCT_CONFIGFILE_TMPFILE=$(mktemp /tmp/cb-product-types.XXXXXXXXX)


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
	rm "$CB_PRODUCT_CONFIGFILE_TMPFILE" >/dev/null 2>&1
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
# Prepare the project configuration file
#########################################################################
preapreProjectConfigurationFile() {
	[ -z "$CB_PROJECT_CONFIGFILE" ] && CB_PROJECT_CONFIGFILE="$CB_SCRIPT_PATH/../conf/project-types.properties"
	if ! [ -r "$CB_PROJECT_CONFIGFILE" ]; then
		echo "$CB_LINE"
		echo "${CB_LINEHEADER}Missing project type configuration file $CB_PROJECT_CONFIGFILE, please install with the cb-install.bat."
		echo "$CB_LINE"
		endWithError
	fi
	
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Use project configuration file: $CB_PROJECT_CONFIGFILE"
	cat "$CB_PROJECT_CONFIGFILE" 2>/dev/null | tr -d '\15\32' | grep -v "#" | grep "=" > "$1" 2>/dev/null
}


#########################################################################
# Prepare the product configuration file
#########################################################################
preapreProductConfigurationFile() {
	[ -z "$CB_PRODUCT_CONFIGFILE" ] && CB_PRODUCT_CONFIGFILE="$CB_SCRIPT_PATH/../conf/product-types.properties"
	! [ -r "$CB_PRODUCT_CONFIGFILE" ] && rm "$CB_PRODUCT_CONFIGFILE_TMPFILE" >/dev/null 2>&1 && return
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Use product configuration file: $CB_PRODUCT_CONFIGFILE"
	cat "$CB_PRODUCT_CONFIGFILE" 2>/dev/null | tr -d '\15\32' | grep -v "#" | grep "=" > "$1" 2>/dev/null
}


#########################################################################
# Print types
#########################################################################
printTypes() {
	typeName=
	configValue=
	count=1
	while IFS= read -r line; do 
		configValue="${line#*=}"
		[ -z "$2" ] && typeName="${configValue%%|*}" || typeName=$(echo "$line" | cut -d'=' -f1)
		#echo "   [$count] ${line%%=*}   		${typeName}"
		echo "   [$count] ${typeName}"
		count=$((count+1))
	done < "$1"
}


#########################################################################
# Get type configuration
#########################################################################
getTypeConfiguration() {
	key=
	configValue=
	count=1
	while IFS= read -r line; do
		configValue="${line#*=}"
		[ "$count" = "$2" ] && key="${line%=*}" && break
		count=$((count+1))
	done < "$1"
	
	[ -z "$3" ] && echo "$configValue" | xargs | sed 's/|/\n/g' 2>/dev/null
	[ -n "$3" ] && [ "$3" = "true" ] && echo "${configValue#*|}" | sed 's/|/\n/g' 2>/dev/null
}


#########################################################################
# Check if project has the configuraiton
#########################################################################
hasProjectTypeConfiguration() {
	[ -z "$(echo "$projectTypeConfiguration" | grep -E "^$1$")" ] && return 1 || return  0
}


#########################################################################
# Select the type
#########################################################################
searchType() {
	key=
	count=1
	while IFS= read -r line; do
		[ "$count" = "$2" ] && key="${line%%=*}" && break
		count=$((count+1))
	done < "$1"
	echo "${key}" 2>/dev/null | sed 's/[[:space:]]*$//g' 2>/dev/null 2>/dev/null
}


#########################################################################
# Select the project type
#########################################################################
selectProjectType() {	
	if [ "$1" -ge 0 ] 2>/dev/null; then
		projectTypeId="$1"
		projectType=$(searchType "$CB_PROJECT_CONFIGFILE_TMPFILE" "$1")
	fi
		
	if [ -z "$projectType" ]; then
		echo "${CB_LINEHEADER}Project type:"

		[ "$1" -ge 0 ] 2>/dev/null && echo "${CB_LINEHEADER}Invalid input $input" && echo ""
		projectType=
		input=
		while [ -z "$projectType" ]; do
			printTypes "$CB_PROJECT_CONFIGFILE_TMPFILE"
			
			echo ""
			read -p "${CB_LINEHEADER}Please choose the project type [1]: " input
			[ -z "$input" ] && input=1

			projectType=$(searchType "$CB_PROJECT_CONFIGFILE_TMPFILE" "$input")
			projectTypeId="$input"
			[ -z "$projectType" ] && echo "${CB_LINEHEADER}Invalid input $input" && echo ""
		done
	else
		echo "${CB_LINEHEADER}Project type [$projectType]"
	fi
	
	export projectTypeId projectType
}


#########################################################################
# Select the product
#########################################################################
selectProduct() {	
	! [ -r "$CB_PRODUCT_CONFIGFILE_TMPFILE" ] && productName="" && return 
	if [ "$1" -ge 0 ] 2>/dev/null; then
		productName=$(searchType "$CB_PRODUCT_CONFIGFILE_TMPFILE" "$1")
	fi
	
	productId=""
	if [ -z "$productName" ]; then
		echo "${CB_LINEHEADER}Products:"

		[ "$1" -ge 0 ] 2>/dev/null && echo "${CB_LINEHEADER}Invalid input $input" && echo ""
		productType=
		input=
		while [ -z "$productName" ]; do
			printTypes "$CB_PRODUCT_CONFIGFILE_TMPFILE" false
			
			echo ""
			read -p "${CB_LINEHEADER}Please select to which product it belongs [1]: " input
			[ -z "$input" ] && input=1

			productId="$input"
			productName=$(searchType "$CB_PRODUCT_CONFIGFILE_TMPFILE" "$input")
			[ -z "$productName" ] && echo "${CB_LINEHEADER}Invalid input $input" && echo ""
		done
	else
		echo "${CB_LINEHEADER}Product name [$productName]"
	fi
	
	export productName productId
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
	command=$(echo "$command" | sed "s/@@projectType@@/$projectType/g;s/@@projectName@@/$projectName/g;s/@@projectRootPackageName@@/$projectRootPackageName/g;s/@@projectGroupId@@/$projectGroupId/g;s/@@projectComponentId@@/$projectComponentId/g;s/@@projectDescription@@/$projectDescription/g;s/@@logFile@@/\/dev\/null/g;")
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Prepared $actionName action: $command"	
	echo $command
}


#########################################################################
# main
#########################################################################
trap 'exithandler $?; exit' 0
trap 'errorhandler $?; exit' 1 2 3 15
echo "$CB_LINE"
[ -r "build.gradle" ] && echo "${CB_LINEHEADER}The current path is inside a project [$PWD], please start outside." && echo "$CB_LINE" && endWithError
echo "${CB_LINEHEADER}Create new project, enter project basic data."
echo "$CB_LINE"

[ -n "$CB_CUSTOM_RUNTIME_CONFIG_PATH" ] && [ -r "$CB_CUSTOM_RUNTIME_CONFIG_PATH/conf/project-types.properties" ] && CB_PROJECT_CONFIGFILE="$CB_CUSTOM_RUNTIME_CONFIG_PATH/conf/project-types.properties"
[ -n "$CB_CUSTOM_RUNTIME_CONFIG_PATH" ] && [ -r "$CB_CUSTOM_RUNTIME_CONFIG_PATH/conf/product-types.properties" ] && CB_PRODUCT_CONFIGFILE="$CB_CUSTOM_RUNTIME_CONFIG_PATH/conf/product-types.properties"

productId=
projectTypeId=
productName=
projectType=
projectName=
projectComponentId=
projectRootPackageName=
projectDescription=

# read the configuration file
preapreProjectConfigurationFile "$CB_PROJECT_CONFIGFILE_TMPFILE"
preapreProductConfigurationFile "$CB_PRODUCT_CONFIGFILE_TMPFILE"

# select product
[ -n "$1" ] && [ "$1" -ge 0 ] 2>/dev/null && productId="$1" && shift
[ -z "$productId" ] && selectProduct "$productName"

if [ -n "$productId" ]; then
	productTypeConfiguration=$(getTypeConfiguration "$CB_PRODUCT_CONFIGFILE_TMPFILE" "$productId")
	[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Product type configuration: $(echo $productTypeConfiguration|sed 's/\n/|/')"
	for i in $productTypeConfiguration; do
		export $(echo "${i%:*}")=$(echo "${i#*:}")
	done
fi

# select project type
[ -n "$1" ] && [ "$1" -ge 0 ] 2>/dev/null && projectType="$1" && shift
selectProjectType "$projectType"
projectTypeConfiguration=$(getTypeConfiguration "$CB_PROJECT_CONFIGFILE_TMPFILE" "$projectTypeId" true)
projectTypeConfigurationParameter=$projectTypeConfiguration
[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Project type configuration: $(echo $projectTypeConfiguration|sed 's/\n/|/')"

# select project details
projectNameEndingParameter=$(echo "$projectTypeConfiguration" | grep projectName | sed 's/^.*=//')
[ "projectName" = "$projectNameEndingParameter" ] && projectNameEndingParameter=""
projectDefaultName="project"
[ -n "$projectComponentId" ] && projectDefaultName="${projectComponentId}-${projectDefaultName}" || projectDefaultName="my-${projectDefaultName}"
[ -n "$projectNameEndingParameter" ] && projectDefaultName="$projectDefaultName$projectNameEndingParameter"

while ! [ -n "$projectName" ]; do
	[ -z "$1" ] && selectInput "project name" "$projectDefaultName"
	[ -n "$1" ] && selectInput "project name" "$projectDefaultName" "$1" && shift
	
	validName="true"
	[ -n "$projectComponentId" ] && [ -n "${inputResult##$projectComponentId-*}" ] && echo "${CB_LINEHEADER}Invalid name it must start with $projectComponentId-." && validName="false"
	[ -n "$projectNameEndingParameter" ] && [ -n "${inputResult%%*$projectNameEndingParameter}" ] && echo "${CB_LINEHEADER}Invalid name it must end with $projectNameEndingParameter." && validName="false"
	[ -d "$inputResult" ] && echo "${CB_LINEHEADER}Project $projectName already exist!" && validName=false 
	[ "$validName" = "true" ] && projectName="$inputResult"
done

projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
[ "$CB_VERBOSE" = "true" ] && echo "${CB_LINEHEADER}Selected project type [$projectType]/[$projectTypeId], configurationType: $projectTypeConfiguration, configurationParameter: $projectTypeConfigurationParameter"	
if hasProjectTypeConfiguration "projectRootPackageName"; then
	[ -z "$projectRootPackageName" ] && projectRootPackageName="my.rootpackage.name"
	[ -z "$1" ] && selectInput "project package name" "$projectRootPackageName"
	[ -n "$1" ] && selectInput "project package name" "$projectRootPackageName" "$1" && shift
	projectRootPackageName="$inputResult"
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

if hasProjectTypeConfiguration "projectGroupId"; then
	if [ -n "$projectGroupId" ]; then
		selectInput "project group id" "${projectName%%-*}" "$projectGroupId" 	
	else
		[ -z "$1" ] && selectInput "project group id" "${projectName%%-*}"
		[ -n "$1" ] && selectInput "project group id" "${projectName%%-*}" "$1" && shift
	fi
	projectGroupId="$inputResult"
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

if hasProjectTypeConfiguration "projectComponentId"; then
	if [ -n "$projectComponentId" ]; then
		selectInput "project component id" "${projectName%%-*}" "$projectComponentId"
	else
		[ -z "$1" ] && selectInput "project component id" "${projectName%%-*}"
		[ -n "$1" ] && selectInput "project component id" "${projectName%%-*}" "$1" && shift
	fi
	projectComponentId="$inputResult"
	projectTypeConfigurationParameter=$(echo "$projectTypeConfigurationParameter" | sed '1d')
fi

if hasProjectTypeConfiguration "projectDescription"; then
	[ -z "$*" ] && [ -z "$projectDescription" ] && projectDescription="The implementation of the $projectName."
	selectInput "project description" "$projectDescription" "$*"
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
