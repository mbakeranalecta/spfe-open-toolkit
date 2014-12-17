<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" 
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all">
    
    <xsl:template match="p/comment-author-to-author | string/comment-author-to-author">
        <xsl:if test="$draft">
            <inline-comment class="comment-author-to-author">
                <xsl:apply-templates/>
            </inline-comment>
        </xsl:if>
    </xsl:template>
    <xsl:template match="p/comment-author-to-reviewer | string/comment-author-to-reviewer">
        <xsl:if test="$draft">
            <inline-comment class="comment-author-to-reviewer">
                <xsl:apply-templates/>
            </inline-comment>
        </xsl:if>
    </xsl:template>
    <xsl:template match="p/comment-reviewer-to-author | string/comment-reviewer-to-author">
        <xsl:if test="$draft">
            <inline-comment class="comment-reviewer-to-author">
                <xsl:apply-templates/>
            </inline-comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="comment-author-to-author">
        <xsl:if test="$draft">
            <block-comment class="comment-author-to-author">
                <xsl:apply-templates/>
            </block-comment>
        </xsl:if>
    </xsl:template>
    <xsl:template match="comment-author-to-reviewer">
        <xsl:if test="$draft">
            <block-comment class="comment-author-to-reviewer">
                <xsl:apply-templates/>
            </block-comment>
        </xsl:if>
    </xsl:template>
    <xsl:template match="comment-reviewer-to-author">
        <xsl:if test="$draft">
            <block-comment class="comment-reviewer-to-author">
                <xsl:apply-templates/>
            </block-comment>
        </xsl:if>
    </xsl:template>
    
    
</xsl:stylesheet>