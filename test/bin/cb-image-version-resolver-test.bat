@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-image-version-resolver-test.bat
::
:: Tests for cb-image-version-resolver.bat.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "SRC_ROOT=%%~fI"
set "SCRIPT=%SRC_ROOT%\bin\cb-image-version-resolver.bat"
set "PASS=0"
set "FAIL=0"
set "SKIP=0"

if not exist "%SCRIPT%" echo ERROR: %SCRIPT% not found & exit /b 1
if not exist "%TEMP%\cb\" mkdir "%TEMP%\cb" >nul 2>nul

echo Running cb-image-version-resolver.bat tests...
echo Using: %SCRIPT%
echo\

echo === Error / usage tests ===
call :TEST_NO_ARGS
call :TEST_HELP_SHORT
call :TEST_HELP_LONG
call :TEST_TOO_MANY_ARGS
call :TEST_UNKNOWN_OPTION
call :TEST_REGISTRY_MISSING_URL
call :TEST_REGISTRY_HELP_DOCUMENTS_OPTION
call :TEST_REGISTRY_URL_VIA_ENV

echo\
echo === Live resolution tests ===
powershell -NoProfile -Command "exit 0" >nul 2>nul
if !ERRORLEVEL! NEQ 0 (
    echo   SKIP: PowerShell not available - skipping all live tests
    set /a SKIP+=13
    goto RESULTS
)
powershell -NoProfile -Command ^
  "(Invoke-RestMethod -Uri 'https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/alpine:pull').token" >nul 2>nul
if !ERRORLEVEL! NEQ 0 (
    echo   SKIP: Docker Hub not reachable - skipping all live tests
    set /a SKIP+=13
    goto RESULTS
)
call :TEST_ALPINE_LATEST
call :TEST_ALPINE_COLON_FORM
call :TEST_ALPINE_TWO_ARG_FORM
call :TEST_NODE_LATEST
call :TEST_ECLIPSE_TEMURIN_25_JRE_ALPINE
call :TEST_ECLIPSE_TEMURIN_25_JDK_ALPINE
call :TEST_JRE_JDK_DIFFERENT
call :TEST_VERIFY_VALID_DIGEST
call :TEST_VERIFY_WRONG_DIGEST
call :TEST_INVALID_IMAGE
call :TEST_INVALID_TAG
call :TEST_NGINX_ALPINE_VARIANT
call :TEST_NGINX_STABLE_ALPINE

