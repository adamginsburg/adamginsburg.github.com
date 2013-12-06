@ECHO OFF

echo _______________________________________________________________________________
echo.
echo   Updated 28 Aug 2001 by Zoltan Milosevic; zoltanm@nickname.net
echo.
echo   This batch file sets the proper file permissions on Windows NT/2000 for the
echo   AXS Site Tracking System.  Use "setperms.sh" for Unix systems.
echo.
echo   To run, open a command prompt or telnet window and navigate to the folder
echo   containing the AXS scripts and data files.  Type the name for
echo   this script, and hit Enter.  All proper permissions will be set.
echo.
echo   Run this file from an account which has the "Change Permission" privilege
echo   for all files in the "axs" folder.  Typically the Administrator or
echo   file owner accounts would be appropriate.
echo.
echo   For more information, visit http://www.xav.com/scripts/axs/
echo.
echo _______________________________________________________________________________
echo.


REM	This command grants Permission level "Change" to the "Everyone" group.
REM	Other permissions are left in place.

cacls log.txt /T /E /C /P Everyone:C
cacls helloworld.pl /T /E /C /P Everyone:C
attrib -R log.txt /S /D
attrib -R helloworld.pl /S /D
