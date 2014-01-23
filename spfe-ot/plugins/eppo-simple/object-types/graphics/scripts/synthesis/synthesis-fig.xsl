<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/object-types/graphic-record"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Make sure that the fig href is an absolute URI so that we know where to copy it from -->
    <xsl:template match="*:fig">
        
        <xsl:variable name="graphic-record-file" select="replace(@href,'(.+)\..+$','$1.xml')"/>
        <xsl:variable name="graphic-record-file-uri" select="resolve-uri($graphic-record-file, base-uri(.))"></xsl:variable>

        <xsl:choose>
            <xsl:when test="doc-available($graphic-record-file-uri)">
                <xsl:variable name="graphic-record" select="document($graphic-record-file-uri)/gr:graphic-record"/>
                
                <xsl:variable name="file" select="resolve-uri($graphic-record//gr:format[1]/gr:uri, $graphic-record-file-uri)"/>
                <gr:fig>
                    <xsl:if test="@id">
                        <xsl:attribute name="id" select="@id"/>
                    </xsl:if>
                    <gr:name><xsl:value-of select="$graphic-record/gr:name"/></gr:name>
                    <gr:alt><xsl:value-of select="$graphic-record/gr:alt"/></gr:alt>
                    <xsl:choose>
                        <xsl:when test="$graphic-record/gr:formats/gr:format">
                            <gr:formats>
                                <xsl:for-each select="$graphic-record/gr:formats/gr:format">
                                    <gr:format>
                                        <gr:type>
                                            <xsl:value-of select="gr:type"/>
                                        </gr:type>
                                        <gr:uri>
                                            <xsl:value-of select="resolve-uri(gr:uri, $graphic-record-file-uri)"/>
                                        </gr:uri>
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
                    <xsl:choose>
                        <xsl:when test="*:caption">
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:when test="$graphic-record/gr:default-caption">
                            <gr:caption>
                                <xsl:copy-of select="$graphic-record/gr:default-caption/*"/>
                            </gr:caption>
                        </xsl:when>
                    </xsl:choose>    
                </gr:fig>
            </xsl:when>
            <xsl:otherwise>
                <gr:fig>
                    <xsl:for-each select="@*[not(name()='href')]">
                        <xsl:copy />
                    </xsl:for-each>
                    <gr:formats>
                        <gr:format>
                            <gr:type>
                                <xsl:value-of select="replace(@href,'.+\.(.+)$','$1')"/>
                            </gr:type>
                            <gr:uri>
                                <xsl:value-of select="resolve-uri(@href, base-uri(.))"/>
                            </gr:uri>
                        </gr:format>
                    </gr:formats>
                    <xsl:apply-templates/>
                </gr:fig>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*:caption">
        <gr:caption>
            <xsl:apply-templates/>
        </gr:caption>
    </xsl:template>
    
    <xsl:template match="*:caption/*:title">
        <gr:title><xsl:apply-templates/></gr:title>
    </xsl:template>
    
    <xsl:template match="*:caption/*:p">
        <gr:p><xsl:apply-templates/></gr:p>
    </xsl:template>
    
</xsl:stylesheet>