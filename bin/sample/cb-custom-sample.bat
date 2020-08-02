@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-custom-sample.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: define parameters
set CUSTOM_CB_LINE=****************************************************************************************


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: MAIN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if %0X==X goto CUSTOM_END
if .%1==. goto CUSTOM_END
if .%1==.start shift & goto CUSTOM_START
if .%1==.build-start shift & goto CUSTOM_BUILD_START
if .%1==.build-end shift & goto CUSTOM_BUILD_END
if .%1==.new-project-start shift & goto CUSTOM_NEW_PROJECT_START
if .%1==.new-project-end shift & goto CUSTOM_NEW_PROJECT_END
if .%1==.install-start shift & goto CUSTOM_INSTALL_START
if .%1==.install-end shift & goto CUSTOM_INSTALL_END
if .%1==.install-package-start shift & goto CUSTOM_INSTALL_PACKAGE_START
if .%1==.install-package-end shift & goto CUSTOM_INSTALL_PACKAGE_END
if .%1==.extract-archive-start shift & goto CUSTOM_EXTRACT_ARCHIVE_START
if .%1==.extract-archive-end shift & goto CUSTOM_EXTRACT_ARCHIVE_END
if .%1==.setenv-start shift & goto CUSTOM_SETENV_START
if .%1==.setenv-end shift & goto CUSTOM_SETENV_END
if .%1==.error-end shift & goto CUSTOM_ERROR_END
echo %CB_LINEHEADER%Unknown parameter: %1
exit /b 1


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
echo %CB_LINEHEADER%START BUILD %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_BUILD_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END BUILD %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START NEW PROJECT %1 %2 %3 %4 %5 %6 %7 %8 %9

:: define own project types
set "CB_CUSTOM_PROJECT_CONFIGFILE=%TEMP%\cb-project-types-custom-%RANDOM%%RANDOM%.tmp"
echo java-library = Simple java library^|projectName^|projectRootPackageName^|projectGroupId^|projectComponentId^|projectDescription >> %CB_CUSTOM_PROJECT_CONFIGFILE%
echo config = Configuration Project^|projectName^|projectGroupId^|projectComponentId^|projectDescription >> %CB_CUSTOM_PROJECT_CONFIGFILE%
echo my-own-type = My own type^|projectName^|projectGroupId^|projectDescription >> %CB_CUSTOM_PROJECT_CONFIGFILE%
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END NEW PROJECT %1 %2 %3 %4 %5 %6 %7 %8 %9
del %CB_CUSTOM_PROJECT_CONFIGFILE%
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_INSTALL_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START INSTALL %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_INSTALL_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END INSTALL %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_INSTALL_PACKAGE_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START PACKAGE INSTALL %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_INSTALL_PACKAGE_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END PACKAGE INSTALL %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_EXTRACT_ARCHIVE_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START EXTRACT ARCHIVE %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_EXTRACT_ARCHIVE_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END EXTRACT ARCHIVE %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_SETENV_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%START SETENV %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_SETENV_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%END SETENV %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_ERROR_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %CB_LINEHEADER%ENDED WITH ERROR: %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::