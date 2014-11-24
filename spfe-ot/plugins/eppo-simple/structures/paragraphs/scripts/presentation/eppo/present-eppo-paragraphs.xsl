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
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple">
	
	<xsl:template match="p">
		<pe:p>
			<!-- FIXME: will this copy attributes with old namespaces? Make it all explicit.-->
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:p>
		<xsl:for-each select="text-object-ref">
			<xsl:variable name="id" select="@id-ref"/>
			<xsl:variable name="content" select="normalize-space(.)"/>
			<xsl:choose>
				<xsl:when test="//text-object[id=$id]">
					<pe:fold id="{generate-id()}" type="text-object" initial-state="closed" reference-text="{$content}">
						<xsl:apply-templates select="//text-object[id=$id]"/>
					</pe:fold>		
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:warning">
						<xsl:with-param name="message">Text object <xsl:value-of select="$id"/> not found.</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
