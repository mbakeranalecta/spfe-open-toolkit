<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    <xsl:template match="p">
        <p>
            <xsl:if test="@hint">
                <xsl:attribute name="class" select="@hint"/>
            </xsl:if>
            <xsl:if test="$draft">
                <xsl:variable name="my-page" select="ancestor::page"/>
                <span class="draft">
                    <b class="decoration-bold">
                        <xsl:value-of select="count(preceding::p[ancestor::page is $my-page])+1"/>
                    </b>
                </span>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
</xsl:stylesheet>