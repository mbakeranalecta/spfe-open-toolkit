<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->

<!-- FIXME: does this belong with the data type or with the text object type??? -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sdto="http://spfeopentoolkit.org/ns/spfe-docs/text-objects"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:param name="topic-set-id"/>
    
    <xsl:variable name="config" as="element(config:spfe)">
        <xsl:sequence select="/config:spfe"/>
    </xsl:variable>
    
    <xsl:param name="sources-to-extract-content-from"/>	
    <xsl:variable name="state-detection" select="sf:get-sources($sources-to-extract-content-from)"/>
    
    <xsl:template name="main" >
        <!-- Create the root "extracted-content element" -->
        <xsl:result-document href="file:///{concat($config/config:content-set-build, '/topic-sets/', $topic-set-id, '/extract/out/schema-defs.xml')}" method="xml" indent="no" omit-xml-declaration="no">
            
            <xsl:apply-templates select="$state-detection"/>
            
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>