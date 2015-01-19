<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="decoration[@class='code']">
        <tt class="decoration-code">
            <xsl:apply-templates/>
        </tt>
    </xsl:template>
    
    <xsl:template match="decoration[@class='bold']">
        <b class="decoration-bold">
            <xsl:apply-templates/>
        </b>
    </xsl:template>
    
    <xsl:template match="decoration[@class='italic']">
        <em class="decoration-italic">
            <xsl:apply-templates/>
        </em>
    </xsl:template>    
</xsl:stylesheet>