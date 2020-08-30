@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: read-version.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: first parameter defines the versin file
:: secomd parameter defines if the qualifier should be added or not (default true)
if not exist "%1" set "version.number=n/a" & goto :eof
for /f "tokens=2 delims==" %%i in ('type %1^|findstr /C:major.number') do ( set "major.number=%%i"  )
for /f "tokens=2 delims==" %%i in ('type %1^|findstr /C:minor.number') do ( set "minor.number=%%i"  )
for /f "tokens=2 delims==" %%i in ('type %1^|findstr /C:revision.number') do ( set "revision.number=%%i"  )
for /f "tokens=2 delims==" %%i in ('type %1^|findstr /C:qualifier') do ( set "qualifier=%%i"  )

:: trim
if defined major.number set major.number=%major.number: =%
if defined minor.number set minor.number=%minor.number: =%
if defined revision.number set revision.number=%revision.number: =%
if defined qualifier set qualifier=%qualifier: =%

:: combine to version number
set "version.number=%major.number%.%minor.number%.%revision.number%"
if defined qualifier if not .%qualifier%==. if .%2==. set "version.number=%version.number%-%qualifier%"
if defined qualifier if not .%qualifier%==. if .%2==.true set "version.number=%version.number%-%qualifier%"
