<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
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
<!--            <xsl:if test="not(title) and gr:graphic-record/gr:default-title">
                <pe:title>
                    <xsl:value-of select="gr:graphic-record/gr:default-title"/>
                </pe:title>
            </xsl:if>   
            <xsl:if test="not(caption) and gr:graphic-record/gr:default-caption">
                <pe:caption>
                    <xsl:apply-templates select="gr:graphic-record/gr:default-caption"/>
                </pe:caption>
            </xsl:if>   -->
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
    
    <xsl:template match="fig-id">
        <xsl:variable name="fig-id" select="@id-ref"/>
        <xsl:variable name="uri" select="@uri"/>
        <xsl:if test="not(ancestor::ss:topic//fig[@id=$fig-id or @uri=$uri]/title)">
            <xsl:call-template name="sf:error">
                <xsl:with-param name="message" select="'No fig/title element found for referenced fig:', if($uri) then $uri else $fig-id, '. A title is required for all referenced figs.'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="target" select="if ($uri) then generate-id(ancestor::ss:topic//fig[@uri=$uri]/@uri) else @id-ref"/>
        <pe:reference type="fig">
            <pe:link href="#fig:{$target}">
                <xsl:text>Figure&#160;</xsl:text>
                <xsl:value-of select="count(ancestor::ss:topic//fig/title intersect $target/preceding::fig/title)+1"/>
            </pe:link>
        </pe:reference>
    </xsl:template>
    
    
</xsl:stylesheet>