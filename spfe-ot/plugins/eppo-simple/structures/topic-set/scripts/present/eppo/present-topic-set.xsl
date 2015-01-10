<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 	
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
 	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
 	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
 	exclude-result-prefixes="#all">
	
<!-- processing directives -->
<xsl:output method="xml" indent="yes"/>

<!-- parameters -->
	
	<!-- FIXME: This should be in config. -->
	<xsl:param name="output-directory"/>
<!-- FIXME: This shoud be read from config file. -->
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
	<xsl:result-document href="file:///{$output-directory}/presentation.xml" method="xml" indent="yes" omit-xml-declaration="no" >

		<pe:pages xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xsi:schemaLocation="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/presentation-types/eppo/schemas/presentation-eppo.xsd">
			<pe:title>
				<xsl:value-of select="sf:string($config/config:topic-set[config:topic-set-id=$topic-set-id]/config:strings, 'eppo-simple-topic-set-title')"/>
			</pe:title>
				
			<!-- process the topics --> 
			<xsl:apply-templates select="$synthesis/ss:synthesis/*"/>
			<xsl:call-template name="create-generated-topics"/>

		</pe:pages>
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

	<xsl:template match="pe:topic/pe:name" mode="#all"/>	
	<xsl:template match="pe:tracking" mode="#all"/>
	
	<xsl:template match="*" >
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Unknown element found in synthesis while creating EPPO-simple presentation: </xsl:text>
				<xsl:value-of select="string-join(for $i in ancestor-or-self::* return name($i), '/'), concat( 'in namespace ', namespace-uri(), '.')"/>
			</xsl:with-param>
			<xsl:with-param name="in" select="base-uri(document(''))"></xsl:with-param>
		</xsl:call-template>
		<xsl:apply-templates/>
	</xsl:template>
	<!-- Targets to absorb fields from the synthesis wrapper.  -->
	<xsl:template match="ss:*"/>
</xsl:stylesheet>
