#!/bin/bash

#########################################################################
#
# insomnia.sh
#
# Copyright by toolarium, all rights reserved.
# MIT License: https://mit-license.org
#
#########################################################################


CB_PACKAGE_VERSION=
if [ "$CB_OS" = "linux" ]; then
	CB_PACKAGE_DOWNLOAD_URL=https://updates.insomnia.rest/downloads/ubuntu/latest?ref=&app=com.insomnia.app
	CB_PACKAGE_DOWNLOAD_NAME=Insomnia.Core.deb
elif [ "$CB_OS" = "mac" ]; then
	CB_PACKAGE_DOWNLOAD_URL=https://updates.insomnia.rest/downloads/mac/latest?ref=&app=com.insomnia.app
	CB_PACKAGE_DOWNLOAD_NAME=Insomnia.Core.dmg
elif [ "$CB_OS" = "cygwin" ]; then
	CB_PACKAGE_DOWNLOAD_URL=https://updates.insomnia.rest/downloads/windows/latest?ref=&app=com.insomnia.app
	CB_PACKAGE_DOWNLOAD_NAME=Insomnia.Core.exe
else
	CB_PACKAGE_DOWNLOAD_URL=https://updates.insomnia.rest/downloads/windows/latest?ref=&app=com.insomnia.app
	CB_PACKAGE_DOWNLOAD_NAME=Insomnia.Core.exe
fi

export CB_PACKAGE_VERSION CB_PACKAGE_DOWNLOAD_URL CB_PACKAGE_DOWNLOAD_NAME