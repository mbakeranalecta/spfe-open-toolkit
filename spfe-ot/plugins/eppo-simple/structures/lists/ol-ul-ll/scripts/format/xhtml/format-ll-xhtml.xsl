<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="ll">
        <ol class="labeled-list">
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    
    <xsl:template match="ll/li">
        <li>
            <p>
                <b>
                    <xsl:apply-templates select="label"/>
                    <xsl:text> - </xsl:text>
                </b>
                <xsl:apply-templates select="p"/>
            </p>
        </li>
    </xsl:template>
    
    <xsl:template match="ll/li/label">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="ll/li/p">
        <xsl:apply-templates/>
    </xsl:template>
    
    
</xsl:stylesheet>