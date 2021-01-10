@ECHO OFF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: cb-custom.bat
::
:: Copyright by toolarium, all rights reserved.
:: MIT License: https://mit-license.org
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: MAIN
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if %0X==X goto CUSTOM_END
if .%1==. goto CUSTOM_END
if .%1==.start shift & goto CUSTOM_START
if .%1==.build-start shift & goto CUSTOM_BUILD_START
if .%1==.build-end shift & goto CUSTOM_BUILD_END
if .%1==.new-project-start shift & goto CUSTOM_NEW_PROJECT_START
if .%1==.new-project-validate-name shift & goto CUSTOM_NEW_PROJECT_VALIDATE_NAME
if .%1==.new-project-validate-rootpackagename shift & goto CUSTOM_NEW_PROJECT_VALIDATE_ROOTPACKAGENAME
if .%1==.new-project-validate-groupid shift & goto CUSTOM_NEW_PROJECT_VALIDATE_GROUPID
if .%1==.new-project-validate-componentid shift & goto CUSTOM_NEW_PROJECT_VALIDATE_COMPONENTID
if .%1==.new-project-validate-description shift & goto CUSTOM_NEW_PROJECT_VALIDATE_DESCRIPTION
if .%1==.new-project-end shift & goto CUSTOM_NEW_PROJECT_END
if .%1==.install-start shift & goto CUSTOM_INSTALL_START
if .%1==.install-end shift & goto CUSTOM_INSTALL_END
if .%1==.download-package-start shift & goto CUSTOM_DOWNLOAD_PACKAGE_START
if .%1==.download-package-end shift & goto CUSTOM_DOWNLOAD_PACKAGE_END
if .%1==.extract-package-start shift & goto CUSTOM_EXTRACT_PACKAGE_START
if .%1==.extract-package-end shift & goto CUSTOM_EXTRACT_PACKAGE_END
if .%1==.setenv-start shift & goto CUSTOM_SETENV_START
if .%1==.setenv-end shift & goto CUSTOM_SETENV_END
if .%1==.custom-config-update-end shift & goto CUSTOM_CONFIG_UPDATE_END
if .%1==.error-end shift & goto CUSTOM_ERROR_END
echo %CB_LINEHEADER%Unknown parameter: %1
exit /b 1


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%START START %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_BUILD_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%START BUILD %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_BUILD_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%END BUILD %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%START NEW PROJECT %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_VALIDATE_NAME
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%VALIDATE NAME %1 %2 %3 %4 %5 %6 %7 %8 %9
:: invalid project name: exit /b 1
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_VALIDATE_ROOTPACKAGENAME
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%VALIDATE ROOTPACKAGENAME %1 %2 %3 %4 %5 %6 %7 %8 %9
:: invalid rootpackagename: exit /b 1
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_VALIDATE_GROUPID
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%VALIDATE GROUPID %1 %2 %3 %4 %5 %6 %7 %8 %9
:: invalid group id: exit /b 1
exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_VALIDATE_COMPONENTID
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%VALIDATE COMPONENTID %1 %2 %3 %4 %5 %6 %7 %8 %9
:: invalid component id: exit /b 1
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_VALIDATE_DESCRIPTION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%VALIDATE DESCRIPTION %1 %2 %3 %4 %5 %6 %7 %8 %9
:: invalid description: exit /b 1
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_NEW_PROJECT_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%END NEW PROJECT %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_INSTALL_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%START INSTALL %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_INSTALL_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%END INSTALL %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_DOWNLOAD_PACKAGE_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%START DOWNLOAD PACKAGE %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_DOWNLOAD_PACKAGE_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%END DOWNLOAD PACKAGE %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_EXTRACT_PACKAGE_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%START EXTRACT PACKAGE %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_EXTRACT_PACKAGE_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%END EXTRACT PACKAGE %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_SETENV_START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%START SETENV %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_SETENV_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%END SETENV %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_CONFIG_UPDATE_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%CUSTOM CONFIG UPDATE [%CB_CUSTOM_CONFIG_VERSION%]
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_ERROR_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::echo %CB_LINEHEADER%ENDED WITH ERROR: %1 %2 %3 %4 %5 %6 %7 %8 %9
goto CUSTOM_END


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CUSTOM_END
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::