<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:gt="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/topic-types/generic-task-topic"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all">
 
	<xsl:template match="ss:topic">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- topic -->
	<xsl:template match="gt:generic-task-topic">
		<xsl:choose>
			<xsl:when test="$media='online'"> 
				<page status="{gt:head/gt:tracking/gt:status}" name="{ancestor::ss:topic/@local-name}">
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

	<xsl:template match="gt:generic-task-topic/gt:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>
	

	<xsl:template match="gt:planning-question">
		<xsl:if test="$config/config:build-command='draft' or esf:section-has-content(gt:planning-question-title/following-sibling::*) ">
		<planning-question>
			<anchor name="{sf:title2anchor(gt:planning-question-title)}"/>
			<xsl:apply-templates/>
		</planning-question>
		</xsl:if>	
	</xsl:template>


	<xsl:template match="gt:planning/gt:planning-question/gt:planning-question-title">	
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>


</xsl:stylesheet>