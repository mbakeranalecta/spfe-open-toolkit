<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="page">
        <xsl:variable name="page-name" select="string(@name)"/>
        <xsl:call-template name="output-html-page">
            <xsl:with-param name="file-name" select="concat(normalize-space(@name), '.html')"/>
            <xsl:with-param name="title" select="title"/>
            <xsl:with-param name="content">
                <xsl:if test="$draft">
                    <div id="draft-header">
                        <p class="status-{translate(@status,' ', '_')}">
                            <b class="decoration-bold">Topic Name: </b>
                            <xsl:value-of select="@name"/>
                            <b class="decoration-bold"> Topic Status: </b>
                            <xsl:value-of select="@status"/>
                        </p>
                        <xsl:if test=".//comment-author-to-author">
                            <p>
                                <b>Index of author notes: </b>
                                <xsl:for-each select=".//comment-author-to-author">
                                    <a href="#comment-author-to-author:{position()}"> [<xsl:value-of
                                        select="position()"/>] </a>
                                    <xsl:text> </xsl:text>
                                </xsl:for-each>
                            </p>
                        </xsl:if>
                        <hr/>
                    </div>
                </xsl:if>
                
                <div id="main-container">
                    <div id="main">
                        <xsl:apply-templates/>
                    </div>
                </div>
                
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="page/title">
        <h1>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>
    
    <xsl:template match="page/toc">
        <ul class="page-toc">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    <xsl:template match="page/toc/toc-entry">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    
</xsl:stylesheet>