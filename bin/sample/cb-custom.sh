#!/bin/bash

#########################################################################
#
# cb-custom
#
# Copyright by toolarium, all rights reserved.
#
# This file is part of the toolarium common-build.
#
# The common-build is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# The common-build is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar. If not, see <http://www.gnu.org/licenses/>.
#
#########################################################################


#########################################################################
# customStart
#########################################################################
customStart() {
	#echo "${CB_LINEHEADER}START $*"
	:
}


#########################################################################
# customVerifyConfiguration
#########################################################################
customVerifyConfiguration() {
	#echo "${CB_LINEHEADER}VERIFY CONFIGURATION $*"
	:
}


#########################################################################
# customBuildStart
#########################################################################
customBuildStart() {
	#echo "${CB_LINEHEADER}START BUILD $*"
	:
}


#########################################################################
# customBuildEnd
#########################################################################
customBuildEnd() {
	#echo "${CB_LINEHEADER}END BUILD $*"
	:
}


#########################################################################
# customNewProjectStart
#########################################################################
customNewProjectStart() {
	#echo "${CB_LINEHEADER}START NEW PROJECT $*"
	:
}


#########################################################################
# customNewProjectValidateName
#########################################################################
customNewProjectValidateName() {
	#echo "${CB_LINEHEADER}VALIDATE NAME $*"
	# invalid project name: exit 1
	exit 0
}


#########################################################################
# customNewProjectValidateRootPackageName
#########################################################################
customNewProjectValidateRootPackageName() {
	#echo "${CB_LINEHEADER}VALIDATE ROOTPACKAGENAME $*"
	# invalid rootpackagename: exit 1
	exit 0
}


#########################################################################
# customNewProjectValidateGroupId
#########################################################################
customNewProjectValidateGroupId() {
	#echo "${CB_LINEHEADER}VALIDATE GROUPID $*"
	# invalid group id: exit 1
	exit 0
}


#########################################################################
# customNewProjectValidateComponentId
#########################################################################
customNewProjectValidateComponentId() {
	#echo "${CB_LINEHEADER}VALIDATE COMPONENTID $*"
	# invalid component id: exit 1
	exit 0
}


#########################################################################
# customNewProjectValidateDescription
#########################################################################
customNewProjectValidateDescription() {
	#echo "${CB_LINEHEADER}VALIDATE DESCRIPTION $*"
	# invalid description: exit 1
	exit 0
}


#########################################################################
# customNewProjectEnd
#########################################################################
customNewProjectEnd() {
	#echo "${CB_LINEHEADER}END NEW PROJECT $*"
	:
}


#########################################################################
# customInstallStart
#########################################################################
customInstallStart() {
	#echo "${CB_LINEHEADER}START INSTALL $*"
	:
}


#########################################################################
# customInstallEnd
#########################################################################
customInstallEnd() {
	#echo "${CB_LINEHEADER}END INSTALL $*"
	:
}


#########################################################################
# customDownloadPackageStart
#########################################################################
customDownloadPackageStart() {
	#echo "${CB_LINEHEADER}START DOWNLOAD PACKAGE $*"
	:
}


#########################################################################
# customDownloadPackageEnd
#########################################################################
customDownloadPackageEnd() {
	#echo "${CB_LINEHEADER}END DOWNLOAD PACKAGE $*"
	:
}


#########################################################################
# customExtractPackageStart
#########################################################################
customExtractPackageStart() {
	#echo "${CB_LINEHEADER}START EXTRACT PACKAGE $*"
	:
}


#########################################################################
# customExtractPackageEnd
#########################################################################
customExtractPackageEnd() {
	#echo "${CB_LINEHEADER}END EXTRACT PACKAGE $*"
	:
}


#########################################################################
# customSetEnvStart
#########################################################################
customSetEnvStart() {
	#echo "${CB_LINEHEADER}START SETENV $*"
	:
}


#########################################################################
# customSetEnvEnd
#########################################################################
customSetEnvEnd() {
	#echo "${CB_LINEHEADER}END SETENV $*"
	:
}


#########################################################################
# customConfigUpdateEnd
#########################################################################
customConfigUpdateEnd() {
	#echo "${CB_LINEHEADER}CUSTOM CONFIG UPDATE [$CB_CUSTOM_CONFIG_VERSION]"
	:
}


#########################################################################
# customErrorEnd
#########################################################################
customErrorEnd() {
	#echo "${CB_LINEHEADER}ENDED WITH ERROR: $*"
	:
}


#########################################################################
# main
#########################################################################
while [ $# -gt 0 ]
do
    case "$1" in
	start)						shift; customStart $*; return 0;;
	verify-configuration)		shift; customVerifyConfiguration $*; return 0;;
	build-start)				shift; customBuildStart $*; return 0;;
	build-end)					shift; customBuildEnd $*; return 0;;
	new-project-start)			shift; customNewProjectStart $*; return 0;;
	new-project-validate-name)	          shift; customNewProjectValidateName $*; return 0;;
	new-project-validate-rootpackagename) shift; customNewProjectValidateRootPackageName $*; return 0;;
	new-project-validate-groupid)	      shift; customNewProjectValidateGroupId $*; return 0;;
	new-project-validate-componentid)     shift; customNewProjectValidateComponentId $*; return 0;;
	new-project-validate-description)     shift; customNewProjectValidateDescription $*; return 0;;
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