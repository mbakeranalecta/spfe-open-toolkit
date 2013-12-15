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

<xsl:param name="presentation-schema">eppo-simple-web-presentation.xsd</xsl:param>
<xsl:param name="draft">no</xsl:param>

<xsl:variable name="config" as="element(config:spfe)">
	<xsl:sequence select="/config:spfe"/>
</xsl:variable>

<xsl:param name="synthesis-files"/>
<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>

<xsl:variable name="topic-set-title">
	<xsl:value-of select="sf:string($config/config:strings, 'eppo-simple-topic-set-title')"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="sf:string($config/config:strings, 'eppo-simple-topic-set-release')"/>
</xsl:variable>
	
<xsl:variable name="doc-set-title" select="$config/config:doc-set/config:title"/>
	
<!--<xsl:variable name="topic-set-id" select="$config/config:topic-set-id"/>-->
	
	
<!--  
=============
Main template
=============
-->
<xsl:template name="main">
	<xsl:result-document href="file:///{concat($config/config:build/config:build-directory, '/temp/presentation/presentation.xml')}" method="xml" indent="no" omit-xml-declaration="no">
		<xsl:element name="{if ($media='paper') then 'book' else 'web'}" >
			<title>
				<xsl:value-of select="sf:string($config/config:strings, 'eppo-simple-topic-set-title')"/>
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
	
<xsl:template match="ss:topic" priority="-1">
	<xsl:call-template name="sf:error">
		<xsl:with-param name="message">
			<xsl:text>A topic of an unrecognised topic type was included in the topic set build. The root element name is "</xsl:text>
			<xsl:value-of select="name(descendant::*[namespace-uri() ne 'http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis'][1])"/>
			<xsl:text>". The topic name is "</xsl:text>
			<xsl:value-of select="@local-name"/>
			<xsl:text>". The topic type is "</xsl:text>
			<xsl:value-of select="@type"/>
			<xsl:text>".</xsl:text>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="topic/name" mode="#all"/>	
<xsl:template match="tracking" mode="#all"/>


	
</xsl:stylesheet>
