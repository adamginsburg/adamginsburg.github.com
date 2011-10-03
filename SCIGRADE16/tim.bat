echo off

rem   250MHz Version
rem   DOWNLOAD selects application code to be loaded from EEPROM or 
rem   downloaded from the host over the fiber optic link
rem   DOWNLOAD = HOST or EEPROM

SET DOWNLOAD=HOST
SET WAVEFORM_FILE=H1RG.waveforms
SET DST_FILE=tim

c:\LEACH\pc_tools\CLAS563\BIN\asm56300 -b -ltim.ls -d DOWNLOAD %DOWNLOAD% -d WAVEFORM_FILE %WAVEFORM_FILE% tim.asm
c:\LEACH\pc_tools\CLAS563\BIN\dsplnk -btim.cld -v tim.cln 
del "%DST_FILE%".lod
c:\LEACH\pc_tools\CLAS563\BIN\cldlod tim.cld > "%DST_FILE%".lod
del tim.cln
del tim.cld

if "%DOWNLOAD%" == "HOST" (
	echo on
	echo Created file 'tim.lod' for downloading over optical fiber
	echo off
)

if "%DOWNLOAD%" == "EEPROM" (
	echo on
	echo Created Motorola S-record file 'tim.s' for EEPROM burning
	echo off
	c:\LEACH\pc_tools\CLAS563\BIN\srec -bs tim.lod
	del tim.lod 
)

echo on
