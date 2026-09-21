@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-image-version-resolver.bat
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

if not defined CB_REGISTRY_URL set "CB_REGISTRY_URL="
set "CB_REGISTRY_URL_ENV=!CB_REGISTRY_URL!"
set "CB_REGISTRY_FLAG=false"
set "RAW_IMAGE="
set "BASE_TAG=latest"


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Parse arguments
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PARSE
if [%1]==[] goto PARSE_DONE
if /I "%~1"=="-h"         goto HELP
if /I "%~1"=="--help"     goto HELP
if /I "%~1"=="--registry" goto PARSE_REGISTRY
:: unknown option (starts with -)
set "_pc=%~1"
if "!_pc:~0,1!"=="-" (
    echo Invalid parameter: %1
    echo\
    goto HELP
)
:: first non-option positional arg -- stop option parsing
goto PARSE_DONE

:PARSE_REGISTRY
set "CB_REGISTRY_FLAG=true"
set "_argNext=%~2"
if not defined _argNext (set "CB_REGISTRY_URL=!CB_REGISTRY_URL_ENV!" & shift & goto PARSE)
if "!_argNext:~0,1!"=="-" (set "CB_REGISTRY_URL=!CB_REGISTRY_URL_ENV!" & shift & goto PARSE)
:: only consume next arg as URL when it looks like one (starts with http)
set "_argPfx=!_argNext:~0,4!"
if /I "!_argPfx!"=="http" (set "CB_REGISTRY_URL=%~2" & shift & shift & goto PARSE)
:: not a URL -- use env var and leave arg for positional parsing
set "CB_REGISTRY_URL=!CB_REGISTRY_URL_ENV!"
shift
goto PARSE

:PARSE_DONE
:: collect positional arguments
if [%1]==[] (
    echo Missing image argument.
    echo\
    goto HELP
)
:: check for image:tag form
set "_ARG1=%~1"
set "_COLON_CHECK=!_ARG1::=!"
if not "!_COLON_CHECK!"=="!_ARG1!" (
    :: colon present -- split on first colon
    for /f "tokens=1,* delims=:" %%A in ("!_ARG1!") do (
        set "RAW_IMAGE=%%A"
        set "BASE_TAG=%%B"
    )
    if [%2] NEQ [] (
        echo Invalid parameter: %2
        echo\
        goto HELP
    )
) else if [%2]==[] (
    set "RAW_IMAGE=!_ARG1!"
    set "BASE_TAG=latest"
) else (
    set "RAW_IMAGE=%~1"
    set "BASE_TAG=%~2"
    if [%3] NEQ [] (
        echo Invalid parameter: %3
        echo\
        goto HELP
    )
)

:: Extract @sha256: digest if present in BASE_TAG (e.g. image:tag@sha256:hex)
set "GIVEN_DIGEST="
echo !BASE_TAG! | findstr /c:"@sha256:" >nul 2>nul
if !ERRORLEVEL! EQU 0 (
    for /f "tokens=1,2 delims=@" %%A in ("!BASE_TAG!") do (
        set "BASE_TAG=%%A"
        set "GIVEN_DIGEST=%%B"
    )
)

:: validate --registry URL
if "!CB_REGISTRY_FLAG!"=="true" if not defined CB_REGISTRY_URL (
    echo ERROR: --registry requires a URL ^(or set CB_REGISTRY_URL env var^)
    exit /b 1
)

