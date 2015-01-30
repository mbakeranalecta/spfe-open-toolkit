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
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
	exclude-result-prefixes="#all">
	
	<!-- topic -->
	<xsl:template match="es:think-plan-do-topic">
		<xsl:result-document href="file:///{$output-directory}/{$topic-set-id}/{ancestor::ss:topic/@local-name}.dita" 
			method="xml" 
			indent="yes" 
			omit-xml-declaration="no" 
			doctype-public="-//OASIS//DTD DITA Topic//EN" 
			doctype-system="topic.dtd">
			<topic id="{ancestor::ss:topic/@local-name}">
				<xsl:apply-templates/>
			</topic>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:head"/>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:title" mode="topic-title">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="es:think-plan-do-topic/es:body/es:title"/>

	<xsl:template match="es:think-plan-do-topic/es:body">
		<!-- Move title outside body because DITA is wierd like that. -->
		<xsl:if test="es:title">
			<title>
				<xsl:apply-templates select="es:title" mode="topic-title"/>
			</title>	
		</xsl:if>
		
		<body>
			<xsl:apply-templates/>
		</body>		
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question">
		<xsl:if test="$config/config:build-command='draft' or sf:has-content(es:planning-question-title/following-sibling::*) ">
			<dlentry id="{sf:title-to-anchor(es:planning-question-title)}">
				<xsl:apply-templates/>
			</dlentry>
		</xsl:if>	
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question/es:planning-question-title">	
		<dt>
			<xsl:apply-templates/>
		</dt>
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:understanding">	
		<section id="Think">
			<title>Understanding <xsl:value-of select="ancestor::es:body/es:title"/></title>
			<xsl:apply-templates/>
		</section>
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning">
		<section id="Plan">
			<title>Planning <xsl:value-of select="ancestor::es:body/es:title"/></title>
			<dl>
				<xsl:apply-templates/>
			</dl>
			
		</section>
	</xsl:template>
	
<!--	<xsl:template match="es:planning-question">
		<xsl:apply-templates/>
	</xsl:template>-->
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question/es:planning-question-body">
		<dd>
			<xsl:apply-templates/>
		</dd>
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:doing">	
		<section id="Do">
			<title>Doing <xsl:value-of select="ancestor::es:body/es:title"/></title>
			<xsl:apply-templates/>
		</section>
	</xsl:template>	
</xsl:stylesheet>