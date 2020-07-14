@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-custom-sample.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


set CUSTOM_CB_LINE=****************************************************************************************
set CUSTOM_PN=%~nx0
set "CUSTOM_CB_SCRIPT_PATH=%~dp0"
set "CUSTOM_PN_FULL=%CB_SCRIPT_PATH%%PN%"
set "CB_CURRENT_PATH=%CD%"

if %0X==X goto CUSTOM_END
if .%1==.start goto CUSTOM_START
if .%1==.build-start goto CUSTOM_BUILD_START
if .%1==.build-end goto CUSTOM_BUILD_END
if .%1==.new-start goto CUSTOM_NEW_START
if .%1==.new-end goto CUSTOM_NEW_END
if .%1==.install-start goto CUSTOM_INSTALL_START
if .%1==.install-end goto CUSTOM_INSTALL_END
if .%1==.extract-archive-start goto CUSTOM_EXTRACT_ARCHIVE_START
if .%1==.extract-archive-end goto CUSTOM_EXTRACT_ARCHIVE_END
if .%1==.error-end goto CUSTOM_ERROR_END
if .%1==.print-variable goto CUSTOM_PRINT_VARIABLE
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CUSTOM_CB_LINE%
echo.
echo START SAMPLE
echo.
echo %CUSTOM_CB_LINE%
set CB_LINE=%CUSTOM_CB_LINE%

goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_BUILD_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START CUSTOM BUILD
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_BUILD_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END CUSTOM BUILD
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START NEW CUSTOM PROJECT
echo %CB_WIZARD_PARAMETERS%

goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END NEW CUSTOM PROJECT
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_INSTALL_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START CUSTOM INSTALL 
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_INSTALL_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END CUSTOM INSTALL
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_EXTRACT_ARCHIVE_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START EXTRACT ARCHIVE
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_EXTRACT_ARCHIVE_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END EXTRACT ARCHIVE
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_ERROR_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%CUSTOM ERROR MESSAGE
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_PRINT_VARIABLE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo    %%CB_CUSTOM_SETTING%%: %CB_CUSTOM_SETTING%
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::