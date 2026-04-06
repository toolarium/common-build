@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-filetail.bat
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
set "SELF=%~f0"

:: defaults
set "FILENAME="
set "PATTERN="

:PARSE
if [%1]==[] goto PARSE_DONE
if /i "%~1"=="-h" goto HELP
if /i "%~1"=="--help" goto HELP
if /i "%~1"=="-f" (
	set "FILENAME=%~2"
	shift
	shift
	goto PARSE
)
if /i "%~1"=="-p" (
	set "PATTERN=%~2"
	shift
	shift
	goto PARSE
)
echo Invalid parameter: %~1 1>&2
echo.
goto HELP_ERR

:PARSE_DONE

if not defined FILENAME (
	echo %PN%: -f ^<filename^> is required 1>&2
	echo run '%PN% -h' for help 1>&2
	exit /b 1
)
if not exist "%FILENAME%" (
	echo %PN%: file not found: %FILENAME% 1>&2
	exit /b 1
)

:: pass args via env vars to avoid cmd.exe escaping hazards for user-provided regex
set "CBFT_SELF=%SELF%"
set "CBFT_FILE=%FILENAME%"
set "CBFT_PATTERN=%PATTERN%"

:: extract embedded PowerShell and execute in a single invocation
powershell -NoProfile -ExecutionPolicy Bypass -Command "$code = (Get-Content -LiteralPath $env:CBFT_SELF | Where-Object { $_.StartsWith(':::PS:::') } | ForEach-Object { $_.Substring(8) }) -join [Environment]::NewLine; $sb = [scriptblock]::Create($code); & $sb -FileName $env:CBFT_FILE -Pattern $env:CBFT_PATTERN"
set "RC=%ERRORLEVEL%"

endlocal & exit /b %RC%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP_ERR
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
call :PRINT_HELP
exit /b 1

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
call :PRINT_HELP
exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRINT_HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - script to tail a file until a pattern in the output is found.
echo usage: %PN% [OPTION]
echo.
echo Overview of the available OPTIONs:
echo  -h, --help           Show this help message.
echo  -p [pattern]         Defines the pattern to stop if this occurs ^(regex^)
echo  -f [filename]        Defines the filename
echo.
goto :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Embedded PowerShell helper. Lines prefixed with ":::PS:::" are
:: extracted at runtime. Uses a StreamReader with FileShare.ReadWrite so
:: it can read a file while another process is writing to it. Polls every
:: 200 ms when at EOF (tail -f equivalent). Exits the moment the pattern
:: matches -- no last-line-hang like the sh version's original bug.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::PS:::param(
:::PS:::    [string] $FileName = '',
:::PS:::    [string] $Pattern  = ''
:::PS:::)
:::PS:::
:::PS:::$ErrorActionPreference = 'Stop'
:::PS:::
:::PS:::if (-not $FileName) {
:::PS:::    [Console]::Error.WriteLine('cb-filetail: -f <filename> is required')
:::PS:::    exit 1
:::PS:::}
:::PS:::if (-not (Test-Path -LiteralPath $FileName)) {
:::PS:::    [Console]::Error.WriteLine("cb-filetail: file not found: $FileName")
:::PS:::    exit 1
:::PS:::}
:::PS:::
:::PS:::# open with shared read/write so a writer process is not blocked
:::PS:::$fs = [System.IO.File]::Open(
:::PS:::    (Resolve-Path -LiteralPath $FileName).Path,
:::PS:::    [System.IO.FileMode]::Open,
:::PS:::    [System.IO.FileAccess]::Read,
:::PS:::    [System.IO.FileShare]::ReadWrite
:::PS:::)
:::PS:::$sr = New-Object System.IO.StreamReader($fs)
:::PS:::try {
:::PS:::    while ($true) {
:::PS:::        $line = $sr.ReadLine()
:::PS:::        if ($null -eq $line) {
:::PS:::            # nothing new; check if file was truncated (rotated) and back off
:::PS:::            if ($fs.Position -gt $fs.Length) { $fs.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null }
:::PS:::            Start-Sleep -Milliseconds 200
:::PS:::            continue
:::PS:::        }
:::PS:::        Write-Output $line
:::PS:::        if ($Pattern -ne '' -and $line -match $Pattern) { break }
:::PS:::    }
:::PS:::} finally {
:::PS:::    $sr.Close()
:::PS:::    $fs.Close()
:::PS:::}
:::PS:::exit 0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
