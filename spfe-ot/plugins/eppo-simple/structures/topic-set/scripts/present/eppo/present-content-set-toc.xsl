<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config" exclude-result-prefixes="#all">

    <!-- TOC templates -->
    <xsl:template name="create-toc-page">
        <!--
            Are topic set groups defined?
                If not, just list topics.
            Do all topic sets belong to a group?
                If not, raise error.
            Do all topic set groups match those defined in content set?
                If not, raise error.
            Create groups.
        -->
        <pe:page status="generated" name="{$topic-set-id}-toc">
            <xsl:call-template name="show-header"/>
            <xsl:choose>
                <xsl:when test="not($config/config:content-set/config:topic-set-groups/config:group)">
                    <pe:ul>
                        <xsl:for-each select="config:topic-set">
                            <pe:li>
                                <pe:p>
                                    <pe:link
                                        href="{normalize-space(config:output-directory)}{if (normalize-space(config:output-directory) = '') then '' else '/'}{normalize-space(config:topic-set-id)}-toc.html">
                                        <xsl:value-of select="config:title"/>
                                    </pe:link>
                                </pe:p>
                            </pe:li>
                        </xsl:for-each>
                    </pe:ul>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="config:topic-set[string(config:group) = '']">
                        <xsl:call-template name="sf:error">
                            <xsl:with-param name="message">The content set configuration file
                                defines topic set groups, but not all topic sets are assigned to a
                                group.</xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    <!-- FIXME: This could be validataed at the config stage
                         FIXME: In fact,could calculate grouping entirely at config stage
                    Make a list of allowed grouping strings from content set groups definition
                    Check that every topic set group expression is on that list.
                        Raise an error if not.
                    -->
                    

                    <xsl:apply-templates select="$config/config:content-set"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="show-footer"/>
        </pe:page>
    </xsl:template>

    <xsl:template match="config:content-set">
        <!-- 
        Recursively for each level of grouping:
            List all topics in this group in alphabetical order
            List all groups in this group in alphabetical order
        -->
        <pe:tree class="toc">
            <xsl:for-each select="config:topic-set[config:group eq '#HOME']">
                <pe:branch>
                    <pe:content>
                        <pe:link href="index.html">
                            <xsl:value-of select="config:title"/>
                        </pe:link>
                    </pe:content>
                </pe:branch>
            </xsl:for-each>

            <xsl:call-template name="group-topic-sets">
                <xsl:with-param name="topic-sets" select="config:topic-set[config:group ne '#HOME']"/>
                <xsl:with-param name="level">1</xsl:with-param>
            </xsl:call-template>
        </pe:tree>
    </xsl:template>

    <xsl:template name="group-topic-sets">
        <xsl:param name="topic-sets"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:for-each-group select="$topic-sets"
            group-by="tokenize(config:group, '\s*;\s*')[$level]">
            <pe:branch state="open">
                <pe:content>
                    <xsl:value-of select="current-grouping-key()"/>
                </pe:content>
                <xsl:for-each select="current-group()/.">
                    <xsl:sort select="config:title"/>
                    <xsl:if test="not(tokenize(config:group, '\s*;\s*')[$level + 1])">
                        <pe:branch>
                            <pe:content>
                                <pe:link
                                    href="{normalize-space(config:output-directory)}{if (normalize-space(config:output-directory) = '') then '' else '/'}{normalize-space(config:topic-set-id)}-toc.html">
                                    <xsl:value-of select="config:title"/>
                                </pe:link>
                            </pe:content>
                        </pe:branch>
                    </xsl:if>
                </xsl:for-each>
                <xsl:call-template name="group-topic-sets">
                    <xsl:with-param name="topic-sets" select="current-group()"/>
                    <xsl:with-param name="level" select="$level + 1"/>
                </xsl:call-template>

            </pe:branch>
        </xsl:for-each-group>
    </xsl:template>




</xsl:stylesheet>
