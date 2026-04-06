@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-version-filter.bat
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
set "PN=%~nx0"

:: defaults
set "verbose=false"
set "versionDir="
set "invertFilter=false"
set "majorVersionThreshold=2"
set "minorVersionThreshold=0"
set "patchVersionThreshold=0"
set "previousMajorMinorThreshold=0"
set "previousMajorPatchThreshold=0"
set "majorMinorMax=0"
set "minorAutoCopied=false"

:: parse arguments
:PARSE
if [%1]==[] goto PARSE_DONE
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.--verbose set "verbose=true" & shift & goto PARSE
if .%1==.--majorThreshold set "majorVersionThreshold=%~2" & shift & shift & goto PARSE
if .%1==.--minorThreshold set "minorVersionThreshold=%~2" & set "previousMajorMinorThreshold=%~2" & set "minorAutoCopied=true" & shift & shift & goto PARSE
if .%1==.--patchThreshold set "patchVersionThreshold=%~2" & set "previousMajorPatchThreshold=%~2" & shift & shift & goto PARSE
if .%1==.--previousMajorMinorThreshold set "previousMajorMinorThreshold=%~2" & set "minorAutoCopied=false" & shift & shift & goto PARSE
if .%1==.--previousMajorPatchThreshold set "previousMajorPatchThreshold=%~2" & shift & shift & goto PARSE
if .%1==.--majorMinorMax set "majorMinorMax=%~2" & shift & shift & goto PARSE
if .%1==.--invertFilter set "invertFilter=true" & shift & goto PARSE
if .%1==.--path set "versionDir=%~2" & shift & shift & goto PARSE
echo Invalid parameter: %1
echo\
goto HELP

:PARSE_DONE

:: In invert mode, tighten auto-copied previousMajorMinorThreshold by 1
:: so more versions fall into the discarded set.
if .%invertFilter%==.true if .%minorAutoCopied%==.true if !previousMajorMinorThreshold! GTR 1 set /a previousMajorMinorThreshold=!previousMajorMinorThreshold! - 1

:: collect input: --path overrides stdin
set "RAW_INPUT="
if defined versionDir (
	if not exist "%versionDir%\" (
		call :LOG_VERBOSE ==^>Could not found version numbers to filter, give up!
		exit /b 1
	)
	call :LOG_VERBOSE Filter versions in directory %versionDir%...
	for /f "delims=" %%D in ('dir /b /ad "%versionDir%" 2^>nul') do set "RAW_INPUT=!RAW_INPUT! %%D"
) else (
	:: read from stdin
	for /f "delims=" %%L in ('more') do (
		for %%T in (%%L) do set "RAW_INPUT=!RAW_INPUT! %%T"
	)
)

if not defined RAW_INPUT (
	call :LOG_VERBOSE ==^>No versions to filter, give up!
	exit /b 0
)

:: sort versions descending (newest first) by padding components to 10 chars
set "SORT_TMP=%TEMP%\cbvf-sort-%RANDOM%.txt"
set "SORT_OUT=%TEMP%\cbvf-sorted-%RANDOM%.txt"
del /f /q "%SORT_TMP%" "%SORT_OUT%" >nul 2>nul
for %%V in (%RAW_INPUT%) do call :PAD_AND_WRITE "%%V" "%SORT_TMP%"
if exist "%SORT_TMP%" (
	%SystemRoot%\System32\sort.exe /r "%SORT_TMP%" > "%SORT_OUT%" 2>nul
	del /f /q "%SORT_TMP%" >nul 2>nul
)

:: filter loop
set "majorVersionCount=0"
set "minorVersionCount=0"
set "patchVersionCount=0"
set "majorMinorCount=0"
set "previousMajor="
set "previousMinor="
set "filteredVersions="
set "versionsToIgnore="
set "overflow=false"

if exist "%SORT_OUT%" (
	for /f "tokens=2" %%V in ('type "%SORT_OUT%"') do call :FILTER_ONE "%%V"
	del /f /q "%SORT_OUT%" >nul 2>nul
)

:: output
if .%invertFilter%==.false (
	call :EMIT "%filteredVersions%"
) else (
	call :EMIT "%versionsToIgnore%"
)

