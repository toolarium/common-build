@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-project-test.bat
::
:: Tests project scaffolding via 'cb.bat --new' for every project type
:: defined in conf/project-types.properties, then optionally runs the
:: build via 'cb' in the created project directory.
::
:: Tool prerequisites (java, gradle, node) are linked from external
:: installs or installed into the temp sandbox - NEVER into the repo.
::
:: Gates:
::   default                       scaffold-only for Groups A+B
::   CB_PROJECT_TEST_BUILD=1       add build phase for A+B
::   CB_PROJECT_TEST_NETWORK=1     add Group C (vuejs, nuxtjs, react)
::   both                          full matrix
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "PASS=0"
set "FAIL=0"
set "SKIP=0"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Build a sandbox CB_HOME (never use the repo)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "SANDBOX_HOME=%TEMP%\cb-project-home-%RANDOM%%RANDOM%"
mkdir "%SANDBOX_HOME%" >nul 2>nul
mkdir "%SANDBOX_HOME%\current" >nul 2>nul
mklink /J "%SANDBOX_HOME%\bin"  "%SRC_ROOT%\bin"  >nul 2>nul
mklink /J "%SANDBOX_HOME%\conf" "%SRC_ROOT%\conf" >nul 2>nul
mklink    "%SANDBOX_HOME%\VERSION" "%SRC_ROOT%\VERSION" >nul 2>nul
if not exist "%SANDBOX_HOME%\VERSION" copy /y "%SRC_ROOT%\VERSION" "%SANDBOX_HOME%\VERSION" >nul 2>nul
set "CB_HOME=%SANDBOX_HOME%"
set "CB=%SANDBOX_HOME%\bin\cb.bat"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Link external tools or install via cb into sandbox
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo Setting up sandbox tools...

:: --- Java ---
set "HAS_JAVA=false"
echo   -^> installing java via cb --install into sandbox...
call "%CB%" --silent --install java --default >nul 2>&1
if exist "%SANDBOX_HOME%\current\java\bin" set "HAS_JAVA=true"

:: --- Gradle ---
set "HAS_GRADLE=false"
echo   -^> installing gradle via cb --install into sandbox...
call "%CB%" --silent --install gradle --default >nul 2>&1
if exist "%SANDBOX_HOME%\current\gradle\bin" set "HAS_GRADLE=true"

