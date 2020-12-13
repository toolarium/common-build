@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-install-check.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


set "PROTOCOL_LOG=%TEMP%\cb-install-check.log"
del /f "%PROTOCOL_LOG%" 2>nul >nul
call :GET_TIMESTAMP CB_START_TIMESTAMP

set CB_PROCESSOR_ARCHITECTURE_NUMBER=64
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:32=%" set CB_PROCESSOR_ARCHITECTURE_NUMBER=32
if not "%PROCESSOR_ARCHITECTURE%"=="%PROCESSOR_ARCHITECTURE:64=%" set CB_PROCESSOR_ARCHITECTURE_NUMBER=64
for /F %%i in ('wmic OS Get CSName ^| findstr /V CSName ^| findstr /v "^$"') do (set "hostname=%%i")
for /F %%i in ('wmic OS Get BuildNumber ^| findstr /V BuildNumber ^| findstr /v "^$"') do (set "buildNumber=%%i")
for /F %%i in ('wmic OS Get Caption ^| findstr /V Caption ^| findstr /v "^$"') do (set "windowsVersion=%%i")

call :PROTOCOL_HEADER "Protocol common build installation (%windowsVersion% %buildNumber%, x%CB_PROCESSOR_ARCHITECTURE_NUMBER%), %CB_START_TIMESTAMP%"
call :PROTOCOL_HEADER "Analyse common build..."
call :PROTOCOL call cb --version
call :PROTOCOL echo "%CB_HOME%"
call :PROTOCOL dir /O-D %CB_HOME%\..\

call :PROTOCOL_HEADER "Analyse common build configuration..."
if not exist %USERPROFILE%\.common-build echo n/a>> "%PROTOCOL_LOG%"
if not exist %USERPROFILE%\.common-build goto COMMON_GRADLE_BUILD
call :PROTOCOL dir /O-D %USERPROFILE%\.common-build\conf\
call :PROTOCOL type %USERPROFILE%\.common-build\conf\.cb-custom-config
FOR /F %%i IN ('dir /O-D/b %USERPROFILE%\.common-build\conf\ ^| findstr -V "cb-custom-config"') DO (
	call :PROTOCOL dir /O-D %USERPROFILE%\.common-build\conf\%%i
	call :PROTOCOL type %USERPROFILE%\.common-build\conf\%%i\lastCheck.properties)

:COMMON_GRADLE_BUILD
call :PROTOCOL_HEADER "Analyse common gradle build..."
if not exist %USERPROFILE%\.gradle\common-gradle-build echo n/a>> "%PROTOCOL_LOG%"
if not exist %USERPROFILE%\.gradle\common-gradle-build goto END
call :PROTOCOL dir /O-D %USERPROFILE%\.gradle\common-gradle-build\
call :PROTOCOL type %USERPROFILE%\.gradle\common-gradle-build\lastCheck.properties

call :PROTOCOL_HEADER "Protocol you find: %PROTOCOL_LOG%"
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROTOCOL_HEADER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "PARAMETERS="
echo.>> "%PROTOCOL_LOG%"
echo ---------------------------------------------------------------------------------------->> "%PROTOCOL_LOG%"
:CHECK_PARAMETER_HEADER
if %0X==X goto CHECK_PARAMETER_HEADER_END
set "PARAMETERS=%PARAMETERS% %~1"
shift
goto CHECK_PARAMETER_HEADER
:CHECK_PARAMETER_HEADER_END
echo .:%PARAMETERS%
echo %PARAMETERS%>> "%PROTOCOL_LOG%"
echo ---------------------------------------------------------------------------------------->> "%PROTOCOL_LOG%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROTOCOL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "PARAMETERS="
set "PARAMETERS_FILTER="
set "PARAMETERS=%~1"
if .%PARAMETERS% == .dir set "PARAMETERS_FILTER= | findstr /C:DIR | findstr /V /i "\.$""
if .%PARAMETERS% == .type set "PARAMETERS_FILTER= | findstr /V "#""
shift
:CHECK_PARAMETER
if %0X==X goto EXECUTE_CALL
set "PARAMETERS=%PARAMETERS% %~1"
shift
goto CHECK_PARAMETER

:EXECUTE_CALL
echo .: %PARAMETERS%>> "%PROTOCOL_LOG%"
set "PARAMETERS=%PARAMETERS%%PARAMETERS_FILTER%"
%PARAMETERS% 2>nul >> "%PROTOCOL_LOG%"
echo.>> "%PROTOCOL_LOG%"
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_TIMESTAMP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "timestampFormat=yyyy-MM-dd HH:mm:ss.fff"
if not .%2==. set "timestampFormat=%2"
for /f "tokens=1-2" %%a in ('powershell get-date -format "{%timestampFormat%}"') do ( set "%1=%%a %%b" )
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
