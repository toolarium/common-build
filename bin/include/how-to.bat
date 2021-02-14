@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: how-to.bat
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

echo.
echo  The common build gives you a complete development environment. All needed 
echo  dependencies like gradle, java, node but also development tools such as eclipse,
echo  jmeter, squirrel, visualvm... are either automatically or can be installed very 
echo  easily on the command line (see below).
echo.
echo  The common build uses only the environment variable CB_HOME, which already exists
echo  after installation. You can also set them manually. All other environment variables
echo  like JAVA_HOME or GRADLE_HOME are not / never touched. You retain full flexibility.
echo.
echo  Multiple versions of software packages are supported. To determine which version is 
echo  the default version, you can define it on the command line.
echo.
echo  1)  Create a new project
echo      Just change the directory where you want to have your new project and create the
echo      project with the following call (follow the wizzard):
echo      cb --new
echo.
echo  2)  Installing additional software
echo      To install additional software like eclipse, jmeter, squirrel... you can install 
echo      them with the parameter --install followed by the software package to installed.
echo      The following will install eclipse:
echo      cb --install eclipse
echo.
echo  4)  Check supported software packages
echo      cb --packages
echo.
echo      If you miss your preferred software package, please let us know by creating an
echo      issue on github.
echo.
echo  5)  Set the common build environment variables on your current shell
echo      To set the same environment variables that are used within the common build, you 
echo      can call this command. The main purpose is in case you ant to call a software
echo      package manually. The first call only shows the environment variables that could
echo      be set. The send calls it in your current shell:
echo      cb --setenv
echo      . cb --setenv
echo.
echo  Further examples:
echo  6)  Install java version 14: cb --install java 14
echo  7)  Install java version 11 and set it as default: cb --install java 11 --default
echo  8)  Install gradle version and force new installation: cb --force --install gradle 6.5
echo  9)  Install specific maven version: cb --install maven 3.6.3
echo  10) Install specific ant version: cb --install ant 1.10.8
echo  11) Install manual node version: cb --install node
echo.
echo  Please visit for more information: https://github.com/toolarium/common-build
echo.


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
