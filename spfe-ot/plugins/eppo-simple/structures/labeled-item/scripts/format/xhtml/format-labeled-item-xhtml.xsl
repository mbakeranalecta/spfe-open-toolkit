<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="labeled-item">
        <xsl:if test="anchor">
            <a name="{anchor/@name}">&#8194;</a>
        </xsl:if>
        <dl>
            <xsl:apply-templates/>
        </dl>
    </xsl:template>
    
    <xsl:template match="label">
        <dt>
            <xsl:apply-templates/>
        </dt>
    </xsl:template>
    
    <xsl:template match="item">
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>
    
    <!-- anchors have to be pulled outside labled items in XHTML -->
    <xsl:template match="labeled-item/anchor"/>
    
    
    
</xsl:stylesheet>