<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all"
    version="2.0">

    
    <xsl:template match="fig">
        <xsl:if test="@id">
            <pe:anchor name="fig:{@id}"/>
        </xsl:if>
        <pe:fig>
            <xsl:if test="@id">
                <xsl:attribute name="fig" select="concat('fig:', @id)"/>
            </xsl:if>
            <xsl:if test="not(title) and gr:graphic-record/gr:default-title">
                <pe:title>
                    <xsl:value-of select="gr:graphic-record/gr:default-title"/>
                </pe:title>
            </xsl:if>   
            <xsl:if test="not(caption) and gr:graphic-record/gr:default-caption">
                <pe:caption>
                    <xsl:apply-templates select="gr:graphic-record/gr:default-caption"/>
                </pe:caption>
            </xsl:if>   
            <xsl:apply-templates/> 
        </pe:fig>
    </xsl:template>
      
    <xsl:template match="fig/caption">
        <pe:caption>
            <xsl:apply-templates/>
        </pe:caption>
    </xsl:template>
    
    <xsl:template match="fig/title">
        <pe:title>
            <xsl:apply-templates/>
        </pe:title>
    </xsl:template>    
</xsl:stylesheet>