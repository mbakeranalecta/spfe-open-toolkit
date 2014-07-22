<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	common-topic-synthesis.xsl
	
	Reads the collection of topic files and text object files
	for the topic set, creates the synthesis element, and hands 
	the rest of the processing off to the inculded/including stylesheets.

	=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	exclude-result-prefixes="#all">

	<xsl:output method="xml" indent="no"/>

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	
	<xsl:param name="authored-content-files"/>
	<xsl:variable name="topics" select="sf:get-sources($authored-content-files)"/>
	
	<!-- FIXME: Need to settle the story on fragments and namespaces.  -->
	<xsl:variable name="fragments" select="$topics/*:fragments/*:body/*:fragment"/>
	
	<xsl:param name="default-topic-scope"/>
	<xsl:param name="topic-set-id"/>
	<xsl:param name="output-directory" select="concat($config/config:doc-set-build, '/topic-sets/', $topic-set-id, '/synthesis/out')"></xsl:param>
	
<!-- 
=============
Main template
=============
-->

	<xsl:template name="main" >
		<!-- Create the root "synthesis element" -->
		<xsl:result-document href="file:///{$output-directory}/synthesis.xml" method="xml" indent="no" omit-xml-declaration="no">
			<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set-id="{$topic-set-id}" title="{sf:string($config//config:strings, 'eppo-simple-topic-set-product')} {sf:string($config//config:strings, 'eppo-simple-topic-set-release')}"> 
				<xsl:apply-templates select="$topics"/>
			</ss:synthesis>
		</xsl:result-document>
	</xsl:template>
	
	<!-- catch any root node that does not have a specific processing attached to it -->
	<!-- priority is -0.6 because wildcard default priority is -0.5-->
	<!-- FIXME: the test should actually be for unknown types, not root elements. But how do we match on that? -->
	<xsl:template match="/*" priority="-0.6">
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Unknown document root element </xsl:text><xsl:value-of select="local-name()"/> 
				<xsl:text> encountered with a namespace of </xsl:text> <xsl:value-of select="namespace-uri()"/> 
				<xsl:text>. You probably need to add a synthesis script for this topic type to the build configuration for the topic set.</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>



