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
	xmlns:lc="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/catalog"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"	
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config" 
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">
	
	<xsl:template match="topic-id">
		<xsl:variable name="topic" select="@id-ref"/>
		
		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($topic, 'topic')">
						<pe:decoration class='italic'>
							<xsl:call-template name="output-link">
								<xsl:with-param name="target" select="$topic"/>
								<xsl:with-param name="type">topic</xsl:with-param>
								<xsl:with-param name="content" as="xs:string">
									<xsl:value-of select="$catalogs//lc:target[@type='topic'][lc:key=$topic]/parent::lc:page/@title"/>
								</xsl:with-param>
								<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
							</xsl:call-template>
						</pe:decoration>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'Topic not found: ', $topic"/> 
				</xsl:call-template>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
</xsl:stylesheet>
