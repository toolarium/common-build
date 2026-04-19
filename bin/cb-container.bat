@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-container.bat
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

set "CB_CONTAINER_VERSION=1.0.0"
set "PN=%~n0"
if not defined CB_LINE set "CB_LINE=------------------------------------------------------------------------------------------------------------------------"
if not defined CB_LINEHEADER set "CB_LINEHEADER=.: "
if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb"
set "CB_CONTAINER_TEMP=!CB_TEMP!\cb-container"
if not exist "!CB_CONTAINER_TEMP!" mkdir "!CB_CONTAINER_TEMP!" >nul 2>nul

:: Go template format strings -defined here to avoid }} parsing issues inside blocks
set "CB_FMT_PS={{.ID}}|{{.Image}}|{{.CreatedAt}}"
set "CB_FMT_IMG={{.ID}}|{{.Repository}}|{{.Tag}}|{{.Size}}|{{.CreatedAt}}"
set "CB_FMT_REPO_TAG={{.Repository}}:{{.Tag}}"
set "CB_FMT_ID_REPO_TAG={{.ID}}|{{.Repository}}:{{.Tag}}"
set "CB_FMT_ID_IMG={{.ID}}|{{.Image}}"
set "CB_FMT_IMAGE={{.Image}}"
set "CB_FMT_SCAN_ID={{.ID}}"

set "CB_CONTAINER_SHELL=/bin/sh"
set "CB_CONTAINER_ID="
set "CB_CONTAINER_ENTRYPOINT="
set "CB_CONTAINER_ENV="
set "CB_CONTAINER_PORT_ARGS="
set "CB_CONTAINER_START_IMAGE="
set "CB_CONTAINER_STOP_TARGET="
set "CB_CONTAINER_SCAN_TARGET="
set "CB_CONTAINER_CLEAN=false"
set "CB_CONTAINER_DELETE_TARGET="
set "CB_CONTAINER_LOG_TARGET="
set "CB_CONTAINER_LOG_LINES="
set "CB_CONTAINER_TAIL=false"
set "CB_CONTAINER_ALL=false"
set "CB_CONTAINER_LIST=false"
set "CB_CONTAINER_VERBOSE=false"

rem read .cb-container config file if present (first line = default parameters)
if not defined CB_CONTAINER_CONFIG_LOADED if exist ".cb-container" (
	set "cbContainerConfig="
	for /f "usebackq tokens=*" %%a in (".cb-container") do (
		if not defined cbContainerConfig set "cbContainerConfig=%%a"
	)
	if defined cbContainerConfig (
		set "CB_CONTAINER_CONFIG_LOADED=true"
		call "%~f0" !cbContainerConfig! %*
		exit /b !ERRORLEVEL!
	)
)

:PARSE_ARGS
if "%~1"=="" goto PARSE_ARGS_END
if /I "%~1"=="-h" (call :PRINT_USAGE & endlocal & exit /b 0)
if /I "%~1"=="--help" (call :PRINT_USAGE & endlocal & exit /b 0)
if /I "%~1"=="-v" (call :PRINT_VERSION & endlocal & exit /b 0)
if /I "%~1"=="--version" (call :PRINT_VERSION & endlocal & exit /b 0)
if /I "%~1"=="-l" (set "CB_CONTAINER_LIST=true" & shift & goto PARSE_ARGS)
if /I "%~1"=="--list" (set "CB_CONTAINER_LIST=true" & shift & goto PARSE_ARGS)
if /I "%~1"=="-a" (set "CB_CONTAINER_ALL=true" & shift & goto PARSE_ARGS)
if /I "%~1"=="--all" (set "CB_CONTAINER_ALL=true" & shift & goto PARSE_ARGS)
if /I "%~1"=="--verbose" (set "CB_CONTAINER_VERBOSE=true" & shift & goto PARSE_ARGS)
if /I "%~1"=="-i" goto PARSE_ID_ARG
if /I "%~1"=="--it" goto PARSE_ID_ARG
goto SKIP_PARSE_ID
:PARSE_ID_ARG
	set "argNext=%~2"
	if not defined argNext (
		set "CB_CONTAINER_ID=auto" & shift & goto PARSE_ARGS
	)
	set "argNextFirst=!argNext:~0,1!"
	if "!argNextFirst!"=="-" (
		set "CB_CONTAINER_ID=auto" & shift & goto PARSE_ARGS
	)
	set "CB_CONTAINER_ID=%~2" & shift & shift & goto PARSE_ARGS
