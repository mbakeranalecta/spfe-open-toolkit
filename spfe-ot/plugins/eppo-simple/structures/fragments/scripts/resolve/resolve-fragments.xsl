<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<!-- ===================================================
	resolve-fragments.xsl
	
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all" >
	
	<xsl:template match="fragment">
		<xsl:param name="in-scope-strings" as="element()*" tunnel="yes" />
		<xsl:apply-templates>
			<xsl:with-param name="in-scope-strings" select="local-strings/string, $in-scope-strings" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>


	<xsl:template match="fragment-ref">
		<xsl:param name="in-scope-fragments" as="element()*" tunnel="yes"/>
		<xsl:param name="in-scope-strings" as="element()*" tunnel="yes" />
		<xsl:variable name="fragment-id" select="@id-ref"/>
		<xsl:variable name="local-fragments" select="/*//fragment, $in-scope-fragments"/>
		<xsl:variable name="matching-fragment" select="$local-fragments[@id=$fragment-id]"/>
		<xsl:variable name="fragment-count" select="count($matching-fragment)"/>	
		<xsl:choose>
			<xsl:when test="$fragment-count = 1">
				<xsl:apply-templates select="$matching-fragment/*">
					<xsl:with-param name="in-scope-strings" select="local-strings/string, $matching-fragment/*:local-strings/*:string, $in-scope-strings" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$fragment-count gt 1">
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">
						<xsl:text>More than one fragment matching the fragment-id </xsl:text>
						<xsl:value-of select="$fragment-id"/>
						<xsl:text> was found. Check that fragment ids are unique and that conditions applied to the build do not result in multiple fragments with the same name being available.</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">
						<xsl:text>No fragment was found matching the fragment id </xsl:text>
						<xsl:value-of select="$fragment-id"/>
						<xsl:text>.</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="local-strings">
		<xsl:apply-templates/>
	</xsl:template>


</xsl:stylesheet>
