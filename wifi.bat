REM Wifi Signal Strength
REM By Fredrik Rodin 2016


@ECHO off
Setlocal EnableDelayedExpansion
:restart

TITLE Wifi Signal Strength

REM all variables
SET /A found=0
SET /A loop=0
SET signal=0
SET /A sigtot=0
SET /A sigavg=0
SET /A sigqual=0
SET /A sigqualavg=0
SET /A sigtime=0
SET /A sighigh=0
SET /A siglow=0
SET mydatefile=0
SET mydate=0
SET mytime=0
SET repeat=0
SET /A repeatloop=0
FOR	/F %%a IN ('COPY /Z "%~dpf0" NUL') DO SET "CR=%%a"

REM set, in seconds, how long to wait between each loop
SET rep=1

CLS
ECHO.
ECHO --------------------
ECHO Wifi Signal Strength
ECHO --------------------
ECHO.
SET /P repeat= Run for X minutes:
ECHO.

REM Sets the date for the filename
FOR /f %%a in ('date /t') do (SET mydatefile=%%a)

REM multiply by 60 to get minutes
SET /A repeat=!repeat!*60


:start
SET /A "spinner=(spinner + 1) %% 4"
SET "spinChars=\|/-"
<NUL SET /p ".=Loading !spinChars:~%spinner%,1!!CR!"

REM wait X seconds between the loops
TIMEOUT /t %rep% /nobreak > NUL

REM Run the wifi status loop
NETSH wlan show interface > tmp_wifi_stat.txt

FOR /F "tokens=*" %%A IN (tmp_wifi_stat.txt) DO (
	FOR /D %%x IN (%%A) DO (
		REM find the line with "Signal"
		IF %%x==Signal (		
			SET /A found=2
		)
		REM Found signal, lets increment to find the actual value
		IF !found!==2 (
			SET /A loop+=1
		)
		REM found third entry, the wifi signal strength
		IF !loop!==3 (
			SET signal=%%x
			SET /A signal=!signal:~0,-1!
			SET /A sigqual=!signal!/2-100
		)
	)
)
REM reset loop-parameters
SET found=0
SET loop=0


REM Add the signal strength to the total sum
SET /A "sigtot+=!signal!"

REM Set time and date
REM FOR /f %%a in ('time /t') do (SET mytime=%%a)
SET mytime=%TIME:~0,-3%
FOR /f %%a in ('date /t') do (SET mydate=%%a)

REM write data to file
ECHO !mydate!,!mytime!,!signal!,!sigqual!>>wifidata_!mydatefile!.txt

REM Restart the loop if there is any time left.
SET /A repeatloop+=1
IF !repeatloop! LSS !repeat! (GOTO start)


:finish
REM figure out some averages strengths etc
SET /A sigavg=!sigtot!/!repeatloop!
SET /A sigtime=!repeatloop!/60
SET /A sigqualavg=((!sigavg!/2)-100)

CLS
ECHO.
ECHO --------------------
ECHO Wifi Signal Strength
ECHO --------------------
ECHO.
ECHO Ran for ~!sigtime! Minutes
ECHO Average Signalstrength was: !sigavg! / !sigqualavg! dBm
ECHO.

:eof
REM remove the temp-file, clear variables and exit the script
DEL tmp_wifi_stat.txt
SET found=
SET loop=
SET loop=
SET signal=
SET sigtot=
SET sigavg=
SET sighigh=
SET siglow=
SET mydatefile=
SET mydate=
SET mytime=
SET repeat=
SET repeatloop=
SET CR=
EXIT /B 0