:SKIP_PARSE_ID
if /I "%~1"=="-s" (set "CB_CONTAINER_SHELL=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--shell" (set "CB_CONTAINER_SHELL=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="-e" (set "CB_CONTAINER_ENTRYPOINT=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--entrypoint" (set "CB_CONTAINER_ENTRYPOINT=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="-p" (call :PARSE_PORT "%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--port" (call :PARSE_PORT "%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--env" (set "CB_CONTAINER_ENV=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--start" (set "CB_CONTAINER_START_IMAGE=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--stop" (set "CB_CONTAINER_STOP_TARGET=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--scan" (set "CB_CONTAINER_SCAN_TARGET=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--clean" (set "CB_CONTAINER_CLEAN=true" & shift & goto PARSE_ARGS)
if /I "%~1"=="--delete" (set "CB_CONTAINER_DELETE_TARGET=%~2" & shift & shift & goto PARSE_ARGS)
if /I "%~1"=="--log" (shift & goto PARSE_LOG_TARGET)
if /I "%~1"=="-t" (set "CB_CONTAINER_TAIL=true" & shift & goto PARSE_ARGS)
if /I "%~1"=="--tail" (set "CB_CONTAINER_TAIL=true" & shift & goto PARSE_ARGS)
:: check if parameter starts with - (unknown option)
set "argCheck=%~1"
if "!argCheck:~0,1!"=="-" (
	echo Invalid parameter: %~1
	echo\
	call :PRINT_USAGE
	endlocal & exit /b 1
)
:: positional argument: image name
set "CB_CONTAINER_START_IMAGE=%~1"
shift
goto PARSE_ARGS
:PARSE_LOG_TARGET
rem determine if next arg is a range or a target
if "%~1"=="" (set "CB_CONTAINER_LOG_TARGET=auto" & goto PARSE_ARGS_END)
set "logArgCheck=%~1"
rem check if value is a pure range (only digits and dash): strip all digits and dashes
set "logArgStripped=!logArgCheck:0=!"
set "logArgStripped=!logArgStripped:1=!"
set "logArgStripped=!logArgStripped:2=!"
set "logArgStripped=!logArgStripped:3=!"
set "logArgStripped=!logArgStripped:4=!"
set "logArgStripped=!logArgStripped:5=!"
set "logArgStripped=!logArgStripped:6=!"
set "logArgStripped=!logArgStripped:7=!"
set "logArgStripped=!logArgStripped:8=!"
set "logArgStripped=!logArgStripped:9=!"
set "logArgStripped=!logArgStripped:-=!"
if "!logArgStripped!"=="" if not "!logArgCheck!"=="-" (
	set "CB_CONTAINER_LOG_TARGET=auto"
	set "CB_CONTAINER_LOG_LINES=!logArgCheck!"
	shift
	goto PARSE_ARGS
)
set "logArgFirst=!logArgCheck:~0,1!"
if "!logArgFirst!"=="-" (
	set "CB_CONTAINER_LOG_TARGET=auto"
	goto PARSE_ARGS
)
set "CB_CONTAINER_LOG_TARGET=%~1"
shift
:PARSE_LOG_LINES
rem check if next arg is a pure range (only digits and dash)
if "%~1"=="" goto PARSE_ARGS_END
set "logLineCheck=%~1"
set "logLineStripped=!logLineCheck:0=!"
set "logLineStripped=!logLineStripped:1=!"
set "logLineStripped=!logLineStripped:2=!"
set "logLineStripped=!logLineStripped:3=!"
set "logLineStripped=!logLineStripped:4=!"
set "logLineStripped=!logLineStripped:5=!"
set "logLineStripped=!logLineStripped:6=!"
set "logLineStripped=!logLineStripped:7=!"
set "logLineStripped=!logLineStripped:8=!"
set "logLineStripped=!logLineStripped:9=!"
set "logLineStripped=!logLineStripped:-=!"
if "!logLineStripped!"=="" if not "!logLineCheck!"=="-" (
	set "CB_CONTAINER_LOG_LINES=!logLineCheck!"
	shift
)
goto PARSE_ARGS
:PARSE_ARGS_END

:: detect container runtime: try nerdctl first, fall back to docker
set "CB_CONTAINER_RUNTIME="
where nerdctl >nul 2>nul && nerdctl info >nul 2>nul && set "CB_CONTAINER_RUNTIME=nerdctl"
if not defined CB_CONTAINER_RUNTIME where docker >nul 2>nul && docker info >nul 2>nul && set "CB_CONTAINER_RUNTIME=docker"
if not defined CB_CONTAINER_RUNTIME (
	echo %CB_LINE%
	echo %CB_LINEHEADER%Neither nerdctl nor docker found in PATH.
	echo %CB_LINE%
	endlocal & exit /b 1
)

:: ensure temp directory is available

:: clean cache (can be combined with other actions)
if /I not "!CB_CONTAINER_CLEAN!"=="true" goto SKIP_CLEAN
rem check if clean is the only action - if so force verbose and exit after
set "hasOtherAction=false"
if defined CB_CONTAINER_DELETE_TARGET set "hasOtherAction=true"
if /I "!CB_CONTAINER_LIST!"=="true" set "hasOtherAction=true"
if defined CB_CONTAINER_ID set "hasOtherAction=true"
if defined CB_CONTAINER_LOG_TARGET set "hasOtherAction=true"
if defined CB_CONTAINER_STOP_TARGET set "hasOtherAction=true"
if defined CB_CONTAINER_START_IMAGE set "hasOtherAction=true"
if defined CB_CONTAINER_SCAN_TARGET set "hasOtherAction=true"
if /I "!hasOtherAction!"=="false" set "CB_CONTAINER_VERBOSE=true"
if not exist "!CB_CONTAINER_TEMP!" goto SKIP_CLEAN_EMPTY
set /a cleanCount=0
for /f %%f in ('dir /b /a-d "!CB_CONTAINER_TEMP!" 2^>nul') do set /a cleanCount+=1
rd /s /q "!CB_CONTAINER_TEMP!" 2>nul
mkdir "!CB_CONTAINER_TEMP!" >nul 2>nul
if /I "!CB_CONTAINER_VERBOSE!"=="true" echo %CB_LINEHEADER%Cache cleaned ^(!cleanCount! file^(s^) removed^).
goto SKIP_CLEAN_PRUNE
:SKIP_CLEAN_EMPTY
if /I "!CB_CONTAINER_VERBOSE!"=="true" echo %CB_LINEHEADER%No cache to clean.
:SKIP_CLEAN_PRUNE
rem prune dangling images
set "CB_PRUNE_TMPFILE=!CB_CONTAINER_TEMP!\cb-prune-%RANDOM%%RANDOM%.tmp"
!CB_CONTAINER_RUNTIME! image prune -f >"!CB_PRUNE_TMPFILE!" 2>nul
if /I "!CB_CONTAINER_VERBOSE!"=="true" (
	set "reclaimedLine="
	for /f "usebackq tokens=*" %%a in ("!CB_PRUNE_TMPFILE!") do set "reclaimedLine=%%a"
	if defined reclaimedLine (
		echo %CB_LINEHEADER%!reclaimedLine!
	) else (
		echo %CB_LINEHEADER%Dangling images pruned.
	)
)
del /f /q "!CB_PRUNE_TMPFILE!" 2>nul
if /I "!hasOtherAction!"=="false" (endlocal & exit /b 0)
:SKIP_CLEAN

:: delete image
if not defined CB_CONTAINER_DELETE_TARGET goto SKIP_DELETE
call :DELETE_IMAGE
endlocal & exit /b %ERRORLEVEL%
:SKIP_DELETE

:: list mode
if /I not "%CB_CONTAINER_LIST%"=="true" goto SKIP_LIST
call :LIST_IMAGES
endlocal & exit /b 0
:SKIP_LIST

:: connect to running container (standalone --id with a container id)
if not defined CB_CONTAINER_ID goto SKIP_CONNECT
if /I "!CB_CONTAINER_ID!"=="auto" goto SKIP_CONNECT
call :CONNECT_TO_CONTAINER
endlocal & exit /b %ERRORLEVEL%
:SKIP_CONNECT

:: scan image with trivy
if not defined CB_CONTAINER_SCAN_TARGET goto SKIP_SCAN
call :SCAN_CONTAINER
endlocal & exit /b %ERRORLEVEL%
:SKIP_SCAN

:: show/tail logs (standalone, not combined with --start)
if not defined CB_CONTAINER_LOG_TARGET goto SKIP_LOG
if /I "!CB_CONTAINER_LOG_TARGET!"=="auto" goto SKIP_LOG
call :SHOW_LOGS
endlocal & exit /b %ERRORLEVEL%
:SKIP_LOG

:: stop a container
if not defined CB_CONTAINER_STOP_TARGET goto SKIP_STOP
call :STOP_CONTAINER
endlocal & exit /b %ERRORLEVEL%
:SKIP_STOP

:: build env args
set "ENV_ARGS="
if defined CB_CONTAINER_ENV call :BUILD_ENV_ARGS

:: start a container from an existing image -resolve tag if not specified
if not defined CB_CONTAINER_START_IMAGE goto SKIP_START
call :RESOLVE_IMAGE
if not defined CB_CONTAINER_RESOLVED_IMAGE (
	set "pullImage=!CB_CONTAINER_START_IMAGE!"
	set "pullCheckColon=!pullImage::=!"
	if "!pullCheckColon!"=="!pullImage!" set "pullImage=!pullImage!:latest"
	echo %CB_LINEHEADER%Image '!CB_CONTAINER_START_IMAGE!' not found locally, pulling !pullImage!...
	!CB_CONTAINER_RUNTIME! pull !pullImage! >nul 2>nul
	if not errorlevel 1 set "CB_CONTAINER_RESOLVED_IMAGE=!pullImage!"
)
if not defined CB_CONTAINER_RESOLVED_IMAGE (
	echo %CB_LINEHEADER%Image '!CB_CONTAINER_START_IMAGE!' not found.
	endlocal & exit /b 1
)
set "CB_CONTAINER_START_IMAGE=!CB_CONTAINER_RESOLVED_IMAGE!"
if /I "%CB_CONTAINER_VERBOSE%"=="true" echo %CB_LINEHEADER%Resolved image: !CB_CONTAINER_START_IMAGE!
set "STARTED_CID="
call :START_CONTAINER
if errorlevel 1 (endlocal & exit /b 1)
if not defined STARTED_CID goto SKIP_START_POST
:: if --id was specified, attach to the started container
if /I not "!CB_CONTAINER_ID!"=="auto" goto SKIP_START_ATTACH
set "CB_CONTAINER_ID=!STARTED_CID!"
call :CONNECT_TO_CONTAINER
endlocal & exit /b %ERRORLEVEL%
:SKIP_START_ATTACH
:: if --log or -t/--tail was specified, show/tail logs
if /I "!CB_CONTAINER_LOG_TARGET!"=="auto" goto START_SHOW_LOGS
if /I "!CB_CONTAINER_TAIL!"=="true" goto START_SHOW_LOGS
goto SKIP_START_LOGS
:START_SHOW_LOGS
set "CB_CONTAINER_LOG_TARGET=!CB_CONTAINER_START_IMAGE!"
call :SHOW_LOGS
endlocal & exit /b %ERRORLEVEL%
:SKIP_START_LOGS
:SKIP_START_POST
endlocal & exit /b 0
:SKIP_START

:: auto-detect Dockerfile in current directory
if exist "Dockerfile" (call :BUILD_AND_RUN "Dockerfile" & endlocal & exit /b !ERRORLEVEL!)
if exist "dockerfile" (call :BUILD_AND_RUN "dockerfile" & endlocal & exit /b !ERRORLEVEL!)
if exist "Containerfile" (call :BUILD_AND_RUN "Containerfile" & endlocal & exit /b !ERRORLEVEL!)

:: no specific action - show the image list as default
call :LIST_IMAGES
endlocal & exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRINT_USAGE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - container manager v%CB_CONTAINER_VERSION%
echo usage: %PN% [OPTION] [image]
echo\
echo Overview of the available OPTIONs:
echo  -h, --help                  Show this help message.
echo  -v, --version               Print the version information.
echo  -l, --list                  List images with running containers.
echo  -a, --all                   Show all images (default: running only).
echo      --verbose               Verbose output.
echo  -i, --it [name^|id]          Connect to a running container. If not running,
echo                              starts it interactively. Supports distro aliases.
echo  -s, --shell ^<shell^>         Shell to use when connecting (default: /bin/sh).
echo  -e, --entrypoint ^<entry^>    Override entrypoint when starting a container.
echo  -p, --port ^<port^>           Publish port. Single port maps to same host port
echo                              (e.g. -p 8080 -^> 8080:8080). With colon, taken as-is
echo                              (e.g. -p 8081:8082). Multiple ports: -p 8080 -p 9090.
echo      --env ^<vars^>            Set environment variables (comma-separated).
echo                              Example: --env MY_VAR="val1",OTHER="val2"
echo      --start ^<name^|id^>       Start a container detached by name or id, e.g.
echo                              --start my-app or --start my-app:1.0.0.
echo      --stop ^<name^|id^>        Stop a running container by name, image name, or id.
echo      --log ^<name^|id^> [n]     Show logs of a container. Optionally limit output:
echo                              10 = first 10 lines, 5-10 = lines 5 to 10,
echo                              5- = from line 5 to end.
echo  -t, --tail                  Tail (follow) mode, used with -l/--log.
echo      --scan ^<name^|id^>        Scan an image with trivy. Comma-separated for multiple.
echo      --clean                 Clean the scan cache and dangling images.
echo      --delete ^<name^|id^>      Delete an image by name or id.
echo\
echo The [image] can be given as a name without tag. The script resolves
echo the best match: prefers :latest, otherwise the newest available tag.
echo\
echo When called without arguments in a directory containing a Dockerfile,
echo the script builds and starts the container from that Dockerfile.
echo\
echo Special files:
echo  .cb-container               First line is read as default parameters, e.g.
echo                              --env KEY="val" -p 8080
echo\
echo Examples:
echo   Build and run from current directory:
echo   %PN%
echo\
echo   Start my-app (:latest or newest tag):
echo   %PN% my-app
echo\
echo   List all images and running containers:
echo   %PN% --list
echo\
echo   Connect to container (starts interactively if not running):
echo   %PN% -i ubuntu
echo   %PN% -i my-app
echo   %PN% -i abc123
echo   %PN% -i kali -s /bin/bash
echo\
echo   Start container:
echo   %PN% --start my-app
echo   %PN% --start my-app:1.0.0
echo   %PN% --start my-app -i
echo   %PN% --start my-app -t
echo   %PN% --start my-app -l 5
echo\
echo   Stop container:
echo   %PN% --stop my-app
echo   %PN% --stop abc123
echo\
echo   Show logs:
echo   %PN% -l my-app
echo   %PN% -l my-app 10
echo   %PN% -l my-app 5-10
echo   %PN% -l my-app 5-
echo   %PN% -l my-app -t
echo   %PN% -l my-app 10- -t
echo\
echo   Scan image with trivy:
echo   %PN% --scan my-app
echo\
echo   Override entrypoint, port, env:
echo   %PN% -e /bin/bash
echo   %PN% -p 8080
echo   %PN% -p 8081:8082
echo   %PN% --env KEY="val",K2="v2"
echo\
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRINT_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINE%
echo toolarium cb-container %CB_CONTAINER_VERSION%
echo %CB_LINE%
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -normalize a single port value and append to CB_CONTAINER_PORT_ARGS
rem "8080"      -> -p 8080:8080
rem "8081:8082" -> -p 8081:8082
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PARSE_PORT
set "portVal=%~1"
echo %portVal% | findstr /C:":" >nul 2>nul
if errorlevel 1 (
	set "CB_CONTAINER_PORT_ARGS=!CB_CONTAINER_PORT_ARGS! -p %portVal%:%portVal%"
) else (
	set "CB_CONTAINER_PORT_ARGS=!CB_CONTAINER_PORT_ARGS! -p %portVal%"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -parse comma-separated env vars into -e flags
rem Input:  CB_CONTAINER_ENV = "KEY1=val1,KEY2=val2"
rem Result: ENV_ARGS = -e KEY1=val1 -e KEY2=val2
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:BUILD_ENV_ARGS
set "ENV_ARGS="
set "envInput=!CB_CONTAINER_ENV!"
:BUILD_ENV_LOOP
if not defined envInput goto :eof
rem split on first comma
for /f "tokens=1,* delims=," %%a in ("!envInput!") do (
	set "entry=%%a"
	set "envInput=%%b"
)
rem trim whitespace
call :TRIM entry
if defined entry set "ENV_ARGS=!ENV_ARGS! -e !entry!"
if defined envInput goto BUILD_ENV_LOOP
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -list all images with their running containers
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:LIST_IMAGES
if /I "%CB_CONTAINER_VERBOSE%"=="true" echo %CB_LINEHEADER%Images and running containers [%CB_CONTAINER_RUNTIME%]

rem collect data into temp files to avoid Go template syntax in for/f
set "CB_CONTAINER_TMPFILE=!CB_CONTAINER_TEMP!\cb-container-%RANDOM%%RANDOM%.tmp"
set "CB_IMAGES_TMPFILE=!CB_CONTAINER_TEMP!\cb-images-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps --format "!CB_FMT_PS!" >"!CB_CONTAINER_TMPFILE!" 2>nul
set "CB_IMAGES_UNSORTED=!CB_CONTAINER_TEMP!\cb-images-unsorted-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% images --format "!CB_FMT_IMG!" >"!CB_IMAGES_UNSORTED!" 2>nul
powershell -NoProfile -Command "Get-Content '!CB_IMAGES_UNSORTED!' | Sort-Object { ($_ -split '\|')[1] + ':' + ($_ -split '\|')[2] }" > "!CB_IMAGES_TMPFILE!"
del /f /q "!CB_IMAGES_UNSORTED!" 2>nul

rem count images
set /a imgCount=0
for /f "usebackq tokens=*" %%a in ("!CB_IMAGES_TMPFILE!") do set /a imgCount+=1

rem print header with count right-aligned
echo %CB_LINE%
set "headerLeft=IMAGE ID      CONTAINER ID  CREATED           STARTED           SIZE     TAG"
rem build timestamp via wmic for locale-independent format
for /f "tokens=*" %%t in ('powershell -NoProfile -Command "Get-Date -Format \"yyyy-MM-dd HH:mm:ss\"" 2^>nul') do set "cbNow=%%t"
if not defined cbNow set "cbNow=%DATE% %TIME:~0,8%"
set "headerRight=!cbNow! - !imgCount! image(s)"
rem pad to CB_LINE length (120 chars)
set "headerPad=                                                                                                                        "
set "headerFull=!headerLeft!!headerPad!"
set "headerFull=!headerFull:~0,120!"
rem calculate right-align position
call :STRLEN headerRight headerRightLen
set /a headerTrim=120 - !headerRightLen!
call set "headerFull=%%headerFull:~0,!headerTrim!%%"
set "headerFull=!headerFull!!headerRight!"
echo !headerFull!
echo %CB_LINE%

if !imgCount! EQU 0 (
	echo %CB_LINEHEADER%No images found.
	del /f /q "!CB_CONTAINER_TMPFILE!" 2>nul
	del /f /q "!CB_IMAGES_TMPFILE!" 2>nul
	goto :eof
)

rem iterate over all images
for /f "usebackq tokens=1,2,3,4,5 delims=|" %%a in ("!CB_IMAGES_TMPFILE!") do (
	set "imageId=%%a"
	set "repo=%%b"
	set "tag=%%c"
	set "imgSize=%%d"
	set "imgCreated=%%e"

	if "!repo!"=="^<none^>" (
		set "repoTag=^<none^>"
	) else (
		set "repoTag=!repo!:!tag!"
	)

	set "shortId=!imageId:~0,12!"

	rem look for matching containers
	set "foundContainer=false"
	set "firstMatch=true"
	for /f "usebackq tokens=1,2,3 delims=|" %%x in ("!CB_CONTAINER_TMPFILE!") do (
		set "cid=%%x"
		set "cimage=%%y"
		set "cstatus=%%z"
		if "!cimage!"=="!repoTag!" (
			call :PRINT_IMAGE_LINE "!shortId!" "!cid!" "!imgCreated!" "!cstatus!" "!imgSize!" "!repoTag!" "!firstMatch!"
			set "foundContainer=true"
			set "firstMatch=false"
		) else if "!cimage!"=="!repo!" (
			call :PRINT_IMAGE_LINE "!shortId!" "!cid!" "!imgCreated!" "!cstatus!" "!imgSize!" "!repoTag!" "!firstMatch!"
			set "foundContainer=true"
			set "firstMatch=false"
		) else if "!cimage!"=="!imageId!" (
			call :PRINT_IMAGE_LINE "!shortId!" "!cid!" "!imgCreated!" "!cstatus!" "!imgSize!" "!repoTag!" "!firstMatch!"
			set "foundContainer=true"
			set "firstMatch=false"
		)
	)

	if "!foundContainer!"=="false" if /I "!CB_CONTAINER_ALL!"=="true" (
		call :PRINT_IMAGE_LINE "!shortId!" "-" "!imgCreated!" "-" "!imgSize!" "!repoTag!" "true"
	)
)

rem verbose summary
if /I "!CB_CONTAINER_VERBOSE!"=="true" (
	set /a runCount=0
	set "CB_RUN_TMPFILE=!CB_CONTAINER_TEMP!\cb-run-count-%RANDOM%%RANDOM%.tmp"
	!CB_CONTAINER_RUNTIME! ps -q >"!CB_RUN_TMPFILE!" 2>nul
	for /f "usebackq tokens=*" %%a in ("!CB_RUN_TMPFILE!") do set /a runCount+=1
	del /f /q "!CB_RUN_TMPFILE!" 2>nul
	echo %CB_LINE%
	echo %CB_LINEHEADER%!imgCount! image^(s^), !runCount! running.
)
del /f /q "!CB_CONTAINER_TMPFILE!" 2>nul
del /f /q "!CB_IMAGES_TMPFILE!" 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -print a formatted image/container line
rem %~1=shortId %~2=containerId %~3=created %~4=started %~5=size %~6=repoTag %~7=firstMatch
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRINT_IMAGE_LINE
set "isFirst=%~7"
if /I "!isFirst!"=="false" (
	set "col1=              "
	set "col2=              "
	set "col3=                  "
	set "col4=                  "
	set "col5=         "
) else (
	set "col1=%~1              "
	set "col1=!col1:~0,14!"
	set "col2=%~2              "
	set "col2=!col2:~0,14!"
	rem truncate created timestamp to YYYY-MM-DD HH:MM
	set "col3=%~3"
	if not "!col3!"=="-" set "col3=!col3:~0,16!"
	set "col3=!col3!                  "
	set "col3=!col3:~0,18!"
	rem truncate started timestamp to YYYY-MM-DD HH:MM
	set "col4=%~4"
	if not "!col4!"=="-" set "col4=!col4:~0,16!"
	set "col4=!col4!                  "
	set "col4=!col4:~0,18!"
	set "col5=%~5         "
	set "col5=!col5:~0,9!"
)
echo !col1!!col2!!col3!!col4!!col5!%~6
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -get string length
rem %~1 = variable name, %~2 = output variable for length
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:STRLEN
set "strlenVal=!%~1!"
set /a %~2=0
:STRLEN_LOOP
if "!strlenVal!"=="" goto :eof
set "strlenVal=!strlenVal:~1!"
set /a %~2+=1
goto STRLEN_LOOP


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -exec into a running container
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CONNECT_TO_CONTAINER
rem verify container is running - try direct ID first
set "containerRunning="
set "CB_FIND_TMPFILE=!CB_CONTAINER_TEMP!\cb-find-%RANDOM%%RANDOM%.tmp"
!CB_CONTAINER_RUNTIME! ps -q --filter "id=!CB_CONTAINER_ID!" >"!CB_FIND_TMPFILE!" 2>nul
for /f "usebackq tokens=*" %%a in ("!CB_FIND_TMPFILE!") do set "containerRunning=%%a"
del /f /q "!CB_FIND_TMPFILE!" 2>nul
if defined containerRunning goto CONNECT_EXEC
rem try resolving by name or image ID
set "findInput=!CB_CONTAINER_ID!"
call :FIND_RUNNING_CONTAINER
if defined FOUND_CID (
	set "CB_CONTAINER_ID=!FOUND_CID!"
	set "containerRunning=!FOUND_CID!"
	set "shortFoundId=!FOUND_CID:~0,12!"
	if defined FOUND_IMAGE echo %CB_LINEHEADER%Resolved '!findInput!' to container !shortFoundId! ^(!FOUND_IMAGE!^).
	goto CONNECT_EXEC
)
rem try to resolve as image and run interactively
rem map distro aliases
set "connectInput=!CB_CONTAINER_ID!"
if /I "!connectInput!"=="arch" set "connectInput=archlinux"
if /I "!connectInput!"=="debian" set "connectInput=library/debian"
if /I "!connectInput!"=="kali" set "connectInput=kalilinux/kali-rolling"
set "CB_CONTAINER_START_IMAGE=!connectInput!"
call :RESOLVE_IMAGE
if not defined CB_CONTAINER_RESOLVED_IMAGE (
	set "pullImage=!connectInput!"
	set "pullCheckColon=!pullImage::=!"
	if "!pullCheckColon!"=="!pullImage!" set "pullImage=!pullImage!:latest"
	echo %CB_LINEHEADER%Image '!CB_CONTAINER_ID!' not found locally, pulling !pullImage!...
	!CB_CONTAINER_RUNTIME! pull !pullImage! >nul 2>nul
	if not errorlevel 1 set "CB_CONTAINER_RESOLVED_IMAGE=!pullImage!"
)
if not defined CB_CONTAINER_RESOLVED_IMAGE (
	echo %CB_LINEHEADER%Container or image '!CB_CONTAINER_ID!' not found.
	exit /b 1
)
set "CB_CONTAINER_RUN_IMAGE=!CB_CONTAINER_RESOLVED_IMAGE!"
call :RUN_CONTAINER
exit /b !ERRORLEVEL!
:CONNECT_EXEC
echo %CB_LINEHEADER%Connecting to container !CB_CONTAINER_ID! with !CB_CONTAINER_SHELL!...
!CB_CONTAINER_RUNTIME! exec -it !CB_CONTAINER_ID! !CB_CONTAINER_SHELL!
exit /b !ERRORLEVEL!


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -build image from Dockerfile and run it
rem %~1 = dockerfile
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:BUILD_AND_RUN
set "dockerfile=%~1"

rem derive project name from current directory
set "projectName="
for %%i in ("%CD%") do set "projectName=%%~ni"
rem lowercase the project name
for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "projectName=!projectName:%%a=%%a!"

echo %CB_LINEHEADER%Building container image '%projectName%' from %dockerfile%...
%CB_CONTAINER_RUNTIME% build -t %projectName% -f "%dockerfile%" .
if errorlevel 1 exit /b 1

set "runArgs=-it --name %projectName% --rm%CB_CONTAINER_PORT_ARGS%%ENV_ARGS%"
if defined CB_CONTAINER_ENTRYPOINT (
	set "runArgs=!runArgs! --entrypoint %CB_CONTAINER_ENTRYPOINT%"
	echo %CB_LINEHEADER%Starting container '%projectName%' with entrypoint '%CB_CONTAINER_ENTRYPOINT%'...
) else (
	echo %CB_LINEHEADER%Starting container '%projectName%'...
)
%CB_CONTAINER_RUNTIME% run !runArgs! %projectName%
exit /b %ERRORLEVEL%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -resolve image name to best matching tag
rem Input:  CB_CONTAINER_START_IMAGE (may lack a tag)
rem Output: CB_CONTAINER_RESOLVED_IMAGE (with tag, or empty if not found)
rem Priority: :latest first, then newest available tag
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RESOLVE_IMAGE
set "CB_CONTAINER_RESOLVED_IMAGE="
set "resolveInput=!CB_CONTAINER_START_IMAGE!"

rem if input already contains a colon (has tag), return as-is
set "resolveCheck=!resolveInput::=!"
if not "!resolveCheck!"=="!resolveInput!" (
	set "CB_CONTAINER_RESOLVED_IMAGE=!resolveInput!"
	goto :eof
)

rem write image list to temp file to avoid Go template in for/f
set "CB_RESOLVE_TMPFILE=!CB_CONTAINER_TEMP!\cb-resolve-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% images --format "!CB_FMT_REPO_TAG!" >"!CB_RESOLVE_TMPFILE!" 2>nul

rem check for :latest first
set "CB_RESOLVE_MATCH_TMPFILE=!CB_CONTAINER_TEMP!\cb-resolve-match-%RANDOM%%RANDOM%.tmp"
findstr /B /C:"!resolveInput!:latest" "!CB_RESOLVE_TMPFILE!" >"!CB_RESOLVE_MATCH_TMPFILE!" 2>nul
for /f "usebackq tokens=*" %%a in ("!CB_RESOLVE_MATCH_TMPFILE!") do (
	if not defined CB_CONTAINER_RESOLVED_IMAGE set "CB_CONTAINER_RESOLVED_IMAGE=%%a"
)
del /f /q "!CB_RESOLVE_MATCH_TMPFILE!" 2>nul
if defined CB_CONTAINER_RESOLVED_IMAGE (del /f /q "!CB_RESOLVE_TMPFILE!" 2>nul & goto :eof)

rem fall back to first matching tag (newest image)
findstr /B /C:"!resolveInput!:" "!CB_RESOLVE_TMPFILE!" >"!CB_RESOLVE_MATCH_TMPFILE!" 2>nul
for /f "usebackq tokens=*" %%a in ("!CB_RESOLVE_MATCH_TMPFILE!") do (
	if not defined CB_CONTAINER_RESOLVED_IMAGE set "CB_CONTAINER_RESOLVED_IMAGE=%%a"
)
del /f /q "!CB_RESOLVE_MATCH_TMPFILE!" 2>nul
del /f /q "!CB_RESOLVE_TMPFILE!" 2>nul
if defined CB_CONTAINER_RESOLVED_IMAGE goto :eof

rem try as image ID (full or short) -input must be a prefix of the ID
call :STRLEN resolveInput resolveInputLen
rem image IDs from docker/nerdctl are typically 12 chars; input must not be longer
set "CB_RESOLVE_ID_TMPFILE=!CB_CONTAINER_TEMP!\cb-resolve-id-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% images --format "!CB_FMT_ID_REPO_TAG!" >"!CB_RESOLVE_ID_TMPFILE!" 2>nul
for /f "usebackq tokens=1,2 delims=|" %%a in ("!CB_RESOLVE_ID_TMPFILE!") do (
	if not defined CB_CONTAINER_RESOLVED_IMAGE (
		set "imgIdPrefix=%%a"
		set "imgIdPrefix=!imgIdPrefix:~0,%resolveInputLen%!"
		if "!imgIdPrefix!"=="!resolveInput!" (
			if not "%%b"=="^<none^>:^<none^>" (
				set "CB_CONTAINER_RESOLVED_IMAGE=%%b"
			) else (
				set "CB_CONTAINER_RESOLVED_IMAGE=!resolveInput!"
			)
		)
	)
)
del /f /q "!CB_RESOLVE_ID_TMPFILE!" 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -start a container from an existing image
rem Checks if a container from that image is already running.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RUN_CONTAINER
rem check if already running - connect to it
set "existingCid="
set "CB_PS_TMPFILE=!CB_CONTAINER_TEMP!\cb-ps-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps --format "!CB_FMT_ID_IMG!" >"!CB_PS_TMPFILE!" 2>nul
for /f "usebackq tokens=1,2 delims=|" %%a in ("!CB_PS_TMPFILE!") do (
	if "%%b"=="!CB_CONTAINER_RUN_IMAGE!" if not defined existingCid set "existingCid=%%a"
)
del /f /q "!CB_PS_TMPFILE!" 2>nul
if not defined existingCid goto RUN_NEW_CONTAINER
echo %CB_LINEHEADER%Container from '!CB_CONTAINER_RUN_IMAGE!' is already running ^(id: !existingCid!^).
echo %CB_LINEHEADER%Connecting...
!CB_CONTAINER_RUNTIME! exec -it !existingCid! !CB_CONTAINER_SHELL!
exit /b !ERRORLEVEL!
:RUN_NEW_CONTAINER
rem remove any stopped container with the same name
set "containerName=!CB_CONTAINER_RUN_IMAGE!"
set "containerName=!containerName:/=-!"
set "containerName=!containerName::=-!"
set "containerName=!containerName:@=-!"
!CB_CONTAINER_RUNTIME! rm -f !containerName! >nul 2>nul
set "runArgs=-it --name !containerName! --rm%CB_CONTAINER_PORT_ARGS%%ENV_ARGS%"
if defined CB_CONTAINER_ENTRYPOINT (
	set "runArgs=!runArgs! --entrypoint !CB_CONTAINER_ENTRYPOINT!"
	echo %CB_LINEHEADER%Running container from '!CB_CONTAINER_RUN_IMAGE!' with entrypoint '!CB_CONTAINER_ENTRYPOINT!'...
) else (
	echo %CB_LINEHEADER%Running container from '!CB_CONTAINER_RUN_IMAGE!'...
)
!CB_CONTAINER_RUNTIME! run !runArgs! !CB_CONTAINER_RUN_IMAGE! !CB_CONTAINER_SHELL!
exit /b !ERRORLEVEL!


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: start a container from an existing image
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:START_CONTAINER
rem check if a container from this image is already running
set "existingCid="
set "CB_PS_TMPFILE=!CB_CONTAINER_TEMP!\cb-ps-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps --format "!CB_FMT_ID_IMG!" >"!CB_PS_TMPFILE!" 2>nul
for /f "usebackq tokens=1,2 delims=|" %%a in ("!CB_PS_TMPFILE!") do (
	if "%%b"=="!CB_CONTAINER_START_IMAGE!" if not defined existingCid set "existingCid=%%a"
)
del /f /q "!CB_PS_TMPFILE!" 2>nul
if not defined existingCid goto START_NEW_CONTAINER
echo %CB_LINEHEADER%Container from '!CB_CONTAINER_START_IMAGE!' is already running ^(id: !existingCid!^).
set "STARTED_CID=!existingCid!"
exit /b 0
:START_NEW_CONTAINER

rem derive container name from image (replace / : @ with -)
set "containerName=!CB_CONTAINER_START_IMAGE!"
set "containerName=!containerName:/=-!"
set "containerName=!containerName::=-!"
set "containerName=!containerName:@=-!"

rem remove any stopped container with the same name
%CB_CONTAINER_RUNTIME% rm !containerName! >nul 2>nul

set "runArgs=-d --name !containerName!%CB_CONTAINER_PORT_ARGS%%ENV_ARGS%"
if defined CB_CONTAINER_ENTRYPOINT (
	set "runArgs=!runArgs! --entrypoint %CB_CONTAINER_ENTRYPOINT%"
	echo %CB_LINEHEADER%Starting container from '!CB_CONTAINER_START_IMAGE!' with entrypoint '%CB_CONTAINER_ENTRYPOINT%'...
) else (
	echo %CB_LINEHEADER%Starting container from '!CB_CONTAINER_START_IMAGE!'...
)
set "startedCid="
set "CB_START_OUT_TMPFILE=!CB_CONTAINER_TEMP!\cb-start-out-%RANDOM%%RANDOM%.tmp"
set "CB_START_ERR_TMPFILE=!CB_CONTAINER_TEMP!\cb-start-err-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% run !runArgs! !CB_CONTAINER_START_IMAGE! >"!CB_START_OUT_TMPFILE!" 2>"!CB_START_ERR_TMPFILE!"
if errorlevel 1 (
	set "startErr="
	for /f "usebackq tokens=*" %%e in ("!CB_START_ERR_TMPFILE!") do if not defined startErr set "startErr=%%e"
	del /f /q "!CB_START_OUT_TMPFILE!" 2>nul
	del /f /q "!CB_START_ERR_TMPFILE!" 2>nul
	echo %CB_LINEHEADER%Failed to start container from '!CB_CONTAINER_START_IMAGE!'.
	if defined startErr echo %CB_LINEHEADER%!startErr!
	exit /b 1
)
for /f "usebackq tokens=*" %%a in ("!CB_START_OUT_TMPFILE!") do set "startedCid=%%a"
del /f /q "!CB_START_OUT_TMPFILE!" 2>nul
del /f /q "!CB_START_ERR_TMPFILE!" 2>nul
set "shortCid=!startedCid:~0,12!"
echo %CB_LINEHEADER%Container started ^(id: !shortCid!^).
set "STARTED_CID=!startedCid!"
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -resolve input to a running container ID
rem Input:  findInput
rem Output: FOUND_CID, FOUND_IMAGE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:FIND_RUNNING_CONTAINER
set "FOUND_CID="
set "FOUND_IMAGE="


rem try by container id
set "CB_FIND_TMPFILE=!CB_CONTAINER_TEMP!\cb-find-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps -q --filter "id=!findInput!" >"!CB_FIND_TMPFILE!" 2>nul
for /f "usebackq tokens=*" %%a in ("!CB_FIND_TMPFILE!") do set "FOUND_CID=%%a"
del /f /q "!CB_FIND_TMPFILE!" 2>nul
if not defined FOUND_CID goto FIND_BY_NAME
set "CB_FIND_TMPFILE=!CB_CONTAINER_TEMP!\cb-find-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps --format "!CB_FMT_IMAGE!" --filter "id=!findInput!" >"!CB_FIND_TMPFILE!" 2>nul
for /f "usebackq tokens=*" %%a in ("!CB_FIND_TMPFILE!") do if not defined FOUND_IMAGE set "FOUND_IMAGE=%%a"
del /f /q "!CB_FIND_TMPFILE!" 2>nul
goto :eof

:FIND_BY_NAME
rem try by container name
set "CB_FIND_TMPFILE=!CB_CONTAINER_TEMP!\cb-find-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps -q --filter "name=!findInput!" >"!CB_FIND_TMPFILE!" 2>nul
for /f "usebackq tokens=*" %%a in ("!CB_FIND_TMPFILE!") do set "FOUND_CID=%%a"
del /f /q "!CB_FIND_TMPFILE!" 2>nul
if not defined FOUND_CID goto FIND_BY_IMAGE
set "CB_FIND_TMPFILE=!CB_CONTAINER_TEMP!\cb-find-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps --format "!CB_FMT_IMAGE!" --filter "name=!findInput!" >"!CB_FIND_TMPFILE!" 2>nul
for /f "usebackq tokens=*" %%a in ("!CB_FIND_TMPFILE!") do if not defined FOUND_IMAGE set "FOUND_IMAGE=%%a"
del /f /q "!CB_FIND_TMPFILE!" 2>nul
goto :eof

:FIND_BY_IMAGE
rem try by image name or image ID
set "CB_CONTAINER_START_IMAGE=!findInput!"
call :RESOLVE_IMAGE
if not defined CB_CONTAINER_RESOLVED_IMAGE goto :eof
rem first try the resolved image directly
set "CB_FIND_TMPFILE=!CB_CONTAINER_TEMP!\cb-find-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps --format "!CB_FMT_ID_IMG!" >"!CB_FIND_TMPFILE!" 2>nul
for /f "usebackq tokens=1,2 delims=|" %%a in ("!CB_FIND_TMPFILE!") do (
	if "%%b"=="!CB_CONTAINER_RESOLVED_IMAGE!" if not defined FOUND_CID (
		set "FOUND_CID=%%a"
		set "FOUND_IMAGE=!CB_CONTAINER_RESOLVED_IMAGE!"
	)
)
del /f /q "!CB_FIND_TMPFILE!" 2>nul
if defined FOUND_CID goto :eof
rem if not found, get all tags for same image ID and try each
set "findImageId="
set "CB_FIND_TMPFILE=!CB_CONTAINER_TEMP!\cb-find-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% images --format "!CB_FMT_ID_REPO_TAG!" >"!CB_FIND_TMPFILE!" 2>nul
for /f "usebackq tokens=1,2 delims=|" %%a in ("!CB_FIND_TMPFILE!") do (
	if "%%b"=="!CB_CONTAINER_RESOLVED_IMAGE!" if not defined findImageId set "findImageId=%%a"
)
if not defined findImageId (del /f /q "!CB_FIND_TMPFILE!" 2>nul & goto :eof)
rem try each tag of the same image ID against running containers
set "CB_FIND_PS_TMPFILE=!CB_CONTAINER_TEMP!\cb-find-ps-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% ps --format "!CB_FMT_ID_IMG!" >"!CB_FIND_PS_TMPFILE!" 2>nul
for /f "usebackq tokens=1,2 delims=|" %%a in ("!CB_FIND_TMPFILE!") do (
	if "%%a"=="!findImageId!" if not defined FOUND_CID (
		for /f "usebackq tokens=1,2 delims=|" %%x in ("!CB_FIND_PS_TMPFILE!") do (
			if "%%y"=="%%b" if not defined FOUND_CID (
				set "FOUND_CID=%%x"
				set "FOUND_IMAGE=%%b"
			)
		)
	)
)
del /f /q "!CB_FIND_TMPFILE!" 2>nul
del /f /q "!CB_FIND_PS_TMPFILE!" 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -show logs of a running container
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SHOW_LOGS
set "findInput=!CB_CONTAINER_LOG_TARGET!"
call :FIND_RUNNING_CONTAINER
if defined FOUND_CID goto SHOW_LOGS_OK
set "CB_CONTAINER_START_IMAGE=!CB_CONTAINER_LOG_TARGET!"
call :RESOLVE_IMAGE
if defined CB_CONTAINER_RESOLVED_IMAGE (
	echo %CB_LINEHEADER%No running container found for '!CB_CONTAINER_LOG_TARGET!'.
) else (
	echo %CB_LINEHEADER%Image '!CB_CONTAINER_LOG_TARGET!' not found.
)
exit /b 1
:SHOW_LOGS_OK
set "shortLogId=!FOUND_CID:~0,12!"
if /I "!CB_CONTAINER_TAIL!"=="true" (
	if /I "!CB_CONTAINER_VERBOSE!"=="true" (
		if defined FOUND_IMAGE (
			echo %CB_LINEHEADER%Tailing logs from '!FOUND_IMAGE!' ^(id: !shortLogId!^)...
		) else (
			echo %CB_LINEHEADER%Tailing logs from container !shortLogId!...
		)
	)
	%CB_CONTAINER_RUNTIME% logs -f !FOUND_CID!
	exit /b 0
)
if /I "!CB_CONTAINER_VERBOSE!"=="true" (
	if defined FOUND_IMAGE (
		echo %CB_LINEHEADER%Logs from '!FOUND_IMAGE!' ^(id: !shortLogId!^)...
	) else (
		echo %CB_LINEHEADER%Logs from container !shortLogId!...
	)
)
if not defined CB_CONTAINER_LOG_LINES goto SHOW_LOGS_ALL

rem parse range: N, N-M, N-, -M
set "rangeStart="
set "rangeEnd="
set "logRange=!CB_CONTAINER_LOG_LINES!"

rem handle 0 = show nothing
if "!logRange!"=="0" (
	exit /b 0
)

rem check if starts with - (e.g. -7 means 1-7)
if "!logRange:~0,1!"=="-" (
	set "rangeStart=1"
	set "rangeEnd=!logRange:~1!"
	goto SHOW_LOGS_RANGE
)

rem check if contains -
set "logRangeCheck=!logRange:-=!"
if not "!logRangeCheck!"=="!logRange!" (
	for /f "tokens=1,2 delims=-" %%a in ("!logRange!") do (
		set "rangeStart=%%a"
		set "rangeEnd=%%b"
	)
) else (
	set "rangeStart=1"
	set "rangeEnd=!logRange!"
)
if not defined rangeStart set "rangeStart=1"

:SHOW_LOGS_RANGE
rem validate: if rangeEnd is 0 or range is invalid, show nothing
if defined rangeEnd (
	if "!rangeEnd!"=="0" exit /b 0
)

set "CB_LOG_TMPFILE=!CB_CONTAINER_TEMP!\cb-log-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% logs !FOUND_CID! >"!CB_LOG_TMPFILE!" 2>&1
set /a logLineNum=0
for /f "usebackq delims=" %%a in ("!CB_LOG_TMPFILE!") do (
	set /a logLineNum+=1
	if !logLineNum! GEQ !rangeStart! (
		if defined rangeEnd (
			if !logLineNum! LEQ !rangeEnd! echo %%a
		) else (
			echo %%a
		)
	)
)
del /f /q "!CB_LOG_TMPFILE!" 2>nul
exit /b 0
:SHOW_LOGS_ALL
%CB_CONTAINER_RUNTIME% logs !FOUND_CID!
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: delete an image by name or id
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DELETE_IMAGE
rem resolve image
set "CB_CONTAINER_START_IMAGE=!CB_CONTAINER_DELETE_TARGET!"
call :RESOLVE_IMAGE
if not defined CB_CONTAINER_RESOLVED_IMAGE (
	echo %CB_LINEHEADER%Image '!CB_CONTAINER_DELETE_TARGET!' not found.
	exit /b 1
)
rem check if a container is using this image
set "findInput=!CB_CONTAINER_RESOLVED_IMAGE!"
set "deleteRunning="
call :FIND_RUNNING_CONTAINER
if defined FOUND_CID (
	echo %CB_LINEHEADER%Cannot delete '!CB_CONTAINER_RESOLVED_IMAGE!': container !FOUND_CID! is running. Stop it first.
	exit /b 1
)
echo %CB_LINEHEADER%Deleting image '!CB_CONTAINER_RESOLVED_IMAGE!'...
!CB_CONTAINER_RUNTIME! rmi !CB_CONTAINER_RESOLVED_IMAGE! >nul 2>nul
if errorlevel 1 (
	echo %CB_LINEHEADER%Failed to delete image '!CB_CONTAINER_RESOLVED_IMAGE!'.
	exit /b 1
)
echo %CB_LINEHEADER%Image deleted.
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: scan an image with trivy
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SCAN_CONTAINER
rem detect trivy - try cb --setenv if not in PATH
where trivy >nul 2>nul
if errorlevel 1 (
	call cb --setenv >nul 2>nul
	if defined TRIVY_HOME set "PATH=!TRIVY_HOME!;!PATH!"
)
where trivy >nul 2>nul
if errorlevel 1 (
	echo %CB_LINEHEADER%Trivy is not installed. Install with: cb --install trivy
	exit /b 1
)
rem get today and timestamp
for /f "tokens=*" %%t in ('powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd'" 2^>nul') do set "scanToday=%%t"
if not defined scanToday set "scanToday=00000000"
for /f "tokens=*" %%t in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'" 2^>nul') do set "scanNow=%%t"
if not defined scanNow set "scanNow=%DATE% %TIME:~0,8%"
rem scan each comma-separated target first, collect all rows
set "scanAllRows=!CB_CONTAINER_TEMP!\cb-scan-all-%RANDOM%%RANDOM%.tmp"
set "scanVerbosePre=!CB_CONTAINER_TEMP!\cb-scan-vpre-%RANDOM%%RANDOM%.tmp"
set "scanVerbosePost=!CB_CONTAINER_TEMP!\cb-scan-vpost-%RANDOM%%RANDOM%.tmp"
type nul > "!scanAllRows!"
type nul > "!scanVerbosePre!"
type nul > "!scanVerbosePost!"
set "scanTargets=!CB_CONTAINER_SCAN_TARGET!"
:SCAN_LOOP
if not defined scanTargets goto SCAN_SUMMARY
for /f "tokens=1* delims=," %%a in ("!scanTargets!") do (
	set "scanOneTarget=%%a"
	set "scanTargets=%%b"
)
rem trim whitespace
call :TRIM scanOneTarget
if not defined scanOneTarget goto SCAN_LOOP
set "CB_SCAN_CURRENT=!scanOneTarget!"
call :SCAN_SINGLE_IMAGE
goto SCAN_LOOP
:SCAN_SUMMARY
rem print verbose pre-messages
if /I "!CB_CONTAINER_VERBOSE!"=="true" type "!scanVerbosePre!" 2>nul
rem print header with timestamp right-aligned
echo %CB_LINE%
set "scanHeader=CVE ID                 SEV  PACKAGE                        INSTALLED      FIXED          TARGET"
set "scanHeaderPad=!scanHeader!                                                                                                                        "
set "scanHeaderPad=!scanHeaderPad:~0,120!"
call :STRLEN scanNow scanNowLen
set /a scanHeaderTrim=120 - !scanNowLen!
call set "scanHeaderPad=%%scanHeaderPad:~0,!scanHeaderTrim!%%"
echo !scanHeaderPad!!scanNow!
echo %CB_LINE%
rem display all rows
if exist "!scanAllRows!" (
	for /f "usebackq tokens=*" %%a in ("!scanAllRows!") do set "hasRows=1"
)
if defined hasRows (
	type "!scanAllRows!"
) else (
	echo No vulnerabilities found.
)
rem compute combined summary
set /a scanCritical=0
set /a scanHigh=0
set /a scanMedium=0
set /a scanLow=0
for /f "usebackq tokens=2" %%s in ("!scanAllRows!") do (
	if "%%s"=="C" set /a scanCritical+=1
	if "%%s"=="H" set /a scanHigh+=1
	if "%%s"=="M" set /a scanMedium+=1
	if "%%s"=="L" set /a scanLow+=1
)
set /a scanTotal=!scanCritical! + !scanHigh! + !scanMedium! + !scanLow!
echo %CB_LINE%
if !scanTotal! GTR 0 (
	echo Summary: !scanTotal! vulnerabilities ^(CRITICAL: !scanCritical!, HIGH: !scanHigh!, MEDIUM: !scanMedium!, LOW: !scanLow!^)
) else (
	echo Summary: 0 vulnerabilities
)
echo %CB_LINE%
rem print verbose post-messages
if /I "!CB_CONTAINER_VERBOSE!"=="true" type "!scanVerbosePost!" 2>nul
del /f /q "!scanAllRows!" 2>nul
del /f /q "!scanVerbosePre!" 2>nul
del /f /q "!scanVerbosePost!" 2>nul
exit /b 0

:SCAN_SINGLE_IMAGE
rem resolve image
set "CB_CONTAINER_RESOLVED_IMAGE="
set "CB_CONTAINER_START_IMAGE=!CB_SCAN_CURRENT!"
call :RESOLVE_IMAGE
if not defined CB_CONTAINER_RESOLVED_IMAGE (
	set "scanCheckColon=!CB_SCAN_CURRENT::=!"
	if not "!scanCheckColon!"=="!CB_SCAN_CURRENT!" (
		if /I "!CB_CONTAINER_VERBOSE!"=="true" echo %CB_LINEHEADER%Image '!CB_SCAN_CURRENT!' not found locally, pulling... >> "!scanVerbosePre!"
		!CB_CONTAINER_RUNTIME! pull !CB_SCAN_CURRENT! >nul 2>nul
		if not errorlevel 1 set "CB_CONTAINER_RESOLVED_IMAGE=!CB_SCAN_CURRENT!"
	)
)
if not defined CB_CONTAINER_RESOLVED_IMAGE (
	echo %CB_LINEHEADER%Image '!CB_SCAN_CURRENT!' not found.
	goto :eof
)
rem resolve image ID
set "scanImageId="
set "CB_SCAN_TMPFILE=!CB_CONTAINER_TEMP!\cb-scan-id-%RANDOM%%RANDOM%.tmp"
%CB_CONTAINER_RUNTIME% images --format "!CB_FMT_SCAN_ID!" --filter "reference=!CB_CONTAINER_RESOLVED_IMAGE!" >"!CB_SCAN_TMPFILE!" 2>nul
for /f "usebackq tokens=*" %%a in ("!CB_SCAN_TMPFILE!") do if not defined scanImageId set "scanImageId=%%a"
del /f /q "!CB_SCAN_TMPFILE!" 2>nul
if not defined scanImageId set "scanImageId=!CB_CONTAINER_RESOLVED_IMAGE:/=-!"
set "scanImageId=!scanImageId::=-!"
set "scanJson=!CB_CONTAINER_TEMP!\!scanImageId!-!scanToday!-trivy.json"
set "scanRows=!CB_CONTAINER_TEMP!\!scanImageId!-!scanToday!-trivy.rows"
rem use cached result if available from today
if exist "!scanRows!" if exist "!scanJson!" (
	if /I "!CB_CONTAINER_VERBOSE!"=="true" echo %CB_LINEHEADER%Using cached scan from today for '!CB_CONTAINER_RESOLVED_IMAGE!'. >> "!scanVerbosePre!"
	type "!scanRows!" >> "!scanAllRows!"
	goto :eof
)
if /I "!CB_CONTAINER_VERBOSE!"=="true" echo %CB_LINEHEADER%Scanning '!CB_CONTAINER_RESOLVED_IMAGE!' with trivy... >> "!scanVerbosePre!"
trivy image --quiet --format json !CB_CONTAINER_RESOLVED_IMAGE! 2>nul > "!scanJson!"
rem format results sorted by severity using powershell
powershell -NoProfile -Command "function tl($s,$m){if($s.Length -le $m){return $s}; return '..'+$s.Substring($s.Length-$m+2)}; $sc=@{CRITICAL='C';HIGH='H';MEDIUM='M';LOW='L'}; $so=@{CRITICAL=1;HIGH=2;MEDIUM=3;LOW=4}; $d=Get-Content '!scanJson!' -Raw|ConvertFrom-Json; $lines=@(); $idx=0; foreach($r in $d.Results){$t=$r.Target; if($r.Vulnerabilities){foreach($v in $r.Vulnerabilities){$s=$v.Severity; $sv=if($sc.ContainsKey($s)){$sc[$s]}else{'?'}; $p=tl $v.PkgName 28; $iv=tl $v.InstalledVersion 12; $ord=if($so.ContainsKey($s)){$so[$s]}else{5}; $fixes=@(if($v.FixedVersion){($v.FixedVersion -split ', *')}else{'-'}); $fv=tl $fixes[0] 12; $lines+=,[PSCustomObject]@{O=$ord;I=$idx;S=0;L=('{0,-22} {1,-4} {2,-30} {3,-14} {4,-14} {5}' -f $v.VulnerabilityID,$sv,$p,$iv,$fv,$t)}; for($fi=1;$fi -lt $fixes.Count;$fi++){$fv=tl $fixes[$fi] 12; $lines+=,[PSCustomObject]@{O=$ord;I=$idx;S=$fi;L=('{0,-22} {1,-4} {2,-30} {3,-14} {4,-14}' -f '','','','',$fv)}}; $idx++}}}; $lines|Sort-Object O,I,S|ForEach-Object{$_.L}" > "!scanRows!"
type "!scanRows!" >> "!scanAllRows!"
if /I "!CB_CONTAINER_VERBOSE!"=="true" echo %CB_LINEHEADER%Scan result stored in !scanRows! >> "!scanVerbosePost!"
if /I "!CB_CONTAINER_VERBOSE!"=="true" echo %CB_LINEHEADER%Scan json stored in !scanJson! >> "!scanVerbosePost!"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -stop a running container by name, image name, or id
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:STOP_CONTAINER
set "findInput=!CB_CONTAINER_STOP_TARGET!"
call :FIND_RUNNING_CONTAINER
if defined FOUND_CID goto STOP_EXECUTE
set "CB_CONTAINER_START_IMAGE=!CB_CONTAINER_STOP_TARGET!"
call :RESOLVE_IMAGE
if defined CB_CONTAINER_RESOLVED_IMAGE (
	echo %CB_LINEHEADER%No running container found for '!CB_CONTAINER_STOP_TARGET!'.
) else (
	echo %CB_LINEHEADER%Image '!CB_CONTAINER_STOP_TARGET!' not found.
)
exit /b 1
:STOP_EXECUTE
set "shortStopId=!FOUND_CID:~0,12!"
if defined FOUND_IMAGE (
	echo %CB_LINEHEADER%Stopping container from '!FOUND_IMAGE!' ^(id: !shortStopId!^)...
) else (
	echo %CB_LINEHEADER%Stopping container !shortStopId!...
)
%CB_CONTAINER_RUNTIME% stop !FOUND_CID! >nul
if errorlevel 1 (
	echo %CB_LINEHEADER%Failed to stop container !shortStopId!.
	exit /b 1
)
echo %CB_LINEHEADER%Container stopped ^(id: !shortStopId!^).
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_INFO -trim leading and trailing spaces from a variable
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TRIM
for /f "tokens=* delims= " %%x in ("!%~1!") do set "%~1=%%x"
:TRIM_LOOP
if "!%~1:~-1!"==" " set "%~1=!%~1:~0,-1!" & goto TRIM_LOOP
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
