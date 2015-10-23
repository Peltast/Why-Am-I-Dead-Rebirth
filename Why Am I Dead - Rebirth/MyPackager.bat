@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat
 
echo. Generating .exe directory
 
set AIR_TARGET=
set OPTIONS=
set OUTPUT=myApp/
call adt -package %OPTIONS% %SIGNING_OPTIONS% -target bundle %OUTPUT% %APP_XML% %FILE_OR_DIR% -extdir lib/
 
pause