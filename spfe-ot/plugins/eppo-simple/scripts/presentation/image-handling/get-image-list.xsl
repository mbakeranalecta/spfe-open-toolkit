<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
exclude-result-prefixes="#all">
	
<xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
<xsl:param name="graphics-catalog-file"/>
<xsl:variable name="graphics-catalog" select="document($graphics-catalog-file)/graphics-catalog"/>

<xsl:param name="vector-if-available">no</xsl:param>

<xsl:output method="text"/>
	
	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	
	<xsl:param name="synthesis-files"/>
	<xsl:variable name="synthesis-dir" select="concat($config/config:build/config:build-directory, '/temp/synthesis/')"/>
	
	<xsl:variable name="synthesis">
		<xsl:for-each select="tokenize($synthesis-files, $config/config:dir-separator)">
			<xsl:sequence select="doc(concat($synthesis-dir, .))"/>	
		</xsl:for-each>
	</xsl:variable>
	
<xsl:template name="main">
	<xsl:apply-templates select="$synthesis"/>
</xsl:template>

<xsl:template match="*">
	<xsl:apply-templates select="//fig"/>
</xsl:template>

<xsl:template match="text()"/>

<xsl:template match="fig">
		<xsl:variable name="uri" select="string(@uri)"/>
		<xsl:variable name="fig-id" select="string(@id)"/>
		
		<xsl:message select="."/>
		<xsl:message select="@uri, '|', $fig-id"/>
		
		<xsl:variable name="this-graphic">
			<xsl:choose>
				<xsl:when test="$graphics-catalog/graphic[uri eq $uri]">
					<xsl:sequence select="$graphics-catalog/graphic[uri eq $uri]/*"/>
				</xsl:when>
				<xsl:when test="$graphics-catalog/graphic[id eq $fig-id]">
					<xsl:sequence select="$graphics-catalog/graphic[id eq $fig-id]/*"/>
				</xsl:when>
					<xsl:otherwise>
						<xsl:message select="'Could not find ', if ($uri) then concat('uri', $uri) else concat('id', $fig-id), ' in catalog'"/>
					</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="graphic-file">
				<xsl:choose>
					<xsl:when test="$vector-if-available eq 'yes'">
						<xsl:choose>
							<xsl:when test="$this-graphic/vector">
								<xsl:value-of select="concat($this-graphic/vector, '&#xA;')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($this-graphic/raster, '&#xA;')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($this-graphic/raster, '&#xA;')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="$graphic-file"/>
<!-- 			<xsl:if test="not(file:exists(file:new($graphic-file)))"  xmlns:file="java.io.File">
				<xsl:call-template name="warning">
					<xsl:with-param name="message" select="'File not found: ', $graphic-file">
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
 -->	</xsl:template>
</xsl:stylesheet>
