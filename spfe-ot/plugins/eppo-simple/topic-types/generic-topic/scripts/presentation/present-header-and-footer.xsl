<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
    xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:template name="show-header">
        <xsl:variable name="topic-type" select="if (ancestor::ss:topic/@virtual-type) then ancestor::ss:topic/@virtual-type else ancestor::ss:topic/@type"/>
        
        <xsl:variable name="topic-set-title" select="sf:string($config/config:topic-set[config:topic-set-id=$topic-set-id]/config:strings, 'eppo-simple-topic-set-title')"/>

        <xsl:variable name="doc-set-title" select="$config/config:doc-set/config:title"/>
        
        <xsl:variable name="is-home-topic-set" select="normalize-space($config/config:doc-set/config:home-topic-set) eq normalize-space($topic-set-id)"/>
        
        <xsl:variable name="doc-set-index-file">
            <xsl:value-of select="if ($is-home-topic-set) then 'index.html' else '../index.html'"/>
        </xsl:variable>
        <xsl:variable name="doc-set-toc-file">
            <xsl:value-of select="if ($is-home-topic-set) 
                                  then concat($config/config:doc-set/config:home-topic-set, '-toc.html') 
                                  else concat('../', $config/config:doc-set/config:home-topic-set,'-toc.html')"/>
        </xsl:variable>
        
        <header>
            <p>
                <xref target="{$doc-set-index-file}" >Home</xref>   
                | 
                <xref target="{$doc-set-toc-file}">TOC</xref>
                
                <xsl:if test="not($is-home-topic-set)">
                    >      
                    <xref target="{normalize-space($topic-set-id)}-toc.html">
                        <xsl:value-of select="$topic-set-title"/>
                    </xref>
                </xsl:if>
            </p>
            <table>
                <xsl:if test="index/reference/key[normalize-space(.) ne '']">
                    <tr>
                        <td><bold>Tags</bold></td>
                        <td>
                            <xsl:for-each select="index/reference">
                                <xsl:variable name="key-text" select="translate(key[1], '{}', '')"/>
                                <xsl:choose>
                                    <xsl:when test="esf:target-exists-not-self(key[1], type, ancestor::topic/name)">
                                        <xsl:call-template name="output-link">
                                            <xsl:with-param name="target" select="key[1]"/>
                                            <xsl:with-param name="type" select="type"/>
                                            <xsl:with-param name="content" select="$key-text"/>
                                            <xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$key-text"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="position() != last()">, </xsl:if>
                            </xsl:for-each>
                        </td>
                    </tr>
                    
                </xsl:if>
            </table>
        </header>
    </xsl:template>
    
    <xsl:template name="show-footer">		
        <xsl:variable name="see-also-links">
            <xsl:for-each select="index/reference[esf:target-exists(key[1], type)]">
                <xsl:call-template name="output-link">
                    <xsl:with-param name="target" select="key[1]"/>
                    <xsl:with-param name="type" select="type"/>
                    <xsl:with-param name="content" select="translate(key[1], '{}', '')"/>
                    <xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
                    <xsl:with-param name="see-also" select="true()"/>
                </xsl:call-template>
            </xsl:for-each>	
        </xsl:variable>
        
        <xsl:if test="$see-also-links/xref | $see-also-links/xref-set">
            <table hint="context">
                <tr>
                    <td><bold>See also</bold></td>
                    <td>
                        <ul>
                            <xsl:for-each-group select="$see-also-links/xref | $see-also-links/xref-set/xref" group-by="@target">
                                <li><xsl:sequence select="."/></li>
                            </xsl:for-each-group>
                        </ul>
                    </td>
                </tr>
            </table>
        </xsl:if>
        
    </xsl:template>
</xsl:stylesheet>