:RESULTS
echo\
echo Results: %PASS% passed, %FAIL% failed, %SKIP% skipped
if %FAIL% EQU 0 (exit /b 0) else (exit /b 1)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_EXIT_CODE
:: %1 = expected, %2 = actual, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if "%~1"=="%~2" (
    set /a PASS+=1
    echo   PASS: %~3
) else (
    set /a FAIL+=1
    echo   FAIL: %~3 - expected exit %~1, got %~2
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_CONTAINS
:: %1 = needle, %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /c:"%~1" "%~2" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
    set /a PASS+=1
    echo   PASS: %~3
) else (
    set /a FAIL+=1
    echo   FAIL: %~3 - missing: %~1
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_NOT_CONTAINS
:: %1 = needle, %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
findstr /c:"%~1" "%~2" >nul 2>nul
if !ERRORLEVEL! NEQ 0 (
    set /a PASS+=1
    echo   PASS: %~3
) else (
    set /a FAIL+=1
    echo   FAIL: %~3 - should not contain: %~1
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ASSERT_OUTPUT_MATCHES_DIGEST
:: checks that a line in %2 contains %1 followed by @sha256:<hex>
:: %1 = image prefix (e.g. "alpine:"), %2 = file, %3 = message
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "_match=false"
for /f "usebackq tokens=*" %%L in ("%~2") do (
    echo %%L | findstr /r /c:"%~1.*@sha256:[0-9a-f]" >nul 2>nul
    if !ERRORLEVEL! EQU 0 set "_match=true"
)
if "!_match!"=="true" (
    set /a PASS+=1
    echo   PASS: %~3
) else (
    set /a FAIL+=1
    echo   FAIL: %~3 - no line matching %~1...@sha256:... found
    type "%~2"
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NO_ARGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: no arguments -^> exit 1 with usage
set "OUT=%TEMP%\cb\cb-image-version-resolver-noargs-%RANDOM%.txt"
call "%SCRIPT%" > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!_RC!" "no args exits with code 1"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "usage line printed"
call :ASSERT_OUTPUT_CONTAINS "resolve" "%OUT%" "description printed"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_SHORT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: -h -^> exit 1 with usage
set "OUT=%TEMP%\cb\cb-image-version-resolver-hs-%RANDOM%.txt"
call "%SCRIPT%" -h > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!_RC!" "-h exits with code 1"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "usage line printed"
call :ASSERT_OUTPUT_CONTAINS "Examples" "%OUT%" "examples section printed"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_HELP_LONG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help -^> exit 1 with usage
set "OUT=%TEMP%\cb\cb-image-version-resolver-hl-%RANDOM%.txt"
call "%SCRIPT%" --help > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!_RC!" "--help exits with code 1"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "usage line printed"
call :ASSERT_OUTPUT_CONTAINS "Examples" "%OUT%" "examples section printed"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_TOO_MANY_ARGS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: three arguments -^> exit 1 with invalid parameter message
set "OUT=%TEMP%\cb\cb-image-version-resolver-tma-%RANDOM%.txt"
call "%SCRIPT%" alpine latest extra > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!_RC!" "three args exits with code 1"
call :ASSERT_OUTPUT_CONTAINS "Invalid parameter:" "%OUT%" "invalid parameter message printed"
call :ASSERT_OUTPUT_CONTAINS "usage:" "%OUT%" "usage line printed"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_UNKNOWN_OPTION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: unknown option -^> exit 1 with invalid parameter message
set "OUT=%TEMP%\cb\cb-image-version-resolver-uo-%RANDOM%.txt"
call "%SCRIPT%" --unknown alpine > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!_RC!" "unknown option exits with code 1"
call :ASSERT_OUTPUT_CONTAINS "Invalid parameter:" "%OUT%" "invalid parameter message printed"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_REGISTRY_MISSING_URL
:: --registry with no URL arg and CB_REGISTRY_URL empty -> validation error
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --registry without URL and no CB_REGISTRY_URL env -^> exit 1
set "OUT=%TEMP%\cb\cb-image-version-resolver-rmu-%RANDOM%.txt"
set "CB_REGISTRY_URL="
call "%SCRIPT%" --registry alpine > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
set "CB_REGISTRY_URL="
call :ASSERT_EXIT_CODE "1" "!_RC!" "--registry with no URL exits with code 1"
call :ASSERT_OUTPUT_CONTAINS "registry" "%OUT%" "error mentions registry"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_REGISTRY_HELP_DOCUMENTS_OPTION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: --help documents --registry option
set "OUT=%TEMP%\cb\cb-image-version-resolver-rhd-%RANDOM%.txt"
call "%SCRIPT%" --help > "%OUT%" 2>&1
call :ASSERT_OUTPUT_CONTAINS "--registry" "%OUT%" "help documents --registry option"
call :ASSERT_OUTPUT_CONTAINS "CB_REGISTRY_USER" "%OUT%" "help documents CB_REGISTRY_USER"
call :ASSERT_OUTPUT_CONTAINS "CB_REGISTRY_PASSWORD" "%OUT%" "help documents CB_REGISTRY_PASSWORD"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_REGISTRY_URL_VIA_ENV
:: --registry with no URL arg; CB_REGISTRY_URL env var is used.
:: alpine is NOT consumed as registry URL (doesn't start with http).
:: Fails with connect error, not "requires a URL", proving env var was used.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: CB_REGISTRY_URL env var accepted by --registry flag
set "OUT=%TEMP%\cb\cb-image-version-resolver-rue-%RANDOM%.txt"
set "CB_REGISTRY_URL=https://127.0.0.1:19999"
call "%SCRIPT%" --registry alpine > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
set "CB_REGISTRY_URL="
call :ASSERT_EXIT_CODE "1" "!_RC!" "--registry with CB_REGISTRY_URL env exits 1 on connect failure"
call :ASSERT_OUTPUT_NOT_CONTAINS "requires a URL" "%OUT%" "no 'requires a URL' error - env var was consumed"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ALPINE_LATEST
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: alpine -^> resolves to versioned tag@digest
set "OUT=%TEMP%\cb\cb-image-version-resolver-al-%RANDOM%.txt"
call "%SCRIPT%" alpine > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!_RC!" "alpine exits 0"
call :ASSERT_OUTPUT_MATCHES_DIGEST "alpine:" "%OUT%" "output matches alpine:tag@sha256:..."
call :ASSERT_OUTPUT_CONTAINS "alpine:" "%OUT%" "output prefixed with alpine:"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ALPINE_COLON_FORM
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: alpine:latest (colon form) -^> resolves to versioned tag@digest
set "OUT=%TEMP%\cb\cb-image-version-resolver-ac-%RANDOM%.txt"
call "%SCRIPT%" alpine:latest > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!_RC!" "alpine:latest exits 0"
call :ASSERT_OUTPUT_MATCHES_DIGEST "alpine:" "%OUT%" "output matches alpine:tag@sha256:..."
call :ASSERT_OUTPUT_CONTAINS "alpine:" "%OUT%" "output prefixed with alpine:"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ALPINE_TWO_ARG_FORM
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: alpine latest (two-arg form) -^> same result as colon form
set "O1=%TEMP%\cb\cb-image-version-resolver-at1-%RANDOM%.txt"
set "O2=%TEMP%\cb\cb-image-version-resolver-at2-%RANDOM%.txt"
call "%SCRIPT%" alpine:latest > "%O1%" 2>&1
call "%SCRIPT%" alpine latest > "%O2%" 2>&1
fc "%O1%" "%O2%" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
    set /a PASS+=1
    echo   PASS: colon form and two-arg form produce identical output
) else (
    set /a FAIL+=1
    echo   FAIL: colon form and two-arg form differ
)
del /f /q "%O1%" "%O2%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NODE_LATEST
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: node -^> resolves to versioned tag@digest
set "OUT=%TEMP%\cb\cb-image-version-resolver-nl-%RANDOM%.txt"
call "%SCRIPT%" node > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!_RC!" "node exits 0"
call :ASSERT_OUTPUT_MATCHES_DIGEST "node:" "%OUT%" "output matches node:tag@sha256:..."
call :ASSERT_OUTPUT_CONTAINS "node:" "%OUT%" "output prefixed with node:"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ECLIPSE_TEMURIN_25_JRE_ALPINE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: eclipse-temurin:25-jre-alpine -^> resolves to pinned jre-alpine tag@digest
set "OUT=%TEMP%\cb\cb-image-version-resolver-jre-%RANDOM%.txt"
call "%SCRIPT%" eclipse-temurin:25-jre-alpine > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!_RC!" "eclipse-temurin:25-jre-alpine exits 0"
call :ASSERT_OUTPUT_MATCHES_DIGEST "eclipse-temurin:" "%OUT%" "output matches eclipse-temurin:tag@sha256:..."
call :ASSERT_OUTPUT_CONTAINS "eclipse-temurin:" "%OUT%" "output prefixed with eclipse-temurin:"
call :ASSERT_OUTPUT_CONTAINS "jre-alpine" "%OUT%" "resolved tag contains jre-alpine"
call :ASSERT_OUTPUT_CONTAINS "25" "%OUT%" "resolved tag contains major version 25"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_ECLIPSE_TEMURIN_25_JDK_ALPINE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: eclipse-temurin:25-jdk-alpine -^> resolves to pinned jdk-alpine tag@digest
set "OUT=%TEMP%\cb\cb-image-version-resolver-jdk-%RANDOM%.txt"
call "%SCRIPT%" eclipse-temurin:25-jdk-alpine > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!_RC!" "eclipse-temurin:25-jdk-alpine exits 0"
call :ASSERT_OUTPUT_MATCHES_DIGEST "eclipse-temurin:" "%OUT%" "output matches eclipse-temurin:tag@sha256:..."
call :ASSERT_OUTPUT_CONTAINS "eclipse-temurin:" "%OUT%" "output prefixed with eclipse-temurin:"
call :ASSERT_OUTPUT_CONTAINS "jdk-alpine" "%OUT%" "resolved tag contains jdk-alpine"
call :ASSERT_OUTPUT_CONTAINS "25" "%OUT%" "resolved tag contains major version 25"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_JRE_JDK_DIFFERENT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: 25-jre-alpine and 25-jdk-alpine resolve to different tags
set "O1=%TEMP%\cb\cb-image-version-resolver-jd1-%RANDOM%.txt"
set "O2=%TEMP%\cb\cb-image-version-resolver-jd2-%RANDOM%.txt"
call "%SCRIPT%" eclipse-temurin:25-jre-alpine > "%O1%" 2>&1
call "%SCRIPT%" eclipse-temurin:25-jdk-alpine > "%O2%" 2>&1
fc "%O1%" "%O2%" >nul 2>nul
if !ERRORLEVEL! NEQ 0 (
    set /a PASS+=1
    echo   PASS: jre and jdk resolve to different references
) else (
    set /a FAIL+=1
    echo   FAIL: jre and jdk resolved to the same reference
)
del /f /q "%O1%" "%O2%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERIFY_VALID_DIGEST
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: alpine:3.24.1^@^<digest^> (valid) -^> verifies and returns reference as-is
set "REF_FILE=%TEMP%\cb\cb-image-version-resolver-ref-%RANDOM%.txt"
call "%SCRIPT%" alpine:3.24.1 > "%REF_FILE%" 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo   SKIP: could not resolve alpine:3.24.1
    del /f /q "%REF_FILE%" >nul 2>nul
    set /a SKIP+=2
    goto :eof
)
set "REF="
for /f "usebackq delims=" %%R in ("%REF_FILE%") do set "REF=%%R"
del /f /q "%REF_FILE%" >nul 2>nul
set "OUT=%TEMP%\cb\cb-image-version-resolver-vfy-%RANDOM%.txt"
call "%SCRIPT%" "!REF!" > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!_RC!" "verify valid digest exits 0"
set "OUT_VAL="
for /f "usebackq delims=" %%R in ("%OUT%") do set "OUT_VAL=%%R"
del /f /q "%OUT%" >nul 2>nul
if "!REF!"=="!OUT_VAL!" (
    set /a PASS+=1
    echo   PASS: verify returns same reference unchanged
) else (
    set /a FAIL+=1
    echo   FAIL: verify returns same reference unchanged
)
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_VERIFY_WRONG_DIGEST
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: alpine:3.24.1^@sha256:0000...0000 (wrong digest) -^> mismatch error
set "OUT=%TEMP%\cb\cb-image-version-resolver-vfy2-%RANDOM%.txt"
call "%SCRIPT%" "alpine:3.24.1@sha256:0000000000000000000000000000000000000000000000000000000000000000" > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!_RC!" "wrong digest exits 1"
call :ASSERT_OUTPUT_CONTAINS "mismatch" "%OUT%" "error mentions mismatch"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_IMAGE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: nonexistentimage12345 (unknown image) -^> exit 1 with error
set "OUT=%TEMP%\cb\cb-image-version-resolver-invimg-%RANDOM%.txt"
call "%SCRIPT%" nonexistentimage12345 > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!_RC!" "unknown image exits 1"
call :ASSERT_OUTPUT_CONTAINS "nonexistentimage12345" "%OUT%" "error mentions the image name"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_INVALID_TAG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: alpine:nonexistenttag12345 (unknown tag) -^> exit 1 with error
set "OUT=%TEMP%\cb\cb-image-version-resolver-invtag-%RANDOM%.txt"
call "%SCRIPT%" alpine:nonexistenttag12345 > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "1" "!_RC!" "unknown tag exits 1"
call :ASSERT_OUTPUT_CONTAINS "nonexistenttag12345" "%OUT%" "error mentions the tag name"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NGINX_ALPINE_VARIANT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: nginx:alpine -^> resolves to versioned X.Y.Z-alpine tag (not plain X.Y.Z)
set "OUT=%TEMP%\cb\cb-image-version-resolver-nax-%RANDOM%.txt"
call "%SCRIPT%" nginx:alpine > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!_RC!" "nginx:alpine exits 0"
call :ASSERT_OUTPUT_MATCHES_DIGEST "nginx:" "%OUT%" "output matches nginx:tag@sha256:..."
call :ASSERT_OUTPUT_CONTAINS "nginx:" "%OUT%" "output prefixed with nginx:"
call :ASSERT_OUTPUT_CONTAINS "-alpine" "%OUT%" "resolved tag contains -alpine suffix, not plain numeric"
del /f /q "%OUT%" >nul 2>nul
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TEST_NGINX_STABLE_ALPINE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TEST: nginx:stable-alpine -^> resolves to stable-alpine literal tag@digest
set "OUT=%TEMP%\cb\cb-image-version-resolver-nsa-%RANDOM%.txt"
call "%SCRIPT%" nginx:stable-alpine > "%OUT%" 2>&1
set "_RC=!ERRORLEVEL!"
call :ASSERT_EXIT_CODE "0" "!_RC!" "nginx:stable-alpine exits 0"
call :ASSERT_OUTPUT_MATCHES_DIGEST "nginx:" "%OUT%" "output matches nginx:tag@sha256:..."
call :ASSERT_OUTPUT_CONTAINS "nginx:" "%OUT%" "output prefixed with nginx:"
call :ASSERT_OUTPUT_CONTAINS "stable-alpine" "%OUT%" "resolved tag contains stable-alpine"
del /f /q "%OUT%" >nul 2>nul
goto :eof
