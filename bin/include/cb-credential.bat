@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-credential.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


set GIT_USERNAME=
set GIT_PASSWORD=
set BASIC_AUTHENTICATION=
setlocal EnableDelayedExpansion
set PN=%~nx0
set "PRINT_CREDENTIAL=false"
set "RAW_CREDENTIAL=false"
set "VERIFY_ONLY="
if not defined GIT_CLIENT set "GIT_CLIENT=%CB_HOME%\current\git\bin\git"
%GIT_CLIENT% --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "GIT_CLIENT=git"


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if %0X==X goto READ_CREDENTIAL
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.--raw shift & set "RAW_CREDENTIAL=true"
if .%1==.--print shift & set "PRINT_CREDENTIAL=true"
if .%1==.--verifyOnly shift & set "VERIFY_ONLY=true"
if not .%1==. set "CB_PARAMETERS=%~1"
shift
goto CHECK_PARAMETER


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - get credentials of an url.
echo.
echo usage: %PN% [OPTION] GIT-URL
echo.
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  --raw                Return the plaintext credentials; otherwise its a
echo                       BASIC_AUTHENTICATION string.
echo  --print              Print the credentials: either as plaintext in combination
echo                       with parameter raw or the BASIC_AUTHENTICATION string.
echo                       In case of not print parameter the environment
echo                       variable will be set GIT_USERNAME, GIT_PASSWORD or
echo                       BASIC_AUTHENTICATION
echo  --verifyOnly         Verifies only the credentials.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:READ_CREDENTIAL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%GIT_CLIENT% --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo. & echo .: ERROR: No git client found. & echo. & goto END_WITH_ERROR
if [%CB_PARAMETERS%] EQU [] echo. & echo .: ERROR: No url found. Please provide external git url & echo. & goto END_WITH_ERROR
for /f "tokens=1,2,3,* delims=/" %%i in ("%CB_PARAMETERS%") do (set "urlProtocol=%%i" & set "urlHost=%%j" & set "urlPath=%%k")
for /f "tokens=1,* delims=:" %%i in ("%urlProtocol%") do (set "urlProtocol=%%i")
if .%urlProtocol% == . echo .: ERROR: No protocol found & goto END_WITH_ERROR
if .%urlHost% == . echo .: ERROR: No host found & goto END_WITH_ERROR

set "tempFile=%TEMP%\cb-%RANDOM%%RANDOM%.dat"
set "credentialFile=%TEMP%\cb-%RANDOM%%RANDOM%.dat"
echo protocol=%urlProtocol%>"%tempFile%"
echo host=%urlHost%>>"%tempFile%"

if defined VERIFY_ONLY type %tempFile% | %GIT_CLIENT% credential-manager get > nul 2>nul
if defined VERIFY_ONLY if %ERRORLEVEL% neq 0 goto END_WITH_ERROR
if defined VERIFY_ONLY goto END

if not defined VERIFY_ONLY type %tempFile% | %GIT_CLIENT% credential-manager get > "%credentialFile%"
del %tempFile%

set "cbUsername=" & set "cbPassword="
type %credentialFile% | findstr /C:username= > %tempFile%
for /f "tokens=1,2* delims==" %%i in (%tempFile%) do (set "cbUsername=%%j")
type %credentialFile% | findstr /C:password= > %tempFile%
for /f "tokens=1,2* delims==" %%i in (%tempFile%) do (set "cbPassword=%%j")
del %tempFile%
del %credentialFile%

if .%RAW_CREDENTIAL% == .false (powershell -Command "[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($env:cbUsername + ':' + $env:cbPassword), 'InsertLineBreaks')" > "%credentialFile%"
	set /p BASIC_AUTHENTICATION=<"%credentialFile%")

endlocal & (
	if not defined VERIFY_ONLY if .%RAW_CREDENTIAL% == .true if .%PRINT_CREDENTIAL% == .true echo GIT_USERNAME=%cbUsername% & echo GIT_PASSWORD=%cbPassword% & goto END
	if not defined VERIFY_ONLY if .%RAW_CREDENTIAL% == .true if .%PRINT_CREDENTIAL% == .false set "GIT_USERNAME=%cbUsername%" & set "GIT_PASSWORD=%cbPassword%" & goto END
	if not defined VERIFY_ONLY if .%PRINT_CREDENTIAL% == .true echo %BASIC_AUTHENTICATION% & goto END
	if not defined VERIFY_ONLY if .%PRINT_CREDENTIAL% == .false set "BASIC_AUTHENTICATION=%BASIC_AUTHENTICATION%"
	goto END
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END_WITH_ERROR
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::