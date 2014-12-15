<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config" exclude-result-prefixes="#all">

	<!-- topic -->
	<xsl:template match="es:essay">
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

	<xsl:template match="es:essay/es:head"/>
	
	<xsl:template match="es:essay/es:body">
		<!-- Move title outside body because DITA is wierd like that. -->
		<xsl:if test="es:title">
			<title>
				<xsl:apply-templates select="es:title" mode="topic-title"/>
			</title>	
		</xsl:if>
		<shortdesc>
			<xsl:apply-templates select="es:precis" mode="precis"/>
		</shortdesc>
		<body>
			<!-- page toc -->
			<!--<xsl:if test="count(../es:section/es:title) gt 1">
							<pe:toc>
				<xsl:for-each select="../es:section/es:title">
					<pe:toc-entry>
						<pe:xref target="#{sf:title-to-anchor(normalize-space(.))}">
							<xsl:value-of select="."/>
						</pe:xref>
					</pe:toc-entry>
				</xsl:for-each>
			</pe:toc>
		</xsl:if>-->
			<xsl:apply-templates/>
		</body>		
	</xsl:template>


	<xsl:template match="es:essay/es:body/es:title" mode="topic-title">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="es:essay/es:body/es:title"/>

	<xsl:template match="es:essay/es:body/es:byline">
		<p>By 
				<xsl:for-each select="es:name">
					<i>
						<xsl:choose>
							<!-- make sure that the target exists -->
							<xsl:when test="esf:target-exists(., 'author')">
								<xsl:call-template name="output-link">
									<xsl:with-param name="target" select="@key"/>
									<xsl:with-param name="type" select="@type"/>
									<xsl:with-param name="class">author</xsl:with-param>
									<xsl:with-param name="content" select="normalize-space(string-join(.,''))"/>
									<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="sf:subject-not-resolved">
									<xsl:with-param name="message" select="'Author name  &quot;', ., '&quot;'"/> 
									<xsl:with-param name="in" select="ancestor::ss:topic/@full-name"/> 
								</xsl:call-template>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</i>
					<xsl:if test="not(position() eq last())">, </xsl:if>
				</xsl:for-each>
			
		</p>
	</xsl:template>
	
	<xsl:template match="es:essay/es:body/es:byline/es:name">

	</xsl:template>
	
	<xsl:template match="es:essay/es:body/es:precis"/>
	<xsl:template match="es:essay/es:body/es:precis" mode="precis">
			<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="es:essay/es:body/es:precis/es:p">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="es:essay/es:body/es:section">
		<xsl:if
			test="$config/config:build-command='draft' or sf:has-content(es:title/following-sibling::*) ">
			<section id="{sf:title-to-anchor(es:title)}">
				<xsl:apply-templates/>
			</section>
		</xsl:if>
	</xsl:template>

	<xsl:template match="es:essay/es:body/es:section/es:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>

</xsl:stylesheet>
