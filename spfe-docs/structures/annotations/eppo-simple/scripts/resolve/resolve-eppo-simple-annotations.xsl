<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://spfeopentoolkit.org/ns/spfe-docs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs"
    version="2.0">

    <xsl:template match="p/eppo-simple-element-name | string/eppo-simple-element-name">
        <name>
            <xsl:attribute name="type">eppo-simple-attribute-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:attribute name="namespace">http://spfeopentoolkit/ns/eppo-simple</xsl:attribute> 
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="p/eppo-simple-attribute-name | string/eppo-simple-attribute-name">
        <name>
            <xsl:attribute name="type">eppo-simple-attribute-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:attribute name="namespace">http://spfeopentoolkit/ns/eppo-simple</xsl:attribute> 
            <xsl:apply-templates/>
        </name>
    </xsl:template> 
    
    <xsl:template match="p/eppo-simple-structure-name | string/eppo-simple-structure-name">
        <name>
            <xsl:attribute name="type">eppo-simple-structure-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:attribute name="namespace">http://spfeopentoolkit/ns/eppo-simple</xsl:attribute> 
            <xsl:apply-templates/>
        </name>
    </xsl:template>

    <xsl:template match="p/eppo-simple-group-name | string/eppo-simple-group-name">
        <name>
            <xsl:attribute name="type">eppo-simple-group-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:attribute name="namespace">http://spfeopentoolkit/ns/eppo-simple</xsl:attribute> 
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
 </xsl:stylesheet>