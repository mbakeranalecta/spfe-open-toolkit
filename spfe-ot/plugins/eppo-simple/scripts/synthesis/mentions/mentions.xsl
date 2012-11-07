<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:template match="*:body//*:task">
        <xsl:element name="mention" namespace="{$output-namespace}">
            <xsl:attribute name="type">task</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*:body//*:term">
        <xsl:element name="mention" namespace="{$output-namespace}">
            <xsl:attribute name="type">term</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*:body//*:feature">
        <xsl:element name="mention" namespace="{$output-namespace}">
            <xsl:attribute name="type">feature</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*:xml-element-name">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>    
    
    <xsl:template match="*:xml-attribute-name">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>   
    
    <xsl:template match="*:xpath">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="*:xslt-function-name">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xslt-function-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>   
    
    <xsl:template match="*:xslt-template-name">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xslt-template-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>   
    

    <xsl:template match="*:xslt-function-parameter-name">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="concat('{', @parent-function-namespace, '}', @parent-function-name)"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>   
    
    <xsl:template match="*:xslt-template-parameter-name">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xslt-template-parameter-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="concat('{', @parent-template-namespace, '}', @parent-template-name)"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>   
    
    <xsl:template match="*:directory-name
                       | *:document-name
                       | *:file-name
                       | *:product-name
                       | *:tool-name
                       | *:xml-namespace-uri">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type" select="local-name()"/>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>