:: --- Node (only when CB_PROJECT_TEST_NETWORK=1) ---
set "HAS_NODE=false"
if "%CB_PROJECT_TEST_NETWORK%"=="1" (
	echo   -^> installing node via cb --install into sandbox...
	call "%CB%" --silent --install node --default >nul 2>&1
	if exist "%SANDBOX_HOME%\current\node" set "HAS_NODE=true"
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Sandbox for project creation
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "SANDBOX=%TEMP%\cb-project-test-%RANDOM%%RANDOM%"
mkdir "%SANDBOX%" >nul 2>nul
set "LOGDIR=%SANDBOX%\logs"
mkdir "%LOGDIR%" >nul 2>nul
if not exist "%SANDBOX%" echo ERROR: could not create sandbox %SANDBOX% & exit /b 1
if not exist "%CB%" echo ERROR: %CB% not found & call :CLEANUP_ALL & exit /b 1

if "!HAS_JAVA!"=="false" (
	echo FAIL: java not available - cb --install java failed.
	call :CLEANUP_ALL
	exit /b 1
)
if "!HAS_GRADLE!"=="false" (
	echo FAIL: gradle not available - cb --install gradle failed.
	call :CLEANUP_ALL
	exit /b 1
)

echo\
echo Running cb.bat project-creation tests...
echo Using:   %CB%
echo CB_HOME: %CB_HOME%
echo Sandbox: %SANDBOX%
echo Java:    !HAS_JAVA!  Gradle: !HAS_GRADLE!  Node: !HAS_NODE!
echo Flags:   BUILD=%CB_PROJECT_TEST_BUILD%  NETWORK=%CB_PROJECT_TEST_NETWORK%
echo\
echo =========================================
echo Group A+B: Gradle-based project types
echo =========================================
echo\

:: Group A - Gradle + Java
call :RUN_TYPE  1  "my-test"                     "java-application"    my.rootpackage.name my my test-description
call :RUN_TYPE  2  "my-lib"                      "java-library"        my.rootpackage.name my my test-description
call :RUN_TYPE  5  "my-test-service-api-spec"    "openapi"             my.rootpackage.name my my test-description
call :RUN_TYPE  6  "my-test-service"             "quarkus"             my.rootpackage.name my my test-description

:: Group B - Gradle-only
call :RUN_TYPE  3  "my-test-config"              "config"              my my test-description
call :RUN_TYPE  4  "my-test-bin"                 "script"              my test-description
call :RUN_TYPE  10 "my-test-app"                 "kubernetes-product"  my my test-description
call :RUN_TYPE  11 "my-test-documentation"       "documentation"       my test-description
call :RUN_TYPE  12 "my-test-container"           "container"           my test-description
call :RUN_TYPE  13 "my-test-org-config"          "organization-config" my test-description

if "%CB_PROJECT_TEST_NETWORK%"=="1" if "!HAS_NODE!"=="false" (
	echo FAIL: node not available - cb --install node failed.
	call :CLEANUP_ALL
	exit /b 1
)
if "%CB_PROJECT_TEST_NETWORK%"=="1" (
	echo\
	echo =========================================
	echo Group C: Node-based project types
	echo =========================================
	echo\
	call :RUN_TYPE 7  "my-test-vue-ui"   "vuejs"  my test-description
	call :RUN_TYPE 8  "my-test-nuxt-ui"  "nuxtjs" my test-description
	call :RUN_TYPE 9  "my-test-react-ui" "react"  my test-description
) else (
	echo\
	echo SKIP: Group C - vuejs, nuxtjs, react - set CB_PROJECT_TEST_NETWORK=1
	set /a SKIP+=3
)

call :CLEANUP_ALL

echo\
echo =========================================
echo Results: %PASS% passed, %FAIL% failed, %SKIP% skipped
echo =========================================
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CLEANUP_ALL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%SANDBOX%" rmdir /s /q "%SANDBOX%" >nul 2>nul
if exist "%SANDBOX_HOME%\bin"             rmdir "%SANDBOX_HOME%\bin"             >nul 2>nul
if exist "%SANDBOX_HOME%\conf"            rmdir "%SANDBOX_HOME%\conf"            >nul 2>nul
if exist "%SANDBOX_HOME%\VERSION"         del /f /q "%SANDBOX_HOME%\VERSION"     >nul 2>nul
if exist "%SANDBOX_HOME%\current\java"    rmdir "%SANDBOX_HOME%\current\java"    >nul 2>nul
if exist "%SANDBOX_HOME%\current\gradle"  rmdir "%SANDBOX_HOME%\current\gradle"  >nul 2>nul
if exist "%SANDBOX_HOME%\current\node"    rmdir "%SANDBOX_HOME%\current\node"    >nul 2>nul
if exist "%SANDBOX_HOME%"                 rmdir /s /q "%SANDBOX_HOME%"           >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RUN_TYPE
:: %1 = type id, %2 = project name, %3 = label, %4..%* = extra args
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "TYPE_ID=%~1"
set "PROJECT_NAME=%~2"
set "LABEL=%~3"
set "EXTRA=%4 %5 %6 %7 %8 %9"
set "SUB_DIR=%SANDBOX%\type!TYPE_ID!-!LABEL!"
set "PROJECT_DIR=!SUB_DIR!\!PROJECT_NAME!"
mkdir "!SUB_DIR!" >nul 2>nul

echo TEST: cb --new !TYPE_ID! ^(!LABEL!^)

:: Phase 1: scaffold
pushd "!SUB_DIR!" >nul 2>nul
call "%CB%" --new !TYPE_ID! !PROJECT_NAME! !EXTRA! >nul 2>&1
popd >nul 2>nul
call :ASSERT_DIR_EXISTS    "!PROJECT_DIR!"  "scaffold: project directory created"
call :ASSERT_SCAFFOLD_FILE "!PROJECT_DIR!"  "scaffold: file present"

:: Phase 2: build (optional)
if not "%CB_PROJECT_TEST_BUILD%"=="1" (
	set /a SKIP+=1
	echo   SKIP: build phase - set CB_PROJECT_TEST_BUILD=1
	goto :eof
)
if not exist "!PROJECT_DIR!\" goto :eof
if "!HAS_GRADLE!"=="true" goto :DO_BUILD
if "!HAS_NODE!"=="true" goto :DO_BUILD
set /a SKIP+=1
echo   SKIP: build phase - gradle/node not available
goto :eof

:DO_BUILD
set "BUILD_LOG=%LOGDIR%\build-type!TYPE_ID!-!LABEL!.log"
pushd "!PROJECT_DIR!" >nul 2>nul
call "%CB%" --silent > "!BUILD_LOG!" 2>&1
set "BUILD_RC=!ERRORLEVEL!"
popd >nul 2>nul
if "!BUILD_RC!"=="0" (
	set /a PASS+=1
	echo   PASS: build: cb exit 0
) else (
	set /a FAIL+=1
	echo   FAIL: build: cb exit !BUILD_RC! - log: !BUILD_LOG!
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_DIR_EXISTS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if exist "%~1\" (
	set /a PASS+=1
	echo   PASS: %~2
) else (
	set /a FAIL+=1
	echo   FAIL: %~2 - dir missing: %~1
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_SCAFFOLD_FILE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
for %%F in (build.gradle settings.gradle README.md package.json) do (
	if exist "%~1\%%F" (
		set /a PASS+=1
		echo   PASS: %~2 ^(%%F^)
		goto :eof
	)
)
set /a FAIL+=1
echo   FAIL: %~2 - no scaffold file in %~1
goto :eof
