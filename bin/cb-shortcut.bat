@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-shurtcut.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


setlocal EnableDelayedExpansion
set PN=%~nx0
set VERBOSE=false
set COMMAND=
set APPLICATION=
set ARGUMENTS=
set DESCRIPTION=
set ICON_LOCATION=
set SHORTCUT=
set WINDOW_STYLE=
set WORKING_DIRECTORY=
set CB_SETENV=

:CHECK_PARAMETER
if %0X==X goto PREPARE_SHORTCUT
if .%1==.--verbose set "VERBOSE=true"
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.--cb-setenv shift & set "CB_SETENV=true" & goto CHECK_PARAMETER

if .%1==.--command shift & set "COMMAND=%~2" & shift & goto CHECK_PARAMETER
if .%1==.--arguments shift & set "ARGUMENTS=%2" & shift & goto CHECK_PARAMETER
::if .%1==.--description shift & set "DESCRIPTION=%2" & shift & goto CHECK_PARAMETER
::if .%1==.--hotkey shift & set "HOTKEY=%2" & shift & goto CHECK_PARAMETER
if .%1==.--icon shift & set "ICON_LOCATION=%2" & shift & goto CHECK_PARAMETER
::if .%1==.--windowstyle shift & set "WINDOW_STYLE=%2" & shift & goto CHECK_PARAMETER
::if .%1==.--workingdirectory shift & set "WORKING_DIRECTORY=%2" & shift & goto CHECK_PARAMETER
if not .%1==. set "SHORTCUT=%~1"
shift
goto CHECK_PARAMETER


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PREPARE_BATCH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "ARGUMENTS=/c %APPLICATION%"
set "APPLICATION=cmd" 
if .%SHORTCUT%==. for %%A in ("%COMMAND%") do (set SHORTCUT=%%~nA.lnk)
::    echo full path: %%~fA
::    echo drive: %%~dA
::    echo path: %%~pA
::    echo file name only: %%~nA
::    echo extension only: %%~xA
::    echo expanded path with short names: %%~sA
::    echo attributes: %%~aA
::    echo date and time: %%~tA
::    echo size: %%~zA
::    echo drive + path: %%~dpA
::    echo name.ext: %%~nxA
::    echo full path + short name: %%~fsA)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CREATE_SHORTCUT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Name             MemberType Definition                             
:: ----             ---------- ----------                             
:: Load             Method     void Load (string)                     
:: Save             Method     void Save ()                           
:: Arguments        Property   string Arguments () {get} {set}        
:: Description      Property   string Description () {get} {set}      
:: FullName         Property   string FullName () {get}               
:: Hotkey           Property   string Hotkey () {get} {set}           
:: IconLocation     Property   string IconLocation () {get} {set}     
:: RelativePath     Property   string RelativePath () {set}           
:: TargetPath       Property   string TargetPath () {get} {set}       
:: WindowStyle      Property   int WindowStyle () {get} {set}         
:: WorkingDirectory Property   string WorkingDirectory () {get} {set} 

echo .: Create shurtcut %SHORTCUT%
set "PWS=powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile"
::%PWS% -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut(%SHORTCUT%); $S.Arguments = %ARGUMENTS%; $S.Description = %DESCRIPTION%; $S.Hotkey = %HOTKEY%; $S.IconLocation = %ICON_LOCATION%; $S.WindowStyle = %WINDOW_STYLE%; $S.WorkingDirectory = %WORKING_DIRECTORY%; $S.TargetPath = %APPLICATION%; $S.Save()"
::if .%ICON_LOCATION%==. %PWS% -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut(%SHORTCUT%); $S.Arguments = %ARGUMENTS%; $S.TargetPath = %APPLICATION%; $S.Save()"
if not .%ICON_LOCATION%==. %PWS% -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut(%SHORTCUT%); $S.Arguments = %ARGUMENTS%; $S.IconLocation = %ICON_LOCATION%; $S.TargetPath = %APPLICATION%; $S.Save()"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PREPARE_SHORTCUT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if .%COMMAND%==. if .%SHORTCUT%==. echo .: ERROR: to less information & goto HELP

:: in case we have no command then we use th shortcut as command
if .%COMMAND%==. if not .%SHORTCUT%==. set "COMMAND=%SHORTCUT%" & set SHORTCUT=

:: split into APPLICATION and ARGUMENTS
if .%ARGUMENTS%==. for /f "tokens=1* delims= " %%i in ("%COMMAND%") do (set "APPLICATION=%%i" & set "ARGUMENTS=%%j")
if .%ARGUMENTS%==. set "APPLICATION=%COMMAND%"

:: batch is differently
if /i [%COMMAND:~-4%]==[.bat] call :PREPARE_BATCH

:PREPARE_SHORTCUT_END
:: be sure we have shortcut and icon location
if .%SHORTCUT%==. set "SHORTCUT=%APPLICATION:~-4%.lnk"
if .%ICON_LOCATION%==. set "ICON_LOCATION=%APPLICATION%

if .%VERBOSE%==.true (echo .: Create shortcut:
	echo      -SHORTCUT      [%SHORTCUT%]
	echo      -APPLICATION   [%APPLICATION%]
	echo      -ARGUMENTS     [%ARGUMENTS%]
	echo      -ICON_LOCATION [%ICON_LOCATION%])

set SHORTCUT='%SHORTCUT%'
set APPLICATION='%APPLICATION%'
set ARGUMENTS='%ARGUMENTS%'
set ICON_LOCATION='%ICON_LOCATION%'
call :CREATE_SHORTCUT
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - create shortcuts
echo usage: %PN% [OPTION] shurtcut
echo.
echo Overview of the available OPTIONs:
echo  -h, --help                  Show this help message.
echo  --verbose                   The verbose mode
echo  --command command           The shortcut command.
::echo  --description description   The description.
::echo  --hotkey hotkey             Defines a hotkey
echo  --icon icon                 The icon location.
::echo  --windowstyle sytle         The windows style (optional)
echo  --workingdirectory wd       The working directory (optional)
echo.
echo Samples:
echo  -%PN% --command "cmd /c c:\devtools\eclipse-2020-06\bin\eclipse.bat" --icon c:\devtools\eclipse-2020-06\eclipse\eclipse.exe eclipse.lnk
echo  -%PN% --command c:\devtools\eclipse-2020-06\bin\eclipse.bat --icon c:\devtools\eclipse-2020-06\eclipse\eclipse.exe eclipse.lnk
echo  -%PN% --command c:\devtools\eclipse-2020-06\bin\eclipse.bat eclipse.lnk
echo  -%PN% --command c:\devtools\eclipse-2020-06\bin\eclipse.bat
echo  -%PN% c:\devtools\eclipse-2020-06\bin\eclipse.bat
echo  -%PN% c:\devtools\eclipse-2020-06\bin\eclipse.bat  --icon c:\devtools\eclipse-2020-06\eclipse\eclipse.exe
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::