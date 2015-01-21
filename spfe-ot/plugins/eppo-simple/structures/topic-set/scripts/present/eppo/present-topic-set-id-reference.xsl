<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:lc="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/link-catalog"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"	
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">


	<xsl:template match="topic-set-id">
		<xsl:variable name="topic-set" select="@id-ref"/>
		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($topic-set, 'topic-set')">
				<xsl:call-template name="output-link">
					<xsl:with-param name="target" select="$topic-set"/>
					<xsl:with-param name="type">topic-set</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:value-of select="$link-catalogs//lc:target[@type='topic-set'][lc:key=$topic-set]/parent::lc:page/@title"/>
					</xsl:with-param>
					<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'Topic set not found: ', $topic-set"/> 
				</xsl:call-template>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
