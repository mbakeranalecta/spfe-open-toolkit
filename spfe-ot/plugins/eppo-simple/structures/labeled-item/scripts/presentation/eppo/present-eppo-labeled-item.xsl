<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
    exclude-result-prefixes="#all" 
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    version="2.0">
    
    <xsl:template match="labeled-item">
        <pe:labeled-item>
            <xsl:apply-templates/>
        </pe:labeled-item>
    </xsl:template>
    
    <xsl:template match="labeled-item/label">
        <pe:label>
            <xsl:apply-templates/>
        </pe:label>
    </xsl:template>
    
    <xsl:template match="labeled-item/item">
        <pe:item>
            <xsl:apply-templates/>
        </pe:item>
    </xsl:template>
    
</xsl:stylesheet>