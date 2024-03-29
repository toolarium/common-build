@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-credential.bat
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

set GIT_USERNAME=
set GIT_PASSWORD=
set GRGIT_USER=
set GRGIT_PASSWORD=
set BASIC_AUTHENTICATION=
setlocal EnableDelayedExpansion
set PN=%~nx0
set "PRINT_CREDENTIAL=false"
set "RAW_CREDENTIAL=false"
set "VERIFY_ONLY="
if not defined TEMP set "TEMP=%TMP%"
if not defined CB_TEMP set "CB_TEMP=%TEMP%\cb"
if not exist %CB_TEMP% mkdir "%CB_TEMP%" >nul 2>nul
if not defined GIT_CLIENT set "GIT_CLIENT=%CB_HOME%\current\git\bin\git"
if not defined GRGIT set "GRGIT=false"
%GIT_CLIENT% --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 set "GIT_CLIENT=git"
set CB_PARAMETERS=


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_PARAMETER
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if %0X==X goto READ_CREDENTIAL
if .%1==.-h goto HELP
if .%1==.--help goto HELP
if .%1==.--raw shift & set "RAW_CREDENTIAL=true"
if .%1==.--print shift & set "PRINT_CREDENTIAL=true"
if .%1==.--grgit shift & set "RAW_CREDENTIAL=true" & set "GRGIT=true"
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
echo  --grgit              Return the plaintext credentials compatible with grgit
echo  --verifyOnly         Verifies only the credentials.
goto END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:READ_CREDENTIAL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%GIT_CLIENT% --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 echo. & echo .: ERROR: No git client found. & echo. & goto END_WITH_ERROR

if [%CB_PARAMETERS%] EQU [] if exist .git\config for /f "tokens=1,2 delims==" %%i in ('type .git\config^|findstr /C:http') do ( call :SET_URL %%j ) 
::if [%CB_PARAMETERS%] EQU [] if exist .git\config for /f "tokens=* delims= " %%a in ("%CB_PARAMATERS%") do ( set "CB_PARAMATERS=%%a" )

if [%CB_PARAMETERS%] EQU [] echo. & echo .: ERROR: No url found. Please provide external git url & echo. & goto END_WITH_ERROR
for /f "tokens=1,2,3,* delims=/" %%i in ("%CB_PARAMETERS%") do (set "urlProtocol=%%i" & set "urlHost=%%j" & set "urlPath=%%k")
for /f "tokens=1,* delims=:" %%i in ("%urlProtocol%") do (set "urlProtocol=%%i")
if .%urlProtocol% == . echo .: ERROR: No protocol found & goto END_WITH_ERROR
if .%urlHost% == . echo .: ERROR: No host found & goto END_WITH_ERROR

set "tempFile=%CB_TEMP%\cb-%RANDOM%%RANDOM%.dat"
set "credentialFile=%CB_TEMP%\cb-%RANDOM%%RANDOM%.dat"
echo protocol=%urlProtocol%>"%tempFile%"
echo host=%urlHost%>>"%tempFile%"

if defined VERIFY_ONLY set "GIT_CREDENTIAL_MANAGER=credential-manager-core"
if defined VERIFY_ONLY %GIT_CLIENT% %GIT_CREDENTIAL_MANAGER% --version >nul 2>nul
if defined VERIFY_ONLY if %ERRORLEVEL% neq 0 set "GIT_CREDENTIAL_MANAGER=credential-manager"
if defined VERIFY_ONLY type %tempFile% | %GIT_CLIENT% %GIT_CREDENTIAL_MANAGER% get > nul 2>nul
if defined VERIFY_ONLY if %ERRORLEVEL% neq 0 goto END_WITH_ERROR
if defined VERIFY_ONLY goto END

if not defined VERIFY_ONLY type %tempFile% | %GIT_CLIENT% credential-manager get > "%credentialFile%"

set "cbUsername=" & set "cbPassword="
type %credentialFile% | findstr /C:username= > %tempFile%
for /f "tokens=1,2* delims==" %%i in (%tempFile%) do (set "cbUsername=%%j")
type %credentialFile% | findstr /C:password= > %tempFile%
for /f "tokens=1,2* delims==" %%i in (%tempFile%) do (set "cbPassword=%%j")

if .%RAW_CREDENTIAL% == .false (powershell -Command "[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($env:cbUsername + ':' + $env:cbPassword), 'InsertLineBreaks')" > "%credentialFile%"
	set /p BASIC_AUTHENTICATION=<"%credentialFile%")

set "CB_GIT_USERNAME_KEY=GIT_USERNAME"
set "CB_GIT_PASSWORD_KEY=GIT_PASSWORD"
if .%GRGIT% == .true set "CB_GIT_USERNAME_KEY=GRGIT_USER" & set "CB_GIT_PASSWORD_KEY=GRGIT_PASS"

endlocal & (
	if not defined VERIFY_ONLY if .%RAW_CREDENTIAL% == .true if .%PRINT_CREDENTIAL% == .true echo %CB_GIT_USERNAME_KEY%=%cbUsername% & echo %CB_GIT_PASSWORD_KEY%=%cbPassword% & goto END
	if not defined VERIFY_ONLY if .%RAW_CREDENTIAL% == .true if .%PRINT_CREDENTIAL% == .false set "%CB_GIT_USERNAME_KEY%=%cbUsername%" & set "%CB_GIT_PASSWORD_KEY%=%cbPassword%" & goto END
	if not defined VERIFY_ONLY if .%PRINT_CREDENTIAL% == .true echo %BASIC_AUTHENTICATION% & goto END
	if not defined VERIFY_ONLY if .%PRINT_CREDENTIAL% == .false set "BASIC_AUTHENTICATION=%BASIC_AUTHENTICATION%"
	goto END
)


:SET_URL
set "CB_PARAMETERS=%~1"
goto :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END_WITH_ERROR
del %tempFile% >nul 2>nul
del %credentialFile% >nul 2>nul
exit /b 1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:END
del %tempFile% >nul 2>nul
del %credentialFile% >nul 2>nul
exit /b 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
