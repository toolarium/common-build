@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-meminfo.bat
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
set "divideFactor=-1"
set "quiet=true"
set "showTimestamp="
set "showJvm="
set "pidId="

:PARSE
if [%1]==[] goto PARSE_DONE
if /i "%~1"=="-h" goto HELP
if /i "%~1"=="--help" goto HELP
if /i "%~1"=="-q" set "quiet=" & shift & goto PARSE
if /i "%~1"=="-ts" set "showTimestamp=true" & shift & goto PARSE
if /i "%~1"=="-jvm" set "showJvm=true" & shift & goto PARSE
if /i "%~1"=="-b" set "divideFactor=0" & shift & goto PARSE
if /i "%~1"=="-k" set "divideFactor=1" & shift & goto PARSE
if /i "%~1"=="-m" set "divideFactor=2" & shift & goto PARSE
if /i "%~1"=="-g" set "divideFactor=3" & shift & goto PARSE
if /i "%~1"=="-t" set "divideFactor=4" & shift & goto PARSE
if /i "%~1"=="-p" set "divideFactor=5" & shift & goto PARSE
if /i "%~1"=="-pid" (
	shift
	set "pidId=%~2"
	call :VALIDATE_NUMBER "!pidId!" || (echo Invalid pid: !pidId! & goto HELP)
	shift
	goto PARSE
)
echo Invalid parameter: %~1
echo\
goto HELP

:PARSE_DONE


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Collect OS memory (via PowerShell: returns TotalKB,FreeKB)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "totalKB=0"
set "freeKB=0"
for /f "tokens=1,2 delims=," %%A in ('powershell -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem; Write-Output ('{0},{1}' -f $o.TotalVisibleMemorySize, $o.FreePhysicalMemory)" 2^>nul') do (
	set "totalKB=%%A"
	set "freeKB=%%B"
)

:: Used = Total - Free, all in KB (stays below 2^31 for machines up to ~2 TB)
set /a usedKB=totalKB - freeKB
set "processKB=0"

if defined pidId (
	for /f "tokens=*" %%A in ('powershell -NoProfile -Command "try { [int]((Get-Process -Id %pidId% -ErrorAction Stop).WorkingSet64 / 1024) } catch { 0 }" 2^>nul') do set "processKB=%%A"
)


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Collect JVM NativeMemoryTracking data via jcmd
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "jvmAvailable="
set "jvmTotalKB=0"
set "jvmHeapKB=0"
set "jvmNonHeapKB=0"
set "jvmThreadKB=0"
set "jvmGcKB=0"
set "jvmCodeKB=0"
if "%showJvm%"=="true" if defined pidId (
	set "jcmdBin="
	where jcmd >nul 2>nul && set "jcmdBin=jcmd"
	if not defined jcmdBin if defined JAVA_HOME if exist "%JAVA_HOME%\bin\jcmd.exe" set "jcmdBin=%JAVA_HOME%\bin\jcmd.exe"
	if defined jcmdBin (
		set "NMT_TMP=%TEMP%\cb-meminfo-nmt-%RANDOM%.txt"
		"!jcmdBin!" %pidId% VM.native_memory summary > "!NMT_TMP!" 2>&1
		findstr /c:"Native Memory Tracking" "!NMT_TMP!" >nul 2>nul
		if !ERRORLEVEL! EQU 0 (
			set "jvmAvailable=true"
			call :PARSE_NMT "!NMT_TMP!"
		)
		del /f /q "!NMT_TMP!" >nul 2>nul
	)
)


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Output header
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%quiet%"=="true" (
	set "HDR="
	if "%showTimestamp%"=="true" call :PAD24 "Timestamp" HDR
	call :APPEND15 "Total" HDR
	call :APPEND15 "Used" HDR
	call :APPEND15 "Free" HDR
	if defined pidId call :APPEND15 "Process[%pidId%]" HDR
	if "!jvmAvailable!"=="true" (
		call :APPEND15 "JVM-Total" HDR
		call :APPEND15 "Heap" HDR
		call :APPEND15 "Non-Heap" HDR
		call :APPEND15 "Thread" HDR
		call :APPEND15 "GC" HDR
		call :APPEND15 "Code" HDR
	)
	echo !HDR!
)


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Output data row
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "ROW="
if "%showTimestamp%"=="true" (
	for /f "tokens=*" %%T in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') do set "TS=%%T"
	call :PAD24 "!TS!" ROW
)
call :FORMAT_KB %totalKB% %divideFactor% CELL & set "ROW=!ROW!!CELL!"
call :FORMAT_KB %usedKB% %divideFactor% CELL & set "ROW=!ROW!!CELL!"
call :FORMAT_KB %freeKB% %divideFactor% CELL & set "ROW=!ROW!!CELL!"
if defined pidId call :FORMAT_KB %processKB% %divideFactor% CELL & if defined pidId set "ROW=!ROW!!CELL!"
if "%jvmAvailable%"=="true" (
	call :FORMAT_KB !jvmTotalKB! %divideFactor% CELL & set "ROW=!ROW!!CELL!"
	call :FORMAT_KB !jvmHeapKB! %divideFactor% CELL & set "ROW=!ROW!!CELL!"
	call :FORMAT_KB !jvmNonHeapKB! %divideFactor% CELL & set "ROW=!ROW!!CELL!"
	call :FORMAT_KB !jvmThreadKB! %divideFactor% CELL & set "ROW=!ROW!!CELL!"
	call :FORMAT_KB !jvmGcKB! %divideFactor% CELL & set "ROW=!ROW!!CELL!"
	call :FORMAT_KB !jvmCodeKB! %divideFactor% CELL & set "ROW=!ROW!!CELL!"
)
echo !ROW!

