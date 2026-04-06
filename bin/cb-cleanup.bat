@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-cleanup.bat - Cleanup common-build atrefacts.
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
set PN=%~nx0
set "CB_LINEHEADER=.: "

:: defaults
set "DOCKER_IMAGE_CLEAN_UNTIL=24"
set "DOCKER_SYSTEM_CLEAN_UNTIL=72"
set "CLEAN_LOG_UNTIL_DAYS=1"
set "GRADLE_CACHE_LAST_ACCESS_DAYS=30"
set "CGB_NUMBER_OF_RELEASE_TO_KEEP=2"

if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb"

:: flags
set "enableCleanupCommonBuild=0"
set "enableCleanupCommonGradleBuild=0"
set "enableDockerImagePrune=0"
set "enableDockerSystemPrune=0"
set "enableCleanupNpm=0"
set "CB_CLEAN_PATH="
set "CB_CLEAN_PATTERN="
set "CB_SILENT=false"
set "SILENT_FLAG="
set "CB_DRY_RUN=false"
set "DRY_RUN_FLAG="
set "argCount=0"

:CHECK_PARAMETER
if [%1]==[] goto PARAM_DONE
set /a argCount+=1
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.--silent set "CB_SILENT=true" & shift & goto CHECK_PARAMETER
if .%1==.--dry-run set "CB_DRY_RUN=true" & shift & goto CHECK_PARAMETER
if .%1==.--cb set "enableCleanupCommonBuild=1" & shift & goto CHECK_PARAMETER
if .%1==.--cgb set "enableCleanupCommonGradleBuild=1" & shift & goto CHECK_PARAMETER
if .%1==.--docker-image set "enableDockerImagePrune=1" & shift & goto CHECK_PARAMETER
if .%1==.--docker-image-until shift & set "DOCKER_IMAGE_CLEAN_UNTIL=%~2" & shift & goto CHECK_PARAMETER
if .%1==.--docker-system set "enableDockerSystemPrune=1" & shift & goto CHECK_PARAMETER
if .%1==.--docker-system-until shift & set "DOCKER_SYSTEM_CLEAN_UNTIL=%~2" & shift & goto CHECK_PARAMETER
if .%1==.--npm set "enableCleanupNpm=1" & shift & goto CHECK_PARAMETER
if .%1==.--log-until shift & set "CLEAN_LOG_UNTIL_DAYS=%~2" & shift & goto CHECK_PARAMETER
if .%1==.--gradle-cache shift & set "GRADLE_CACHE_LAST_ACCESS_DAYS=%~2" & shift & goto CHECK_PARAMETER
if .%1==.--path shift & set "CB_CLEAN_PATH=%~2" & shift & goto CHECK_PARAMETER
if .%1==.--pattern shift & set "CB_CLEAN_PATTERN=%~2" & shift & goto CHECK_PARAMETER
echo %CB_LINEHEADER%Invalid parameter: %1
echo\
goto HELP

:PARAM_DONE
:: validate CB_HOME and run expensive checks only when actually executing
if not exist "%CB_TEMP%" mkdir "%CB_TEMP%" >nul 2>nul
if not defined CB_HOME echo %CB_LINEHEADER%Missing CB_HOME environment variable, please install with the cb-install. & goto END

:: detect docker/nerdctl
set "CB_DOCKER_CMD="
where nerdctl >nul 2>nul && nerdctl info >nul 2>nul && set "CB_DOCKER_CMD=nerdctl"
if not defined CB_DOCKER_CMD where docker >nul 2>nul && docker info >nul 2>nul && set "CB_DOCKER_CMD=docker"

if .%CB_SILENT%==.true set "SILENT_FLAG=--silent"
if .%CB_DRY_RUN%==.true set "DRY_RUN_FLAG=--dry-run"
if .%CB_DRY_RUN%==.true if .%CB_SILENT%==.false echo %CB_LINEHEADER%[DRY-RUN mode -- no files will be deleted]

:: if no args were given (and no --path/--pattern), use defaults
if %argCount% EQU 0 if not defined CB_CLEAN_PATH if not defined CB_CLEAN_PATTERN (
	set "enableCleanupCommonBuild=1"
	set "enableCleanupCommonGradleBuild=1"
	set "enableDockerImagePrune=1"
)

:: resolve custom setting script if not already set (e.g. via cb --setenv)
if not defined CB_CUSTOM_SETTING_SCRIPT if defined CB_CUSTOM_RUNTIME_CONFIG_PATH if exist "%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat" set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_RUNTIME_CONFIG_PATH%\bin\cb-custom.bat"
if not defined CB_CUSTOM_SETTING_SCRIPT if defined CB_CUSTOM_SETTING if exist "%CB_CUSTOM_SETTING%" set "CB_CUSTOM_SETTING_SCRIPT=%CB_CUSTOM_SETTING%"

:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" cleanup-start %1 %2 %3 %4 %5 %6 %7 2>nul

