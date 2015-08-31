<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">
	
	<xsl:template match="object-ref">
		<xsl:variable name="id-ref" select="@id-ref"/>
		<xsl:choose>
			<xsl:when test="$objects/ss:synthesis/ss:object[@local-name eq $id-ref]">
				<xsl:apply-templates select="$objects/ss:synthesis/ss:object[@local-name eq $id-ref]/*"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'No object found for object reference: ', $id-ref"/>
					<xsl:with-param name="in" select="base-uri(document(''))"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
