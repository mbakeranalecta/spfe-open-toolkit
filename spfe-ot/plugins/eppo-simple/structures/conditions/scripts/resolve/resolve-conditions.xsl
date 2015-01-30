<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	resolve-conditions.xsl

	This stylesheet is designed to be included in other stylesheets to
	process common text structures used in all SPFE schemas.
	
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all" >


	<!-- Apply if conditions -->
	<xsl:template match="es:*[@if]" priority="1">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:choose>
			<xsl:when test="sf:conditions-met($conditions, $config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:condition-tokens)">
				<xsl:next-match/>
			</xsl:when>
			<xsl:otherwise>
				<!-- suppress the element -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
