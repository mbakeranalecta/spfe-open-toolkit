<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>

	<xsl:template match="table">
		<pe:table>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:table>
	</xsl:template>
	
	<xsl:template match="table/caption">
		<pe:caption>
			<xsl:apply-templates/>
		</pe:caption>
	</xsl:template>
	
	<xsl:template match="table/title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
	</xsl:template>
	
	<xsl:template match="table/thead">
		<pe:thead>
			<xsl:apply-templates/>
		</pe:thead>
	</xsl:template>
	
	<xsl:template match="table/tbody">
		<pe:tbody>
			<xsl:apply-templates/>
		</pe:tbody>
	</xsl:template>
	
	<xsl:template match="table/thead/tr">
		<pe:tr>
			<xsl:apply-templates/>
		</pe:tr>
	</xsl:template>
	
	<xsl:template match="table/thead/tr/td">
		<pe:td>
			<xsl:apply-templates/>
		</pe:td>
	</xsl:template>
	
	<xsl:template match="table/tbody/tr">
		<pe:tr>
			<xsl:apply-templates/>
		</pe:tr>
	</xsl:template>
	
	<xsl:template match="table/tbody/tr/td">
		<pe:td>
			<!-- FIXME: Hack to get the if-then-tables working. -->
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:td>
	</xsl:template>
	
</xsl:stylesheet>
