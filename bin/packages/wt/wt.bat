@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: wt.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "CB_WT_RELEASE_URL=https://api.github.com/repos/microsoft/terminal/releases"
set "CB_WT_ONLY_STABLE=true"
set "CB_PACKAGE_NO_DEFAULT=true"

set cbInfoTemp=%TEMP%\toolarium-common-build_wt-info%RANDOM%%RANDOM%.txt & set cbErrorTemp=%TEMP%\toolarium-common-build_wt-error%RANDOM%%RANDOM%.txt
del %cbInfoTemp% 2>nul & del %cbErrorTemp% 2>nul
if .%CB_WT_ONLY_STABLE% == .true powershell -Command "$releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_WT_RELEASE_URL%"; $releases | ? { $_.prerelease -ne 'false' } | Select-Object -Property tag_name |  select-object -First 1 -ExpandProperty tag_name" 2>%cbErrorTemp% > %cbInfoTemp%
if .%CB_WT_ONLY_STABLE% == .false powershell -Command "$releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_WT_RELEASE_URL%" | Select-Object -First 1; Split-Path -Path $releases.zipball_url -Leaf" 2>%cbErrorTemp% > %cbInfoTemp%
if exist %cbInfoTemp% (set /pCB_WT_VERSION=<%cbInfoTemp%)
if .%CB_WT_VERSION%==. set "ERROR_INFO=Could not get remote release information." & goto CB_WT_INSTALL_FAILED
set CB_PACKAGE_VERSION=%CB_WT_VERSION:~1%
del %cbInfoTemp% 2>nul & del %cbErrorTemp% 2>nul
::zip
::powershell -Command "$releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_WT_RELEASE_URL%"; $releases | ? { $_.tag_name -eq $Env:CB_WT_VERSION } | Select-Object -Property zipball_url |  select-object -First 1 -ExpandProperty zipball_url" 2>%cbErrorTemp% > %cbInfoTemp%
:: msi
powershell -Command "$releases = Invoke-RestMethod -Headers $githubHeader -Uri "%CB_WT_RELEASE_URL%"; $releases | ? { $_.tag_name -eq $Env:CB_WT_VERSION } | Select -expand assets | select -first 1 -ExpandProperty browser_download_url" 2>%cbErrorTemp% > %cbInfoTemp%
if exist %cbInfoTemp% (set /pCB_WT_DOWNLOAD_VERSION_URL=<%cbInfoTemp%)
if .%CB_WT_DOWNLOAD_VERSION_URL%==. set "ERROR_INFO=Could not get download url of verison %CB_PACKAGE_VERSION%." & goto CB_WT_INSTALL_FAILED
del %cbInfoTemp% 2>nul & del %cbErrorTemp% 2>nul
set "CB_PACKAGE_DOWNLOAD_URL=%CB_WT_DOWNLOAD_VERSION_URL%"
::set "CB_PACKAGE_DOWNLOAD_NAME=Microsoft.WindowsTerminal_%CB_PACKAGE_VERSION%_Windows10_PreinstallKit.zip"
set "CB_PACKAGE_DOWNLOAD_NAME=Microsoft.WindowsTerminal_%CB_PACKAGE_VERSION%.msixbundle"
goto CB_WT_END

:CB_WT_INSTALL_FAILED
:CB_WT_END
:: see https://docs.microsoft.com/en-us/windows/terminal/ 
set "CB_POST_INSTALL_ACTION=%CB_HOME%\bin\cb-shortcut.bat --command %USERPROFILE%\AppData\Local\Microsoft\WindowsApps\wt.exe --icon %CB_BIN%\packages\wt\wt.ico "%USERPROFILE%\desktop\wt.lnk""


