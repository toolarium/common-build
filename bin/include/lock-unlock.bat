@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: lock-unlock.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


setlocal EnableDelayedExpansion
if [%1] equ [--unlock] shift & goto UNLOCK

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:LOCK
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "lockFile=%1"
set "lockFilePath=%~dp1"
mkdir "%lockFilePath%" >nul 2>nul 
set "lockTimeout=%2"
if .lockTimeout==. set lockTimeout=60
set "lockTimeStamp=" & set "lockDifference=" & set "curentLockTimestamp="
for /f "tokens=1 delims=." %%a in ('powershell get-date -uformat %%s') do ( set "curentLockTimestamp=%%a" )
if exist %lockFile% set /p lockTimeStamp=<%lockFile%
::echo diff %lockDifference% %curentLockTimestamp% %lockTimeStamp% 
if not defined lockDifference echo %curentLockTimestamp%>"%lockFile%" & goto END
if %lockDifference% LEQ %lockTimeout% if .%CB_INSTALL_SILENT%==.false echo %CB_LINEHEADER%Another process is already doing the update.
if %lockDifference% LEQ %lockTimeout% goto END_WITH_ERROR
echo %curentLockTimestamp%>"%lockFile%"
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UNLOCK
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
del /f /q "%1" >nul 2>nul
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