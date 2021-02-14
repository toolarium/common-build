@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-cleanuppath.bat
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


:: read path
set "SYSTEM_PATH=" & set "USER_PATH="
for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "Path" 2^>nul') do (if /I "%%N" == "Path" (set "SYSTEM_PATH=%%P" & goto GET_USER_PATH_FROM_REGISTRY))
:GET_USER_PATH_FROM_REGISTRY
for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKCU\Environment" /v "Path" 2^>nul') do (if /I "%%N" == "Path" (set "USER_PATH=%%P" & goto GET_USER_PATH_FROM_REGISTRY_END))
:GET_USER_PATH_FROM_REGISTRY_END

if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb"
if not exist %CB_TEMP% mkdir "%CB_TEMP%" >nul 2>nul
set "TMPFILE=%CB_TEMP%\cb-cleanuppath-%RANDOM%%RANDOM%.txt"
set VERBOSE=false


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if %0X==X goto END
if .%1==. goto HELP
if .%1 == .--verbose shift & set VERBOSE=true
if .%2==. goto HELP
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1 == .--user shift & goto CLEANUP_USERPATH %1
if .%1 == .--system shift & goto CLEANUP_SYSTEMPATH %1
if .%1 == .--path shift & goto CLEANUP_PATH %1
goto CHECK_PARAMETER


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo cb-cleanpath - cleanup path
echo usage: cb-cleanpath [OPTION]
echo.
echo Overview of the available OPTIONs:
echo  -h, --help                        Show this help message.
echo  -s, --system expression-to-clean  Cleanup system path and set the SYSTEM_PATH environment variable.
echo  -u, --user expression-to-clean    Cleanup user path and set the USER_PATH environment variable.
echo  -p, --path expression-to-clean    Cleanup path and set the PATH environment variable.
echo.
echo Example:
echo  -Cleanup user path: cb-cleanpath --user toolarium
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEANUP_PATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if .%VERBOSE% == .true echo .: Clean path with %1: %PATH% 
set OLDPATH=%PATH%
:CLEANUP_PATH_LOOP
::extract the first text token with the default delimiter of semicolon
for /f "tokens=1 delims=;" %%G in ("%OLDPATH%") do (
:: copy text token to TMPFILE unless what we want to remove is found and remove text token from OLDPATH
<NUL set /p="%%G" | find /i "%1" >NUL 2>&1 || <NUL set /p="%%G;" >>%TMPFILE%
set "OLDPATH=%OLDPATH:*;=%"
)

:: repeat loop until OLDPATH no longer has any delimiters, and then add any remaining value to TMPFILE
echo %OLDPATH% | findstr /C:";" >NUL && (goto :CLEANUP_PATH_LOOP) || <NUL set /p="%OLDPATH%" >>%TMPFILE%

:: set the OLDPATH to TMPFILE
for /f "usebackq delims=" %%G in (%TMPFILE%) do (set "OLDPATH=%%G")
::type %TMPFILE%
del %TMPFILE% >NUL 2>&1
if .%VERBOSE% == .true echo .: Cleaned path with %1: %OLDPATH% 
set "PATH=%OLDPATH%"
set OLDPATH=
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEANUP_USERPATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if .%VERBOSE% == .true echo .: Clean user path with %1: %USER_PATH% 
:CLEANUP_USERPATH_LOOP
::extract the first text token with the default delimiter of semicolon
for /f "tokens=1 delims=;" %%G in ("%USER_PATH%") do (
:: copy text token to TMPFILE unless what we want to remove is found and remove text token from USER_PATH
<NUL set /p="%%G" | find /i "%1" >NUL 2>&1 || <NUL set /p="%%G;" >>%TMPFILE%
set "USER_PATH=%USER_PATH:*;=%"
)

:: repeat loop until USER_PATH no longer has any delimiters, and then add any remaining value to TMPFILE
echo %USER_PATH% | findstr /C:";" >NUL && (goto :CLEANUP_USERPATH_LOOP) || <NUL set /p="%USER_PATH%" >>%TMPFILE%

:: set the USER_PATH to TMPFILE
for /f "usebackq delims=" %%G in (%TMPFILE%) do (set "USER_PATH=%%G")
::type %TMPFILE%
del %TMPFILE% >NUL 2>&1
if .%VERBOSE% == .true echo .: Cleaned user path with %1: %USER_PATH% 
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEANUP_SYSTEMPATH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if .%VERBOSE% == .true echo .: Clean system path with %1: %SYSTEM_PATH% 
:CLEANUP_SYSTEMPATH_LOOP
::extract the first text token with the default delimiter of semicolon
for /f "tokens=1 delims=;" %%G in ("%SYSTEM_PATH%") do (
:: copy text token to TMPFILE unless what we want to remove is found and remove text token from SYSTEM_PATH
<NUL set /p="%%G" | find /i "%1" >NUL 2>&1 || <NUL set /p="%%G;" >>%TMPFILE%
set "SYSTEM_PATH=%SYSTEM_PATH:*;=%"
)

:: repeat loop until SYSTEM_PATH no longer has any delimiters, and then add any remaining value to TMPFILE
echo %SYSTEM_PATH% | findstr /C:";" >NUL && (goto :CLEANUP_SYSTEMPATH_LOOP) || <NUL set /p="%SYSTEM_PATH%" >>%TMPFILE%

:: set the SYSTEM_PATH to TMPFILE
for /f "usebackq delims=" %%G in (%TMPFILE%) do (set "SYSTEM_PATH=%%G")
::type %TMPFILE%
del %TMPFILE% >NUL 2>&1
if .%VERBOSE% == .true echo .: Cleaned system path with %1: %SYSTEM_PATH% 
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
set TMPFILE=
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
