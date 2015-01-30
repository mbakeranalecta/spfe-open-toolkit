<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config" exclude-result-prefixes="#all">

	<!-- topic -->
	<xsl:template match="es:docset-home-topic">
		<pe:page status="{es:head/es:history/es:revision[last()]/es:status}"
			name="{ancestor::ss:topic/@local-name}">
			<xsl:call-template name="show-header"/>
			<xsl:apply-templates/>
			<xsl:call-template name="show-footer"/>
		</pe:page>
	</xsl:template>

	<xsl:template match="es:docset-home-topic/es:head"/>

	<xsl:template match="es:docset-home-topic/es:title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
		<!-- page toc -->
		<xsl:if test="count(../es:section/es:title) gt 1">
			<pe:toc>
				<xsl:for-each select="../es:section/es:title">
					<pe:toc-entry>
						<pe:link target="#{sf:title-to-anchor(normalize-space(.))}">
							<xsl:value-of select="."/>
						</pe:link>
					</pe:toc-entry>
				</xsl:for-each>
			</pe:toc>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
