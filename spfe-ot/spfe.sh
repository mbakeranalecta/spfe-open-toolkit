#!/bin/bash

# This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.
# (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved.

if [ -e "$1" ]; then

    if [ $SPFE_BUILD_DIR == ""]; then 
        SPFE_BUILD_DIR=$HOME/spfebuild 
    fi

    echo "Building in directory: $SPFE_BUILD_DIR"

    SPFE_TEMP_BUILD_FILE=$SPFE_BUILD_DIR/temp/spfebuild.xml

    java -classpath $SPFEOT_HOME/tools/saxon9he/saxon9he.jar net.sf.saxon.Transform \
    -xsl:$SPFEOT_HOME/1.0/scripts/config/config.xsl \
    -it:main \
    configfile=$PWD/$1 \
    HOME=$HOME \
    SPFEOT_HOME=$SPFEOT_HOME \
    SPFE_BUILD_DIR=$SPFE_BUILD_DIR \
    SPFE_BUILD_COMMAND=$2
    
    rc=$?
    if [[ $rc != 0 ]] ; then
        echo "An error occurred interpreting the configuration file."
        exit $rc
    fi
    
    ant $2 -f $SPFE_TEMP_BUILD_FILE -lib $SPFEOT_HOME/tools/xml-commons-resolver-1.2/resolver.jar -emacs  $3 $4 $5 $6 $7 $8
  
else

    echo "Config file $1 not found."

fi

   
