#!/bin/bash

#########################################################################
#
# cb-custom-sample
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
# customVerifyConfiguration
#########################################################################
customVerifyConfiguration() {
	echo "${CB_LINEHEADER}VERIFY CONFIGURATION $*"
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
	CB_CUSTOM_PROJECT_CONFIGFILE=$(mkdir /tmp/cb 2>/dev/null; mktemp /tmp/cb/cb-project-types-custom.XXXXXXXXX)
	echo "java-library = Simple java library|projectName|projectRootPackageName|projectGroupId|projectComponentId|projectDescription" >> $CB_CUSTOM_PROJECT_CONFIGFILE
	echo "config = Configuration Project|projectName|projectGroupId|projectComponentId|projectDescription" >> $CB_CUSTOM_PROJECT_CONFIGFILE
	echo "my-own-type = My own type|projectName|projectGroupId|projectDescription" >> $CB_CUSTOM_PROJECT_CONFIGFILE
}


#########################################################################
# customNewProjectValidateName
#########################################################################
customNewProjectValidateName() {
	echo "${CB_LINEHEADER}VALIDATE NAME $@"
	# invalid project name: return 1
	return 0
}


#########################################################################
# customNewProjectValidateRootPackageName
#########################################################################
customNewProjectValidateRootPackageName() {
	echo "${CB_LINEHEADER}VALIDATE ROOTPACKAGENAME $@"
	# invalid rootpackagename: return 1
	return 0
}


#########################################################################
# customNewProjectValidateGroupId
#########################################################################
customNewProjectValidateGroupId() {
	echo "${CB_LINEHEADER}VALIDATE GROUPID $@"
	# invalid group id: return 1
	return 0
}


#########################################################################
# customNewProjectValidateComponentId
#########################################################################
customNewProjectValidateComponentId() {
	echo "${CB_LINEHEADER}VALIDATE COMPONENTID $@"
	# invalid component id: return 1
	return 0
}


#########################################################################
# customNewProjectValidateDescription
#########################################################################
customNewProjectValidateDescription() {
	echo "${CB_LINEHEADER}VALIDATE DESCRIPTION $@"
	# invalid description: return 1
	return 0
}


#########################################################################
# customNewProjectEnd
#########################################################################
customNewProjectEnd() {
	echo "${CB_LINEHEADER}END NEW PROJECT $*"
	rm -f "$CB_CUSTOM_PROJECT_CONFIGFILE" >/dev/null 2>&1
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
# customCleanupStart
#########################################################################
customCleanupStart() {
	echo "${CB_LINEHEADER}START CLEANUP $@"
}


#########################################################################
# customCleanupEnd
#########################################################################
customCleanupEnd() {
	echo "${CB_LINEHEADER}END CLEANUP $@"
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
	start)						shift; customStart "$@"; return 0;;
	verify-configuration)		shift; customVerifyConfiguration "$@"; return 0;;
	build-start)				shift; customBuildStart "$@"; return 0;;
	build-end)					shift; customBuildEnd "$@"; return 0;;
	new-project-start)			shift; customNewProjectStart "$@"; return 0;;
	new-project-validate-name)	          shift; customNewProjectValidateName "$@"; return 0;;
	new-project-validate-rootpackagename) shift; customNewProjectValidateRootPackageName "$@"; return 0;;
	new-project-validate-groupid)	      shift; customNewProjectValidateGroupId "$@"; return 0;;
	new-project-validate-componentid)     shift; customNewProjectValidateComponentId "$@"; return 0;;
	new-project-validate-description)     shift; customNewProjectValidateDescription "$@"; return 0;;
	new-project-end)			shift; customNewProjectEnd "$@"; return 0;;
	install-start)				shift; customInstallStart "$@"; return 0;;
	install-end)				shift; customInstallEnd "$@"; return 0;;
	download-package-start)		shift; customDownloadPackageStart "$@"; return 0;;
	download-package-end)		shift; customDownloadPackageEnd "$@"; return 0;;
	extract-package-start)		shift; customExtractPackageStart "$@"; return 0;;
	extract-package-end )		shift; customExtractPackageEnd "$@"; return 0;;
	setenv-start)				shift; customSetEnvStart "$@"; return 0;;
	setenv-end)					shift; customSetEnvEnd "$@"; return 0;;
	custom-config-update-end)	shift; customConfigUpdateEnd "$@"; return 0;;
	cleanup-start)				shift; customCleanupStart "$@"; return 0;;
	cleanup-end)				shift; customCleanupEnd "$@"; return 0;;
	error-end)					shift; customErrorEnd "$@"; return 0;;
	*)							return 0;;
    esac
    shift
done


#########################################################################
# EOF
#########################################################################