@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-open-ports.bat
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
set "CB_LINEHEADER=.: "
set "fileOutputName=open-ports.dat"

:: defaults
set "suppressHeader=0"
set "ignoreLocalhost=1"
set "writeFile="
set "logPath="
set "filterParameter="

:PARSE
if [%1]==[] goto PARSE_DONE
if /i "%~1"=="-h" goto HELP
if /i "%~1"=="--help" goto HELP
if /i "%~1"=="-q" set "suppressHeader=1" & shift & goto PARSE
if /i "%~1"=="-i" set "ignoreLocalhost=1" & shift & goto PARSE
if /i "%~1"=="--ignoreLocalhost" set "ignoreLocalhost=1" & shift & goto PARSE
if /i "%~1"=="-l" set "ignoreLocalhost=0" & shift & goto PARSE
if /i "%~1"=="--localhost" set "ignoreLocalhost=0" & shift & goto PARSE
if /i "%~1"=="-p" (
	set "logPath=%~2"
	set "writeFile=1"
	shift
	shift
	goto PARSE
)
if /i "%~1"=="-f" (
	set "fileOutputName=%~2"
	set "writeFile=1"
	shift
	shift
	goto PARSE
)
set "firstArgChar=%~1"
set "firstArgChar=!firstArgChar:~0,1!"
if "!firstArgChar!"=="-" (echo Invalid parameter: %~1 & echo\  & goto HELP)
if defined filterParameter (
	set "filterParameter=!filterParameter!|%~1"
) else (
	set "filterParameter=%~1"
)
shift
goto PARSE

:PARSE_DONE

:: resolve output file when requested
set "outFileArg="
if defined writeFile (
	if not defined logPath (
		echo %CB_LINEHEADER%Missing -p path argument
		exit /b 1
	)
	if not exist "%logPath%\" (
		echo %CB_LINEHEADER%Could not create file because path %logPath% is not accessable!
		exit /b 1
	)
	set "outFileArg=%logPath%\%fileOutputName%"
	echo %CB_LINEHEADER%Write output to !outFileArg!...
)

:: pass args via env vars so cmd.exe never has to escape user-provided regexes
set "CBOP_SELF=%SELF%"
set "CBOP_IL=%ignoreLocalhost%"
set "CBOP_SH=%suppressHeader%"
set "CBOP_FR=%filterParameter%"
set "CBOP_OUT=%outFileArg%"

:: extract embedded PowerShell (lines prefixed ":::PS:::") and run it in a single
:: powershell.exe invocation to avoid double process-startup cost.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$code = (Get-Content -LiteralPath $env:CBOP_SELF | Where-Object { $_.StartsWith(':::PS:::') } | ForEach-Object { $_.Substring(8) }) -join [Environment]::NewLine; $sb = [scriptblock]::Create($code); & $sb -IgnoreLocalhost ([int]$env:CBOP_IL) -SuppressHeader ([int]$env:CBOP_SH) -FilterRegex $env:CBOP_FR -OutFile $env:CBOP_OUT"
set "RC=%ERRORLEVEL%"

