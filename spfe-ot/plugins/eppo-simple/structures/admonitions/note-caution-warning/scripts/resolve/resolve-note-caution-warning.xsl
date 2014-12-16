<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->

<!-- Stylesheets that import this stylesheets must define the $strings variable. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" 
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all">
    
    <xsl:template match="note">
        <admonition>
            <signal-word>Note</signal-word>
            <xsl:apply-templates/>
        </admonition>
    </xsl:template>
    
    <xsl:template match="caution">
        <admonition>
            <signal-word>Caution</signal-word>
            <xsl:apply-templates/>
        </admonition>
    </xsl:template>
    
    <xsl:template match="warning">
        <admonition>
            <signal-word>Warning</signal-word>
            <xsl:apply-templates/>
        </admonition>
    </xsl:template>
    
    <xsl:template match="note/title | caution/title | warning/title">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="note/body | caution/body | warning/body">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>