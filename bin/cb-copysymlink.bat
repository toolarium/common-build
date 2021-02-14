@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-copysymlink.bat
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

setlocal
set PN=%~nx0
set "CB_LINEHEADER=.: "
set CB_SILENT=false
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.--silent shift & set CB_SILENT=true
if .%1==. goto HELP
if .%2==. goto HELP


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MAIN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set SOURCE=%1
set DEST=%2
if not exist %1 echo %CB_LINEHEADER%Could not found source folder %1. & exit /b 1
if not exist %2 if [%CB_SILENT%] equ [false] echo %CB_LINEHEADER%Create destination folder %2.
mkdir %DEST% >nul 2>nul

for /f "tokens=1-3 delims=><" %%a in ('dir %1 /al /s') do call :COPY_SYMLINK "%%a" "%%b" "%%c"
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - copy a folder of symbolic links to another
echo usage: %PN% [source-directory] [destination-directory]
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:COPY_SYMLINK
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not .%2 == ."JUNCTION" goto :eof
set "dirContent=%~3"
set "destLink=%dirContent:*[=%" 
set "destLink=%destLink:]=%"
for /F %%a in ("%dirContent%") do set "linkName=%%a"
if [%CB_SILENT%] equ [false] echo %CB_LINEHEADER%Copy link [%SOURCE%\%linkName%] (of %destLink%) to [%DEST%\%linkName%]
if exist %DEST%\%linkName% rmdir /s/q %DEST%\%linkName% >nul 2>nul
mklink /J %DEST%\%linkName% %destLink% >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
