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
	
	<xsl:param name="default-topic-scope"/>
	<xsl:param name="topic-set-id"/>
	
<!-- 
=============
Main template
=============
-->

	<xsl:template name="main" >
		<!-- Create the root "synthesis element" -->
		<xsl:result-document href="file:///{concat($config/config:doc-set-build, '/', $topic-set-id, '/synthesis/synthesis.xml')}" method="xml" indent="no" omit-xml-declaration="no">
			<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set-id="{$topic-set-id}" title="{sf:string($config//config:strings, 'eppo-simple-topic-set-product')} {sf:string($config//config:strings, 'eppo-simple-topic-set-release')}"> 
				<xsl:apply-templates select="$topics"/>
			</ss:synthesis>
		</xsl:result-document>
	</xsl:template>
	
	<!-- catch any root node that does not have a specific processing attached to it -->
	<xsl:template match="/*" priority="-1">
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Unknown document root element </xsl:text><xsl:value-of select="local-name()"/> 
				<xsl:text>encountered with a namespace of </xsl:text> <xsl:value-of select="namespace-uri()"/>. 
				<xsl:text>You probably need to add a synthesis script for this topic type to the build configuration for the topic set.</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	

	<xsl:template name="apply-topic-attributes">
			<!-- copy existing attributes -->
		<xsl:copy-of select="@*" copy-namespaces="no"/>
		
		<xsl:attribute name="default-reference-scope" select="$default-reference-scope"/>
		<!-- add scope attributes, if scope meets conditions -->
		<xsl:choose>
			<xsl:when test="scope">
				<xsl:attribute name="scope">
					<xsl:for-each select="scope">
						<xsl:variable name="conditions" select="@if"/>
						<xsl:if test="sf:conditions-met($conditions, $condition-tokens)">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$default-topic-scope">
				<xsl:attribute name="scope" select="$default-topic-scope"/>
			</xsl:when>	
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>



