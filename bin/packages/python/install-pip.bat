@ECHO OFF
setlocal enabledelayedexpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: install-pip.bat
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


:: Skip if pip is already installed
if exist "%CB_PACKAGE_DIRECTORY_NAME%\Scripts\pip.exe" goto :EOF

:: The embeddable Python package comments out "import site" in the _pth file.
:: Pip requires site-packages support, so uncomment it.
for %%f in ("%CB_PACKAGE_DIRECTORY_NAME%\python*._pth") do (
    powershell -nologo -command "(Get-Content '%%f') -replace '^#import site', 'import site' | Set-Content '%%f'"
)

:: Download get-pip.py and install pip
set "CB_GET_PIP=%CB_TEMP%\get-pip-%RANDOM%.py"
if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Downloading get-pip.py...
powershell -nologo -command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '!CB_GET_PIP!'" >nul 2>nul
if not exist "!CB_GET_PIP!" (
    echo %CB_LINEHEADER%Failed to download get-pip.py, pip will not be available.
    goto :EOF
)

if [%CB_INSTALL_SILENT%] equ [false] echo %CB_LINEHEADER%Installing pip into %CB_PACKAGE_DIRECTORY_NAME%...
"%CB_PACKAGE_DIRECTORY_NAME%\python.exe" "!CB_GET_PIP!" --no-warn-script-location
if %ERRORLEVEL% NEQ 0 echo %CB_LINEHEADER%pip installation failed.

del /f /q "!CB_GET_PIP!" >nul 2>nul
endlocal
