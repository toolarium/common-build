@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: rust.bat
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
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:32=%" set "CB_PACKAGE_DOWNLOAD_URL=https://static.rust-lang.org/rustup/dist/i686-pc-windows-msvc/rustup-init.exe"
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:64=%" set "CB_PACKAGE_DOWNLOAD_URL=https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
set "CB_PACKAGE_DOWNLOAD_NAME=rustup-init.exe"
set "CB_PACKAGE_NO_DEFAULT=true"
set "CB_PACKAGE_INSTALL_PARAMETER=-q -y"
