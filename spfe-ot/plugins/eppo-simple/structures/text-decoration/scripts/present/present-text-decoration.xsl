<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"	
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">
	
	<xsl:template match="p/bold | string/bold">
		<pe:decoration class='bold'>
			<xsl:apply-templates/>
		</pe:decoration>
	</xsl:template>
	
	<xsl:template match="p/italic | string/italic">
		<pe:decoration class="italic">
			<xsl:apply-templates/>
		</pe:decoration>
	</xsl:template>
	
	<xsl:template match="p/code | string/code">
		<pe:decoration class="code">
			<xsl:apply-templates/>
		</pe:decoration>
	</xsl:template>
	
	<xsl:template match="p/quotes | string/quotes">
		<xsl:text>“</xsl:text>
			<xsl:apply-templates/>
		<xsl:text>”</xsl:text>
	</xsl:template>

</xsl:stylesheet>
