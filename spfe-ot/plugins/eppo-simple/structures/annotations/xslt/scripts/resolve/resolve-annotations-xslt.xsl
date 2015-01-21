<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    version="2.0">
    


    <xsl:template match="p/xslt-function-name | string/xslt-function-name">
        <name>
            <xsl:attribute name="type">xslt-function-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="p/xslt-template-name | string/xslt-template-name">
        <name>
            <xsl:attribute name="type">xslt-template-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    

    <xsl:template match="p/xslt-function-parameter-name | string/xslt-function-parameter-name">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="concat('{', @parent-function-namespace, '}', @parent-function-name)"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="p/xslt-template-parameter-name | string/xslt-template-parameter-name">
        <name>
            <xsl:attribute name="type">xslt-template-parameter-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="concat('{', @parent-template-namespace, '}', @parent-template-name)"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
</xsl:stylesheet>