endlocal
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:LOG_VERBOSE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if .%verbose%==.true echo %* 1>&2
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PAD_AND_WRITE
:: %1 = raw version string, %2 = output file
:: emits "<padded> <original>" to file if version parses as MAJOR.MINOR.PATCH
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "V=%~1"
set "REST=%V%"
:: strip leading v or V
if /i "%V:~0,1%"=="v" set "REST=%V:~1%"
set "MAJOR="
set "MINOR="
set "PATCH="
for /f "tokens=1,2,3 delims=.-+" %%A in ("%REST%") do (
	set "MAJOR=%%A"
	set "MINOR=%%B"
	set "PATCH=%%C"
)
if not defined MAJOR goto :eof
if not defined MINOR goto :eof
if not defined PATCH goto :eof
:: verify numeric
set "T=true"
for /f "delims=0123456789" %%X in ("%MAJOR%%MINOR%%PATCH%") do set "T=false"
if "%T%"=="false" goto :eof
set "PM=0000000000%MAJOR%"
set "PN1=0000000000%MINOR%"
set "PP=0000000000%PATCH%"
set "PADDED=!PM:~-10!.!PN1:~-10!.!PP:~-10!"
>>"%~2" echo !PADDED! %V%
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:FILTER_ONE
:: %1 = raw version (e.g. 1.2.3)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "VN=%~1"
call :LOG_VERBOSE   Process directory %VN%...

:: once cap has been exceeded, route everything to ignored
if "!overflow!"=="true" (
	set "versionsToIgnore=!versionsToIgnore!;%VN%"
	goto :eof
)

for /f "tokens=1,2,3 delims=.-+" %%A in ("%VN%") do (
	set "VMAJOR=%%A"
	set "VMINOR=%%B"
	set "VPATCH=%%C"
)

if defined previousMajor (
	if "!previousMajor!"=="!VMAJOR!" (
		call :_SAME_MAJOR
	) else (
		call :_DIFF_MAJOR
	)
) else (
	call :_FIRST_VERSION
)

:: tighten thresholds for subsequent majors
if !majorVersionCount! GTR 1 (
	set "minorVersionThreshold=!previousMajorMinorThreshold!"
	set "patchVersionThreshold=!previousMajorPatchThreshold!"
)

