<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:eppo="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all">
	
	<!-- topic -->
	<xsl:template match="eppo:essay">
		<xsl:choose>
			<xsl:when test="$media='online'"> 
				<page status="{eppo:head/eppo:history/eppo:revision[last()]/eppo:status}" name="{ancestor::ss:topic/@local-name}">
					<xsl:call-template name="show-header"/>
					<xsl:apply-templates /> 
					<xsl:call-template name="show-footer"/>		
				</page>
			</xsl:when>
			<xsl:when test="$media='paper'">
				<chapter status="{eppo:head/eppo:tracking/eppo:status}" name="{eppo:name}">
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
	
	<xsl:template match="eppo:head"/>

	<xsl:template match="eppo:essay/eppo:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>
	
	<xsl:template match="eppo:byline">
		<p hint="byline"><xsl:apply-templates/></p>
	</xsl:template>
	
	<xsl:template match="eppo:precis">
		<title>Summary</title>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="eppo:section">
		<xsl:if test="$config/config:build-command='draft' or sf:has-content(eppo:title/following-sibling::*) ">
		<section>
			<anchor name="{sf:title-to-anchor(eppo:title)}"/>
			<xsl:apply-templates/>
		</section>
		</xsl:if>	
	</xsl:template>
	
	<xsl:template match="eppo:section/eppo:title">	
			<title>
				<xsl:apply-templates/>
			</title>
	</xsl:template>
	
</xsl:stylesheet>