:: Official Docker Hub images (no slash) get library/ prefix, unless a custom registry is set
set "IMAGE=!RAW_IMAGE!"
if "!CB_REGISTRY_FLAG!"=="false" (
    echo !RAW_IMAGE! | findstr /c:"/" >nul 2>nul
    if !ERRORLEVEL! NEQ 0 set "IMAGE=library/!RAW_IMAGE!"
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Daily cache -- avoid repeated registry lookups for the same image
:: Cache location: <CB_IMAGE_VERSION_RESOLVER_PATH or %TEMP%\cb\image-version-resolver-cache>\<yyyyMMdd>-<safeKey>.txt
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "CB_IMAGE_CACHE_DIR=%TEMP%\cb\image-version-resolver-cache"
if defined CB_IMAGE_VERSION_RESOLVER_PATH set "CB_IMAGE_CACHE_DIR=!CB_IMAGE_VERSION_RESOLVER_PATH!"
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd'"`) do set "TODAY=%%D"
set "CACHE_KEY=!RAW_IMAGE!:!BASE_TAG!"
set "CACHE_KEY=!CACHE_KEY::=_!"
set "CACHE_KEY=!CACHE_KEY:/=_!"
set "CACHE_FILE=!CB_IMAGE_CACHE_DIR!\!TODAY!-!CACHE_KEY!.txt"

:: For verification or private registry, skip the cache
if defined GIVEN_DIGEST goto VERIFY
if "!CB_REGISTRY_FLAG!"=="true" goto SKIP_CACHE_READ

if exist "!CACHE_FILE!" (
    for /f "usebackq delims=" %%R in ("!CACHE_FILE!") do (
        echo %%R
        exit /b 0
    )
)


:SKIP_CACHE_READ
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Detect wget in PATH; prefer wget over PowerShell for HTTP calls
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "WGET_CMD="
where wget.exe >nul 2>nul
if !ERRORLEVEL! EQU 0 set "WGET_CMD=wget.exe"

if "!CB_REGISTRY_FLAG!"=="true" goto RESOLVE_PRIVATE
if defined WGET_CMD goto RESOLVE_DOCKERHUB_WGET


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Docker Hub (PowerShell) -- obtain bearer token, resolve tag + digest
:: Note: $c=[char]94 creates '^' in PS without CMD consuming it.
::       Use bare '|' (not '^|') for PS pipeline operators inside "...".
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RESOLVE_DOCKERHUB_PS
set "PS_OUT=%TEMP%\cb\cb-image-version-resolver-%RANDOM%%RANDOM%.tmp"
powershell -NoProfile -Command ^
  "$c=[char]94; $ErrorActionPreference='Stop'; " ^
  "$image='!IMAGE!'; $rawImage='!RAW_IMAGE!'; $baseTag='!BASE_TAG!'; " ^
  "$tokenUrl='https://auth.docker.io/token?service=registry.docker.io&scope=repository:' + $image + ':pull'; " ^
  "$tok=(Invoke-RestMethod -Uri $tokenUrl).token; " ^
  "if(-not $tok){[Console]::Error.WriteLine('ERROR: Failed to get token'); exit 1}; " ^
  "$authH=@{Authorization='Bearer ' + $tok}; " ^
  "$allTags=(Invoke-RestMethod -Uri ('https://registry-1.docker.io/v2/' + $image + '/tags/list') -Headers $authH).tags; " ^
  "if(-not $allTags){[Console]::Error.WriteLine('ERROR: No tags found for ''' + $rawImage + '''. The image may not exist or may be inaccessible.'); exit 1}; " ^
  "$majorStr=''; $suffix=''; " ^
  "if($baseTag -match ($c+'([0-9]+)')){$majorStr=$Matches[1]; $suffix=$baseTag -replace ($c+'[0-9][0-9._]*'),'' }; " ^
  "if(-not $majorStr -and $baseTag -ne 'latest' -and $baseTag -ne 'edge' -and $baseTag -ne 'stable'){ " ^
  "  $variant=@($allTags | Where-Object{$_ -match ($c+'[0-9]+\.[0-9]+(\.[0-9]+)?-'+[regex]::Escape($baseTag)+'$$')}); " ^
  "  if($variant.Count -gt 0){ $newestTag=($variant | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) } " ^
  "  elseif($allTags -contains $baseTag){ $newestTag=$baseTag } " ^
  "  else{[Console]::Error.WriteLine('ERROR: Tag ''' + $baseTag + ''' not found for image ''' + $rawImage + ''''); exit 1} " ^
  "} else { " ^
  "  $trailing=@($allTags | Where-Object{$_ -match ($c+[regex]::Escape($baseTag)+'-[0-9]+\.[0-9]+$')}); " ^
  "  if($trailing.Count -gt 0){ $newestTag=($trailing | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) } " ^
  "  else{ " ^
  "    $cands=@($allTags | Where-Object{$_ -match ($c+'[0-9]')} | Where-Object{ " ^
  "      if($suffix){ $_ -match ($c+$majorStr+'([._-]|$$)') -and $_ -like ('*'+$suffix) } " ^
  "      elseif($majorStr){ $_ -match ($c+$majorStr+'(\.[0-9]+)*$$') } " ^
  "      else{ $_ -match ($c+'[0-9]+\.[0-9]+(\.[0-9]+)?$$') } " ^
  "    }); " ^
  "    if($cands.Count -eq 0){[Console]::Error.WriteLine('ERROR: No matching tags'); exit 1}; " ^
  "    $newestTag=($cands | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) " ^
  "  } " ^
  "}; " ^
  "$accept='application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.manifest.v1+json'; " ^
  "$resp=Invoke-WebRequest -Uri ('https://registry-1.docker.io/v2/' + $image + '/manifests/' + $newestTag) -Headers ($authH + @{Accept=$accept}) -Method Head -UseBasicParsing; " ^
  "$digest=$resp.Headers['Docker-Content-Digest']; " ^
  "if(-not $digest){[Console]::Error.WriteLine('ERROR: No digest'); exit 1}; " ^
  "Write-Output ($rawImage + ':' + $newestTag + '@' + $digest)" > "!PS_OUT!" 2>&1
goto CHECK_RESULT


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Docker Hub (wget) -- wget for HTTP calls, PowerShell for JSON/sorting
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RESOLVE_DOCKERHUB_WGET
set "TOK_FILE=%TEMP%\cb\cb-image-version-resolver-tok-%RANDOM%.tmp"
set "TAGS_FILE=%TEMP%\cb\cb-image-version-resolver-tags-%RANDOM%.tmp"
set "HDRS_FILE=%TEMP%\cb\cb-image-version-resolver-hdrs-%RANDOM%.tmp"
set "NTAG_FILE=%TEMP%\cb\cb-image-version-resolver-ntag-%RANDOM%.tmp"
set "DG_FILE=%TEMP%\cb\cb-image-version-resolver-dg-%RANDOM%.tmp"

:: 1. Get auth token
!WGET_CMD! -q --no-check-certificate -O "!TOK_FILE!" "https://auth.docker.io/token?service=registry.docker.io&scope=repository:!IMAGE!:pull" 2>nul
if !ERRORLEVEL! NEQ 0 (echo ERROR: Failed to get Docker Hub token 1>&2 & del /f /q "!TOK_FILE!" >nul 2>nul & exit /b 1)
set "DH_TOKEN="
for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "(Get-Content '!TOK_FILE!' -Raw | ConvertFrom-Json).token"`) do set "DH_TOKEN=%%T"
del /f /q "!TOK_FILE!" >nul 2>nul
if not defined DH_TOKEN (echo ERROR: Failed to parse auth token 1>&2 & exit /b 1)

:: 2. Get tags list
!WGET_CMD! -q --no-check-certificate -O "!TAGS_FILE!" --header="Authorization: Bearer !DH_TOKEN!" "https://registry-1.docker.io/v2/!IMAGE!/tags/list" 2>nul
if !ERRORLEVEL! NEQ 0 (echo ERROR: No tags found for '!RAW_IMAGE!'. The image may not exist or may be inaccessible. 1>&2 & del /f /q "!TAGS_FILE!" >nul 2>nul & exit /b 1)

:: 3. Filter and sort tags using PowerShell
powershell -NoProfile -Command ^
  "$c=[char]94; $ErrorActionPreference='Stop'; $baseTag='!BASE_TAG!'; $rawImage='!RAW_IMAGE!'; " ^
  "$allTags=(Get-Content '!TAGS_FILE!' -Raw | ConvertFrom-Json).tags; " ^
  "if(-not $allTags){[Console]::Error.WriteLine('ERROR: No tags found for ''' + $rawImage + '''. The image may not exist or may be inaccessible.'); exit 1}; " ^
  "$majorStr=''; $suffix=''; " ^
  "if($baseTag -match ($c+'([0-9]+)')){$majorStr=$Matches[1]; $suffix=$baseTag -replace ($c+'[0-9][0-9._]*'),'' }; " ^
  "if(-not $majorStr -and $baseTag -ne 'latest' -and $baseTag -ne 'edge' -and $baseTag -ne 'stable'){ " ^
  "  $variant=@($allTags | Where-Object{$_ -match ($c+'[0-9]+\.[0-9]+(\.[0-9]+)?-'+[regex]::Escape($baseTag)+'$$')}); " ^
  "  if($variant.Count -gt 0){ $newestTag=($variant | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) } " ^
  "  elseif($allTags -contains $baseTag){ $newestTag=$baseTag } " ^
  "  else{[Console]::Error.WriteLine('ERROR: Tag ''' + $baseTag + ''' not found for image ''' + $rawImage + ''''); exit 1} " ^
  "} else { " ^
  "  $trailing=@($allTags | Where-Object{$_ -match ($c+[regex]::Escape($baseTag)+'-[0-9]+\.[0-9]+$')}); " ^
  "  if($trailing.Count -gt 0){ $newestTag=($trailing | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) } " ^
  "  else{ " ^
  "    $cands=@($allTags | Where-Object{$_ -match ($c+'[0-9]')} | Where-Object{ " ^
  "      if($suffix){ $_ -match ($c+$majorStr+'([._-]|$$)') -and $_ -like ('*'+$suffix) } " ^
  "      elseif($majorStr){ $_ -match ($c+$majorStr+'(\.[0-9]+)*$$') } " ^
  "      else{ $_ -match ($c+'[0-9]+\.[0-9]+(\.[0-9]+)?$$') } " ^
  "    }); " ^
  "    if($cands.Count -eq 0){[Console]::Error.WriteLine('ERROR: No matching tags'); exit 1}; " ^
  "    $newestTag=($cands | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) " ^
  "  } " ^
  "}; " ^
  "Write-Output $newestTag" > "!NTAG_FILE!" 2>&1
if !ERRORLEVEL! NEQ 0 (type "!NTAG_FILE!" 1>&2 & del /f /q "!TAGS_FILE!" "!NTAG_FILE!" >nul 2>nul & exit /b 1)
set "NEWEST_TAG="
for /f "usebackq delims=" %%N in ("!NTAG_FILE!") do set "NEWEST_TAG=%%N"
del /f /q "!TAGS_FILE!" "!NTAG_FILE!" >nul 2>nul
if not defined NEWEST_TAG (echo ERROR: No matching tag found 1>&2 & exit /b 1)

:: 4. HEAD request to get Docker-Content-Digest header
set "ACCEPT=application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.manifest.v1+json"
!WGET_CMD! -q --no-check-certificate --spider -S --header="Authorization: Bearer !DH_TOKEN!" --header="Accept: !ACCEPT!" "https://registry-1.docker.io/v2/!IMAGE!/manifests/!NEWEST_TAG!" 2>"!HDRS_FILE!"
powershell -NoProfile -Command ^
  "$c=[char]94; $ErrorActionPreference='Stop'; " ^
  "$h=Get-Content '!HDRS_FILE!' | Where-Object{$_ -match 'Docker-Content-Digest'}; " ^
  "if(-not $h){[Console]::Error.WriteLine('ERROR: No digest header'); exit 1}; " ^
  "Write-Output (@($h)[0].Trim() -replace ($c+'Docker-Content-Digest:\s*'),'')" > "!DG_FILE!" 2>&1
if !ERRORLEVEL! NEQ 0 (type "!DG_FILE!" 1>&2 & del /f /q "!HDRS_FILE!" "!DG_FILE!" >nul 2>nul & exit /b 1)
set "DIGEST="
for /f "usebackq delims=" %%D in ("!DG_FILE!") do set "DIGEST=%%D"
del /f /q "!HDRS_FILE!" "!DG_FILE!" >nul 2>nul
if not defined DIGEST (echo ERROR: Empty digest 1>&2 & exit /b 1)

set "RESOLVED_REF=!RAW_IMAGE!:!NEWEST_TAG!@!DIGEST!"
goto WRITE_CACHE


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Private registry -- Basic/Bearer auth, then resolve newest tag + digest
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RESOLVE_PRIVATE
set "PS_OUT=%TEMP%\cb\cb-image-version-resolver-%RANDOM%%RANDOM%.tmp"
powershell -NoProfile -Command ^
  "$c=[char]94; $ErrorActionPreference='Stop'; " ^
  "$registryUrl='!CB_REGISTRY_URL!'; $image='!IMAGE!'; $rawImage='!RAW_IMAGE!'; $baseTag='!BASE_TAG!'; " ^
  "$user='!CB_REGISTRY_USER!'; $pass='!CB_REGISTRY_PASSWORD!'; " ^
  "$pair=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($user + ':' + $pass)); " ^
  "$basicH=@{Authorization='Basic ' + $pair}; " ^
  "try { Invoke-WebRequest -Uri ($registryUrl + '/v2/') -Headers $basicH -UseBasicParsing -ErrorAction Stop | Out-Null; $authH=$basicH } " ^
  "catch { " ^
  "  $wwwAuth=''; try{$wwwAuth=$_.Exception.Response.Headers['Www-Authenticate']}catch{}; " ^
  "  if($wwwAuth -match ($c+'Basic ')){$authH=$basicH} " ^
  "  elseif($wwwAuth -match 'realm=""([^""]+)""'){ " ^
  "    $realm=$Matches[1]; $svc=''; if($wwwAuth -match 'service=""([^""]+)""'){$svc=$Matches[1]}; " ^
  "    $tokUrl=$realm + '?service=' + $svc + '&scope=repository:' + $image + ':pull'; " ^
  "    $tokResp=Invoke-RestMethod -Uri $tokUrl -Headers $basicH; " ^
  "    $tok=if($tokResp.token){$tokResp.token}else{$tokResp.access_token}; " ^
  "    $authH=@{Authorization='Bearer ' + $tok} " ^
  "  } else{[Console]::Error.WriteLine('ERROR: Auth failed'); exit 1} " ^
  "}; " ^
  "$allTags=(Invoke-RestMethod -Uri ($registryUrl + '/v2/' + $image + '/tags/list') -Headers $authH).tags; " ^
  "if(-not $allTags){[Console]::Error.WriteLine('ERROR: No tags found for ''' + $rawImage + '''. The image may not exist or may be inaccessible.'); exit 1}; " ^
  "$majorStr=''; $suffix=''; " ^
  "if($baseTag -match ($c+'([0-9]+)')){$majorStr=$Matches[1]; $suffix=$baseTag -replace ($c+'[0-9][0-9._]*'),'' }; " ^
  "if(-not $majorStr -and $baseTag -ne 'latest' -and $baseTag -ne 'edge' -and $baseTag -ne 'stable'){ " ^
  "  $variant=@($allTags | Where-Object{$_ -match ($c+'[0-9]+\.[0-9]+(\.[0-9]+)?-'+[regex]::Escape($baseTag)+'$$')}); " ^
  "  if($variant.Count -gt 0){ $newestTag=($variant | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) } " ^
  "  elseif($allTags -contains $baseTag){ $newestTag=$baseTag } " ^
  "  else{[Console]::Error.WriteLine('ERROR: Tag ''' + $baseTag + ''' not found for image ''' + $rawImage + ''''); exit 1} " ^
  "} else { " ^
  "  $trailing=@($allTags | Where-Object{$_ -match ($c+[regex]::Escape($baseTag)+'-[0-9]+\.[0-9]+$')}); " ^
  "  if($trailing.Count -gt 0){ $newestTag=($trailing | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) } " ^
  "  else{ " ^
  "    $cands=@($allTags | Where-Object{$_ -match ($c+'[0-9]')} | Where-Object{ " ^
  "      if($suffix){ $_ -match ($c+$majorStr+'([._-]|$$)') -and $_ -like ('*'+$suffix) } " ^
  "      elseif($majorStr){ $_ -match ($c+$majorStr+'(\.[0-9]+)*$$') } " ^
  "      else{ $_ -match ($c+'[0-9]+\.[0-9]+(\.[0-9]+)?$$') } " ^
  "    }); " ^
  "    if($cands.Count -eq 0){[Console]::Error.WriteLine('ERROR: No matching tags'); exit 1}; " ^
  "    $newestTag=($cands | Sort-Object{ $v=$_ -replace ('['+$c+'0-9.]'),'.'; $v=$v -replace '\.+','.'; $v=$v -replace ($c+'\.|\.$$'),''; try{[version]$v}catch{[version]'0.0'} } | Select-Object -Last 1) " ^
  "  } " ^
  "}; " ^
  "$accept='application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.manifest.v1+json'; " ^
  "$resp=Invoke-WebRequest -Uri ($registryUrl + '/v2/' + $image + '/manifests/' + $newestTag) -Headers ($authH + @{Accept=$accept}) -Method Head -UseBasicParsing; " ^
  "$digest=$resp.Headers['Docker-Content-Digest']; " ^
  "if(-not $digest){[Console]::Error.WriteLine('ERROR: No digest'); exit 1}; " ^
  "Write-Output ($rawImage + ':' + $newestTag + '@' + $digest)" > "!PS_OUT!" 2>&1


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Verification path: caller supplied a digest -- verify it matches tag
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:VERIFY
set "PS_OUT=%TEMP%\cb\cb-image-version-resolver-%RANDOM%%RANDOM%.tmp"
if "!CB_REGISTRY_FLAG!"=="true" goto VERIFY_PRIVATE

:VERIFY_DOCKERHUB
powershell -NoProfile -Command ^
  "$ErrorActionPreference='Stop'; " ^
  "$image='!IMAGE!'; $rawImage='!RAW_IMAGE!'; $baseTag='!BASE_TAG!'; $givenDigest='!GIVEN_DIGEST!'; " ^
  "$tokenUrl='https://auth.docker.io/token?service=registry.docker.io&scope=repository:' + $image + ':pull'; " ^
  "$tok=(Invoke-RestMethod -Uri $tokenUrl).token; " ^
  "if(-not $tok){[Console]::Error.WriteLine('ERROR: Failed to get token'); exit 1}; " ^
  "$authH=@{Authorization='Bearer ' + $tok}; " ^
  "$accept='application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.manifest.v1+json'; " ^
  "$resp=Invoke-WebRequest -Uri ('https://registry-1.docker.io/v2/' + $image + '/manifests/' + $baseTag) -Headers ($authH + @{Accept=$accept}) -Method Head -UseBasicParsing; " ^
  "$actualDigest=$resp.Headers['Docker-Content-Digest']; " ^
  "if($actualDigest -ne $givenDigest){ [Console]::Error.WriteLine('ERROR: Digest mismatch for ' + $rawImage + ':' + $baseTag); [Console]::Error.WriteLine('  provided: ' + $givenDigest); [Console]::Error.WriteLine('  actual:   ' + $actualDigest); exit 1 }; " ^
  "Write-Output ($rawImage + ':' + $baseTag + '@' + $givenDigest)" > "!PS_OUT!" 2>&1
goto CHECK_RESULT

:VERIFY_PRIVATE
powershell -NoProfile -Command ^
  "$c=[char]94; $ErrorActionPreference='Stop'; " ^
  "$registryUrl='!CB_REGISTRY_URL!'; $image='!IMAGE!'; $rawImage='!RAW_IMAGE!'; $baseTag='!BASE_TAG!'; $givenDigest='!GIVEN_DIGEST!'; " ^
  "$user='!CB_REGISTRY_USER!'; $pass='!CB_REGISTRY_PASSWORD!'; " ^
  "$pair=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($user + ':' + $pass)); " ^
  "$basicH=@{Authorization='Basic ' + $pair}; " ^
  "try { Invoke-WebRequest -Uri ($registryUrl + '/v2/') -Headers $basicH -UseBasicParsing -ErrorAction Stop | Out-Null; $authH=$basicH } " ^
  "catch { " ^
  "  $wwwAuth=''; try{$wwwAuth=$_.Exception.Response.Headers['Www-Authenticate']}catch{}; " ^
  "  if($wwwAuth -match ($c+'Basic ')){$authH=$basicH} " ^
  "  elseif($wwwAuth -match 'realm=""([^""]+)""'){ " ^
  "    $realm=$Matches[1]; $svc=''; if($wwwAuth -match 'service=""([^""]+)""'){$svc=$Matches[1]}; " ^
  "    $tokUrl=$realm + '?service=' + $svc + '&scope=repository:' + $image + ':pull'; " ^
  "    $tokResp=Invoke-RestMethod -Uri $tokUrl -Headers $basicH; " ^
  "    $tok=if($tokResp.token){$tokResp.token}else{$tokResp.access_token}; " ^
  "    $authH=@{Authorization='Bearer ' + $tok} " ^
  "  } else{[Console]::Error.WriteLine('ERROR: Auth failed'); exit 1} " ^
  "}; " ^
  "$accept='application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.manifest.v1+json'; " ^
  "$resp=Invoke-WebRequest -Uri ($registryUrl + '/v2/' + $image + '/manifests/' + $baseTag) -Headers ($authH + @{Accept=$accept}) -Method Head -UseBasicParsing; " ^
  "$actualDigest=$resp.Headers['Docker-Content-Digest']; " ^
  "if($actualDigest -ne $givenDigest){ [Console]::Error.WriteLine('ERROR: Digest mismatch for ' + $rawImage + ':' + $baseTag); [Console]::Error.WriteLine('  provided: ' + $givenDigest); [Console]::Error.WriteLine('  actual:   ' + $actualDigest); exit 1 }; " ^
  "Write-Output ($rawImage + ':' + $baseTag + '@' + $givenDigest)" > "!PS_OUT!" 2>&1
goto CHECK_RESULT


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check result from PS-based paths, then fall through to cache+output
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CHECK_RESULT
if !ERRORLEVEL! NEQ 0 (
    type "!PS_OUT!" 1>&2
    del /f /q "!PS_OUT!" >nul 2>nul
    exit /b 1
)
for /f "usebackq delims=" %%R in ("!PS_OUT!") do set "RESOLVED_REF=%%R"
del /f /q "!PS_OUT!" >nul 2>nul


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Write daily cache, clean stale entries, and emit output
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:WRITE_CACHE
if "!CB_REGISTRY_FLAG!"=="true" goto EMIT_ONLY
if not exist "!CB_IMAGE_CACHE_DIR!" mkdir "!CB_IMAGE_CACHE_DIR!" >nul 2>nul
(echo !RESOLVED_REF!)>"!CACHE_FILE!"
:: Remove stale cache files (date prefix older than today)
for %%F in ("!CB_IMAGE_CACHE_DIR!\*.txt") do (
    set "_fn=%%~nF"
    for /f "tokens=1 delims=-" %%D in ("!_fn!") do (
        if "%%D" LSS "!TODAY!" del /f /q "%%F" >nul 2>nul
    )
)
:EMIT_ONLY
echo !RESOLVED_REF!
endlocal
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:HELP
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %PN% - Resolve a Docker Hub image reference to a pinned tag@digest.
echo\
echo usage: %PN% [OPTION] ^<image^>[^:^<tag^>]
echo    or: %PN% [OPTION] ^<image^> ^<tag^>
echo\
echo Overview of the available OPTIONs:
echo  -h, --help              Show this help message.
echo  --registry ^<url^>        Use a remote Docker Registry v2 instead of Docker Hub.
echo                          The URL can also be set via the CB_REGISTRY_URL env var.
echo                          Requires CB_REGISTRY_USER and CB_REGISTRY_PASSWORD env vars.
echo\
echo Arguments:
echo  ^<image^>                 Docker Hub image name, e.g. alpine or library/alpine.
echo                          Official images (no namespace) are automatically prefixed
echo                          with 'library/', e.g. alpine -^> library/alpine.
echo                          This auto-prefix is not applied when --registry is used.
echo  ^<tag^>                   Tag to resolve. Defaults to 'latest' when omitted.
echo                          Numeric tags are resolved to their newest patch/build
echo                          variant on the same major version line.
echo\
echo Examples
echo :: resolve the newest alpine tag and its digest:
echo #^> %PN% alpine
echo\
echo :: resolve via explicit latest tag (colon form):
echo #^> %PN% alpine:latest
echo\
echo :: resolve via two-argument form:
echo #^> %PN% library/alpine latest
echo\
echo :: resolve the newest eclipse-temurin 25 JRE on Alpine:
echo #^> %PN% eclipse-temurin:25-jre-alpine
echo\
echo :: resolve the newest eclipse-temurin 25 JDK on Alpine:
echo #^> %PN% eclipse-temurin:25-jdk-alpine
echo\
echo :: resolve from a private registry using env-var credentials:
echo #^> set CB_REGISTRY_USER=user ^& set CB_REGISTRY_PASSWORD=pass ^& %PN% myapp:1.0 --registry https://reg.example.com
echo\
exit /b 1
