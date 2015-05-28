<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config" exclude-result-prefixes="#all">

    <!-- processing directives -->
    <xsl:output method="xml" indent="yes"/>

    <!-- FIXME: Why is this script reading all the TOC files? Only actually processing the file for this topic-set. -->
    <xsl:param name="toc-files"/>
    <xsl:variable name="toc" select="sf:get-sources(concat($config/config:toc-directory,'/', $topic-set-id, '.toc.xml'), 'Loading toc file: ')"/>

    <!-- TOC templates -->
    <xsl:template name="create-toc-page">

        <xsl:variable name="topic-set-title">
            <xsl:choose>
                <xsl:when test="$topic-set-id eq 'spfe.objects'">
                    <xsl:text>Text Objects</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:title"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            

        <pe:page status="generated" name="{$topic-set-id}-toc">
            <xsl:call-template name="show-header"/>
            <pe:title>
                <xsl:value-of select="$topic-set-title"/>
            </pe:title>
            <xsl:apply-templates select="$toc"/>
            <xsl:call-template name="show-footer"/>
        </pe:page>
    </xsl:template>

    <xsl:template match="toc[@topic-set-id=$topic-set-id]">
        <xsl:choose>
            <xsl:when test="node">
                <pe:tree class="toc">
                    <xsl:apply-templates/>
                </pe:tree>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="sf:warning">
                    <xsl:with-param name="message">
                        <xsl:text>No toc nodes found. The topic set may be empty.</xsl:text>
                    </xsl:with-param>
                    <xsl:with-param name="in" select="$topic-set-id"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="toc"/>

    <xsl:template match="node[@topic-type]">
        <pe:branch state="open">
            <pe:content>
                <xsl:value-of select="@name"/>
            </pe:content>
            <xsl:apply-templates/>
        </pe:branch>
    </xsl:template>

    <xsl:template match="node">
        <pe:branch state="open">
            <pe:content>
                <pe:link href="{normalize-space(@id)}.html">
                    <xsl:value-of select="@name"/>
                </pe:link>
            </pe:content>
            <xsl:apply-templates/>
        </pe:branch>
    </xsl:template>

</xsl:stylesheet>
