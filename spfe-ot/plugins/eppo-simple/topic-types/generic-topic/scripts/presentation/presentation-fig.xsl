<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/object-types/graphic-record"
    exclude-result-prefixes="#all"
    version="2.0">

    
    <xsl:template match="*:fig">
        <xsl:if test="@id">
            <anchor name="fig:{@id}"/>
        </xsl:if>
        <fig>
            <xsl:if test="@id">
                <xs:attribute name="fig" select="fig:{@id}"/>
            </xsl:if>
            <xsl:if test="not(*:title) and gr:graphic-record/gr:default-title">
                <title>
                    <xsl:value-of select="gr:graphic-record/gr:default-title"/>
                </title>
            </xsl:if>   
            <xsl:if test="not(*:caption) and gr:graphic-record/gr:default-caption">
                <caption>
                    <xsl:apply-templates select="gr:graphic-record/gr:default-caption"/>
                </caption>
            </xsl:if>   
            <xsl:apply-templates/> 
        </fig>
    </xsl:template>
    
    <xsl:template match="gr:graphic-record">
        <gr:graphic-record>
            <!-- copy everything except the default caption -->
            <xsl:copy-of  select="gr:name" copy-namespaces="no"/>
            <xsl:copy-of  select="gr:alt" copy-namespaces="no"/>
            <xsl:copy-of  select="gr:uri" copy-namespaces="no"/>
            <xsl:copy-of select="gr:formats" copy-namespaces="no"/>
            <xsl:copy-of select="gr:source" copy-namespaces="no"/>
        </gr:graphic-record>
    </xsl:template>
    
    <xsl:template match="*:fig/*:caption">
        <caption>
            <xsl:apply-templates/>
        </caption>
    </xsl:template>
    
    <xsl:template match="*:fig/*:title">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    
  
    <xsl:template match="gr:*" />
    <!-- mop up any left over text fields -->
    
</xsl:stylesheet>