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
	
	<xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
	<xsl:import href="synthesize-text-structures.xsl"/>
	<xsl:output method="xml" indent="no"/>

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	
	<!-- FIXME: Generalize the load function. Remove need for hard coded sourcd dirs. See schema docs.-->
	<xsl:param name="topic-files"/>
	<xsl:variable name="topics-dir" select="concat($config/config:build/config:build-directory, '/temp/topics/')"/>
	
	<!-- FIXME: switch to sending in full paths, then use config:dir-separator in the regex -->
	<xsl:variable name="topics">
		<xsl:for-each select="tokenize($topic-files, ';')">
			<xsl:sequence select="doc(concat('file:///',translate($topics-dir,'\','/'), .))"/>	
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:param name="text-objects-files"/>
	<xsl:variable name="text-objects"  xml:base="text-objects/">
		<xsl:sequence select="document(tokenize($text-objects-files, $config/config:dir-separator))//text-object"/>
	</xsl:variable>

	<xsl:param name="topic-set-id"/>
	<xsl:param name="draft">no</xsl:param>
	<xsl:param name="optional-product"/>
	<xsl:param name="default-topic-scope"/>


 <!-- 
=============
Main template
=============
-->

	<xsl:template name="main" >
		<!-- Create the root "synthesis element" -->
		<xsl:result-document href="file:///{concat($config/config:build/config:build-directory, '/temp/synthesis/synthesis.xml')}" method="xml" indent="no" omit-xml-declaration="no">
			<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set="{$config/config:topic-set-id}"> 
				<xsl:apply-templates select="$topics"/>
				<xsl:apply-templates select="$text-objects"/>
			</ss:synthesis>
		</xsl:result-document>
	</xsl:template>
	

	<xsl:template name="apply-topic-attributes">
			<!-- copy existing attributes -->
		<xsl:copy-of select="@*" copy-namespaces="no"/>
		
		<xsl:attribute name="default-reference-scope" select="$default-reference-scope"/>
		
		<!-- add optional-product attribute-->
		<xsl:if test="$optional-product">
			<xsl:attribute name="optional-product" select="$optional-product"/>
		</xsl:if>				
		
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
	
	<xsl:template match="topic" priority="-1">
		<xsl:call-template name="error">
			<xsl:with-param name="message">
				<xsl:text>A topic element was found for which no synthesis-level topic template exists. For topic: </xsl:text>
				<xsl:value-of select="name"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="scope"/>
	
</xsl:stylesheet>