endlocal & exit /b %RC%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - script to read all open ports. Optional filter can be passed as argument.
echo usage: %PN% [OPTION] [filter1 filter2 ...]
echo\
echo Overview of the available OPTIONs:
echo  -h, --help             Show this help message.
echo  -q                     Suppress header
echo  -l, --localhost        Include ports on localhost ^(127.0.0.1^)
echo  -i, --ignoreLocalhost  Ignore ports on localhost ^(127.0.0.1^) [default]
echo  -p [path]              Defines the output path and don't print output
echo  -f [filename]          Defines the filename, default: %fileOutputName%
echo\
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Embedded PowerShell helper. Lines prefixed with ":::PS:::" are
:: extracted at runtime into a temporary .ps1 file. The ":::" prefix
:: makes each line a batch comment so cmd.exe ignores it entirely.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::PS:::param(
:::PS:::    [int]    $IgnoreLocalhost = 1,
:::PS:::    [string] $FilterRegex     = '',
:::PS:::    [int]    $SuppressHeader  = 0,
:::PS:::    [string] $OutFile         = ''
:::PS:::)
:::PS:::
:::PS:::$ErrorActionPreference = 'SilentlyContinue'
:::PS:::
:::PS:::# PROG is widened from the Linux default of 15 to 30 because Windows process
:::PS:::# names are routinely longer (e.g. Quarkus/Spring-Boot *-runner.exe names).
:::PS:::$fmt = "{0,-6}`t{1,-7}`t{2,-30}`t{3,-10}`t{4,-5}`t{5,-5}`t{6,-5}`t{7,-13}`t{8,-10}`t{9,-15}`t{10,-50}"
:::PS:::$lines = New-Object System.Collections.Generic.List[string]
:::PS:::
:::PS:::if ($SuppressHeader -eq 0) {
:::PS:::    [void]$lines.Add(($fmt -f 'PORT','PID','PROG','SIZE(KB)','CPU','PRIO','NLWP','TIME','USER','GROUP','PATH'))
:::PS:::}
:::PS:::
:::PS:::# gather listening TCP + UDP endpoints via netstat -ano (fast: one subprocess, bulk output)
:::PS:::$all = New-Object System.Collections.Generic.List[object]
:::PS:::foreach ($line in (& netstat.exe -ano 2>$null)) {
:::PS:::    $line = $line.Trim()
:::PS:::    if ($line -eq '') { continue }
:::PS:::    $f = $line -split '\s+'
:::PS:::    if ($f.Count -lt 4) { continue }
:::PS:::    $proto = $f[0]
:::PS:::    if ($proto -ne 'TCP' -and $proto -ne 'UDP') { continue }
:::PS:::    if ($proto -eq 'TCP') {
:::PS:::        if ($f.Count -lt 5) { continue }
:::PS:::        if ($f[3] -ne 'LISTENING') { continue }
:::PS:::        $local = $f[1]; $ownerPid = [int]$f[4]
:::PS:::    } else {
:::PS:::        $local = $f[1]; $ownerPid = [int]$f[3]
:::PS:::    }
:::PS:::    # split "addr:port" — address may be IPv6 in [brackets]
:::PS:::    $idx = $local.LastIndexOf(':')
:::PS:::    if ($idx -lt 0) { continue }
:::PS:::    $addr = $local.Substring(0, $idx).Trim('[', ']')
:::PS:::    $port = [int]$local.Substring($idx + 1)
:::PS:::    $all.Add([PSCustomObject]@{ Addr = $addr; Port = $port; OwnerPid = $ownerPid }) | Out-Null
:::PS:::}
:::PS:::
:::PS:::# filter out localhost bindings unless caller asked for them
:::PS:::if ($IgnoreLocalhost -eq 1) {
:::PS:::    $all = $all | Where-Object { $_.Addr -ne '127.0.0.1' -and $_.Addr -ne '::1' }
:::PS:::}
:::PS:::
:::PS:::# dedupe (port, pid)
:::PS:::$seen = @{}
:::PS:::$all = $all | Where-Object {
:::PS:::    $k = "$($_.Port)|$($_.OwnerPid)"
:::PS:::    if ($seen.ContainsKey($k)) { $false } else { $seen[$k] = 1; $true }
:::PS:::}
:::PS:::
:::PS:::# one bulk Win32_Process CIM call gives Name/ExecutablePath/WorkingSetSize/
:::PS:::# Priority/ThreadCount/CreationDate/KernelModeTime/UserModeTime for every pid.
:::PS:::# Avoids per-PID Get-Process access (which throws on protected processes and
:::PS:::# is slow due to exception overhead). USER/GROUP stay '-' because GetOwner
:::PS:::# can stall on SID lookups on domain-joined machines — matches the Linux
:::PS:::# script's behavior for foreign processes when not running as root.
:::PS:::$procMap = @{}
:::PS:::foreach ($wp in (Get-CimInstance -ClassName Win32_Process -ErrorAction SilentlyContinue)) {
:::PS:::    $procMap[[int]$wp.ProcessId] = $wp
:::PS:::}
:::PS:::$now = Get-Date
:::PS:::
:::PS:::# build rows
:::PS:::$rows = foreach ($c in $all) {
:::PS:::    $pidv  = [int]$c.OwnerPid
:::PS:::    $port  = $c.Port
:::PS:::    $prog  = '-'; $size = '-'; $cpu = '-'; $prio = '-'; $nlwp = '-'
:::PS:::    $etime = '-'; $user = '-'; $group = '-'; $path = '-'
:::PS:::
:::PS:::    if ($pidv -eq 0)     { $prog = 'Idle' }
:::PS:::    elseif ($pidv -eq 4) { $prog = 'System' }
:::PS:::
:::PS:::    $wp = $procMap[$pidv]
:::PS:::    if ($wp) {
:::PS:::        if ($wp.Name) {
:::PS:::            # strip trailing ".exe" to match Linux ps-style short names
:::PS:::            $n = $wp.Name
:::PS:::            if ($n.ToLower().EndsWith('.exe')) { $n = $n.Substring(0, $n.Length - 4) }
:::PS:::            $prog = $n
:::PS:::        }
:::PS:::        if ($wp.WorkingSetSize) { $size = [int]($wp.WorkingSetSize / 1024) }
:::PS:::        if ($wp.Priority -ne $null) { $prio = $wp.Priority }
:::PS:::        if ($wp.ThreadCount) { $nlwp = $wp.ThreadCount }
:::PS:::        if ($wp.ExecutablePath) { $path = $wp.ExecutablePath }
:::PS:::        if ($wp.CreationDate) {
:::PS:::            $ts = $now - $wp.CreationDate
:::PS:::            if ($ts.TotalSeconds -gt 0) {
:::PS:::                if ($ts.Days -gt 0) {
:::PS:::                    $etime = ('{0}-{1:D2}:{2:D2}:{3:D2}' -f $ts.Days, $ts.Hours, $ts.Minutes, $ts.Seconds)
:::PS:::                } else {
:::PS:::                    $etime = ('{0:D2}:{1:D2}:{2:D2}' -f $ts.Hours, $ts.Minutes, $ts.Seconds)
:::PS:::                }
:::PS:::                # KernelModeTime + UserModeTime are in 100-ns units
:::PS:::                $cpuSecs = ([double]$wp.KernelModeTime + [double]$wp.UserModeTime) / 10000000.0
:::PS:::                $cpu = [string][math]::Round(($cpuSecs / $ts.TotalSeconds) * 100, 1)
:::PS:::            }
:::PS:::        }
:::PS:::    }
:::PS:::
:::PS:::    [PSCustomObject]@{
:::PS:::        Port = $port; OwnerPid = $pidv; Prog = $prog; Size = $size; Cpu = $cpu;
:::PS:::        Prio = $prio; Nlwp = $nlwp; Etime = $etime; User = $user; Group = $group; Path = $path
:::PS:::    }
:::PS:::}
:::PS:::
:::PS:::# sort numerically by port
:::PS:::$rows = @($rows) | Sort-Object -Property @{ Expression = { [int]$_.Port } }
:::PS:::
:::PS:::# apply user regex filter (matches concatenated visible fields, same spirit as the sh version)
:::PS:::if ($FilterRegex -ne '') {
:::PS:::    $rows = $rows | Where-Object {
:::PS:::        $s = "$($_.Port) $($_.OwnerPid) $($_.Prog) $($_.Path) $($_.User)"
:::PS:::        $s -match $FilterRegex
:::PS:::    }
:::PS:::}
:::PS:::
:::PS:::foreach ($r in $rows) {
:::PS:::    [void]$lines.Add(($fmt -f $r.Port, $r.OwnerPid, $r.Prog, $r.Size, $r.Cpu, $r.Prio, $r.Nlwp, $r.Etime, $r.User, $r.Group, $r.Path))
:::PS:::}
:::PS:::
:::PS:::if ($OutFile -ne '') {
:::PS:::    $lines | Out-File -FilePath $OutFile -Encoding ascii
:::PS:::} else {
:::PS:::    $lines | ForEach-Object { Write-Output $_ }
:::PS:::}
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
