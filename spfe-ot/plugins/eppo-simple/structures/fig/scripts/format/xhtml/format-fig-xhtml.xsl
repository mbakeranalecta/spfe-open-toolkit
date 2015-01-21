<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    <!-- FIG -->
    <!-- FIXME: alt should be supplied from the default caption if not present in source -->
    <xsl:template match="fig">
        <xsl:if test="title">
            <h4>
                <xsl:text>Figure&#160;</xsl:text>
                <xsl:value-of
                    select="count(ancestor::page//fig/title intersect preceding::fig/title)+1"/>
                <xsl:text>&#160;&#160;&#160;</xsl:text>
                <xsl:value-of select="title"/>
            </h4>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="fig/title"/>
</xsl:stylesheet>