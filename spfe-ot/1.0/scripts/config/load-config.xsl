<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://spfeopentoolkit.org/ns/spfe-ot/config"
    xmlns:spfe="http://spfeopentoolkit.org/spfe-ot/1.0/xslt/fuctions"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gen="dummy-namespace-for-the-generated-xslt"
    xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-ot/config"
    exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="../common/utility-functions.xsl"/>

    <xsl:param name="HOME"/>
    <xsl:param name="SPFEOT_HOME"/>
    <xsl:param name="SPFE_BUILD_DIR"/>

    <!-- directories -->
    <xsl:variable name="home" select="translate($HOME, '\', '/')"/>
    <xsl:variable name="spfeot-home" select="translate($SPFEOT_HOME, '\', '/')"/>
    <xsl:variable name="build-directory" select="translate($SPFE_BUILD_DIR, '\', '/')"/>
    <xsl:variable name="content-set-build-root-directory"
        select="concat($build-directory,  '/', /content-set/content-set-id)"/>
    <xsl:variable name="content-set-build"
        select="concat($content-set-build-root-directory, '/build')"/>
    <xsl:variable name="content-set-output"
        select="concat($content-set-build-root-directory, '/output')"/>

    <xsl:function name="spfe:resolve-defines" as="xs:string">
        <xsl:param name="value"/>
        <xsl:variable name="defines" as="element(define)*">
            <define name="HOME" value="{$home}"/>
            <define name="SPFEOT_HOME" value="{$spfeot-home}"/>
            <define name="CONTENT_SET_BUILD_DIR" value="{$content-set-build}"/>
            <define name="CONTENT_SET_OUTPUT_DIR" value="{$content-set-output}"/>
            <define name="CONTENT_SET_BUILD_ROOT_DIR" value="{$content-set-build-root-directory}"/>
        </xsl:variable>
        <xsl:variable name="result">
            <xsl:analyze-string select="$value" regex="\$\{{([^}}]*)\}}">
                <xsl:matching-substring>
                    <xsl:value-of select="$defines[@name=regex-group(1)]/@value"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join($result,'')"/>
    </xsl:function>

    <!-- 
    =============================================================================
         Read the configuration 
    =============================================================================
    -->

    <!-- copy the attribute nodes from the config files -->
    <xsl:template match="@*" priority="-0.1">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- copy the element nodes from the config files -->
    <!-- add a base-uri attribute to each so we can resolve relative URIs 
         correctly based on the config file in which they occurred -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/topic-set">
        <xsl:if test="not(topic-set-link-priority)">
            <topic-set-link-priority>1</topic-set-link-priority>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="/topic-set/topic-set-id"/>
    <xsl:template match="/object-set"><xsl:apply-templates/></xsl:template>
    <xsl:template match="/object-set/object-set-id"/>
    <xsl:template match="/topic-type">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(topic-type-link-priority)">
                <topic-type-link-priority>1</topic-type-link-priority>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <!--<xsl:template match="spfe/topic-type/name"/>-->
    <xsl:template match="/object-type"><xsl:apply-templates/></xsl:template>
    <xsl:template match="/object-type/name"/>
    <xsl:template match="/structure"><xsl:apply-templates/></xsl:template>
    <xsl:template match="/structure/name"/>
    <xsl:template match="/file-type"><xsl:apply-templates/></xsl:template>
    <xsl:template match="/file-type/name"/>
    <xsl:template match="/structures/name"/>
    <xsl:template match="content-set/topic-sets"><xsl:apply-templates/></xsl:template>
    <xsl:template match="/content-set/object-sets"><xsl:apply-templates/></xsl:template>
    <xsl:template match="/content-set/output-formats/output-format"><xsl:apply-templates/></xsl:template>
    <xsl:template match="/content-set/output-formats/output-format/name"/>
    <xsl:template match="/topic-set/topic-types"><xsl:apply-templates/></xsl:template>

    <xsl:template match="script">
        <xsl:param tunnel="yes" name="rewrite-namespace"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
        <xsl:if test="$rewrite-namespace">
            <xsl:sequence select="$rewrite-namespace"/>
        </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- surpress the including version of the name in favor to the included one -->
    <xsl:template match="topic-type[href]">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="topic-type[href]/name"/>

    
    <xsl:template match="//topic-type/href| //object-type/href| //output-format/href| //presentation-type/href| //topic-set/href| //object-set/href| //structure/href| //file-type/href //object-type/href">
        <xsl:variable name="this" select="."/>
        <xsl:if test="not(doc-available(sf:local-to-url(resolve-uri(spfe:resolve-defines(.),base-uri($this)))))">
            <xsl:call-template name="sf:error">
                <xsl:with-param name="message">
                    <xsl:text>Configuration file </xsl:text>
                    <xsl:value-of select="resolve-uri(spfe:resolve-defines(.),base-uri($this))"/>
                    <xsl:text> not found. This may mean the file is not present or that is it not a valid XML file.</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="in" select="base-uri(document(''))"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="../rewrite-namespace">
                <xsl:apply-templates
                    select="document(sf:local-to-url(resolve-uri(spfe:resolve-defines(.),base-uri($this))))"
                   >
                    <xsl:with-param name="rewrite-namespace" tunnel="yes">
                        <xsl:sequence select="../rewrite-namespace"/>
                    </xsl:with-param>
                </xsl:apply-templates>      
            </xsl:when>
        <xsl:otherwise>
        <xsl:apply-templates
            select="document(sf:local-to-url(resolve-uri(spfe:resolve-defines(.),base-uri($this))))"
           />
        </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xsl:template match="href|include|script[not(href)]|build-rules">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="sf:url-to-local(resolve-uri(spfe:resolve-defines(.),base-uri()))"
            />
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
