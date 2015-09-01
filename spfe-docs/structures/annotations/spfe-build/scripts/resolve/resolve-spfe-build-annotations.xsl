<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://spfeopentoolkit.org/ns/spfe-docs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs"
    version="2.0">

    <xsl:template match="p/config-setting | string/config-setting">
        <name>
            <xsl:attribute name="type">config-setting</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:attribute name="namespace">http://spfeopentoolkit.org/ns/spfe-ot/config</xsl:attribute> 
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="p/ant-element | string/ant-element">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:attribute name="namespace">ANT</xsl:attribute> 
            <xsl:apply-templates/>
        </name>
    </xsl:template> 

    <xsl:template match="p/spfe-xslt-function | string/spfe-xslt-function">
        <name>
            <xsl:attribute name="type">spfe-xslt-function</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="p/spfe-build-variable | string/spfe-build-variable">
        <name>
            <xsl:attribute name="type">spfe-build-variable</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="p/spfe-build-script | string/spfe-build-script">
        <name>
            <xsl:attribute name="type">spfe-build-script</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    
 </xsl:stylesheet>