<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/object-types/graphic-record"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- FIXME: This should be in config. -->
    <xsl:param name="output-image-directory">graphics</xsl:param>
    
    <xsl:template match="*:fig">
        <xsl:if test="@id">
            <anchor name="fig:{@id}"/>
        </xsl:if>
        <!-- FIXME: This just chooses the first format. Need logic to choose best available or
        pass that task to format layer.-->
        <fig>
            <xsl:if test="@id">
                <xs:attribute name="fig" select="fig:{@id}"/>
            </xsl:if>
            <xsl:apply-templates/>
        </fig>
    </xsl:template>
    
    <xsl:template match="gr:graphic-record">
        <gr:graphic-record>
            <xsl:copy-of  select="gr:name" copy-namespaces="no"/>
            <xsl:copy-of  select="gr:alt" copy-namespaces="no"/>
            <xsl:copy-of  select="gr:uri" copy-namespaces="no"/>
            <xsl:copy-of select="gr:formats" copy-namespaces="no"/>
            <xsl:copy-of select="gr:source" copy-namespaces="no"/>
        </gr:graphic-record>
        <xsl:choose>
            <xsl:when test="*:caption">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="gr:default-caption">
                <caption>
                    <xsl:apply-templates select="gr:default-caption" mode="replace-caption"/>
                </caption>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gr:caption" mode="replace-caption">
        <caption>
            <xsl:apply-templates/>
        </caption>
    </xsl:template>
    
    <xsl:template match="gr:caption/gr:title" mode="replace-caption">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    
    <xsl:template match="gr:p" mode="replace-caption">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="gr:*"/>
    <!-- mop up any left over text fields -->
    
</xsl:stylesheet>