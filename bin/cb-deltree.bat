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
if ".%1" ==".--silent" set "CB_SILENT=true" & shift

set "TMPFILE=%TEMP%\cb-deltree-%RANDOM%%RANDOM%.tmp"
dir /B "%1" > "%TMPFILE%" 2>nul
for /f %%i in (%TMPFILE%) do (call :DELETE_FOLDER %%i)
if exist %TMPFILE% del /f /q %TMPFILE% >nul 2>nul
goto END

:DELETE_FOLDER
if not exist "%1\*" if [%CB_SILENT%] equ [false] echo %CB_LINEHEADER%Ignore file [%1].
if not exist "%1\*" goto :eof
if [%CB_SILENT%] equ [false] echo %CB_LINEHEADER%Delete folder [%1]...
del /f /q /s "%1\*.*" >nul 2>nul
rd /s /q "%1" >nul 2>nul
:: repeat because rd is sometimes buggy 
if exist "%1" rd /s /q "%1" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::