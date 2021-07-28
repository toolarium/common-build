@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: git.bat
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


if not defined CB_GIT_VERSION set "CB_GIT_VERSION=2.32.0"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_GIT_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/git-for-windows/git/releases/download/v%CB_PACKAGE_VERSION%.windows.1"
set "CB_PACKAGE_DOWNLOAD_NAME=Git-%CB_PACKAGE_VERSION%-%CB_PROCESSOR_ARCHITECTURE_NUMBER%-bit.exe"
::set "CB_PACKAGE_VERSION_NAME="
set "CB_PACKAGE_DIRECTORY_NAME=%CB_DEVTOOLS%\git-%CB_PACKAGE_VERSION%"

if .%CB_INSTALL_OVERWRITE_DIST%==.false if exist %CB_PACKAGE_DIRECTORY_NAME% set "CB_PACKAGE_ALREADY_EXIST=true"

set "CB_GIT_AUTOINSTALL_FILENAME=%CB_DEVTOOLS%\.repository\git-autoinstall-%CB_PACKAGE_VERSION%.txt"
echo [Setup] >>%CB_GIT_AUTOINSTALL_FILENAME%
echo Lang=default >>%CB_GIT_AUTOINSTALL_FILENAME%
echo Dir=%CB_DEVTOOLS%\git-%CB_PACKAGE_VERSION% >>%CB_GIT_AUTOINSTALL_FILENAME%
echo Group=Git >>%CB_GIT_AUTOINSTALL_FILENAME%
echo NoIcons=0 >>%CB_GIT_AUTOINSTALL_FILENAME%
echo SetupType=default >>%CB_GIT_AUTOINSTALL_FILENAME%
echo Components=gitlfs >>%CB_GIT_AUTOINSTALL_FILENAME%
echo Tasks= >>%CB_GIT_AUTOINSTALL_FILENAME%
echo EditorOption=VIM >>%CB_GIT_AUTOINSTALL_FILENAME%
echo CustomEditorPath= >>%CB_GIT_AUTOINSTALL_FILENAME%
echo PathOption=Cmd >>%CB_GIT_AUTOINSTALL_FILENAME%
echo SSHOption=OpenSSH >>%CB_GIT_AUTOINSTALL_FILENAME%
echo TortoiseOption=false >>%CB_GIT_AUTOINSTALL_FILENAME%
echo CURLOption=OpenSSL >>%CB_GIT_AUTOINSTALL_FILENAME%
echo CRLFOption=CRLFAlways >>%CB_GIT_AUTOINSTALL_FILENAME%
echo BashTerminalOption=MinTTY >>%CB_GIT_AUTOINSTALL_FILENAME%
echo GitPullBehaviorOption=Merge >>%CB_GIT_AUTOINSTALL_FILENAME%
echo PerformanceTweaksFSCache=Enabled >>%CB_GIT_AUTOINSTALL_FILENAME%
echo UseCredentialManager=Enabled >>%CB_GIT_AUTOINSTALL_FILENAME%
echo EnableSymlinks=Disabled >>%CB_GIT_AUTOINSTALL_FILENAME%
echo EnablePseudoConsoleSupport=Disabled >>%CB_GIT_AUTOINSTALL_FILENAME%
set "CB_PACKAGE_INSTALL_PARAMETER=/LOADINF="%CB_GIT_AUTOINSTALL_FILENAME%" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS"
