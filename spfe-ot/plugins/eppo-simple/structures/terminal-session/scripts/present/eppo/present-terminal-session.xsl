<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>

	<xsl:strip-space elements="terminal-session"/>

	<xsl:template match="terminal-session">
	<!-- do it all here so we can control the whitespace in output -->
		<pe:codeblock>
			<xsl:text/><xsl:apply-templates/><xsl:text/>
		</pe:codeblock>
	</xsl:template>
	
	<xsl:template match="terminal-session/prompt">
	<!-- account for the possibility that there is no response between entries -->
	<xsl:if test="preceding-sibling::entry">
			<xsl:text>&#xA;</xsl:text>
	</xsl:if>
		<xsl:if test="normalize-space(.)">
			<xsl:text/><xsl:value-of select="normalize-space(.)"/><xsl:text/>
			<xsl:text>&#160;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="terminal-session/entry">
		<xsl:if test="normalize-space(.)">
			<xsl:sequence select="esf:process-placeholders(., 'code', 'placeholder')"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="terminal-session/response">
		<xsl:if test="normalize-space(.)">
			<xsl:text>&#xA;</xsl:text>
			<xsl:text/><xsl:apply-templates/><xsl:text/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
