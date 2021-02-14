@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: scoop.bat
::
:: Copyright by toolarium, all rights reserved.
::
:: This file is part of the toolarium common-build.
::
:: The common-build is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: The common-build is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with Foobar. If not, see <http://www.gnu.org/licenses/>.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "CB_PACKAGE_VERSION="
set "CB_PACKAGE_DOWNLOAD_URL=NA"
set "CB_PACKAGE_DOWNLOAD_NAME="
set "CB_PACKAGE_INSTALL_PARAMETER="
set "CB_PACKAGE_NO_DEFAULT=true"
set "CB_PKG_FILTER="

powershell -nologo -command "Set-ExecutionPolicy RemoteSigned -scope CurrentUser" >nul 2>nul	
set "CB_PACKAGE_ALREADY_EXIST=false"
set "CB_POST_INSTALL_ACTION=powershell -nologo -command "iwr -useb get.scoop.sh ^| iex"
