#!/bin/bash

if [ -e "$1" ]; then

    SPFE_TEMP_BUILD_FILE=$(tempfile)

    java -classpath $SPFEOT_HOME/tools/saxon9he/saxon9he.jar net.sf.saxon.Transform \
    -s:$1 \
    -xsl:$SPFEOT_HOME/scripts/config/config.xsl \
    -o:$SPFE_TEMP_BUILD_FILE \
    HOME=$HOME \
    SPFEOT_HOME=$SPFEOT_HOME \
    SPFE_BUILD_COMMAND=$2
    
    ant $2 -f $SPFE_TEMP_BUILD_FILE -lib $SPFEOT_HOME/tools/xml-commons-resolver-1.2/resolver.jar $3 $4 $5 $6 $7 $8
  
else

    echo "Config file $1 not found."

fi

   
