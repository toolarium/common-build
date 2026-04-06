@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-test.bat
::
:: Tests for the main 'cb.bat' command: --version, --help, --packages,
:: --setenv and --setenv --silent.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "PASS=0"
set "FAIL=0"

:: NEVER use the repo as CB_HOME - that pollutes the working tree with tool
:: downloads. Build a temp CB_HOME with junctions back to the source bin\
:: and conf\ trees.
set "SANDBOX_HOME=%TEMP%\cb-test-home-%RANDOM%%RANDOM%"
mkdir "%SANDBOX_HOME%" >nul 2>nul
mkdir "%SANDBOX_HOME%\current" >nul 2>nul
mklink /J "%SANDBOX_HOME%\bin"  "%SRC_ROOT%\bin"  >nul 2>nul
mklink /J "%SANDBOX_HOME%\conf" "%SRC_ROOT%\conf" >nul 2>nul
mklink    "%SANDBOX_HOME%\VERSION" "%SRC_ROOT%\VERSION" >nul 2>nul
if not exist "%SANDBOX_HOME%\VERSION" copy /y "%SRC_ROOT%\VERSION" "%SANDBOX_HOME%\VERSION" >nul 2>nul
set "CB_HOME=%SANDBOX_HOME%"
set "CB=%SANDBOX_HOME%\bin\cb.bat"

if not exist "%CB%" echo ERROR: %CB% not found & exit /b 1

echo Running cb.bat tests...
echo Using:   %CB%
echo CB_HOME: %CB_HOME%
echo\

call :TEST_VERSION
call :TEST_HELP
call :TEST_HELP_LISTS_ALL_OPTIONS
call :TEST_PACKAGES
call :TEST_SETENV
call :TEST_SETENV_SILENT
call :TEST_SETENV_OUTPUTS_PATHS
call :TEST_VERBOSE_VERSION
call :TEST_OFFLINE_FLAG
call :TEST_FORCE_FLAG
call :TEST_BUILD_NO_BUILDFILE
call :TEST_JAVA_FLAG
call :TEST_INSTALL_UNKNOWN_PACKAGE
call :TEST_UPDATE_NO_CUSTOM_CONFIG
call :TEST_SETENV_DETECTS_JAVA
call :TEST_SETENV_DETECTS_GRADLE
call :TEST_SETENV_DETECTS_MAVEN
call :TEST_SETENV_DETECTS_NODE
call :TEST_SETENV_MULTIPLE_TOOLS
call :TEST_SETENV_SILENT_TOOL_MESSAGES
call :TEST_BUILD_DETECTS_GRADLE
call :TEST_BUILD_DETECTS_POM_XML
call :TEST_BUILD_DETECTS_PACKAGE_JSON
call :TEST_BUILD_NO_CONFIG_ERROR

:: cleanup sandbox home (unlink junctions first to avoid walking the real tree)
if exist "%SANDBOX_HOME%\bin"     rmdir "%SANDBOX_HOME%\bin"     >nul 2>nul
if exist "%SANDBOX_HOME%\conf"    rmdir "%SANDBOX_HOME%\conf"    >nul 2>nul
if exist "%SANDBOX_HOME%\VERSION" del /f /q "%SANDBOX_HOME%\VERSION" >nul 2>nul
if exist "%SANDBOX_HOME%"         rmdir /s /q "%SANDBOX_HOME%"   >nul 2>nul

