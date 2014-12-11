<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple/text-objects"
    exclude-result-prefixes="#all" 
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/text-objects">
    
    <xsl:template match="if-then-table-object">
        <xsl:variable name="name" select="head/id"/>
        <xsl:variable name="type" select="sf:name-in-clark-notation(.)"/>
        <!-- FIXME: This assumes that IDs are unique, which is not guaranteed. Should detect duplicate IDs or randomize names. -->
        <xsl:result-document href="file:///{$output-directory}/{$name}.xml" method="xml" indent="yes" omit-xml-declaration="no">
            
            <ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
                topic-set-id="spfe.text-objects" 
                title="{sf:string($config//config:strings, 'product')} {sf:string($config//config:strings, 'product-release')}"> 
                <ss:text-object 
                    type="{$type}" 
                    full-name="{$type}#{$name}"
                    local-name="{$name}"
                    title="{body/title}"
                    excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::p[1], 30, ' ...'))}">
                    <table-basic-object>
                        <xsl:apply-templates/>
                    </table-basic-object>
                </ss:text-object>
            </ss:synthesis>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="if-then-table-object/head">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="if-then-table-object/body">
        <body>
            <xsl:apply-templates/>
        </body>
    </xsl:template>
    
    <xsl:template match="if-then-table">
        <table>
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    
    <xsl:template match="if-then-table-head">
        <thead>
            <tr>
                <xsl:apply-templates/>
            </tr>
        </thead>
    </xsl:template>
    
    <xsl:template match="if-then-table-body">
        <tbody>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>
    
    <xsl:template match="if-then-table-body/if-then-row">
        <xsl:variable name="if-cell">
            <xsl:apply-templates select="if"/>
        </xsl:variable>
        <xsl:apply-templates select="then">
            <xsl:with-param name="cells" select="$if-cell" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="then/if-then-row">
        <xsl:param name="cells" tunnel="yes"/>
        <xsl:variable name="if-cell">
            <xsl:apply-templates select="if"/>
        </xsl:variable>
        <xsl:apply-templates select="then">
            <xsl:with-param name="cells" select="if(preceding-sibling::if-then-row) then $if-cell else ($cells, $if-cell)" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="if-then-table-body//if">
        <xsl:variable name="num-alts" select="count(../descendant::do)"/>
           <td>
               <xsl:if test="$num-alts gt 1">
                   <xsl:attribute name="rowspan" select="$num-alts"/>
               </xsl:if>
               <xsl:apply-templates/>
           </td> 
    </xsl:template>
    
    <xsl:template match="if-then-table-body//do">
        <xsl:param name="cells" tunnel="yes"/>
        <tr>
            <xsl:sequence select="$cells"/>
            <td>
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>
   
    <xsl:template match="if-then-table-body//then">
            <xsl:apply-templates/>     
    </xsl:template>
    
</xsl:stylesheet>