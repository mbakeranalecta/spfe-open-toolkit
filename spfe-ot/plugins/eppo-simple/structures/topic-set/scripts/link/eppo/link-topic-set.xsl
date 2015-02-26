<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 	
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
 	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
 	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
 	exclude-result-prefixes="#all">
	
<!-- processing directives -->
<xsl:output method="xml" indent="yes"/>

<!-- parameters -->
	
	<!-- FIXME: This should be in config. -->
	<xsl:param name="output-directory"/>
	<xsl:variable name="draft" select="if (lower-case(config:config/config:build-command) eq 'draft') then 'yes' else 'no'"/>
	
<xsl:param name="topic-set-id"/>

<xsl:variable name="config" as="element(config:config)">
	<xsl:sequence select="/config:config"/>
</xsl:variable>

<xsl:param name="synthesis-files"/>
<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>

<xsl:variable name="topic-set-title" select="sf:string($config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:strings, 'eppo-simple-topic-set-title')"/>
<!--  
=============
Main template
=============
-->
<xsl:template name="main">
	<xsl:result-document href="file:///{$output-directory}/linked.xml" method="xml" indent="yes" omit-xml-declaration="no" >
			<xsl:apply-templates select="$synthesis"/>
	</xsl:result-document>
</xsl:template>
	
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