if %enableCleanupCommonBuild% EQU 1 call :CLEANUP_COMMON_BUILD
if %enableCleanupCommonGradleBuild% EQU 1 call :CLEANUP_COMMON_GRADLE_BUILD
if %enableDockerImagePrune% EQU 1 call :DOCKER_IMAGE_PRUNE
if %enableDockerSystemPrune% EQU 1 call :DOCKER_SYSTEM_PRUNE
if %enableCleanupNpm% EQU 1 call :CLEANUP_NPM

:: custom setting script
if exist "%CB_CUSTOM_SETTING_SCRIPT%" call "%CB_CUSTOM_SETTING_SCRIPT%" cleanup-end %1 %2 %3 %4 %5 %6 %7 2>nul

:: --path / --pattern: delete matching files/directories under the given path
if defined CB_CLEAN_PATH goto RUN_PATH_PATTERN
if defined CB_CLEAN_PATTERN goto RUN_PATH_PATTERN
goto END

:RUN_PATH_PATTERN
if not defined CB_CLEAN_PATH set "CB_CLEAN_PATH=."
if not defined CB_CLEAN_PATTERN goto END
if not exist "%CB_CLEAN_PATH%" (if .%CB_SILENT%==.false echo %CB_LINEHEADER%Path %CB_CLEAN_PATH% does not exist.) & goto END
if .%CB_SILENT%==.false echo %CB_LINEHEADER%Cleanup %CB_CLEAN_PATH% (pattern: %CB_CLEAN_PATTERN%)...
call "%CB_HOME%\bin\cb-clean-files.bat" %SILENT_FLAG% %DRY_RUN_FLAG% --path "%CB_CLEAN_PATH%" --pattern "%CB_CLEAN_PATTERN%" --days %CLEAN_LOG_UNTIL_DAYS%
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEANUP_COMMON_BUILD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_LOGS=%CB_HOME%\logs"
if .%CB_SILENT%==.false echo %CB_LINEHEADER%Cleanup %CB_LOGS%...
if exist "%CB_LOGS%" call "%CB_HOME%\bin\cb-clean-files.bat" %SILENT_FLAG% %DRY_RUN_FLAG% --path "%CB_LOGS%" --pattern * --days %CLEAN_LOG_UNTIL_DAYS%
if .%CB_SILENT%==.false echo %CB_LINEHEADER%Cleanup %CB_TEMP%...
if exist "%CB_TEMP%" call "%CB_HOME%\bin\cb-clean-files.bat" %SILENT_FLAG% %DRY_RUN_FLAG% --path "%CB_TEMP%" --pattern * --days %CLEAN_LOG_UNTIL_DAYS%
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEANUP_COMMON_GRADLE_BUILD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: stop gradle daemon
where gradle >nul 2>nul && gradle --version >nul 2>nul && (if .%CB_SILENT%==.false echo %CB_LINEHEADER%Stop gradle daemon...) && gradle --stop >nul 2>nul

if not defined CGB_TEMP set "CGB_TEMP=%TEMP%\cgb-%USERNAME%"
if .%CB_SILENT%==.false echo %CB_LINEHEADER%Cleanup %CGB_TEMP%...
if exist "%CGB_TEMP%" call "%CB_HOME%\bin\cb-clean-files.bat" %SILENT_FLAG% %DRY_RUN_FLAG% --path "%CGB_TEMP%" --pattern * --days %CLEAN_LOG_UNTIL_DAYS%

:: remove old daemon folders except the newest
set "GRADLE_DAEMON=%USERPROFILE%\.gradle\daemon"
if exist "%GRADLE_DAEMON%" if .%CB_SILENT%==.false echo %CB_LINEHEADER%Cleanup %GRADLE_DAEMON%...
if exist "%GRADLE_DAEMON%" call :KEEP_NEWEST_DIR "%GRADLE_DAEMON%"
if exist "%GRADLE_DAEMON%" call "%CB_HOME%\bin\cb-clean-files.bat" %SILENT_FLAG% %DRY_RUN_FLAG% --path "%GRADLE_DAEMON%" --pattern * --days %CLEAN_LOG_UNTIL_DAYS%
if exist "%GRADLE_DAEMON%" if .%CB_DRY_RUN%==.false call :REMOVE_EMPTY_DIRS "%GRADLE_DAEMON%"

