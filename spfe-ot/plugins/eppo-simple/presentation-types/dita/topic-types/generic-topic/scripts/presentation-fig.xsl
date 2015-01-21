<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all"
    version="2.0">

    
    <xsl:template match="fig">
        <fig>
            <xsl:if test="@id">
                <xsl:attribute name="fig" select="concat('fig:', @id)"/>
            </xsl:if>
            <xsl:if test="title">
                <xsl:apply-templates select="title" mode="fig-title"/>
            </xsl:if>          
        </fig>
    </xsl:template>
    
    <xsl:template match="gr:graphic-record">
        <image href="{gr:formats/gr:format[1]/gr:href}"/>
    </xsl:template>
    
    <xsl:template match="fig/caption">
            <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="fig/title"/> 
    <xsl:template match="fig/title" mode="fig-title">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    
  
    <xsl:template match="gr:*" />
    <!-- mop up any left over text fields -->
    
</xsl:stylesheet>