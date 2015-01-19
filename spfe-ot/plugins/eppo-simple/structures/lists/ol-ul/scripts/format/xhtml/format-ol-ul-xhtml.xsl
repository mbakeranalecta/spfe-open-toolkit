<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="ul">
        <ul>
            <xsl:if test="@hint">
                <xsl:attribute name="class" select="@hint"/>
            </xsl:if>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    <xsl:template match="ol">
        <ol>
            <xsl:if test="@hint">
                <xsl:attribute name="class" select="@hint"/>
            </xsl:if>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    
    <xsl:template match="li">
        <li>
            <xsl:if test="@hint">
                <xsl:attribute name="class" select="@hint"/>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>    
    
    
</xsl:stylesheet>