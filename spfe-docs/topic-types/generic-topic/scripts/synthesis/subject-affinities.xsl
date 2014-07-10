<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://spfeopentoolkit.org/spfe-docs/topic-types/generic-topic"
    xpath-default-namespace="http://spfeopentoolkit.org/spfe-docs/topic-types/generic-topic"
    version="2.0">

    <xsl:template match="config-setting">
        <name>
            <xsl:attribute name="type">config-setting</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:attribute name="namespace">http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config</xsl:attribute> 
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="ant-element">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:attribute name="namespace">ANT</xsl:attribute> 
            <xsl:apply-templates/>
        </name>
    </xsl:template> 
    
    <xsl:template match="spfe-build-property">
        <name>
            <xsl:attribute name="type">spfe-build-property</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>

    <xsl:template match="spfe-build-function">
        <name>
            <xsl:attribute name="type">spfe-build-function</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="spfe-build-variable">
        <name>
            <xsl:attribute name="type">spfe-build-variable</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="spfe-build-script">
        <name>
            <xsl:attribute name="type">spfe-build-script</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    
 </xsl:stylesheet>