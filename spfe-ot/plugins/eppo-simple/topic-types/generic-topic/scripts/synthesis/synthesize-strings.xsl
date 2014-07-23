<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->

<!-- Stylesheets that import this stylesheets must define the $strings variable. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" 
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/topic-types/generic-topic"
    exclude-result-prefixes="#all">
    
    <xsl:template match="string-ref">
        <!-- Selects the string definition in the inmost local scope.
             If two string definitions in the same scope have the same ID it 
             selects the first in document order. -->
        <xsl:param name="in-scope-strings" as="element()*" tunnel="yes"/>
        <xsl:variable name="local-strings" select="local-strings/string, /*//p/string, $in-scope-strings" as="element()*"/>   
        <xsl:variable name="string-id" select="@id-ref"/>
        <xsl:variable name="substitution" select="$local-strings[@id=$string-id][1]"/>
        
        <xsl:choose>
            <xsl:when test="$substitution">
                <xsl:apply-templates select="$substitution/node()">
                    <xsl:with-param name="in-scope-strings" select="$local-strings" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="sf:error">
                    <xsl:with-param name="message">
                        <xsl:text>No string found with string id </xsl:text>
                        <xsl:value-of select="$string-id"/>
                        <xsl:text>.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="local-strings/string"/>
    
    <xsl:template match="string">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>