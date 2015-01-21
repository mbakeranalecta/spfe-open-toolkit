<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="inline-comment">
        <span class="{@class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="block-comment">
        <div class="{@class}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
</xsl:stylesheet>