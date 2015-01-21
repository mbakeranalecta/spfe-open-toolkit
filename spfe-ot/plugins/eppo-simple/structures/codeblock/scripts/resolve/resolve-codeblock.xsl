<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	resolve-text-structures.xsl

	This stylesheet is designed to be included in other stylesheets to
	process common text structures used in all SPFE schemas.
	
  This stylesheet implements conditional elements using a global template match
  xsl:template match="*". Any templates added to this stylesheet to do special
  processing of text structures must also implement the conditional element 
  logic, since any specific template match will override the global match, 
  meaning that the conditional logic will not be applied to it.
	
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all" >


	<xsl:template match="code-block | terminal-session/*">
		<xsl:choose>
			<xsl:when test="contains(., '&#09;')">
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">Tab character found in <xsl:value-of
							select="parent::*/name()"/> element. Tabs cannot be formatted reliably.
						Replace tabs with spaces.</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy copy-namespaces="no">
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
