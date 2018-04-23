<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
    xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config" exclude-result-prefixes="#all"
    version="2.0">
    <xsl:template name="show-header">
        <xsl:variable name="topic-type" select="ancestor::ss:topic/@type"/>

        <xsl:variable name="topic-set-title"
            select="$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:title"/>

        <xsl:variable name="content-set-title" select="$config/config:content-set/config:title"/>

        <xsl:variable name="is-home-topic-set"
            select="normalize-space($config/config:content-set/config:home-topic-set) eq normalize-space($topic-set-id)"/>

        <xsl:variable name="content-set-index-file">
            <xsl:value-of select="if ($is-home-topic-set) then 'index.html' else '../index.html'"/>
        </xsl:variable>
        <xsl:variable name="content-set-toc-file">
            <xsl:value-of
                select="if ($is-home-topic-set) 
                                  then concat($config/config:content-set/config:home-topic-set, '-toc.html') 
                                  else concat('../', $config/config:content-set/config:home-topic-set,'-toc.html')"
            />
        </xsl:variable>

        <pe:context-nav>
            <pe:home>
                <pe:link href="{$content-set-index-file}"><xsl:value-of select="$content-set-title"/></pe:link>
            </pe:home>
            <pe:breadcrumbs>
                <pe:breadcrumb>
                    <pe:link href="{$content-set-toc-file}">Collections</pe:link>
                </pe:breadcrumb>
                <xsl:if test="not($is-home-topic-set)">
                    <pe:breadcrumb>
                        <pe:link href="{normalize-space($topic-set-id)}-toc.html">
                            <xsl:value-of select="$topic-set-title"/>
                        </pe:link>
                    </pe:breadcrumb>
                </xsl:if>
                <pe:breadcrumb>
                    <xsl:value-of select="ancestor::ss:topic/@title"/>
                </pe:breadcrumb>
            </pe:breadcrumbs>
            <!-- FIXME: If used, this needs to be based on a set of topic-level realtionships derived in the link step. -->
<!--            <xsl:if test="index/entry/term[normalize-space(.) ne '']">
                <pe:keywords>
                    <pe:title>Tags</pe:title>
                    <pe:keyword>
                        <xsl:for-each select="index/entry">
                            <xsl:variable name="key-text" select="translate(term[1], '{}', '')"/>
                            <xsl:choose>
                                <xsl:when
                                    test="esf:target-exists-not-self(term[1], type, ancestor::ss:topic/@name)">
                                    <xsl:call-template name="output-link">
                                        <xsl:with-param name="target" select="key[1]"/>
                                        <xsl:with-param name="type" select="type"/>
                                        <xsl:with-param name="content" select="$key-text"/>
                                        <xsl:with-param name="current-page-name"
                                            select="ancestor-or-self::ss:topic/@full-name"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$key-text"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="position() != last()">, </xsl:if>
                        </xsl:for-each>
                    </pe:keyword>
                </pe:keywords>
            </xsl:if>
-->        </pe:context-nav>
    </xsl:template>

    <xsl:template name="show-footer">
<!--        <xsl:variable name="see-also-links">
            <xsl:for-each select="index/reference[esf:target-exists(key[1], type)]">
                <xsl:call-template name="output-link">
                    <xsl:with-param name="target" select="key[1]"/>
                    <xsl:with-param name="type" select="type"/>
                    <xsl:with-param name="content" select="translate(key[1], '{}', '')"/>
                    <xsl:with-param name="current-page-name"
                        select="ancestor-or-self::ss:topic/@full-name"/>
                    <xsl:with-param name="see-also" select="true()"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$see-also-links/link">
            <pe:table hint="context">
                <pe:tr>
                    <pe:td>
                        <pe:decoration class="bold">See also</pe:decoration>
                    </pe:td>
                    <pe:td>
                        <pe:ul>
                            <xsl:for-each-group
                                select="$see-also-links/link"
                                group-by="@href">
                                <pe:li>
                                    <xsl:sequence select="."/>
                                </pe:li>
                            </xsl:for-each-group>
                        </pe:ul>
                    </pe:td>
                </pe:tr>
            </pe:table>
       </xsl:if>
--> 
    </xsl:template>
</xsl:stylesheet>
