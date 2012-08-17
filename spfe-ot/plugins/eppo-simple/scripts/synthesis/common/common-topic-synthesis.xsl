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
	
	<xsl:param name="topic-files"/>
	<xsl:variable name="topics" select="sf:get-sources($topic-files)"/>
	
	<xsl:param name="text-objects-files"/>
	<xsl:variable name="text-objects"  select="sf:get-sources($text-objects-files)"/>

	<xsl:param name="default-topic-scope"/>


 <!-- 
=============
Main template
=============
-->

	<xsl:template name="main" >
		<!-- Create the root "synthesis element" -->
		<xsl:result-document href="file:///{concat($config/config:build/config:build-directory, '/temp/synthesis/synthesis.xml')}" method="xml" indent="no" omit-xml-declaration="no">
			<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set-id="{$config/config:topic-set-id}" title="{sf:string($config/config:strings, 'eppo-simple-topic-set-product')} {sf:string($config/config:strings, 'eppo-simple-topic-set-release')}"> 
				<xsl:apply-templates select="$topics"/>
				<xsl:apply-templates select="$text-objects"/>
			</ss:synthesis>
		</xsl:result-document>
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