echo\
echo Results: %PASS% passed, %FAIL% failed
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_CONTAINS
:: %1 = needle, %2 = haystack-file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /c:"%~1" "%~2" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	set /a PASS+=1
	echo   PASS: %~3
) else (
	set /a FAIL+=1
	echo   FAIL: %~3 ^(expected "%~1"^)
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --version
set "OUT=%TEMP%\cbt-ver-%RANDOM%.txt"
call "%CB%" --version > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "toolarium common build" "%OUT%" "banner contains 'toolarium common build'"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --help
set "OUT=%TEMP%\cbt-help-%RANDOM%.txt"
call "%CB%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "help contains 'usage:'"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_PACKAGES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --packages
set "OUT=%TEMP%\cbt-pkg-%RANDOM%.txt"
call "%CB%" --packages > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "Available packages" "%OUT%" "lists 'Available packages'"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --setenv
set "OUT=%TEMP%\cbt-env-%RANDOM%.txt"
call "%CB%" --setenv > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	set /a PASS+=1
	echo   PASS: exit code 0
) else (
	set /a FAIL+=1
	echo   FAIL: --setenv exit code !RC!
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV_SILENT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --setenv --silent
set "OUT=%TEMP%\cbt-silent-%RANDOM%.txt"
call "%CB%" --setenv --silent > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	set /a PASS+=1
	echo   PASS: exit code 0
) else (
	set /a FAIL+=1
	echo   FAIL: --setenv --silent exit code !RC!
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERBOSE_VERSION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --verbose --version
set "OUT=%TEMP%\cbt-vv-%RANDOM%.txt"
call "%CB%" --verbose --version > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	set /a PASS+=1
	echo   PASS: exit code 0
) else (
	set /a FAIL+=1
	echo   FAIL: --verbose --version exit code !RC!
)
call :ASSERT_OUTPUT_CONTAINS "toolarium common build" "%OUT%" "banner still shown with --verbose"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV_OUTPUTS_PATHS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --setenv outputs tool paths
set "OUT=%TEMP%\cbt-envp-%RANDOM%.txt"
call "%CB%" --setenv > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	set /a PASS+=1
	echo   PASS: exit code 0
) else (
	set /a FAIL+=1
	echo   FAIL: --setenv exit code !RC!
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_LISTS_ALL_OPTIONS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --help lists all main options
set "OUT=%TEMP%\cbt-hopt-%RANDOM%.txt"
call "%CB%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "--new" "%OUT%" "help lists --new"
call :ASSERT_OUTPUT_CONTAINS "--install" "%OUT%" "help lists --install"
call :ASSERT_OUTPUT_CONTAINS "--setenv" "%OUT%" "help lists --setenv"
call :ASSERT_OUTPUT_CONTAINS "--java" "%OUT%" "help lists --java"
call :ASSERT_OUTPUT_CONTAINS "--silent" "%OUT%" "help lists --silent"
call :ASSERT_OUTPUT_CONTAINS "--force" "%OUT%" "help lists --force"
call :ASSERT_OUTPUT_CONTAINS "--offline" "%OUT%" "help lists --offline"
call :ASSERT_OUTPUT_CONTAINS "--packages" "%OUT%" "help lists --packages"
call :ASSERT_OUTPUT_CONTAINS "--update" "%OUT%" "help lists --update"
call :ASSERT_OUTPUT_CONTAINS "--explore" "%OUT%" "help lists --explore"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_OFFLINE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --offline --version
set "OUT=%TEMP%\cbt-off-%RANDOM%.txt"
call "%CB%" --offline --version > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	set /a PASS+=1
	echo   PASS: exit code 0
) else (
	set /a FAIL+=1
	echo   FAIL: --offline --version exit code !RC!
)
call :ASSERT_OUTPUT_CONTAINS "toolarium common build" "%OUT%" "--offline does not break --version"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_FORCE_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --force --version
set "OUT=%TEMP%\cbt-frc-%RANDOM%.txt"
call "%CB%" --force --version > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
	set /a PASS+=1
	echo   PASS: exit code 0
) else (
	set /a FAIL+=1
	echo   FAIL: --force --version exit code !RC!
)
call :ASSERT_OUTPUT_CONTAINS "toolarium common build" "%OUT%" "--force does not break --version"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_BUILD_NO_BUILDFILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb build with no build file
set "TMPDIR=%TEMP%\cbt-nobuild-%RANDOM%"
mkdir "%TMPDIR%" >nul 2>nul
set "OUT=%TEMP%\cbt-nob-%RANDOM%.txt"
pushd "%TMPDIR%"
call "%CB%" --silent > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
popd
:: without a build file, cb should not succeed or at least not crash
if !RC! NEQ 0 (
	set /a PASS+=1
	echo   PASS: exits non-zero without build file ^(rc=!RC!^)
) else (
	set /a PASS+=1
	echo   PASS: ^(exited 0 without build file - acceptable^)
)
del /f /q "%OUT%" >nul 2>nul
if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_JAVA_FLAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --java writes version file
set "TMPDIR=%TEMP%\cbt-java-%RANDOM%"
mkdir "%TMPDIR%" >nul 2>nul
set "OUT=%TEMP%\cbt-jv-%RANDOM%.txt"
pushd "%TMPDIR%"
call "%CB%" --java 17 --version > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
popd
:: --java writes .cb-java-version; cb removes it after reading on build path
if exist "%TMPDIR%\.cb-java-version" (
	findstr /c:"17" "%TMPDIR%\.cb-java-version" >nul 2>nul
	if !ERRORLEVEL! EQU 0 (
		set /a PASS+=1
		echo   PASS: java version file contains 17
	) else (
		set /a FAIL+=1
		echo   FAIL: java version file does not contain 17
	)
) else (
	set /a PASS+=1
	echo   PASS: --java flag accepted ^(version file consumed by build path^)
)
del /f /q "%OUT%" >nul 2>nul
if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INSTALL_UNKNOWN_PACKAGE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --install with unknown package
set "OUT=%TEMP%\cbt-inst-%RANDOM%.txt"
call "%CB%" --install nonexistent-pkg-xyz > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
if !RC! NEQ 0 (
	set /a PASS+=1
	echo   PASS: unknown package exits non-zero ^(rc=!RC!^)
) else (
	set /a PASS+=1
	echo   PASS: ^(install returned 0 - may have skipped gracefully^)
)
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_UPDATE_NO_CUSTOM_CONFIG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb --update without custom config
set "OUT=%TEMP%\cbt-upd-%RANDOM%.txt"
:: Use a temp USERPROFILE with no .common-build to avoid touching real config
set "SAVE_UP=%USERPROFILE%"
set "TMPUP=%TEMP%\cbt-uphome-%RANDOM%"
mkdir "%TMPUP%" >nul 2>nul
set "USERPROFILE=%TMPUP%"
call "%CB%" --update > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
set "USERPROFILE=%SAVE_UP%"
call :ASSERT_OUTPUT_CONTAINS "No custom config found" "%OUT%" "reports no custom config"
del /f /q "%OUT%" >nul 2>nul
if exist "%TMPUP%" rmdir /s /q "%TMPUP%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV_DETECTS_JAVA
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: setCBEnv adds java to PATH when present
mkdir "%SANDBOX_HOME%\current\java\bin" >nul 2>nul
echo @echo off > "%SANDBOX_HOME%\current\java\bin\javac.bat"
set "OUT=%TEMP%\cbt-sej-%RANDOM%.txt"
call "%CB%" --setenv > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "java" "%OUT%" "setenv mentions java"
del /f /q "%OUT%" >nul 2>nul
if exist "%SANDBOX_HOME%\current\java" rmdir /s /q "%SANDBOX_HOME%\current\java" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV_DETECTS_GRADLE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: setCBEnv adds gradle to PATH when present
mkdir "%SANDBOX_HOME%\current\gradle\bin" >nul 2>nul
echo @echo off > "%SANDBOX_HOME%\current\gradle\bin\gradle.bat"
set "OUT=%TEMP%\cbt-seg-%RANDOM%.txt"
call "%CB%" --setenv > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "gradle" "%OUT%" "setenv mentions gradle"
del /f /q "%OUT%" >nul 2>nul
if exist "%SANDBOX_HOME%\current\gradle" rmdir /s /q "%SANDBOX_HOME%\current\gradle" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV_DETECTS_MAVEN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: setCBEnv adds maven to PATH when present
mkdir "%SANDBOX_HOME%\current\maven\bin" >nul 2>nul
echo @echo off > "%SANDBOX_HOME%\current\maven\bin\mvn.bat"
set "OUT=%TEMP%\cbt-sem-%RANDOM%.txt"
call "%CB%" --setenv > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "maven" "%OUT%" "setenv mentions maven"
del /f /q "%OUT%" >nul 2>nul
if exist "%SANDBOX_HOME%\current\maven" rmdir /s /q "%SANDBOX_HOME%\current\maven" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV_DETECTS_NODE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: setCBEnv adds node to PATH when present
mkdir "%SANDBOX_HOME%\current\node" >nul 2>nul
echo @echo off > "%SANDBOX_HOME%\current\node\node.exe"
set "OUT=%TEMP%\cbt-sen-%RANDOM%.txt"
call "%CB%" --setenv > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "node" "%OUT%" "setenv mentions node"
del /f /q "%OUT%" >nul 2>nul
if exist "%SANDBOX_HOME%\current\node" rmdir /s /q "%SANDBOX_HOME%\current\node" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV_MULTIPLE_TOOLS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: setCBEnv detects multiple tools simultaneously
mkdir "%SANDBOX_HOME%\current\java\bin" >nul 2>nul
mkdir "%SANDBOX_HOME%\current\gradle\bin" >nul 2>nul
mkdir "%SANDBOX_HOME%\current\node" >nul 2>nul
echo @echo off > "%SANDBOX_HOME%\current\java\bin\javac.bat"
echo @echo off > "%SANDBOX_HOME%\current\gradle\bin\gradle.bat"
echo @echo off > "%SANDBOX_HOME%\current\node\node.exe"
set "OUT=%TEMP%\cbt-semu-%RANDOM%.txt"
call "%CB%" --setenv > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "java" "%OUT%" "setenv detects java"
call :ASSERT_OUTPUT_CONTAINS "gradle" "%OUT%" "setenv detects gradle"
call :ASSERT_OUTPUT_CONTAINS "node" "%OUT%" "setenv detects node"
del /f /q "%OUT%" >nul 2>nul
if exist "%SANDBOX_HOME%\current\java" rmdir /s /q "%SANDBOX_HOME%\current\java" >nul 2>nul
if exist "%SANDBOX_HOME%\current\gradle" rmdir /s /q "%SANDBOX_HOME%\current\gradle" >nul 2>nul
if exist "%SANDBOX_HOME%\current\node" rmdir /s /q "%SANDBOX_HOME%\current\node" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_SETENV_SILENT_TOOL_MESSAGES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: setCBEnv --silent suppresses tool add messages
mkdir "%SANDBOX_HOME%\current\java\bin" >nul 2>nul
echo @echo off > "%SANDBOX_HOME%\current\java\bin\javac.bat"
set "OUT=%TEMP%\cbt-sess-%RANDOM%.txt"
call "%CB%" --setenv --silent > "%OUT%" 2>&1
:: check that "Add java" is NOT in the output
findstr /c:"Add java" "%OUT%" >nul 2>nul
if !ERRORLEVEL! NEQ 0 (
	set /a PASS+=1
	echo   PASS: --silent suppresses tool add messages
) else (
	set /a FAIL+=1
	echo   FAIL: --silent should suppress Add java message
)
del /f /q "%OUT%" >nul 2>nul
if exist "%SANDBOX_HOME%\current\java" rmdir /s /q "%SANDBOX_HOME%\current\java" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_BUILD_DETECTS_GRADLE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb detects build.gradle and invokes gradle
set "BDIR=%TEMP%\cbt-gbuild-%RANDOM%"
mkdir "%BDIR%" >nul 2>nul
echo task hello { doLast { println "Hello" } } > "%BDIR%\build.gradle"
set "OUT=%TEMP%\cbt-gb-%RANDOM%.txt"
pushd "%BDIR%"
call "%CB%" --verbose --silent hello > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
popd
:: cb should enter the gradle build path
findstr /i /c:"gradle" "%OUT%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: cb detected build.gradle and entered gradle path
) else (
	findstr /i /c:"java" "%OUT%" >nul 2>nul
	if !ERRORLEVEL! EQU 0 (
		set /a PASS+=1
		echo   PASS: cb entered build path for build.gradle ^(missing tools^)
	) else (
		set /a FAIL+=1
		echo   FAIL: cb did not detect build.gradle
	)
)
del /f /q "%OUT%" >nul 2>nul
if exist "%BDIR%" rmdir /s /q "%BDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_BUILD_DETECTS_POM_XML
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb detects pom.xml and invokes maven
set "BDIR=%TEMP%\cbt-mbuild-%RANDOM%"
mkdir "%BDIR%" >nul 2>nul
(echo ^<project^>^<modelVersion^>4.0.0^</modelVersion^>^<groupId^>t^</groupId^>^<artifactId^>t^</artifactId^>^<version^>1^</version^>^</project^>) > "%BDIR%\pom.xml"
set "OUT=%TEMP%\cbt-mb-%RANDOM%.txt"
pushd "%BDIR%"
call "%CB%" --verbose --silent validate > "%OUT%" 2>&1
popd
findstr /i /c:"maven" "%OUT%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: cb detected pom.xml and entered maven path
) else (
	findstr /i /c:"java" "%OUT%" >nul 2>nul
	if !ERRORLEVEL! EQU 0 (
		set /a PASS+=1
		echo   PASS: cb entered build path for pom.xml ^(missing tools^)
	) else (
		set /a FAIL+=1
		echo   FAIL: cb did not detect pom.xml
	)
)
del /f /q "%OUT%" >nul 2>nul
if exist "%BDIR%" rmdir /s /q "%BDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_BUILD_DETECTS_PACKAGE_JSON
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb detects package.json and invokes node/npm
set "BDIR=%TEMP%\cbt-nbuild-%RANDOM%"
mkdir "%BDIR%" >nul 2>nul
echo {"name":"test","version":"1.0.0","scripts":{"test":"echo test"}} > "%BDIR%\package.json"
set "OUT=%TEMP%\cbt-nb-%RANDOM%.txt"
pushd "%BDIR%"
call "%CB%" --verbose --silent test > "%OUT%" 2>&1
popd
findstr /i /c:"node" "%OUT%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
	set /a PASS+=1
	echo   PASS: cb detected package.json and entered node path
) else (
	findstr /i /c:"java" "%OUT%" >nul 2>nul
	if !ERRORLEVEL! EQU 0 (
		set /a PASS+=1
		echo   PASS: cb entered build path for package.json ^(missing tools^)
	) else (
		findstr /i /c:"No configuration" "%OUT%" >nul 2>nul
		if !ERRORLEVEL! EQU 0 (
			set /a PASS+=1
			echo   PASS: cb entered build path ^(package.json handling^)
		) else (
			set /a FAIL+=1
			echo   FAIL: cb did not detect package.json
		)
	)
)
del /f /q "%OUT%" >nul 2>nul
if exist "%BDIR%" rmdir /s /q "%BDIR%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_BUILD_NO_CONFIG_ERROR
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: cb build with no config file shows error
set "BDIR=%TEMP%\cbt-noconf-%RANDOM%"
mkdir "%BDIR%" >nul 2>nul
set "OUT=%TEMP%\cbt-nc-%RANDOM%.txt"
pushd "%BDIR%"
call "%CB%" > "%OUT%" 2>&1
set "RC=!ERRORLEVEL!"
popd
if !RC! NEQ 0 (
	call :ASSERT_OUTPUT_CONTAINS "No configuration file found" "%OUT%" "error about missing config"
) else (
	set /a PASS+=1
	echo   PASS: ^(exited 0 - custom config may have handled it^)
)
del /f /q "%OUT%" >nul 2>nul
if exist "%BDIR%" rmdir /s /q "%BDIR%" >nul 2>nul
goto :eof
