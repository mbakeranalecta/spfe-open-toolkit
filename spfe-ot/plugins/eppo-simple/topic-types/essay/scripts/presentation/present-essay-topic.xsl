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
		<pe:page status="{es:head/es:history/es:revision[last()]/es:status}"
			name="{ancestor::ss:topic/@local-name}">
			<xsl:call-template name="show-header"/>
			<xsl:apply-templates/>
			<xsl:call-template name="show-footer"/>
		</pe:page>
	</xsl:template>

	<xsl:template match="es:essay/es:head"/>

	<xsl:template match="es:essay/es:body/es:title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
		<!-- page toc -->
		<xsl:if test="count(../es:section/es:title) gt 1">
			<pe:toc>
				<xsl:for-each select="../es:section/es:title">
					<pe:toc-entry>
						<pe:xref target="#{sf:title-to-anchor(normalize-space(.))}">
							<xsl:value-of select="."/>
						</pe:xref>
					</pe:toc-entry>
				</xsl:for-each>
			</pe:toc>
		</xsl:if>
	</xsl:template>

	<xsl:template match="es:essay/es:body/es:byline">
		<pe:byline>
			<pe:by-label>By </pe:by-label>
			<pe:authors>
				<!-- FIXME: This should be checking the link catalogs to see if there are links for authors. -->
				<xsl:for-each select="es:author">
					<pe:name hint="author">
						<xsl:apply-templates/>
					</pe:name>
					<xsl:if test="not(position() eq last())">, </xsl:if>
				</xsl:for-each>
			</pe:authors>
		</pe:byline>
	</xsl:template>
	
	<xsl:template match="es:essay/es:body/es:byline/es:author">

	</xsl:template>
	
	<xsl:template match="es:essay/es:body/es:precis">
		<pe:precis>
			<pe:title>Summary</pe:title>
			<xsl:apply-templates/>
		</pe:precis>
	</xsl:template>

	<xsl:template match="es:essay/es:body/es:section">
		<xsl:if
			test="$config/config:build-command='draft' or sf:has-content(es:title/following-sibling::*) ">
			<pe:section>
				<pe:anchor name="{sf:title-to-anchor(es:title)}"/>
				<xsl:apply-templates/>
			</pe:section>
		</xsl:if>
	</xsl:template>

	<xsl:template match="es:essay/es:body/es:section/es:title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
	</xsl:template>

</xsl:stylesheet>
