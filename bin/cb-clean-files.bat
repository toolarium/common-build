@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-clean-files.bat
::
:: Deletes regular files older than N days from a single directory
:: (non-recursive, top level only), filtered by an optional glob pattern.
:: Rejects dangerous target paths (drive root, %SystemRoot%, %ProgramFiles%,
:: %ProgramFiles(x86)%, %USERPROFILE%). Supports --dry-run and --silent
:: modes, reports how many files were deleted.
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
if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb"
if not exist "%CB_TEMP%" mkdir "%CB_TEMP%" >nul 2>nul
set "CB_SILENT=false"
set "CB_DRY_RUN=false"
set "CLEAN_PATH=%CB_TEMP%"
set "CLEAN_PATTERN=*"
set "CLEAN_DAYS=1"
if not defined CLEAN_PATH set "CLEAN_PATH=%TMP%"

:CHECK_PARAMETER
if [%1]==[] goto CLEAN
if .%1==.--silent set "CB_SILENT=true"
if .%1==.--dry-run set "CB_DRY_RUN=true"
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.--path shift & set "CLEAN_PATH=%~2"
if .%1==.--pattern shift & set "CLEAN_PATTERN=%~2"
if .%1==.--days shift & set "CLEAN_DAYS=%~2"
shift
goto CHECK_PARAMETER

:CLEAN
:: validate --days is a non-negative integer
set "DAYS_VALID=true"
for /f "delims=0123456789" %%A in ("%CLEAN_DAYS%") do set "DAYS_VALID=false"
if not "%CLEAN_DAYS%"=="" if "%DAYS_VALID%"=="false" echo .: Invalid --days value [%CLEAN_DAYS%], must be a non-negative integer & exit /b 1
if "%CLEAN_DAYS%"=="" echo .: Invalid --days value, must be a non-negative integer & exit /b 1

:: refuse dangerous paths (root of drive, system locations, user profile root)
if not exist "%CLEAN_PATH%" echo .: Path %CLEAN_PATH% don't exist & goto END
for %%P in ("%CLEAN_PATH%") do set "CLEAN_PATH_ABS=%%~fP"
if /i "%CLEAN_PATH_ABS:~-2%"==":\" echo .: Refusing to clean dangerous path [%CLEAN_PATH_ABS%] & exit /b 1
if /i "%CLEAN_PATH_ABS%"=="%SystemRoot%" echo .: Refusing to clean dangerous path [%CLEAN_PATH_ABS%] & exit /b 1
if /i "%CLEAN_PATH_ABS%"=="%ProgramFiles%" echo .: Refusing to clean dangerous path [%CLEAN_PATH_ABS%] & exit /b 1
if /i "%CLEAN_PATH_ABS%"=="%ProgramFiles(x86)%" echo .: Refusing to clean dangerous path [%CLEAN_PATH_ABS%] & exit /b 1
if /i "%CLEAN_PATH_ABS%"=="%USERPROFILE%" echo .: Refusing to clean dangerous path [%CLEAN_PATH_ABS%] & exit /b 1

set "DELETED_COUNT=0"
if .%CB_DRY_RUN%==.true goto CLEAN_DRY_RUN
if .%CB_SILENT%==.true goto CLEAN_SILENT
echo .: Clean in [%CLEAN_PATH%] with pattern [%CLEAN_PATTERN%] which are older than %CLEAN_DAYS% day(s)...
for /f "delims=" %%F in ('forfiles /p "%CLEAN_PATH%" /m %CLEAN_PATTERN% /D -%CLEAN_DAYS% /C "cmd /c if @isdir==FALSE echo @path" 2^>nul') do (
	set /a DELETED_COUNT+=1
	del /f /q %%F 2>nul
	echo Delete file %%F
)
echo .: Deleted %DELETED_COUNT% file(s).
goto END

:CLEAN_SILENT
for /f "delims=" %%F in ('forfiles /p "%CLEAN_PATH%" /m %CLEAN_PATTERN% /D -%CLEAN_DAYS% /C "cmd /c if @isdir==FALSE echo @path" 2^>nul') do (
	set /a DELETED_COUNT+=1
	del /f /q %%F 2>nul
)
goto END

:CLEAN_DRY_RUN
if .%CB_SILENT%==.false echo .: [DRY-RUN] Would clean in [%CLEAN_PATH%] with pattern [%CLEAN_PATTERN%] which are older than %CLEAN_DAYS% day(s)...
for /f "delims=" %%F in ('forfiles /p "%CLEAN_PATH%" /m %CLEAN_PATTERN% /D -%CLEAN_DAYS% /C "cmd /c if @isdir==FALSE echo @path" 2^>nul') do (
	set /a DELETED_COUNT+=1
	if .%CB_SILENT%==.false echo [DRY-RUN] Would delete %%F
)
if .%CB_SILENT%==.false echo .: [DRY-RUN] Would delete %DELETED_COUNT% file(s).
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - clean files
echo usage: %PN% [OPTION]
echo\
echo Deletes regular files ^(NOT directories^) older than N days from the
echo top level of a single directory, filtered by an optional glob pattern.
echo Non-recursive: subdirectories are never entered and never removed.
echo Dangerous target paths ^(drive root, %%SystemRoot%%, %%ProgramFiles%%,
echo %%ProgramFiles(x86^)%%, %%USERPROFILE%%^) are refused.
echo\
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  --silent             Suppress informational output.
echo  --dry-run            List matching files without deleting them.
echo  --path path          Target directory ^(default %%CB_TEMP%%^). The directory itself is never removed.
echo  --pattern pattern    File name glob, default ^*
echo  --days days          Delete files with mtime older than N days, default 1
echo\
echo Examples:
echo  Delete cb temp files older than 1 day:
echo  cb-clean-files
echo\
echo  Delete gradle worker files in %%TEMP%%:
echo  cb-clean-files --path %%TEMP%% --pattern gradle-worker^*
echo\
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::