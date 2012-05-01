<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:mention="mention">
    
    <xsl:template match="*:task">
        <mention type="task" key="{.}"><xsl:apply-templates/></mention>
    </xsl:template>
    <xsl:template match="*:term">
        <mention type="term" key="{.}"><xsl:apply-templates/></mention>
    </xsl:template>
    <xsl:template match="*:feature">
        <mention type="feature" key="{.}"><xsl:apply-templates/></mention>
    </xsl:template>


    <xsl:template match="*:xml-element-name">
        <name type="xpath" key="{if (@xpath) then @xpath else .}">
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="*:xml-attribute-name">
        <name type="xpath" key="{if (@xpath) then @xpath else .}">
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="*:xpath">
        <name type="xpath" key="{.}">
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="*:directory-name">
        <name type="directory-name" key="{.}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    <xsl:template match="*:document-name">
        <name type="document-name" key="{.}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    <xsl:template match="*:file-name">
        <name type="file-name" key="{.}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="*:product-name">
        <name type="product-name" key="{.}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>

    <xsl:template match="*:tool-name">
        <name type="tool-name" key="{.}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="*:xml-namespace-uri">
        <name type="xml-namspace-uri" key="{.}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>

</xsl:stylesheet>