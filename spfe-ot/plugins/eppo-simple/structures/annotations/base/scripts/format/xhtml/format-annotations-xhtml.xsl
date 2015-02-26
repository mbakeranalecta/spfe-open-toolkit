<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="name">
        <b class="decoration-bold">
            <xsl:apply-templates/>
        </b>
    </xsl:template>
    
    <!-- FIXME: Should this be in a "link" structure? It is not an annotation at this point. -->
    
    <xsl:template match="link">
        <xsl:variable name="class" select="if (@class) then @class else 'default'"/>
        <xsl:variable name="href" select="@href"/>
        <a href="{$href}" class="{$class}"
            title="{if(ancestor::context) then 'See also - ' else ''}{@title}">
            <xsl:if test="@onclick">
                <xsl:attribute name="onClick" select="@onclick"/>
            </xsl:if>
            <xsl:if test="@external = 'true'">
                <xsl:attribute name="target">_blank</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    
</xsl:stylesheet>