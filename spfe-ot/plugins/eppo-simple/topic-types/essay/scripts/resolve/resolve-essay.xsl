<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->

<xsl:stylesheet version="2.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
exclude-result-prefixes="#all">
	

	
	<xsl:template match="essay">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:variable name="name" select="head/id"/>
		<xsl:variable name="type" select="sf:name-in-clark-notation(.)"/>
		
		<ss:topic 
			type="{$type}" 
			full-name="{$type}#{$name}"
			local-name="{$name}"
			topic-type-alias="{sf:get-topic-type-alias-singular($topic-set-id, $type, $config)}"
			title="{body/title}"
			excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::p[1], 30, ' ...'))}">

			<xsl:copy>
				<xsl:copy-of select="@*" copy-namespaces="no"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</ss:topic>

	</xsl:template>
	
	<xsl:template match="byline/author-name">
		<name>
			<xsl:attribute name="type">author</xsl:attribute>
			<xsl:attribute name="key" select="normalize-space(.)"/>
			<xsl:if test="@namespace">
				<xsl:attribute name="namespace" select="@namespace"/> 
			</xsl:if>
			<xsl:apply-templates/>
		</name>
	</xsl:template>
	

</xsl:stylesheet>

