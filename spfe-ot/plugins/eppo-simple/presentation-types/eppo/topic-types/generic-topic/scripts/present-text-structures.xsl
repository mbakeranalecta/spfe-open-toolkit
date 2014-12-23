<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>
<!--<xsl:output indent="no"/>-->
<xsl:strip-space elements="terminal-session"/>




	<!-- FIXME: This needs to be an explicit list or else it overrides subject-templates.xsl in 
		the import order. Might be fixed by converting individual reference types to subject or name 
		at the synthesis stage, or by changing the import order. -->
	<xsl:template match="title
		| tr
		| td
		| th
">
		
		<xsl:element name="pe:{local-name()}" namespace="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="body">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="text-object">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="text-object/tracking"/>
	<xsl:template match="text-object/id"/>
	
	<xsl:template match="text-object/title">
		<pe:title><xsl:apply-templates/></pe:title>
	</xsl:template>



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
