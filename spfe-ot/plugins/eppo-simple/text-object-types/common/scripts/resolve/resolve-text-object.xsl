<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<!-- ===================================================
	resolve-text-object.xsl
	
	Reads the collection of text-object files
	for the content set, creates the synthesis element, and hands 
	the rest of the processing off to the inculded/including stylesheets.

	=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:esto="http://spfeopentoolkit.org/ns/eppo-simple/text-objects"
	exclude-result-prefixes="#all">
	<xsl:variable name="topic-set-id">spfe.text-objects</xsl:variable>

	<xsl:output method="xml" indent="no"/>

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	
	<xsl:param name="authored-content-files"/>
	<xsl:variable name="topics" select="sf:get-sources($authored-content-files)"/>
	
	
	<xsl:variable name="fragments" select="$topics/*:fragments/*:body/*:fragment"/>
	
	
	<xsl:variable 
		name="strings" 
		select=" 
			$config/config:content-set/config:strings/config:string"
		as="element()*"/>
		
	
	
	<xsl:param name="default-topic-scope"/>

	<!-- FIXME: This should not be defaulted. -->
	<xsl:param name="output-directory" select="concat($config/config:content-set-build, '/topic-sets/spfe.text-objects/resolve/out')"/>
	
<!-- 
=============
Main template
=============
-->

	<xsl:template name="main" >
		<!-- Create the root "synthesis element" -->
		<xsl:result-document href="file:///{$output-directory}/synthesis.xml" method="xml" indent="no" omit-xml-declaration="no">
			<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set-id="spfe.text-objects" title="{sf:string($config//config:strings, 'product')} {sf:string($config//config:strings, 'product-release')}"> 
				<xsl:apply-templates select="$topics">
					<xsl:with-param name="in-scope-strings" select="$strings" tunnel="yes"/>
					<xsl:with-param name="in-scope-fragments" select="$fragments" tunnel="yes"/>
				</xsl:apply-templates>
			</ss:synthesis>
		</xsl:result-document>
	</xsl:template>
	
	<!-- FIXME: these should be made explicit to avoid passing on elements that should be specifically handled or rejected. -->
	
	<!-- catch any root node that does not have a specific processing attached to it -->
	<!-- priority is -0.6 because wildcard default priority is -0.5-->
	<!-- FIXME: the test should actually be for unknown types, not root elements. But how do we match on that? -->
	<xsl:template match="/*" priority="-0.6">
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Unknown text-object root element </xsl:text>
				<xsl:value-of select="local-name()"/> 
				<xsl:text> encountered with a namespace of </xsl:text> 
				<xsl:value-of select="namespace-uri()"/> 
				<xsl:text>. You probably need to add a synthesis script for this text object type to the build configuration for the content set.</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*" priority="-1">
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Unknown element "</xsl:text><xsl:value-of select="local-name()"/> 
				<xsl:text>" encountered in a text-object of type </xsl:text> <xsl:value-of select="sf:name-in-clark-notation(/*[1])"/> 
				<xsl:text>. You probably need to add a synthesis script for this element type to the build configuration for the content set.</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>



