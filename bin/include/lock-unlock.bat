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
if [%1] equ [--unlock] shift & goto UNLOCK

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:LOCK
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "lockFile=%~1"
set "lockFilePath=%~dp1"
mkdir "%lockFilePath%" >nul 2>nul 
set "lockTimeout=%2"
if .lockTimeout==. set lockTimeout=60
set "lockTimeStamp=" & set "lockDifference=" & set "curentLockTimestamp="
for /f "tokens=1 delims=." %%a in ('powershell get-date -uformat %%s') do ( set "curentLockTimestamp=%%a" )
if exist "%lockFile%" set /p lockTimeStamp=<"%lockFile%"
::echo diff %lockDifference% %curentLockTimestamp% %lockTimeStamp% 
if not defined lockDifference echo %curentLockTimestamp%>"%lockFile%" & goto END
if %lockDifference% LEQ %lockTimeout% if .%CB_INSTALL_SILENT%==.false echo %CB_LINEHEADER%Another process is already doing the update.
if %lockDifference% LEQ %lockTimeout% goto END_WITH_ERROR
echo %curentLockTimestamp%>"%lockFile%"
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UNLOCK
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist %1 del /f /q "%~1" >nul 2>nul
goto END


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