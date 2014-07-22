<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/topic-types/generic-topic"
    exclude-result-prefixes="#all">
    <!-- This is simply to suppress the error that would be raised if nothing matched the 
         root element of the fragments file. All fragments across the synthesis files are
         read by one script to create a fragments database.
    -->
    <xsl:template match="fragments"/>

</xsl:stylesheet>