<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
    exclude-result-prefixes="#all"
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
        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="@href">
                    <xsl:value-of select="@href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="my-output-directory" select="$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:output-directory"/>
                    <xsl:variable name="target-output-directory" select="@topic-dir"/>
                    <xsl:choose>
                        <xsl:when test="$my-output-directory =  $target-output-directory">
                            <xsl:value-of select="concat(@topic-id, '.html')"/>
                        </xsl:when>
                        <xsl:when test="$my-output-directory = '' and $target-output-directory = ''">
                            <xsl:value-of select="concat(@topic-id, '.html')"/>
                        </xsl:when>
                        <xsl:when test="$my-output-directory = '' and $target-output-directory ne ''">
                            <xsl:value-of select="concat($target-output-directory, '/', @topic-id, '.html')"/>
                        </xsl:when>
                        <xsl:when test="$my-output-directory ne '' and $target-output-directory = ''">
                            <xsl:value-of select="concat('../', @topic-id, '.html')"/>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat( '../', $target-output-directory, '/', @topic-id, '.html')"/>  
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
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