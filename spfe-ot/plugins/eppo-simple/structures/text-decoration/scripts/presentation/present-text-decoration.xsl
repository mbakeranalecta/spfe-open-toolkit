<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"	
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">
	
	<xsl:template match="p/bold | string/bold">
		<pe:bold>
			<xsl:apply-templates/>
		</pe:bold>
	</xsl:template>
	
	<xsl:template match="p/italic | string/italic">
		<pe:italic>
			<xsl:apply-templates/>
		</pe:italic>
	</xsl:template>
	
	<xsl:template match="p/code | string/code">
		<pe:code>
			<xsl:apply-templates/>
		</pe:code>
	</xsl:template>
	
	<xsl:template match="p/quote | string/quote">
		<xsl:text>“</xsl:text>
			<xsl:apply-templates/>
		<xsl:text>”</xsl:text>
	</xsl:template>
	
	<!-- FIXME: Need to do something more definite here. Need to give a clear contract to the format layer. -->
	<!-- FIXME: Does this ever get called? -->
	<xsl:template match="decoration">
		<xsl:message terminate="yes">decoration template got called. Who knew?</xsl:message>
		<xsl:copy-of select="."/>
	</xsl:template>


</xsl:stylesheet>
