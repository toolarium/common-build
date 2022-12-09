@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: lock-unlock.bat
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


setlocal EnableDelayedExpansion
if not defined CB_LINEHEADER set "CB_LINEHEADER=.: "
if not defined CB_INSTALL_SILENT set "CB_INSTALL_SILENT=false"
if [%1] equ [--unlock] shift & goto UNLOCK
if [%1] equ [--lock] shift

:: get pid
for /f "USEBACKQ TOKENS=2 DELIMS==" %%A in (`wmic process where ^(Name^="WMIC.exe" AND CommandLine LIKE "^%^%^%TIME^%^%^%"^) get ParentProcessId /value 2^>nul ^| find "ParentProcessId"`) do set "PID=%%A"


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:LOCK
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
call :PARSE_LOCK_FILE %1 %2 %3
if %lockProcessId%==%processId% call :DELETE_LOCKFILE %lockFile% & set lockDifference=%curentLockTimestamp%
if %lockDifference% LEQ %lockTimeout% if .%CB_INSTALL_SILENT%==.false echo %CB_LINEHEADER%Another process is already doing the update, pid:%lockProcessId%.
if %lockDifference% LEQ %lockTimeout% goto END_WITH_ERROR
echo %curentLockTimestamp%=%processId%>"%lockFile%"
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UNLOCK
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
call :PARSE_LOCK_FILE %1 %2 %3
call :DELETE_LOCKFILE %lockFile%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PARSE_LOCK_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "lockFilePath="
if [%1] equ [] (set "lockFile=lockfile") else (set "lockFile=%~1" & set "lockFilePath=%~dp1")
if [%2] equ [] (set lockTimeout=60) else (set "lockTimeout=%2")
if [%3] equ [] (set "processId=%PID%") else (set "processId=%3")
if not exist %lockFilePath% mkdir "%lockFilePath%" >nul 2>nul 
set "lockTimeStamp=0" & set "lockProcessId=" & set "lockDifference=0" & set "curentLockTimestamp="
for /f "tokens=1 delims=." %%a in ('powershell get-date -uformat %%s') do ( set "curentLockTimestamp=%%a" )
if exist %lockFile% for /f "tokens=1,* delims=^=" %%i in (%lockFile%) do (
	set "lockTimeStamp=%%i" & set "lockTimeStamp=!lockTimeStamp: =!"
	set lockProcessId=%%j & set "lockProcessId=!lockProcessId: =!"
)

set /a "lockDifference=%curentLockTimestamp%-%lockTimeStamp%"
::echo %CB_LINEHEADER%[%lockFilePath%][%lockFile%], %lockTimeStamp%, id: %lockProcessId% - current:%curentLockTimestamp%, id: %processId% - diff: %lockDifference%
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DELETE_LOCKFILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist %1 del /f /q "%~1" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END_WITH_ERROR
endlocal
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
endlocal
:END
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::