@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-dockterm.bat
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
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion

set "DOCKTERM_VERSION=0.2.0"
set "PN=%~n0"
if not defined CB_LINE set "CB_LINE=------------------------------------------------------------------------------------------------------------------------"
if not defined CB_LINEHEADER set "CB_LINEHEADER=.: "
if not defined CB_SCRIPT_PATH set "CB_SCRIPT_PATH=%~dp0"
set "CB_DOCKTERM_CONFIGFILE=%CB_SCRIPT_PATH%..\conf\dockterm-types.properties"

set "DOCKTERM_TYPE_INPUT="
set "DOCKTERM_SHELL=/bin/sh"
set "DOCKTERM_REMOVE_IMAGE=--rm"
set "DOCKTERM_VERBOSE=false"

:PARSE_ARGS
if "%~1"=="" goto PARSE_ARGS_END
if /I "%~1"=="-h" (call :PRINT_USAGE & endlocal & exit /b 0)
if /I "%~1"=="--help" (call :PRINT_USAGE & endlocal & exit /b 0)
if /I "%~1"=="-v" (call :PRINT_VERSION & endlocal & exit /b 0)
if /I "%~1"=="--version" (call :PRINT_VERSION & endlocal & exit /b 0)
if /I "%~1"=="--verbose" (set "DOCKTERM_VERBOSE=true" & shift & goto PARSE_ARGS)
if /I "%~1"=="-k" (set "DOCKTERM_REMOVE_IMAGE=" & shift & goto PARSE_ARGS)
if /I "%~1"=="--keep-image" (set "DOCKTERM_REMOVE_IMAGE=" & shift & goto PARSE_ARGS)
if /I "%~1"=="-s" (shift & set "DOCKTERM_SHELL=%~2" & shift & goto PARSE_ARGS)
if /I "%~1"=="--shell" (shift & set "DOCKTERM_SHELL=%~2" & shift & goto PARSE_ARGS)
set "DOCKTERM_TYPE_INPUT=%~1"
shift
goto PARSE_ARGS
:PARSE_ARGS_END

if not exist "%CB_DOCKTERM_CONFIGFILE%" (
	echo %CB_LINE%
	echo %CB_LINEHEADER%Missing dockterm configuration file %CB_DOCKTERM_CONFIGFILE%!
	echo %CB_LINE%
	endlocal & exit /b 1
)

:: detect container runtime: try nerdctl info first, fall back to docker info
set "CB_CONTAINER_RUNTIME="
where nerdctl >nul 2>nul && nerdctl info >nul 2>nul && set "CB_CONTAINER_RUNTIME=nerdctl"
if not defined CB_CONTAINER_RUNTIME where docker >nul 2>nul && docker info >nul 2>nul && set "CB_CONTAINER_RUNTIME=docker"
if not defined CB_CONTAINER_RUNTIME (
	echo %CB_LINE%
	echo %CB_LINEHEADER%No reachable container runtime ^(nerdctl or docker^).
	echo %CB_LINE%
	endlocal & exit /b 1
)
if /I "%DOCKTERM_VERBOSE%"=="true" echo %CB_LINEHEADER%Using container runtime: %CB_CONTAINER_RUNTIME%

:: prepare temp filtered config file (comments/blank lines stripped)
if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb" & mkdir "%CB_TEMP%" >nul 2>nul
set "CB_DOCKTERM_CONFIGFILE_TMPFILE=%CB_TEMP%\cb-dockterm-types-%RANDOM%%RANDOM%.tmp"
type "%CB_DOCKTERM_CONFIGFILE%" 2>nul | findstr /V "^#" | findstr /C:"=" > "%CB_DOCKTERM_CONFIGFILE_TMPFILE%"

:: try to resolve input first
set "docktermType="
set "docktermImage="
if defined DOCKTERM_TYPE_INPUT call :RESOLVE_TYPE "%DOCKTERM_TYPE_INPUT%"

if defined docktermType (
	echo %CB_LINEHEADER%Dockterm type [%CB_CONTAINER_RUNTIME%/%docktermType%] -^> %CB_CONTAINER_RUNTIME% run %DOCKTERM_REMOVE_IMAGE% --name %docktermType% -it -h %docktermType% %docktermImage% %DOCKTERM_SHELL%
	goto RUN_CONTAINER
)

if defined DOCKTERM_TYPE_INPUT echo %CB_LINEHEADER%Invalid input %DOCKTERM_TYPE_INPUT% & echo\

