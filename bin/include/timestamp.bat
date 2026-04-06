@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: timestamp.bat
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
:: along with the common-build. If not, see <http://www.gnu.org/licenses/>.
::
:: Usage: call timestamp.bat <outVar> [format]
::        outVar  - name of the variable that receives the timestamp
::        format  - optional .NET date format, defaults to "yyyy-MM-dd HH:mm:ss.fff"
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if .%1==. exit /b 1

set "_cb_ts_fmt=yyyy-MM-dd HH\:mm\:ss.fff"
if not .%2==. set "_cb_ts_fmt=%~2"

for /f "usebackq delims=" %%a in (`powershell -NoLogo -NoProfile -Command "Get-Date -Format '%_cb_ts_fmt%'"`) do set "%~1=%%a"
set "_cb_ts_fmt="

exit /b 0
