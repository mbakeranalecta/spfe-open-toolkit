<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 	
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
 	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 	exclude-result-prefixes="#all">
	
<!-- processing directives -->
<xsl:output method="xml" indent="yes"/>
	
	<!-- FIXME: hack -->
	<xsl:variable name="media">online</xsl:variable>

<!-- parameters -->
	
	<!-- FIXME: This should be in config. -->
	<xsl:param name="output-image-directory">graphics</xsl:param>
	<xsl:param name="output-directory" select="concat($config/config:doc-set-build, '/topic-sets/', $topic-set-id, '/presentation/out')"/>

<xsl:param name="draft">no</xsl:param>
	
<xsl:param name="topic-set-id"/>

<xsl:variable name="config" as="element(config:spfe)">
	<xsl:sequence select="/config:spfe"/>
</xsl:variable>

<xsl:param name="synthesis-files"/>
<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>

<xsl:variable name="topic-set-title" select="sf:string($config/config:topic-set[config:topic-set-id=$topic-set-id]/config:strings, 'eppo-simple-topic-set-title')"/>
<!--  
=============
Main template
=============
-->
<xsl:template name="main">
	<xsl:result-document href="file:///{$output-directory}/presentation.xml" method="xml" indent="no" omit-xml-declaration="no">
		<xsl:element name="{if ($media='paper') then 'book' else 'web'}" >
			<title>
				<xsl:value-of select="sf:string($config/config:topic-set[config:topic-set-id=$topic-set-id]/config:strings, 'eppo-simple-topic-set-title')"/>
			</title>
				
			<!-- process the topics --> 
			<xsl:apply-templates select="$synthesis/ss:synthesis/*"/>
			<xsl:call-template name="create-generated-topics"/>

		</xsl:element>
	</xsl:result-document>
</xsl:template>

<xsl:template name="create-generated-topics">
	<xsl:call-template name="create-toc-page"/>
</xsl:template>
	
<xsl:template match="ss:topic" priority="1">
	<!-- Individual topic types can also match ss:topic for further processing. -->
	<xsl:call-template name="sf:info">
		<xsl:with-param name="message" select="'Creating page ', string(@local-name)"/>
	</xsl:call-template>
	<xsl:next-match/>
</xsl:template>
	
<!-- This is to make sure processing continues if topic types do not provide their own version. -->	
<xsl:template match="ss:topic" priority="-0.1">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="topic/name" mode="#all"/>	
<xsl:template match="tracking" mode="#all"/>
	
	<xsl:template match="*" >
		<xsl:call-template name="sf:warning">
			<xsl:with-param name="message">
				<xsl:text>Unknown element found in synthesis: </xsl:text>
				<xsl:value-of select="concat('{', namespace-uri(), '}', name())"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:apply-templates/>
	</xsl:template>
	<!-- Targets to absorb fields from the synthesis wrapper.  -->
	<xsl:template match="ss:*"/>
</xsl:stylesheet>