endlocal
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:VALIDATE_NUMBER
:: returns errorlevel 0 if numeric, 1 otherwise
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "VN_IN=%~1"
if "%VN_IN%"=="" exit /b 1
for /f "delims=0123456789" %%X in ("%VN_IN%") do exit /b 1
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PAD24
:: pad %1 to 24 chars, append to variable named %2
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "S=%~1                                                  "
set "S=!S:~0,24!"
set "%~2=!%~2!!S!"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:APPEND15
:: pad %1 to 15 chars, append to variable named %2
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "S=%~1                                                  "
set "S=!S:~0,15!"
set "%~2=!%~2!!S!"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:FORMAT_KB
:: %1 = value in KB, %2 = divideFactor (-1=auto, 0=B, 1=K, 2=M, 3=G, 4=T, 5=P)
:: %3 = out variable name, stores 15-char padded formatted value
::
:: Since input is in KB, the "bytes" unit requires multiplying by 1024
:: which would overflow 32-bit for large values. We represent B by
:: showing "_v K" is invalid; instead when -b is asked we just multiply
:: using powershell to avoid overflow.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "FK_VAL=%~1"
set "FK_DF=%~2"
set "FK_UNIT="
set /a FK_IDX=1

if "%FK_DF%"=="0" (
	:: bytes: use powershell to avoid 32-bit overflow
	for /f "tokens=*" %%R in ('powershell -NoProfile -Command "[int64]%FK_VAL% * 1024"') do set "FK_VAL=%%R"
	set "FK_IDX=0"
	goto :_FK_UNIT
)

:: start unit index at 1 (K). Loop reducing by 1024 until condition.
if "%FK_DF%"=="-1" (
	:_FK_AUTO_LOOP
	if !FK_VAL! GTR 1024 (
		set /a FK_IDX=FK_IDX + 1
		set /a FK_VAL=FK_VAL / 1024
		goto :_FK_AUTO_LOOP
	)
) else (
	:: explicit unit: K=1 (no divide), M=2 (1 divide), G=3 (2 divides), T=4, P=5
	set /a FK_REMAIN=FK_DF - 1
	:_FK_FIXED_LOOP
	if !FK_REMAIN! GTR 0 (
		set /a FK_IDX=FK_IDX + 1
		set /a FK_VAL=FK_VAL / 1024
		set /a FK_REMAIN=FK_REMAIN - 1
		goto :_FK_FIXED_LOOP
	)
)

