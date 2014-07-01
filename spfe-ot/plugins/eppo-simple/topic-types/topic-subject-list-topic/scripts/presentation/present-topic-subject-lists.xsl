<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	exclude-result-prefixes="#all"
	xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/subject-topic-list">

	<!-- 
		=================
		Element templates
		=================
	-->

	<xsl:template
		match="ss:topic[@type='http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/subject-topic-list']">
		<page type="{@type}" name="{@local-name}">
			<xsl:call-template name="show-header"/>
			<title>
				<xsl:value-of select="@title"/>
			</title>
			<xsl:apply-templates/>
			<xsl:call-template name="show-footer"/>
		</page>

	</xsl:template>


	<!-- subject-topic-list -->
	<xsl:template match="subject-topic-list">
		<xsl:variable name="xpath" select="xpath"/>
		<xsl:variable name="name" select="name"/>
		<xsl:message select="name(), namespace-uri()"/>

		<!-- info -->

		<p>
			<xsl:value-of select="parent::ss:topic/@excerpt"/>
		</p>
		<xsl:for-each select="topics-on-subject/topic">
			<labeled-item>
				<label>
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="full-name"/>
						<xsl:with-param name="type">topic</xsl:with-param>
						<xsl:with-param name="content">
							<xsl:value-of select="topic-type-alias"/>: <xsl:value-of select="title"/>
						</xsl:with-param>
						<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
					</xsl:call-template>
				</label>

				<item>
					<p><xsl:value-of select="excerpt"></xsl:value-of></p>
				</item>
			</labeled-item>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
