@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-cleanup-test.bat
::
:: Tests for cb-cleanup.bat. Sets up a fake USERPROFILE tree containing
:: a .gradle/common-gradle-build folder with known version directories,
:: then runs cb-cleanup.bat against it to verify the --dry-run mode and
:: that --cgb deletes exactly the versions returned by
:: cb-version-filter.bat --invertFilter.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "CLEANUP=%SRC_ROOT%\bin\cb-cleanup.bat"
set "VERSION_FILTER=%SRC_ROOT%\bin\cb-version-filter.bat"
set "TEST_ROOT=%TEMP%\cb-cleanup-test-%RANDOM%%RANDOM%"
set "PASS=0"
set "FAIL=0"

if not exist "%CLEANUP%" echo ERROR: %CLEANUP% not found & exit /b 1
if not exist "%VERSION_FILTER%" echo ERROR: %VERSION_FILTER% not found & exit /b 1

echo Running cb-cleanup.bat tests...
echo Using: %CLEANUP%
echo.

if exist "%TEST_ROOT%" rmdir /s /q "%TEST_ROOT%" >nul 2>nul
mkdir "%TEST_ROOT%" >nul 2>nul

call :TEST_HELP
call :TEST_H_SHORT
call :TEST_INVALID_ARG
call :TEST_DRY_RUN_BANNER_AND_NO_DELETE
call :TEST_CGB_DELETES_PER_VERSION_FILTER
call :TEST_SILENT_SUPPRESSES_BANNER
call :TEST_PATH_PATTERN_DRY_RUN
call :TEST_CB_DELETES_LOGS
call :TEST_LOG_UNTIL_THRESHOLD
call :TEST_GRADLE_CACHE_THRESHOLD
call :TEST_DOCKER_IMAGE_ARG_PARSING
call :TEST_DOCKER_SYSTEM_ARG_PARSING
call :TEST_NPM_ARG_PARSING
call :TEST_DEFAULT_MODE

if exist "%TEST_ROOT%" rmdir /s /q "%TEST_ROOT%" >nul 2>nul

