<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo" exclude-result-prefixes="#all"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple">

	<!-- subject-topic-list -->
	<xsl:template match="*:subject-topic-list/*:topics-on-subject/*:topic">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:call-template name="output-link">
				<xsl:with-param name="target" select="full-name"/>
				<xsl:with-param name="type">topic</xsl:with-param>
				<xsl:with-param name="content">
					<xsl:value-of select="topic-type-alias"/>: <xsl:value-of select="title"/>
				</xsl:with-param>
				<xsl:with-param name="current-page-name"
					select="ancestor-or-self::ss:topic/@full-name"/>
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="node() | @*" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>
