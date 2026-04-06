@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: read-version.bat
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


:: first parameter defines the versin file
:: secomd parameter defines if the qualifier should be added or not (default true)
if not exist "%~1" set "version.number=n/a" & goto :eof
set "major.number="
set "minor.number="
set "revision.number="
set "qualifier="
for /f "usebackq eol=# tokens=1,2 delims== " %%a in ("%~1") do (
  if /i "%%a"=="major.number"    set "major.number=%%b"
  if /i "%%a"=="minor.number"    set "minor.number=%%b"
  if /i "%%a"=="revision.number" set "revision.number=%%b"
  if /i "%%a"=="qualifier"       set "qualifier=%%b"
)

:: trim
if defined major.number set major.number=%major.number: =%
if defined minor.number set minor.number=%minor.number: =%
if defined revision.number set revision.number=%revision.number: =%
if defined qualifier set qualifier=%qualifier: =%

:: combine to version number
set "version.number=%major.number%.%minor.number%.%revision.number%"
if defined qualifier if not .%qualifier%==. if .%2==. set "version.number=%version.number%-%qualifier%"
if defined qualifier if not .%qualifier%==. if .%2==.true set "version.number=%version.number%-%qualifier%"