:PROMPT_TYPE
echo %CB_LINEHEADER%Dockterm type:
call :PRINT_TYPES
echo\
set "input=1"
set /p input=%CB_LINEHEADER%Please choose the dockterm type [1]:
call :RESOLVE_TYPE "%input%"
if not defined docktermType echo %CB_LINEHEADER%Invalid input %input% & echo\ & goto PROMPT_TYPE

:RUN_CONTAINER
if not defined docktermImage (
	echo %CB_LINE%
	echo %CB_LINEHEADER%Could not find corresponding image for dockterm type %docktermType%.
	echo %CB_LINE%
	del /f /q "%CB_DOCKTERM_CONFIGFILE_TMPFILE%" 2>nul
	endlocal & exit /b 1
)

if /I "%DOCKTERM_VERBOSE%"=="true" echo %CB_LINEHEADER%Pulling %docktermImage%...
if /I "%DOCKTERM_VERBOSE%"=="true" (
	call %CB_CONTAINER_RUNTIME% pull %docktermImage%
) else (
	call %CB_CONTAINER_RUNTIME% pull %docktermImage% >nul 2>nul
)
if errorlevel 1 (del /f /q "%CB_DOCKTERM_CONFIGFILE_TMPFILE%" 2>nul & endlocal & exit /b 1)

del /f /q "%CB_DOCKTERM_CONFIGFILE_TMPFILE%" 2>nul
call %CB_CONTAINER_RUNTIME% run %DOCKTERM_REMOVE_IMAGE% --name %docktermType% -it -h %docktermType% %docktermImage% %DOCKTERM_SHELL%
endlocal & exit /b %ERRORLEVEL%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRINT_USAGE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - docker term v%DOCKTERM_VERSION%
echo usage: %PN% [OPTION] [type]
echo\
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  -v, --version        Print the version information.
echo      --verbose        Verbose output (show pull progress).
echo  -k, --keep-image     Keep container after exit (omit --rm).
echo  -s, --shell ^<shell^>  Defines the shell, default: /bin/sh.
echo\
echo The [type] may be given as the numeric menu index or the type name.
echo Available types are defined in conf\dockterm-types.properties (key=value
echo format where key is the type name and value is the Docker image).
echo\
echo Default types: alpine, arch, debian, fedora, kali, kaliexp, ubuntu
echo\
echo To add a custom type, edit conf\dockterm-types.properties:
echo   myimage = registry.example.com/my-dev-image:latest
echo Then run: %PN% myimage
echo\
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRINT_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo toolarium dockterm %DOCKTERM_VERSION%
echo %CB_LINE%
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRINT_TYPES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set /a count=0
for /f "usebackq tokens=1,* delims== " %%i in ("%CB_DOCKTERM_CONFIGFILE_TMPFILE%") do (
	set /a count+=1
	set "v=%%j"
	call :TRIM v
	set "k=%%i                "
	set "k=!k:~0,16!"
	echo    [!count!] !k! !v!
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RESOLVE_TYPE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "docktermType="
set "docktermImage="
set "rt_input=%~1"
:: numeric?
set /a rt_num=0
set /a rt_num=%rt_input% 2>nul
if "%rt_num%"=="0" goto RESOLVE_BY_NAME
if %rt_num% LEQ 0 goto RESOLVE_BY_NAME

set /a count=0
for /f "usebackq tokens=1,* delims== " %%i in ("%CB_DOCKTERM_CONFIGFILE_TMPFILE%") do (
	set /a count+=1
	if !count! EQU %rt_num% (
		set "docktermType=%%i"
		set "docktermImage=%%j"
		call :TRIM docktermImage
	)
)
goto :eof

:RESOLVE_BY_NAME
for /f "usebackq tokens=1,* delims== " %%i in ("%CB_DOCKTERM_CONFIGFILE_TMPFILE%") do (
	set "rt_key=%%i"
	call :TRIM rt_key
	if /I "!rt_key!"=="%rt_input%" (
		set "docktermType=!rt_key!"
		set "docktermImage=%%j"
		call :TRIM docktermImage
	)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TRIM
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
for /f "tokens=* delims= " %%x in ("!%~1!") do set "%~1=%%x"
:: strip trailing spaces
:TRIM_LOOP
if "!%~1:~-1!"==" " set "%~1=!%~1:~0,-1!" & goto TRIM_LOOP
goto :eof
