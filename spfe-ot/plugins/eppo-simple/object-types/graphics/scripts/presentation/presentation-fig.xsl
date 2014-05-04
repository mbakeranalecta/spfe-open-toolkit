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
        <fig id="{@id}" href="{$output-image-directory}/{sf:get-file-name-from-path(gr:formats/gr:format[1]/gr:uri)}">
            <xsl:apply-templates/>
        </fig>
    </xsl:template>
    
    <xsl:template match="gr:graphic-record">
        <gr:graphic-record>
            <gr:name>
                <xsl:value-of select="gr:name"/>
            </gr:name>
            <gr:alt>
                <xsl:value-of select="gr:alt"/>
            </gr:alt>
            <gr:uri>
                <xsl:value-of select="gr:uri"/>
            </gr:uri>
            <xsl:choose>
                <xsl:when test="/gr:formats/gr:format">
                    <gr:formats>
                        <xsl:for-each select="gr:formats/gr:format">
                            <gr:format>
                                <xsl:copy-of select="gr:type"/>
                                <xsl:copy-of select="gr:href"/>
                                <xsl:copy-of select="gr:height"/>
                                <xsl:copy-of select="gr:width"/>
                                <xsl:copy-of select="gr:dpi"/>
                            </gr:format>
                        </xsl:for-each>
                    </gr:formats>
                </xsl:when>
                <xsl:otherwise>
                    <gr:formats>
                        <gr:format>
                            <gr:uri>
                                <xsl:value-of select="resolve-uri(@href, base-uri(.))"/>
                            </gr:uri>
                        </gr:format>
                    </gr:formats>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="gr:source"/>
        </gr:graphic-record>
        <xsl:choose>
            <xsl:when test="*:caption">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="gr:default-caption">
                <caption>
                    <xsl:copy-of select="gr:default-caption/*"/>
                </caption>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

<!--    <xsl:template match="gr:caption">
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
    </xsl:template>-->
    
    <xsl:template match="gr:*"/>
    <!-- mop up any left over text fields -->
    
</xsl:stylesheet>