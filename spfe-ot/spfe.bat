@ECHO OFF
REM This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.
REM (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved.

REM Replacing bat with py
python %SPFEOT_HOME%/spfe.py %*
GOTO END

if "%SPFE_BUILD_DIR%" == "" set SPFE_BUILD_DIR=%HOMEDRIVE%%HOMEPATH%\spfebuild
if "%1"=="-clean" goto CLEAN
if "%1"=="" goto NOCONFIGFILE
if not exist %1 goto CONFIGFILEMISSING

echo Building in directory: %SPFE_BUILD_DIR%

set SPFE_TEMP_BUILD_FILE=%SPFE_BUILD_DIR%/spfebuild.xml
set ANT_OPTS=-XX:PermSize=512m

java -classpath "%SPFEOT_HOME%/tools/saxon9he/saxon9he.jar" net.sf.saxon.Transform -it:main  -xsl:"%SPFEOT_HOME%"/1.0/scripts/config/config.xsl  -o:"%SPFE_TEMP_BUILD_FILE%" configfile="%~dpnx1" HOME="%HOMEDRIVE%%HOMEPATH%" SPFEOT_HOME="%SPFEOT_HOME%" SPFE_BUILD_DIR="%SPFE_BUILD_DIR%" SPFE_BUILD_COMMAND=%2

IF %ERRORLEVEL% NEQ 0 goto CONFIGERROR 

ant %2 -f "%SPFE_TEMP_BUILD_FILE%" -lib  "%SPFEOT_HOME%\tools\xml-commons-resolver-1.2\resolver.jar" -emacs %3 %4 %5 %6 %7 %8



goto END

:CONFIGFILEMISSING
    echo Config file %1 not found.
	goto END

:NOCONFIGFILE
	echo No config file specified.
	echo Syntax is: spfe config-file build-command 
	goto END
:CONFIGERROR
    echo An error occurred interpreting the configuration file.
	goto END
:CLEAN
    rmdir /s "%SPFE_BUILD_DIR%"

:END

