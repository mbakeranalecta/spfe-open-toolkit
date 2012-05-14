@ECHO OFF
REM This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.
REM (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved.
if "%1"=="" goto NOCONFIGFILE
if not exist %1 goto CONFIGFILEMISSING

set SPFE_TEMP_BUILD_FILE=%TEMP%/spfetemp%RANDOM%.xml
java -classpath %SPFEOT_HOME%/tools/saxon9he/saxon9he.jar net.sf.saxon.Transform -s:%1 -xsl:%SPFEOT_HOME%/scripts/config/config.xsl -o:%SPFE_TEMP_BUILD_FILE% HOME=%HOMEDRIVE%%HOMEPATH% SPFEOT_HOME=%SPFEOT_HOME% SPFE_BUILD_COMMAND=%2

ant %2 -f %SPFE_TEMP_BUILD_FILE% -lib  %SPFEOT_HOME%\tools\xml-commons-resolver-1.2\resolver.jar %3 %4 %5 %6 %7 %8 

goto END

:CONFIGFILEMISSING
    echo Config file %1 not found.
	goto END

:NOCONFIGFILE
	echo No config file specified.
	echo Syntax is: spfe config-file build-command 

:END

