<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all"
    version="2.0">

    
    <xsl:template match="fig">
        <fig>
            <xsl:if test="@id">
                <xsl:attribute name="fig" select="concat('fig:', @id)"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="not(title) and gr:graphic-record/gr:default-title">
                    <title>
                        <xsl:value-of select="gr:graphic-record/gr:default-title"/>
                    </title>
                </xsl:when>  
                <xsl:when test="title">
                    <xsl:apply-templates select="title" mode="fig-title"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="not(caption) and gr:graphic-record/gr:default-caption">
                    <xsl:apply-templates select="gr:graphic-record/gr:default-caption"/>              
            </xsl:if>   
            <xsl:apply-templates/> 
        </fig>
    </xsl:template>
    
    <xsl:template match="gr:graphic-record">
        <image href="{gr:formats/gr:format[1]/gr:href}"/>
<!--        <gr:graphic-record>
            <!-\- copy everything except the default caption -\->
            <xsl:copy-of  select="gr:name" copy-namespaces="no"/>
            <xsl:copy-of  select="gr:alt" copy-namespaces="no"/>
            <xsl:copy-of  select="gr:uri" copy-namespaces="no"/>
            <xsl:copy-of select="gr:formats" copy-namespaces="no"/>
            <xsl:copy-of select="gr:source" copy-namespaces="no"/>
        </gr:graphic-record>
-->    </xsl:template>
    
    <xsl:template match="fig/caption">
            <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="fig/title"/> 
    <xsl:template match="fig/title" mode="fig-title">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    
  
    <xsl:template match="gr:*" />
    <!-- mop up any left over text fields -->
    
</xsl:stylesheet>