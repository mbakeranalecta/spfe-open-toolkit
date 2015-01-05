<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:lc="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/link-catalog"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"	
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config" 
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">
	
	<xsl:template match="p/subject">
		<xsl:variable name="content" select="normalize-space(.)"/>
			<xsl:choose>
				<xsl:when test="esf:target-exists(@key, @type)">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="@key"/>
						<xsl:with-param name="type" select="@type"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:subject-not-resolved">
						<xsl:with-param name="message" select="concat(@type, ' name &quot;', @key, '&quot;')"/>
						<xsl:with-param name="in" select="ancestor::ss:topic/@full-name"/> 
					</xsl:call-template>
					<xsl:value-of select="$content"/>								
				</xsl:otherwise>
			</xsl:choose>		
	</xsl:template>
	
	

	<xsl:template match="p/name ">
		<!-- FIXME: handle namespace of the name? -->
		<xsl:if test="not(@key)">
			<xsl:call-template name="sf:warning">
				<xsl:with-param name="message" 
					select="'&quot;name&quot; subject element found with no &quot;key&quot; attribute:', . "/>		
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="content" select="normalize-space(.)"/>
		<pe:name type="{@type}">
			<xsl:choose>
				<xsl:when test="esf:target-exists(@key, @type)">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="@key"/>
						<xsl:with-param name="type" select="@type"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:subject-not-resolved">
						<xsl:with-param name="message" select="concat(@type, ' name &quot;', (if (@key) then @key else .), '&quot;')"/> 
						<xsl:with-param name="in" select="ancestor::ss:topic/@full-name"/> 
					</xsl:call-template>
					<xsl:value-of select="$content"/>								
				</xsl:otherwise>
			</xsl:choose>
		</pe:name>	
	</xsl:template>
	
	
	<xsl:template match="p/decoration">
		<xsl:copy-of select="."/>
	</xsl:template>

</xsl:stylesheet>
