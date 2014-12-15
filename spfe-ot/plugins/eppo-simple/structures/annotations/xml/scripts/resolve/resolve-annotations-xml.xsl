<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    version="2.0">
    

    <xsl:template match="p/xml-element-name | string/xml-element-name">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="p/xml-attribute-name | string/xml-attribute-name">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="p/xpath | string/xpath">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
</xsl:stylesheet>