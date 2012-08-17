<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->

<!-- Stylesheets that import this stylesheets must define the $strings variable. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" exclude-result-prefixes="#all">
    
    <xsl:template match="*:string-ref">
        <xsl:param name="local-strings" as="element()*" tunnel="yes"/>
        <xsl:variable name="id" select="@id-ref"/>
        <xsl:variable name="substitution" select="$strings/string[@id = $id], $local-strings[@id=$id]"/>

        <xsl:choose>
            <xsl:when test="$substitution[2]">
                <xsl:call-template name="error">
                    <xsl:with-param name="message">
                        <xsl:text>Multiple strings found with string id </xsl:text>
                        <xsl:value-of select="$id"/>
                        <xsl:text>. Matching strings: </xsl:text>
                        <xsl:for-each select="$substitution">
                            <xsl:value-of select="."/>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$substitution[1]">
                <xsl:apply-templates select="$substitution/node()">
                    <xsl:with-param name="local-strings" select="*:string" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="error">
                    <xsl:with-param name="message">
                        <xsl:text>No string found with string id </xsl:text>
                        <xsl:value-of select="$id"/>
                        <xsl:text>.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*:string"/>
</xsl:stylesheet>