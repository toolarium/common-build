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
set "CB_VERBOSE=false"
if ".%~1" ==".--verbose" set "CB_VERBOSE=true" & shift
if not exist "%~1" goto END

set "TMPFILE=%TEMP%\cb-deltree-%RANDOM%%RANDOM%.tmp"
if [%CB_VERBOSE%] equ [true] echo %CB_LINEHEADER%Delete [%1]...
dir /B /s "%~1" > "%TMPFILE%" 2>nul
for /f %%i in ("%TMPFILE%") do (call :DELETE_FOLDER "%%i")
if exist %TMPFILE% del /f /q %TMPFILE% >nul 2>nul
rd /s /q "%~1" >nul 2>nul
:: repeat because rd is sometimes buggy 
if exist "%~1" rd /s /q "%1" >nul 2>nul
goto END

:DELETE_FOLDER
if [%CB_VERBOSE%] equ [true] echo %CB_LINEHEADER%Delete [%1]...
del /f /q /s "%1\*.*" >nul 2>nul
del /f /q /s "%1\*" >nul 2>nul
del /f /q /s "%1" >nul 2>nul
rd /s /q "%1" >nul 2>nul
:: repeat because rd is sometimes buggy 
if exist "%1" rd /s /q "%1" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::