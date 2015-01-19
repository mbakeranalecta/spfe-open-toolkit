<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <!-- TREES -->
    
    <xsl:template match="tree[@class='toc']">
        <ol class="tree">
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    
    <xsl:template match="tree//branch">
        <li>
            <xsl:choose>
                <xsl:when test="branch">
                    <label for="{generate-id()}">
                        <xsl:if test="not(content/link)">
                            <xsl:attribute name="class">folder</xsl:attribute>
                        </xsl:if>
                        <xsl:apply-templates select="content"/>
                    </label> 
                    <input type="checkbox" id="{generate-id()}" >
                        <!-- FIXME: How should we handle class="fixed"?-->
                        <xsl:if test="@state='open'">
                            <xsl:attribute name="checked"/>
                        </xsl:if>
                    </input> 				
                    <ol>			
                        <xsl:apply-templates select="branch"/>
                    </ol>				
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">file</xsl:attribute>
                    <xsl:apply-templates select="content"/>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    
    <xsl:template match="tree//branch/content">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>