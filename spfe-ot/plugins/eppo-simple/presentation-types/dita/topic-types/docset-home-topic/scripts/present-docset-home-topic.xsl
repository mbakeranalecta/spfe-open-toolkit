<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config" exclude-result-prefixes="#all">

	<!-- topic -->
	<xsl:template match="es:docset-home-topic">
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

	<xsl:template match="es:docset-home-topic/es:head"/>
	
	<xsl:template match="es:docset-home-topic/es:body/es:title" mode="topic-title">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="es:docset-home-topic/es:body/es:title"/>
	
	<!-- FIXME: This could be made general just doing es:body once -->
	<xsl:template match="es:docset-home-topic/es:body">
		<!-- Move title outside body because DITA is wierd like that. -->
		<xsl:if test="es:title">
			<title>
				<xsl:apply-templates select="es:title" mode="topic-title"/>
			</title>	
		</xsl:if>
		
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
</xsl:stylesheet>
