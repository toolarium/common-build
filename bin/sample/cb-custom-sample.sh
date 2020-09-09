#!/bin/bash

#########################################################################
#
# cb-custom-sample
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


# define parameters
CUSTOM_CB_LINE="****************************************************************************************"


#########################################################################
# customStart
#########################################################################
customStart() {
	CB_LINE="${CUSTOM_CB_LINE}"
	export CB_LINE
	
	echo "${CB_LINE}"
	echo ""
	echo "START SAMPLE"
	echo ""
	echo "${CB_LINE}"
}


#########################################################################
# customBuildStart
#########################################################################
customBuildStart() {
	echo "${CB_LINEHEADER}START BUILD $*"
}


#########################################################################
# customBuildEnd
#########################################################################
customBuildEnd() {
	echo "${CB_LINEHEADER}END BUILD $*"
}


#########################################################################
# customNewProjectStart
#########################################################################
customNewProjectStart() {
	echo "${CB_LINEHEADER}START NEW PROJECT $*"
	
	# define own project types
	CB_CUSTOM_PROJECT_CONFIGFILE=$(mktemp /tmp/cb-project-types-custom.XXXXXXXXX)
	echo "java-library = Simple java library|projectName|projectRootPackageName|projectGroupId|projectComponentId|projectDescription" >> $CB_CUSTOM_PROJECT_CONFIGFILE
	echo "config = Configuration Project|projectName|projectGroupId|projectComponentId|projectDescription" >> $CB_CUSTOM_PROJECT_CONFIGFILE
	echo "my-own-type = My own type|projectName|projectGroupId|projectDescription" >> $CB_CUSTOM_PROJECT_CONFIGFILE
}


#########################################################################
# customNewProjectEnd
#########################################################################
customNewProjectEnd() {
	echo "${CB_LINEHEADER}END NEW PROJECT $*"
	del $CB_CUSTOM_PROJECT_CONFIGFILE >/dev/null 2>&1
}


#########################################################################
# customInstallStart
#########################################################################
customInstallStart() {
	echo "${CB_LINEHEADER}START INSTALL $*"
}


#########################################################################
# customInstallEnd
#########################################################################
customInstallEnd() {
	echo "${CB_LINEHEADER}END INSTALL $*"
}


#########################################################################
# customDownloadPackageStart
#########################################################################
customDownloadPackageStart() {
	echo "${CB_LINEHEADER}START DOWNLOAD PACKAGE $*"
}


#########################################################################
# customDownloadPackageEnd
#########################################################################
customDownloadPackageEnd() {
	echo "${CB_LINEHEADER}END DOWNLOAD PACKAGE $*"
}


#########################################################################
# customExtractPackageStart
#########################################################################
customExtractPackageStart() {
	echo "${CB_LINEHEADER}START EXTRACT PACKAGE $*"
}


#########################################################################
# customExtractPackageEnd
#########################################################################
customExtractPackageEnd() {
	echo "${CB_LINEHEADER}END EXTRACT PACKAGE $*"
}


#########################################################################
# customSetEnvStart
#########################################################################
customSetEnvStart() {
	echo "${CB_LINEHEADER}START SETENV $*"
}


#########################################################################
# customSetEnvEnd
#########################################################################
customSetEnvEnd() {
	echo "${CB_LINEHEADER}END SETENV $*"
}


#########################################################################
# customConfigUpdateEnd
#########################################################################
customConfigUpdateEnd() {
	echo "${CB_LINEHEADER}CUSTOM CONFIG UPDATE [$CB_CUSTOM_CONFIG_VERSION]"
}


#########################################################################
# customErrorEnd
#########################################################################
customErrorEnd() {
	echo "${CB_LINEHEADER}ENDED WITH ERROR: $*"
}


#########################################################################
# main
#########################################################################
while [ $# -gt 0 ]
do
    case "$1" in
	start)						shift; customStart $*; return 0;;
	build-start)				shift; customBuildStart $*; return 0;;
	build-end)					shift; customBuildEnd $*; return 0;;
	new-project-start)			shift; customNewProjectStart $*; return 0;;
	new-project-end)			shift; customNewProjectEnd $*; return 0;;
	install-start)				shift; customInstallStart $*; return 0;;
	install-end)				shift; customInstallEnd $*; return 0;;
	download-package-start)		shift; customDownloadPackageStart $*; return 0;;
	download-package-end)		shift; customDownloadPackageEnd $*; return 0;;
	extract-package-start)		shift; customExtractPackageStart $*; return 0;;
	extract-package-end )		shift; customExtractPackageEnd $*; return 0;;	
	setenv-start)				shift; customSetEnvStart $*; return 0;;
	setenv-end)					shift; customSetEnvEnd $*; return 0;;
	custom-config-update-end)	shift; customConfigUpdateEnd $*; return 0;;
	error-end)					shift; customErrorEnd $*; return 0;;
	*)							echo "${CB_LINEHEADER}Unknown parameter: $1"; return 1;;
    esac
    shift
done


#########################################################################
# EOF
#########################################################################