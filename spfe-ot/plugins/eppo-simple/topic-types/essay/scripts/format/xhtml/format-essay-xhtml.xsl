<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:lf="local-functions"
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
	xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	exclude-result-prefixes="#all">

	
	<xsl:template match="byline">
		<p>
			<i><xsl:value-of select="by-label"/></i>
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	
	<xsl:template match="byline/authors">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="by-label"/>

	
	<xsl:template match="precis">
		<div class="precis">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="precis/title">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>

</xsl:stylesheet>
