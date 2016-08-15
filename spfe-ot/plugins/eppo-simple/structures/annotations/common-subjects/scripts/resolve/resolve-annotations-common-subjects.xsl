<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    version="2.0">
    
    <xsl:template match="p/annotation | string/annotation | p/phrase/annotation | string/phrase/annotation">
        <annotation>
            <xsl:attribute name="type" select="@type"/>
            <xsl:attribute name="key" select="if (@specifically) then @specifically else normalize-space(.)"/>
            <xsl:apply-templates/>
        </annotation>
    </xsl:template>
    
    <xsl:template match="p/task | string/task">
        <annotation>
            <xsl:attribute name="type">task</xsl:attribute>
            <xsl:attribute name="key" select="if (@specifically) then @specifically else normalize-space(.)"/>
            <xsl:apply-templates/>
        </annotation>
    </xsl:template>
    
    <xsl:template match="p/term | string/term">
        <annotation>
            <xsl:attribute name="type">term</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </annotation>
    </xsl:template>
    
    <xsl:template match="p/feature | string/feature">
        <annotation>
            <xsl:attribute name="type">feature</xsl:attribute>
            <xsl:attribute name="key" select="if (@specifically) then @specifically else normalize-space(.)"/>
            <xsl:apply-templates/>
        </annotation>
    </xsl:template>
    
    <xsl:template match="p/concept | string/concept">
        <annotation>
            <xsl:attribute name="type">concept</xsl:attribute>
            <xsl:attribute name="key" select="if (@specifically) then @specifically else normalize-space(.)"/>
            <xsl:apply-templates/>
        </annotation>
    </xsl:template>

</xsl:stylesheet>