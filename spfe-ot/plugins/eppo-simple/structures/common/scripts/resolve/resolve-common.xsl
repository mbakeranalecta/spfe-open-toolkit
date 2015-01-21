<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<!-- ===================================================
	resolve-common.xsl
	
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all" >
    
    <!-- Priority is -0.9 to set it below the generic root element match that tests for unknown roots. -->
    <!-- Using a namespace prefix here to avoid matching everything in all namespaces -->
    <xsl:template match="es:*" priority="-0.9" >
        <xsl:copy>
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>    
</xsl:stylesheet>