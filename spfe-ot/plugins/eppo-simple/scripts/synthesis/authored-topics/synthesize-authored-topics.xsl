<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	synthesize-authored-topics.xsl
	
	Reads the collection of topic files and text object files
	for the topic set, processes the topic element, and hands 
	the rest of the processing off to the inculded stylesheets.

	=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:spfe="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
exclude-result-prefixes="#all">
	<xsl:import href="../common/common-topic-synthesis.xsl"/> 
	

	<xsl:variable name="config">
		<xsl:sequence select="/"/>
	</xsl:variable>
	

	<xsl:template match="topic">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:choose>
			<xsl:when test="sf:conditions-met($conditions, $condition-tokens)">
				<topic>
					<xsl:call-template name="apply-topic-attributes"/>
					<xsl:apply-templates/>
				</topic>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="info">
					<xsl:with-param name="message">
						<xsl:text>Suppressing topic </xsl:text>
						<xsl:value-of select="name"/>
						<xsl:text> because its conditions (</xsl:text>
						<xsl:value-of select="$conditions"/>
						<xsl:text>) do not match the conditions specified for the build ( </xsl:text>
						<xsl:value-of select="$condition-tokens"/>
						<xsl:text>).</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>

