<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/object-types/graphic-record"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- FIXME: This should be in config. -->
    <xsl:param name="output-image-directory">graphics</xsl:param>
    
    <xsl:template match="gr:fig">
        <xsl:if test="@id">
            <anchor name="fig:{@id}"/>
        </xsl:if>
        <!-- FIXME: This just choosed the first format. Need logic to choose best available or
        pass that task to format layer.-->
        <fig id="{@id}" href="{$output-image-directory}/{sf:get-file-name-from-path(gr:formats/gr:format[1]/gr:uri)}">
            <xsl:apply-templates/>
        </fig>
    </xsl:template>
    
    <xsl:template match="gr:caption">
        <caption>
            <xsl:apply-templates/>
        </caption>
    </xsl:template>
    
    <xsl:template match="gr:caption/gr:title">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    
    <xsl:template match="gr:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="gr:*"/>
    <!-- mop up any left over text fields -->
    
</xsl:stylesheet>