:: enforce majorMinorMax
if !majorMinorMax! GTR 0 (
	if !majorMinorCount! GTR !majorMinorMax! (
		:: move the just-kept cap-breaking version to ignored
		call :MOVE_LAST_KEPT_TO_IGNORED
		set "overflow=true"
	)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MOVE_LAST_KEPT_TO_IGNORED
:: extract last ;token from filteredVersions and append to versionsToIgnore
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "X=!filteredVersions!"
set "LAST="
:_MLKI_LOOP
if "!X!"=="" goto :_MLKI_DONE
if "!X:~-1!"==";" goto :_MLKI_DONE
set "LAST=!X:~-1!!LAST!"
set "X=!X:~0,-1!"
goto :_MLKI_LOOP
:_MLKI_DONE
:: drop trailing ; from X
if "!X:~-1!"==";" set "X=!X:~0,-1!"
set "filteredVersions=!X!"
if defined LAST set "versionsToIgnore=!versionsToIgnore!;!LAST!"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_SAME_MAJOR
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if defined previousMinor (
	if "!previousMinor!"=="!VMINOR!" (
		:: same minor
		if !patchVersionThreshold! GTR !patchVersionCount! (
			set /a patchVersionCount+=1
			set "filteredVersions=!filteredVersions!;%VN%"
		) else (
			set "versionsToIgnore=!versionsToIgnore!;%VN%"
		)
	) else (
		:: different minor
		if !minorVersionThreshold! GTR 0 (
			if !minorVersionThreshold! GTR !minorVersionCount! (
				set "previousMinor=!VMINOR!"
				set /a minorVersionCount+=1
				set /a majorMinorCount+=1
				set "patchVersionCount=1"
				set "filteredVersions=!filteredVersions!;%VN%"
			) else (
				set "versionsToIgnore=!versionsToIgnore!;%VN%"
			)
		) else (
			set "previousMinor=!VMINOR!"
			set /a minorVersionCount+=1
			set /a majorMinorCount+=1
			set "patchVersionCount=1"
			set "filteredVersions=!filteredVersions!;%VN%"
		)
	)
) else (
	set "previousMinor=!VMINOR!"
	set /a minorVersionCount+=1
	set /a majorMinorCount+=1
	set "patchVersionCount=1"
	set "filteredVersions=!filteredVersions!;%VN%"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_DIFF_MAJOR
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if !majorVersionThreshold! GTR 0 (
	if !majorVersionThreshold! GTR !majorVersionCount! (
		set "previousMajor=!VMAJOR!"
		set /a majorVersionCount+=1
		set /a majorMinorCount+=1
		set "previousMinor=!VMINOR!"
		set "minorVersionCount=1"
		set "patchVersionCount=1"
		set "filteredVersions=!filteredVersions!;%VN%"
	) else (
		set "versionsToIgnore=!versionsToIgnore!;%VN%"
	)
) else (
	set "previousMajor=!VMAJOR!"
	set /a majorVersionCount+=1
	set /a majorMinorCount+=1
	set "previousMinor=!VMINOR!"
	set "minorVersionCount=1"
	set "patchVersionCount=1"
	set "filteredVersions=!filteredVersions!;%VN%"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:_FIRST_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "previousMajor=!VMAJOR!"
set /a majorVersionCount+=1
set /a majorMinorCount+=1
set "previousMinor=!VMINOR!"
set "minorVersionCount=1"
set "patchVersionCount=1"
if !majorVersionThreshold! GTR 0 (
	if !majorVersionThreshold! GEQ !majorVersionCount! (
		set "filteredVersions=!filteredVersions!;%VN%"
	) else (
		set "versionsToIgnore=!versionsToIgnore!;%VN%"
	)
) else (
	set "filteredVersions=!filteredVersions!;%VN%"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:STRIP_LAST_TOKEN
:: remove trailing ;token from filteredVersions
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "X=!filteredVersions!"
:STRIP_LOOP
if "!X:~-1!"==";" goto :eof_strip
if "!X!"=="" goto :eof_strip
set "X=!X:~0,-1!"
if not "!X:~-1!"==";" goto STRIP_LOOP
:eof_strip
set "filteredVersions=!X!"
:: drop the trailing ; if present
if "!filteredVersions:~-1!"==";" set "filteredVersions=!filteredVersions:~0,-1!"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:EMIT
:: print semicolon-separated list, one version per line, stripping leading ;
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "S=%~1"
if "%S%"=="" goto :eof
if "%S:~0,1%"==";" set "S=%S:~1%"
for %%V in ("%S:;=" "%") do (
	set "X=%%~V"
	if defined X echo !X!
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - Script to filter version numbers. It expect a list of version number in semver style, e.g. 2.1.3.
echo                         In case there is no input piped nothing will be done. The path parameter allows to
echo                         search in a specific folder for directories with version numbers.
echo\
echo usage: %PN% [OPTION]
echo\
echo Overview of the available OPTIONs:
echo  -h, --help                             Show this help message.
echo  --verbose                              Verbose mode.
echo  --majorThreshold ^<num^>               Defines the major version number threshold, default %majorVersionThreshold%.
echo  --minorThreshold ^<num^>               Defines the minor version number threshold, default %minorVersionThreshold%.
echo  --patchThreshold ^<num^>               Defines the patch version number threshold, default %patchVersionThreshold%.
echo  --previousMajorMinorThreshold ^<num^>  Defines the minor version number threshold of previous major version, default %previousMajorMinorThreshold%.
echo  --previousMajorPatchThreshold ^<num^>  Defines the patch version number threshold of previous major version, default %previousMajorPatchThreshold%.
echo  --majorMinorMax ^<num^>                Defines the max number of major / minor versions.
echo  --invertFilter                         Invert the filter: the filtered version are that one which should be ignored.
echo  --path [path]                          Defines the path where the filter reads directories with version numbers (no prefix nor appendix).
echo\
echo Examples
echo :: result should contain max 2 major numbers with max 2 minor and max 2 patch versions. The minor and patch versions are limited to 1 of previous major versions:
echo #^> type myfile ^| %PN% --majorThreshold 2
echo\
echo :: result should contain max 2 major numbers with max 2 minor and max 2 patch versions. The minor versions is limited to 1 of previous major versions and patch versions to 2:
echo #^> type myfile ^| %PN% --majorThreshold 2 --previousMajorPatchThreshold 2
echo\
echo :: result should contain max 2 major numbers with max 2 minor and max 2 patch versions. The minor versions is limited to 1 of previous major versions and patch versions to 2:
echo #^> echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 ^| %PN% --majorThreshold 2 --previousMajorPatchThreshold 2
echo\
echo :: result list up the versions to skip: 2.1.0 1.2.1 1.2.0
echo #^> echo 2.2.1 2.2.0 2.1.2 2.1.1 2.1.0 1.3.4 1.3.3 1.2.1 1.2.0 ^| %PN% --majorThreshold 2 --previousMajorPatchThreshold 2 --invertFilter
echo\
echo :: read all directories of test directory with versions and result should contain max 2 major, max 2 minor and max 2 patch versions. The minor versions is limited to 1 of previous major versions and patch versions to 2. It returns the versions to skip:
echo #^> %PN% --path test --majorThreshold 2 --previousMajorPatchThreshold 2 --invertFilter
echo\
exit /b 1
