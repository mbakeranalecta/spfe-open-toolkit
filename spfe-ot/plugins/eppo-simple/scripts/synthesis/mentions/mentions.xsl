<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:mention="mention">
    
    <xsl:template match="*:body//*:task">
        <mention type="task" key="{normalize-space(.)}"><xsl:apply-templates/></mention>
    </xsl:template>
    <xsl:template match="*:body//*:term">
        <mention type="term" key="{normalize-space(.)}"><xsl:apply-templates/></mention>
    </xsl:template>
    <xsl:template match="*:body//*:feature">
        <mention type="feature" key="{normalize-space(.)}"><xsl:apply-templates/></mention>
    </xsl:template>


    <xsl:template match="*:xml-element-name">
        <name type="xpath" key="{normalize-space(if (@xpath) then @xpath else .)}">
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="*:xml-attribute-name">
        <name type="xpath" key="{normalize-space(if (@xpath) then @xpath else .)}">
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="*:xpath">
        <name type="xpath" key="{normalize-space(.)}">
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="*:directory-name">
        <name type="directory-name" key="{normalize-space(.)}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    <xsl:template match="*:document-name">
        <name type="document-name" key="{normalize-space(.)}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    <xsl:template match="*:file-name">
        <name type="file-name" key="{normalize-space(.)}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="*:product-name">
        <name type="product-name" key="{normalize-space(.)}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>

    <xsl:template match="*:tool-name">
        <name type="tool-name" key="{normalize-space(.)}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="*:xml-namespace-uri">
        <name type="xml-namspace-uri" key="{normalize-space(.)}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>

</xsl:stylesheet>