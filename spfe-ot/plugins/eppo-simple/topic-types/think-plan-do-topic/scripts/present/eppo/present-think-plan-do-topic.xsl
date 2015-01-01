<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	exclude-result-prefixes="#all">
	
	<!-- topic -->
	<xsl:template match="es:think-plan-do-topic">
		<pe:page status="{es:head/es:history/es:revision[last()]/es:status}" name="{ancestor::ss:topic/@local-name}">
			<xsl:call-template name="show-header"/>
			<xsl:apply-templates /> 
			<xsl:call-template name="show-footer"/>		
		</pe:page>
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:head"/>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:title">
		<xsl:variable name="title" select="."></xsl:variable>
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
		<!-- page toc -->
		<pe:toc>
			<pe:toc-entry><pe:xref target="#Think">Understanding <xsl:value-of select="$title"/></pe:xref></pe:toc-entry>
			<pe:toc-entry><pe:xref target="#Plan">Planning <xsl:value-of select="$title"/></pe:xref></pe:toc-entry>
			<pe:toc-entry><pe:xref target="#Do">Doing <xsl:value-of select="$title"/></pe:xref></pe:toc-entry>
		</pe:toc>
		
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question">
		<xsl:if test="$config/config:build-command='draft' or sf:has-content(es:planning-question-title/following-sibling::*) ">
			<pe:labeled-item>
				<pe:anchor name="{sf:title-to-anchor(es:planning-question-title)}"/>
				<xsl:apply-templates/>
			</pe:labeled-item>
		</xsl:if>	
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question/es:planning-question-title">	
		<pe:label>
			<xsl:apply-templates/>
		</pe:label>
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:understanding">	
		<pe:section>
			<pe:anchor name="Think"/>
			<pe:title>Understanding <xsl:value-of select="ancestor::es:body/es:title"/></pe:title>
			<xsl:apply-templates/>
		</pe:section>
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning">
		<pe:section>
			<pe:anchor name="Plan"/>
			<pe:title>Planning <xsl:value-of select="ancestor::es:body/es:title"/></pe:title>
			<xsl:apply-templates/>
		</pe:section>
	</xsl:template>
	
<!--	<xsl:template match="es:planning-question">
		<xsl:apply-templates/>
	</xsl:template>-->
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question/es:planning-question-body">
		<pe:item>
			<xsl:apply-templates/>
		</pe:item>
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:doing">	
		<pe:section>
			<pe:anchor name="Do"/>
			<pe:title>Doing <xsl:value-of select="ancestor::es:body/es:title"/></pe:title>
			<xsl:apply-templates/>
		</pe:section>
	</xsl:template>	
</xsl:stylesheet>