:_FK_UNIT
if !FK_IDX! EQU 0 set "FK_UNIT= "
if !FK_IDX! EQU 1 set "FK_UNIT=K"
if !FK_IDX! EQU 2 set "FK_UNIT=M"
if !FK_IDX! EQU 3 set "FK_UNIT=G"
if !FK_IDX! EQU 4 set "FK_UNIT=T"
if !FK_IDX! EQU 5 set "FK_UNIT=P"
if !FK_IDX! EQU 6 set "FK_UNIT=E"
if !FK_IDX! EQU 7 set "FK_UNIT=Z"
if !FK_IDX! EQU 8 set "FK_UNIT=Y"
if not defined FK_UNIT set "FK_UNIT=?"

set "FK_CELL=!FK_VAL! !FK_UNIT!                                                  "
set "FK_CELL=!FK_CELL:~0,15!"
set "%~3=!FK_CELL!"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PARSE_NMT
:: %1 = NMT output file
:: parses jvmTotalKB, jvmHeapKB, etc. from jcmd NMT output
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "NMT_FILE=%~1"
set "NMT_SECTION="
for /f "usebackq delims=" %%L in ("%NMT_FILE%") do (
	set "LINE=%%L"
	:: detect section
	echo !LINE!| findstr /b /c:"Total:" >nul && call :NMT_EXTRACT "!LINE!" jvmTotalKB
	echo !LINE!| findstr /c:"-                 Java Heap" >nul && set "NMT_SECTION=Heap"
	echo !LINE!| findstr /c:"-                     Class" >nul && set "NMT_SECTION=NonHeap"
	echo !LINE!| findstr /c:"-                    Thread" >nul && set "NMT_SECTION=Thread"
	echo !LINE!| findstr /c:"-                        GC" >nul && set "NMT_SECTION=GC"
	echo !LINE!| findstr /c:"-                      Code" >nul && set "NMT_SECTION=Code"
	if defined NMT_SECTION (
		echo !LINE!| findstr /c:"committed=" >nul && (
			if "!NMT_SECTION!"=="Heap" call :NMT_EXTRACT "!LINE!" jvmHeapKB & set "NMT_SECTION="
			if "!NMT_SECTION!"=="NonHeap" call :NMT_EXTRACT "!LINE!" jvmNonHeapKB & set "NMT_SECTION="
			if "!NMT_SECTION!"=="Thread" call :NMT_EXTRACT "!LINE!" jvmThreadKB & set "NMT_SECTION="
			if "!NMT_SECTION!"=="GC" call :NMT_EXTRACT "!LINE!" jvmGcKB & set "NMT_SECTION="
			if "!NMT_SECTION!"=="Code" call :NMT_EXTRACT "!LINE!" jvmCodeKB & set "NMT_SECTION="
		)
	)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:NMT_EXTRACT
:: %1 = line containing committed=NNN[KB|MB]
:: %2 = output variable name (stores KB)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "NX_LINE=%~1"
for /f "tokens=1,2 delims==KMBG " %%A in ('echo !NX_LINE!^| findstr /r /c:"committed=[0-9][0-9]*"') do (
	set "NX_VAL=%%B"
)
:: (Simplified: assume KB. Real jcmd output can be MB; would need unit detection.)
for /f "tokens=2 delims==" %%V in ('echo !NX_LINE!^| findstr /r /c:"committed=[0-9][0-9]*"') do (
	for /f "delims=KMBG " %%N in ("%%V") do set "%~2=%%N"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - Evaluate the memory usage.
echo usage: %PN% [OPTION]
echo\
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  -q                   Suppress header
echo  -ts                  Add timestamp as first column
echo  -jvm                 Show JVM memory details (requires -pid, NativeMemoryTracking enabled)
echo  -b                   Format in bytes
echo  -k                   Format in kilo bytes
echo  -m                   Format in mega bytes
echo  -g                   Format in giga bytes
echo  -t                   Format in tera bytes
echo  -p                   Format in peta bytes
echo  -pid ^<pid^>           Filter a specific process
exit /b 0
