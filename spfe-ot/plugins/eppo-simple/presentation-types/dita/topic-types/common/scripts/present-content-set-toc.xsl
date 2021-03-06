<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
    exclude-result-prefixes="#all">
    
    <xsl:param name="toc-files"/>
    <xsl:variable name="content-set-id" select="$config/config:content-set/config:content-set-id"/>
    <xsl:variable name="unsorted-toc" >
        <xsl:variable name="temp-tocs" select="sf:get-sources($toc-files, 'Loading toc file: ')"/>
        <xsl:if test="count(distinct-values($temp-tocs/toc/@topic-set-id)) lt count($temp-tocs/toc)">
            <xsl:call-template name="sf:error">
                <xsl:with-param name="message">
                    <xsl:text>Duplicate TOCs detected.&#x000A; There appears to be more than one TOC in scope for the same topic set. Topic set IDs encountered include:&#x000A;</xsl:text>
                    <xsl:for-each select="$temp-tocs/toc">
                        <xsl:value-of select="@topic-set-id,'&#x000A;'"/>
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:sequence select="$temp-tocs"/>
    </xsl:variable>
    
    <xsl:variable name="toc">
        <xsl:choose>
             <xsl:when test="$config/config:content-set/config:topic-sets">
                <xsl:call-template name="sf:warning">
                    <xsl:with-param name="message">
                        <!-- FIXME: Should test for the two conditions subjects below. -->
                        <xsl:text>Topic set type order not specified. TOC will be in the order topic sets are listed in the /spfe/content-set configuration setting. External TOC files will be ignored. If topic set IDs specified in <feature>content set configuration file</feature> do not match those defined in the topic set, that topic set will not be included.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:for-each select="$config/config:content-set/config:topic-sets/config:topic-set">
                    <xsl:variable name="id" select="config:id"/>
                    <xsl:sequence select="$unsorted-toc/toc[@topic-set-id eq $id]"/>
                </xsl:for-each>
                
            </xsl:when>
            <xsl:otherwise>
                <!-- FIXME: Is this even possible now? -->
                <xsl:call-template name="sf:warning">
                    <xsl:with-param name="message">
                        <xsl:text>Content set configuration not found in config file. TOC will be in alphabetical order by topic-set-type.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:for-each select="$unsorted-toc/toc">
                    <xsl:sort select="@topic-set-type"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- TOC templates -->
    <xsl:template name="create-map">
        <xsl:result-document href="file:///{$output-directory}/{$content-set-id}.ditamap" 
            method="xml" 
            indent="yes" 
            omit-xml-declaration="no" 
            doctype-public="-//OASIS//DTD DITA Map//EN" 
            doctype-system="map.dtd">
            <map id="{$content-set-id}">
               <title><xsl:value-of select="$config/config:content-set/config:title"/></title>       
               <xsl:apply-templates select="$toc"/>
            </map>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="toc[@topic-set-id ne $config/config:content-set/config:home-topic-set]">
        <mapref href="{normalize-space(@deployment-relative-path)}{normalize-space(@topic-set-id)}.ditamap"/>
    </xsl:template>
    <xsl:template match="toc"/>

    <xsl:template match="node"/>
    
    
</xsl:stylesheet>