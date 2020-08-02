@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-deltree.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


setlocal EnableDelayedExpansion
set "CB_SILENT=false"
if .%1 == .--silent set "CB_SILENT=true" & shift
set "folderToDelete=%1"
if .%folderToDelete% == . goto END
if not exist %folderToDelete% goto END

if [%CB_SILENT%] equ [false] echo %CB_LINEHEADER%Delete folder %folderToDelete%...
del /f /q /s %folderToDelete%\*.* >nul
rd /s /q %folderToDelete%
:: repeat because rd is sometimes buggy 
if exist %folderToDelete% rd /s /q %folderToDelete%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::