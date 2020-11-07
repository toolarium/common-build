@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-clean.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


setlocal EnableDelayedExpansion
set PN=%~nx0
if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb"
if not exist %CB_TEMP% mkdir "%CB_TEMP%" >nul 2>nul
set "CB_SILENT=true"
set "CLEAN_PATH=%CB_TEMP%"
set "CLEAN_PATTERN=*.*"
set "CLEAN_DAYS=1"
if [%CLEAN_PATH%] EQU [] set "CLEAN_PATH=%TMP%"

:CHECK_PARAMETER
if %0X==X goto CLEAN
if .%1==.--silent set "CB_SILENT=true"
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.--path shift & set "CLEAN_PATH=%2"
if .%1==.--pattern shift & set "CLEAN_PATTERN=%2"
if .%1==.--days shift & set "CLEAN_DAYS=%2"
if .%1==.--file-only shift & set "CLEAN_DAYS=%2"
shift
goto CHECK_PARAMETER

:CLEAN
if not exist %CLEAN_PATH% echo .: Path %CLEAN_PATH% don't exist & goto END

if .%CB_SILENT%==.true goto CLEAN_SILENT
echo .: Clean in [%CLEAN_PATH%] with pattern [%CLEAN_PATTERN%] which are older than %CLEAN_DAYS% day(s)...
forfiles /p "%CLEAN_PATH%" /m %CLEAN_PATTERN% /D -%CLEAN_DAYS% /C "cmd /c del /f /q @path & echo Delete file @path" 2>nul
goto END

:CLEAN_SILENT
echo .: Clean silent in [%CLEAN_PATH%] with pattern [%CLEAN_PATTERN%] which are older than %CLEAN_DAYS% day(s)...
forfiles /p "%CLEAN_PATH%" /m %CLEAN_PATTERN% /D -%CLEAN_DAYS% /C "cmd /c del /f /q @path" 2>nul
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - clean files
echo usage: %PN% [OPTION]
echo.
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  --path path          Defines the path, default %%CB_TEMP%%.
echo  --pattern pattern    Defines the file pattern, default cb-^*.^* 
echo  --days days          The number of days back to delete, default 1  
echo.
echo Examples:
echo  Delete cb temp files:
echo  cb-clean
echo.
echo  Delete gradle worrker files:
echo  cb-clean --path %%TEMP%% --pattern gradle-worker^*
echo.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::