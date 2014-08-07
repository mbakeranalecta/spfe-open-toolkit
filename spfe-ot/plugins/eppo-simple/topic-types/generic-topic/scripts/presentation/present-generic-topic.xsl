<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:gt="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/topic-types/generic-topic"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
 exclude-result-prefixes="#all">
	
	<!-- topic -->
	<xsl:template match="gt:generic-topic">
		<xsl:choose>
			<xsl:when test="$media='online'"> 
				<page status="{gt:head/gt:history/gt:revision[last()]/gt:status}" name="{ancestor::ss:topic/@local-name}">
					<xsl:call-template name="show-header"/>
					<xsl:apply-templates /> 
					<xsl:call-template name="show-footer"/>		
				</page>
			</xsl:when>
			<xsl:when test="$media='paper'">
				<chapter status="{gt:head/gt:tracking/gt:status}" name="{gt:name}">
					<xsl:apply-templates/>
				</chapter>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'Unknown media specified: ', $media"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="gt:head"/>

	<xsl:template match="gt:generic-topic/gt:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>
	
	<xsl:template match="gt:section">
		<xsl:if test="$config/config:build-command='draft' or sf:has-content(gt:title/following-sibling::*) ">
		<section>
			<anchor name="{sf:title-to-anchor(gt:title)}"/>
			<xsl:apply-templates/>
		</section>
		</xsl:if>	
	</xsl:template>
	
	<xsl:template match="gt:section/gt:title">	
			<title>
				<xsl:apply-templates/>
			</title>
	</xsl:template>
	
</xsl:stylesheet>