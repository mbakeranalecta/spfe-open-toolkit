<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    version="2.0">
    
    <xsl:template match="p/task | string/task">
        <subject>
            <xsl:attribute name="type">task</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </subject>
    </xsl:template>
    
    <xsl:template match="p/term | string/term">
        <subject>
            <xsl:attribute name="type">term</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </subject>
    </xsl:template>
    
    <xsl:template match="p/feature | string/feature">
        <subject>
            <xsl:attribute name="type">feature</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </subject>
    </xsl:template>

    <xsl:template match="p/xml-element-name | string/xml-element-name">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>    
    
    <xsl:template match="p/xml-attribute-name | string/xml-attribute-name">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="p/xpath | string/xpath">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>


    <xsl:template match="p/xslt-function-name | string/xslt-function-name">
        <name>
            <xsl:attribute name="type">xslt-function-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="p/xslt-template-name | string/xslt-template-name">
        <name>
            <xsl:attribute name="type">xslt-template-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    

    <xsl:template match="p/xslt-function-parameter-name | string/xslt-function-parameter-name">
        <name>
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="concat('{', @parent-function-namespace, '}', @parent-function-name)"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="p/xslt-template-parameter-name | string/xslt-template-parameter-name">
        <name>
            <xsl:attribute name="type">xslt-template-parameter-name</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="concat('{', @parent-template-namespace, '}', @parent-template-name)"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </name>
    </xsl:template>   
    
    <xsl:template match="
        p/directory-name  | string/directory-name
        | p/document-name  | string/document-name
        | p/file-name  | string/file-name
        | p/product-name  | string/product-name
        | p/tool-name  | string/tool-name
        | p/xml-namespace-uri  | string/xml-namespace-uri
                       ">
        <name>
            <xsl:attribute name="type" select="local-name()"/>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>

</xsl:stylesheet>