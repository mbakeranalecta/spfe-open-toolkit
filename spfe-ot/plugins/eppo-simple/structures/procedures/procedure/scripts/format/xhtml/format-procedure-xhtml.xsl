<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="procedure">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="procedure/steps/step">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="procedure/title">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="procedure/steps">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="procedure/steps/step/title">
        <h4>
            <xsl:text>Step&#160;</xsl:text>
            <xsl:value-of select="count(../preceding-sibling::*:step)+1"/>
            <xsl:text>:&#160;</xsl:text>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>
    
</xsl:stylesheet>