:: cleanup old common-gradle-build releases via cb-version-filter --invertFilter
set "GRADLE_CGB=%USERPROFILE%\.gradle\common-gradle-build"
if exist "%GRADLE_CGB%" (
	if .%CB_SILENT%==.false echo %CB_LINEHEADER%Cleanup old common-gradle-build releases in %GRADLE_CGB%...
	for /f "delims=" %%V in ('call "%CB_HOME%\bin\cb-version-filter.bat" --path "%GRADLE_CGB%" --majorThreshold 2 --minorThreshold 2 --patchThreshold 2 --previousMajorPatchThreshold 1 --previousMajorMinorThreshold 1 --majorMinorMax 10 --invertFilter 2^>nul') do call :DELETE_DIR "%GRADLE_CGB%\%%V"
)
set "GRADLE_CACHES=%USERPROFILE%\.gradle\caches"
if exist "%GRADLE_CACHES%" call "%CB_HOME%\bin\cb-clean-files.bat" %SILENT_FLAG% %DRY_RUN_FLAG% --path "%GRADLE_CACHES%" --pattern * --days %GRADLE_CACHE_LAST_ACCESS_DAYS%
if exist "%GRADLE_CACHES%" if .%CB_DRY_RUN%==.false call :REMOVE_EMPTY_DIRS "%GRADLE_CACHES%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DELETE_DIR
:: param %1: directory to delete, honors CB_DRY_RUN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "DEL_TARGET=%~1"
if not exist "%DEL_TARGET%" goto :eof
if .%CB_DRY_RUN%==.true (
	echo %CB_LINEHEADER%[DRY-RUN] Would delete %DEL_TARGET%
) else (
	if .%CB_SILENT%==.false echo %CB_LINEHEADER%Delete %DEL_TARGET%
	rmdir /s /q "%DEL_TARGET%" >nul 2>nul
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:REMOVE_EMPTY_DIRS
:: param %1: root path; removes empty subdirectories (deepest first)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "EMPTY_ROOT=%~1"
for /f "delims=" %%D in ('dir /s /b /ad "%EMPTY_ROOT%" 2^>nul ^| sort /r') do rmdir "%%D" 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:KEEP_NEWEST_DIR
:: param %1: path whose child directories to prune; keeps the newest child dir
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "KEEP_PATH=%~1"
set "KEEP_NEWEST="
for /f "delims=" %%D in ('dir /b /ad /o-d "%KEEP_PATH%" 2^>nul') do (
	if not defined KEEP_NEWEST (
		set "KEEP_NEWEST=%%D"
	) else (
		call :DELETE_DIR "%KEEP_PATH%\%%D"
	)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DOCKER_IMAGE_PRUNE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not defined CB_DOCKER_CMD goto :eof
if .%CB_SILENT%==.false echo %CB_LINEHEADER%Docker image prune (until %DOCKER_IMAGE_CLEAN_UNTIL%H)...
%CB_DOCKER_CMD% image prune -f -a --filter "until=%DOCKER_IMAGE_CLEAN_UNTIL%H"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DOCKER_SYSTEM_PRUNE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not defined CB_DOCKER_CMD goto :eof
if .%CB_SILENT%==.false echo %CB_LINEHEADER%Docker system prune (until %DOCKER_SYSTEM_CLEAN_UNTIL%H)...
%CB_DOCKER_CMD% system prune -f -a --filter "until=%DOCKER_SYSTEM_CLEAN_UNTIL%H"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEANUP_NPM
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :eof
if .%CB_SILENT%==.false echo %CB_LINEHEADER%Cleanup npm cache...
call npm cache clean --force
call npm cache verify
call npx browserslist@latest --update-db
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_DOCKER_CMD_INFO=%CB_DOCKER_CMD%"
if not defined CB_DOCKER_CMD_INFO set "CB_DOCKER_CMD_INFO=docker"
echo %PN% - Cleanup common-build atrefacts
echo usage: %PN% [OPTION]...
echo\
echo Runs one or more cleanup targets. Without any
echo arguments it runs --cb, --cgb and --docker-image.
echo\
echo Targets:
echo  --cb                         Clean common-build: %%CB_HOME%%\logs, %%CB_TEMP%%
echo  --cgb                        Clean common-gradle-build: stop gradle daemon,
echo                               %%CGB_TEMP%%, ~\.gradle\daemon ^(keep newest^),
echo                               ~\.gradle\common-gradle-build, ~\.gradle\caches
echo  --docker-image               %CB_DOCKER_CMD_INFO% image prune ^(until %DOCKER_IMAGE_CLEAN_UNTIL% hours^)
echo  --docker-system              %CB_DOCKER_CMD_INFO% system prune ^(until %DOCKER_SYSTEM_CLEAN_UNTIL% hours^)
echo  --npm                        npm cache clean + verify + browserslist update
echo  --path ^<dir^>               Custom cleanup: top-level files under ^<dir^>
echo  --pattern ^<glob^>           Glob pattern for --path ^(default: all files^)
echo\
echo Thresholds:
echo  --log-until ^<n^>            Days to keep logs/temp files ^(default %CLEAN_LOG_UNTIL_DAYS%^)
echo  --gradle-cache ^<n^>         Days since last access for gradle cache ^(default %GRADLE_CACHE_LAST_ACCESS_DAYS%^)
echo  --docker-image-until ^<h^>   %CB_DOCKER_CMD_INFO% image prune age in hours ^(default %DOCKER_IMAGE_CLEAN_UNTIL%^)
echo  --docker-system-until ^<h^>  %CB_DOCKER_CMD_INFO% system prune age in hours ^(default %DOCKER_SYSTEM_CLEAN_UNTIL%^)
echo\
echo Misc:
echo  -h, --help                   Show this help message.
echo  --silent                     Suppress informational output.
echo  --dry-run                    Show what would be deleted without touching anything.
echo\
echo Examples:
echo  Default cleanup ^(cb + cgb + docker-image^):
echo  cb-cleanup
echo\
echo  Delete gradle worker files in %%TEMP%%:
echo  cb-cleanup --path %%TEMP%% --pattern gradle-worker*
echo\
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
endlocal
