<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    <xsl:template match="admonition">
        <div class="admonition-{@class}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="admonition/title">
        <p class="admonition-title">
            <span class="admonition-signal-word">
                <xsl:value-of select="../signal-word"/>
            </span>
            <xsl:text>: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="admonition/signal-word"/>
    
</xsl:stylesheet>