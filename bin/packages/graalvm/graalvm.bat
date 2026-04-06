@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: graalvm.bat
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


if not defined CB_GRAALVM_VERSION set "CB_GRAALVM_VERSION=21.0.2"
set "CB_PACKAGE_VERSION=%1"
if .%CB_PACKAGE_VERSION%==. set "CB_PACKAGE_VERSION=%CB_GRAALVM_VERSION%"
set "CB_PACKAGE_BASE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DOWNLOAD_NAME=graalvm-community-jdk-%CB_PACKAGE_VERSION%_windows-x%CB_PROCESSOR_ARCHITECTURE_NUMBER%_bin.zip"
set "CB_PACKAGE_DEST_VERSION_NAME=graalvm-%CB_PACKAGE_VERSION%"
set "CB_PACKAGE_DIRECTORY_NAME=%CB_DEVTOOLS%\graalvm-%CB_PACKAGE_VERSION%"

if .%CB_INSTALL_OVERWRITE_DIST%==.false if exist %CB_PACKAGE_DIRECTORY_NAME% set "CB_PACKAGE_ALREADY_EXIST=true"

:: GraalVM Native Image requires Visual Studio Build Tools with C++ workload.
:: Check if cl.exe (MSVC compiler) is available; if not, install Build Tools via winget.
where cl.exe >nul 2>nul
if %ERRORLEVEL% EQU 0 goto :GRAALVM_VSBT_FOUND
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC" goto :GRAALVM_VSBT_FOUND
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC" goto :GRAALVM_VSBT_FOUND
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\VC" goto :GRAALVM_VSBT_FOUND
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC" goto :GRAALVM_VSBT_FOUND
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Professional\VC" goto :GRAALVM_VSBT_FOUND
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC" goto :GRAALVM_VSBT_FOUND
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Enterprise\VC" goto :GRAALVM_VSBT_FOUND
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC" goto :GRAALVM_VSBT_FOUND

:: Resolve winget: check PATH first, then known install locations
set "CB_WINGET_CMD="
where winget >nul 2>nul && set "CB_WINGET_CMD=winget"
if not defined CB_WINGET_CMD if exist "%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe" set "CB_WINGET_CMD=%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe"
if not defined CB_WINGET_CMD for /f "delims=" %%W in ('powershell -nologo -command "(Get-Command winget -ErrorAction SilentlyContinue).Source" 2^>nul') do set "CB_WINGET_CMD=%%W"
if defined CB_WINGET_CMD goto :GRAALVM_INSTALL_VSBT

:: winget not found, try to install it
echo %CB_LINEHEADER%Install Microsoft winget...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -OutFile '%TEMP%\winget.msixbundle'; Add-AppxPackage -Path '%TEMP%\winget.msixbundle'"
where winget >nul 2>nul && set "CB_WINGET_CMD=winget"
if not defined CB_WINGET_CMD if exist "%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe" set "CB_WINGET_CMD=%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe"
if defined CB_WINGET_CMD goto :GRAALVM_INSTALL_VSBT

echo %CB_LINEHEADER%WARNING: Could not find winget. Visual Studio Build Tools with C++ workload not found.
echo %CB_LINEHEADER%GraalVM Native Image requires it. Please install manually:
echo %CB_LINEHEADER%  winget install Microsoft.VisualStudio.2022.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive"
goto :GRAALVM_VSBT_FOUND

:GRAALVM_INSTALL_VSBT
echo %CB_LINEHEADER%Visual Studio Build Tools not found, installing C++ workload for GraalVM Native Image...
%CB_WINGET_CMD% install Microsoft.VisualStudio.2022.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive"

:GRAALVM_VSBT_FOUND

:: Resolve the VC directory path and create a junction link under current\vc
set "CB_VC_DIR="
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC" set "CB_VC_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC"
if defined CB_VC_DIR goto :GRAALVM_VC_LINK
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC" set "CB_VC_DIR=%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC"
if defined CB_VC_DIR goto :GRAALVM_VC_LINK
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\VC" set "CB_VC_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\VC"
if defined CB_VC_DIR goto :GRAALVM_VC_LINK
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC" set "CB_VC_DIR=%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC"
if defined CB_VC_DIR goto :GRAALVM_VC_LINK
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Professional\VC" set "CB_VC_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Professional\VC"
if defined CB_VC_DIR goto :GRAALVM_VC_LINK
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC" set "CB_VC_DIR=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC"
if defined CB_VC_DIR goto :GRAALVM_VC_LINK
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Enterprise\VC" set "CB_VC_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Enterprise\VC"
if defined CB_VC_DIR goto :GRAALVM_VC_LINK
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC" set "CB_VC_DIR=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC"
if defined CB_VC_DIR goto :GRAALVM_VC_LINK
goto :GRAALVM_VC_DONE

:GRAALVM_VC_LINK
if not defined CB_CURRENT_PATH goto :GRAALVM_VC_DONE
if exist "%CB_CURRENT_PATH%\vc" rmdir /q "%CB_CURRENT_PATH%\vc" >nul 2>nul
mklink /J "%CB_CURRENT_PATH%\vc" "%CB_VC_DIR%" >nul 2>nul
echo %CB_VC_DIR%> "%CB_CURRENT_PATH%\vc.path"
if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Created link current\vc to %CB_VC_DIR%

:GRAALVM_VC_DONE

:: The archive contains a top-level directory with + in the name (e.g. graalvm-community-openjdk-21.0.2+13.1).
:: CB_PACKAGE_DEST_VERSION_NAME extracts into graalvm-<version>/, creating a nested structure.
:: The post-install action moves the inner contents up and removes the nested directory.
set CB_POST_INSTALL_ACTION=powershell -nologo -command "$d = Get-ChildItem '%CB_PACKAGE_DIRECTORY_NAME%' -Directory -Filter 'graalvm-community-*'; if($d) { foreach($i in Get-ChildItem $d.FullName) { Move-Item $i.FullName '%CB_PACKAGE_DIRECTORY_NAME%' -Force }; Remove-Item $d.FullName -Recurse -Force }"