echo.
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_EQ
:: %1 = expected, %2 = actual, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
set "_EXP=%~1"
set "_ACT=%~2"
if "%~1"=="%~2" (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [expected=!_EXP!, got=!_ACT!]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_CONTAINS
:: %1 = needle, %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
set "_NEEDLE=%~1"
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [missing: !_NEEDLE!]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_NOT_CONTAINS
:: %1 = needle, %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~3"
set "_NEEDLE=%~1"
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [found unexpected: !_NEEDLE!]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_DIR_EXISTS
:: %1 = directory, %2 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~2"
if exist "%~1\" (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [missing dir: %~1]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_DIR_MISSING
:: %1 = directory, %2 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_MSG=%~2"
if not exist "%~1\" (
	set /a PASS+=1
	echo   PASS: !_MSG!
) else (
	set /a FAIL+=1
	echo   FAIL: !_MSG! [dir still exists: %~1]
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SETUP_FAKE_HOME
:: %1 = output variable name to receive the fake HOME path
:: %2..%9 = version directories to create (up to 8)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_HOME=%TEST_ROOT%\home-%RANDOM%"
mkdir "%_HOME%\.gradle\common-gradle-build" >nul 2>nul
mkdir "%_HOME%\.gradle\daemon" >nul 2>nul
mkdir "%_HOME%\.gradle\caches" >nul 2>nul
set "%~1=%_HOME%"
:SETUP_LOOP
shift
if "%~1"=="" goto :eof
mkdir "%_HOME%\.gradle\common-gradle-build\%~1" >nul 2>nul
echo content > "%_HOME%\.gradle\common-gradle-build\%~1\marker.txt" 2>nul
goto SETUP_LOOP


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help
set "OUT=%TEST_ROOT%\help.txt"
call "%CLEANUP%" --help > "%OUT%" 2>&1
call :ASSERT_CONTAINS "Cleanup common-build" "%OUT%" "help mentions purpose"
call :ASSERT_CONTAINS "--cb " "%OUT%" "help lists --cb"
call :ASSERT_CONTAINS "--cgb" "%OUT%" "help lists --cgb"
call :ASSERT_CONTAINS "--dry-run" "%OUT%" "help lists --dry-run"
call :ASSERT_CONTAINS "--silent" "%OUT%" "help lists --silent"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_H_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -h
set "OUT=%TEST_ROOT%\h.txt"
call "%CLEANUP%" -h > "%OUT%" 2>&1
call :ASSERT_CONTAINS "Cleanup common-build" "%OUT%" "-h shows help"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_ARG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: invalid argument rejected
set "OUT=%TEST_ROOT%\inv.txt"
call "%CLEANUP%" --not-a-real-flag > "%OUT%" 2>&1
call :ASSERT_CONTAINS "Invalid parameter" "%OUT%" "error message shown"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DRY_RUN_BANNER_AND_NO_DELETE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --dry-run prints banner and does not delete
call :SETUP_FAKE_HOME HOME_A 1.0.0 1.0.1 1.0.2 1.1.0 1.1.1 2.0.0 2.0.1 2.1.0
set "OUT=%TEST_ROOT%\dry.txt"
set "CB_HOME=%SRC_ROOT%"
set "USERPROFILE=!HOME_A!"
call "%CLEANUP%" --cgb --dry-run > "%OUT%" 2>&1
call :ASSERT_CONTAINS "DRY-RUN mode" "%OUT%" "dry-run banner printed"
call :ASSERT_CONTAINS "[DRY-RUN] Would delete" "%OUT%" "dry-run marker printed per version"
set "CGB=!HOME_A!\.gradle\common-gradle-build"
call :ASSERT_DIR_EXISTS "!CGB!\1.0.0" "1.0.0 not deleted in dry-run"
call :ASSERT_DIR_EXISTS "!CGB!\1.0.1" "1.0.1 not deleted in dry-run"
call :ASSERT_DIR_EXISTS "!CGB!\1.0.2" "1.0.2 not deleted in dry-run"
call :ASSERT_DIR_EXISTS "!CGB!\1.1.0" "1.1.0 not deleted in dry-run"
call :ASSERT_DIR_EXISTS "!CGB!\1.1.1" "1.1.1 not deleted in dry-run"
call :ASSERT_DIR_EXISTS "!CGB!\2.0.0" "2.0.0 not deleted in dry-run"
call :ASSERT_DIR_EXISTS "!CGB!\2.0.1" "2.0.1 not deleted in dry-run"
call :ASSERT_DIR_EXISTS "!CGB!\2.1.0" "2.1.0 not deleted in dry-run"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_CGB_DELETES_PER_VERSION_FILTER
:: Real delete. Verifies that versions listed by --invertFilter are gone
:: and the rest are still on disk.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --cgb deletes exactly the versions from cb-version-filter --invertFilter
call :SETUP_FAKE_HOME HOME_B 1.0.0 1.0.1 1.0.2 1.1.0 1.1.1 2.0.0 2.0.1 2.1.0
set "CGB=!HOME_B!\.gradle\common-gradle-build"

:: ask version-filter what to delete (authoritative) and save to a file
set "TO_DELETE=%TEST_ROOT%\to-delete.txt"
call "%VERSION_FILTER%" --path "!CGB!" --majorThreshold 2 --minorThreshold 2 --patchThreshold 2 --previousMajorPatchThreshold 1 --previousMajorMinorThreshold 1 --majorMinorMax 10 --invertFilter > "!TO_DELETE!" 2>nul

:: run real delete
set "CB_HOME=%SRC_ROOT%"
set "USERPROFILE=!HOME_B!"
call "%CLEANUP%" --cgb > nul 2>&1

:: every version marked for deletion must now be gone
for /f "usebackq delims=" %%V in ("!TO_DELETE!") do (
	if not "%%V"=="" call :ASSERT_DIR_MISSING "!CGB!\%%V" "deleted %%V (matches --invertFilter)"
)

:: keep list = all versions NOT in the to-delete file
for %%V in (1.0.0 1.0.1 1.0.2 1.1.0 1.1.1 2.0.0 2.0.1 2.1.0) do (
	findstr /x /c:"%%V" "!TO_DELETE!" >nul 2>nul
	if !ERRORLEVEL! NEQ 0 call :ASSERT_DIR_EXISTS "!CGB!\%%V" "kept %%V (NOT in --invertFilter output)"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SILENT_SUPPRESSES_BANNER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --silent --dry-run omits the DRY-RUN mode banner
call :SETUP_FAKE_HOME HOME_C 1.0.0 2.0.0
set "OUT=%TEST_ROOT%\silent.txt"
set "CB_HOME=%SRC_ROOT%"
set "USERPROFILE=!HOME_C!"
call "%CLEANUP%" --cgb --dry-run --silent > "%OUT%" 2>&1
call :ASSERT_NOT_CONTAINS "DRY-RUN mode" "%OUT%" "--silent suppresses DRY-RUN banner"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SETUP_FAKE_CB_HOME
:: %1 = output variable name, receives the fake CB_HOME path
:: Creates bin/cb-clean-files.bat (copy) + empty logs/.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_CBH=%TEST_ROOT%\cbhome-%RANDOM%"
mkdir "%_CBH%\bin" >nul 2>nul
mkdir "%_CBH%\logs" >nul 2>nul
copy /y "%SRC_ROOT%\bin\cb-clean-files.bat" "%_CBH%\bin\cb-clean-files.bat" >nul 2>nul
set "%~1=%_CBH%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:BACKDATE
:: %1 = file path, %2 = days to backdate
:: Uses PowerShell to set LastWriteTime.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
powershell -NoProfile -Command "(Get-Item -LiteralPath '%~1').LastWriteTime = (Get-Date).AddDays(-%~2)" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PATH_PATTERN_DRY_RUN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --path/--pattern --dry-run doesn't delete matching files
set "TDIR=%TEST_ROOT%\pp-%RANDOM%"
mkdir "%TDIR%" >nul 2>nul
echo x > "%TDIR%\old-a.log"
echo x > "%TDIR%\keep.txt"
call :BACKDATE "%TDIR%\old-a.log" 10
set "OUT=%TEST_ROOT%\pp.txt"
set "CB_HOME=%SRC_ROOT%"
call "%CLEANUP%" --path "%TDIR%" --pattern "*.log" --log-until 1 --dry-run > "%OUT%" 2>&1
call :ASSERT_CONTAINS "DRY-RUN" "%OUT%" "dry-run marker in output"
call :ASSERT_DIR_EXISTS "%TDIR%" "target dir still present"
if exist "%TDIR%\old-a.log" (
	set /a PASS+=1
	echo   PASS: old-a.log kept on dry-run
) else (
	set /a FAIL+=1
	echo   FAIL: old-a.log was deleted on dry-run
)
if exist "%TDIR%\keep.txt" (
	set /a PASS+=1
	echo   PASS: keep.txt untouched
) else (
	set /a FAIL+=1
	echo   FAIL: keep.txt missing
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_CB_DELETES_LOGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --cb deletes old log files via cb-clean-files
call :SETUP_FAKE_CB_HOME FAKE_CBH
set "FAKE_TMP=%TEST_ROOT%\cbtmp-%RANDOM%"
mkdir "%FAKE_TMP%" >nul 2>nul
echo x > "!FAKE_CBH!\logs\old.log"
echo x > "!FAKE_CBH!\logs\fresh.log"
echo x > "%FAKE_TMP%\old.tmp"
call :BACKDATE "!FAKE_CBH!\logs\old.log" 10
call :BACKDATE "%FAKE_TMP%\old.tmp" 10
set "CB_HOME=!FAKE_CBH!"
set "CB_TEMP=%FAKE_TMP%"
call "%CLEANUP%" --cb --silent >nul 2>&1
if not exist "!FAKE_CBH!\logs\old.log" (
	set /a PASS+=1
	echo   PASS: old log deleted by --cb
) else (
	set /a FAIL+=1
	echo   FAIL: old log not deleted by --cb
)
if exist "!FAKE_CBH!\logs\fresh.log" (
	set /a PASS+=1
	echo   PASS: fresh log kept by --cb
) else (
	set /a FAIL+=1
	echo   FAIL: fresh log deleted by --cb
)
if not exist "%FAKE_TMP%\old.tmp" (
	set /a PASS+=1
	echo   PASS: old CB_TEMP file deleted by --cb
) else (
	set /a FAIL+=1
	echo   FAIL: old CB_TEMP file not deleted by --cb
)
set "CB_TEMP="
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_LOG_UNTIL_THRESHOLD
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --log-until threshold honored
call :SETUP_FAKE_CB_HOME FAKE_CBH
set "FAKE_TMP=%TEST_ROOT%\cbtmp2-%RANDOM%"
mkdir "%FAKE_TMP%" >nul 2>nul
echo x > "%FAKE_TMP%\twoday.log"
echo x > "%FAKE_TMP%\tenday.log"
call :BACKDATE "%FAKE_TMP%\twoday.log" 2
call :BACKDATE "%FAKE_TMP%\tenday.log" 10
set "CB_HOME=!FAKE_CBH!"
set "CB_TEMP=%FAKE_TMP%"
call "%CLEANUP%" --cb --log-until 5 --silent >nul 2>&1
if not exist "%FAKE_TMP%\tenday.log" (
	set /a PASS+=1
	echo   PASS: 10-day file deleted at --log-until 5
) else (
	set /a FAIL+=1
	echo   FAIL: 10-day file should have been deleted
)
if exist "%FAKE_TMP%\twoday.log" (
	set /a PASS+=1
	echo   PASS: 2-day file kept at --log-until 5
) else (
	set /a FAIL+=1
	echo   FAIL: 2-day file should have been kept
)
set "CB_TEMP="
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_GRADLE_CACHE_THRESHOLD
:: Verify --gradle-cache value reaches %USERPROFILE%\.gradle\caches.
:: cb-clean-files --dry-run prints 'Would delete N file(s)' -- check the count.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --gradle-cache threshold reaches .gradle\caches
call :SETUP_FAKE_HOME HOME_G 1.0.0 2.0.0
echo x > "!HOME_G!\.gradle\caches\old.bin"
call :BACKDATE "!HOME_G!\.gradle\caches\old.bin" 60
set "CB_HOME=%SRC_ROOT%"
set "USERPROFILE=!HOME_G!"
set "OUT_HI=%TEST_ROOT%\gchi.txt"
set "OUT_LO=%TEST_ROOT%\gclo.txt"
call "%CLEANUP%" --cgb --gradle-cache 90 --dry-run > "!OUT_HI!" 2>&1
call "%CLEANUP%" --cgb --gradle-cache 5 --dry-run > "!OUT_LO!" 2>&1
:: @ threshold 90: the caches clean-files block should report "Would delete 0 file"
findstr /c:"caches" "!OUT_HI!" >nul 2>nul
findstr /c:"Would delete 0 file" "!OUT_HI!" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: 60-day file not counted at --gradle-cache 90
) else (
	set /a FAIL+=1
	echo   FAIL: --gradle-cache 90 should skip 60-day file
)
:: @ threshold 5: should NOT be "Would delete 0 file" (i.e. the number is >=1)
findstr /c:"caches" "!OUT_LO!" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	findstr /c:"Would delete 0 file" "!OUT_LO!" >nul 2>nul
	if !ERRORLEVEL! EQU 0 (
		:: all counts are zero -> caches file not counted; fail
		findstr /c:"Would delete 1 file" "!OUT_LO!" >nul 2>nul
		if !ERRORLEVEL! EQU 0 (
			set /a PASS+=1
			echo   PASS: 60-day file counted at --gradle-cache 5
		) else (
			set /a FAIL+=1
			echo   FAIL: --gradle-cache 5 should count 60-day file
		)
	) else (
		set /a PASS+=1
		echo   PASS: 60-day file counted at --gradle-cache 5
	)
) else (
	set /a FAIL+=1
	echo   FAIL: caches cleanup not invoked
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DOCKER_IMAGE_ARG_PARSING
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --docker-image / --docker-image-until accepted by parser
set "OUT=%TEST_ROOT%\di.txt"
set "CB_HOME=%SRC_ROOT%"
call "%CLEANUP%" --docker-image --docker-image-until 48 --dry-run > "%OUT%" 2>&1
call :ASSERT_NOT_CONTAINS "Invalid parameter" "%OUT%" "--docker-image / --docker-image-until parse cleanly"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DOCKER_SYSTEM_ARG_PARSING
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --docker-system / --docker-system-until accepted by parser
set "OUT=%TEST_ROOT%\ds.txt"
set "CB_HOME=%SRC_ROOT%"
call "%CLEANUP%" --docker-system --docker-system-until 72 --dry-run > "%OUT%" 2>&1
call :ASSERT_NOT_CONTAINS "Invalid parameter" "%OUT%" "--docker-system / --docker-system-until parse cleanly"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NPM_ARG_PARSING
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --npm accepted by parser
set "OUT=%TEST_ROOT%\npm.txt"
set "CB_HOME=%SRC_ROOT%"
call "%CLEANUP%" --npm --dry-run > "%OUT%" 2>&1
call :ASSERT_NOT_CONTAINS "Invalid parameter" "%OUT%" "--npm parses cleanly"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_DEFAULT_MODE
:: no args triggers the argCount==0 default branch (cb + cgb + docker-image).
:: Cannot combine with --dry-run (that would make argCount > 0), so point
:: every path at a fresh empty fake tree.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: no args runs default targets (cb + cgb + docker-image)
call :SETUP_FAKE_CB_HOME FAKE_CBH
call :SETUP_FAKE_HOME HOME_D 2.0.0
set "FAKE_TMP=%TEST_ROOT%\defaulttmp-%RANDOM%"
mkdir "%FAKE_TMP%" >nul 2>nul
set "OUT=%TEST_ROOT%\default.txt"
set "CB_HOME=!FAKE_CBH!"
set "CB_TEMP=%FAKE_TMP%"
set "USERPROFILE=!HOME_D!"
call "%CLEANUP%" > "%OUT%" 2>&1
call :ASSERT_CONTAINS "Cleanup" "%OUT%" "default mode invokes Cleanup targets"
call :ASSERT_CONTAINS "common-gradle-build" "%OUT%" "default mode invokes --cgb branch"
set "CB_TEMP="
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
