<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="caption">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="caption/p">
        <p class="caption">
            <xsl:apply-templates/>
        </p>
    </xsl:template>  
    
</xsl:stylesheet>