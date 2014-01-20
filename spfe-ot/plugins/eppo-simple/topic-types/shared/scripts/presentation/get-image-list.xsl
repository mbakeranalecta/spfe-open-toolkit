<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
exclude-result-prefixes="#all">

<xsl:param name="vector-if-available">no</xsl:param>

<xsl:output method="text"/>
	
<xsl:variable name="config" as="element(config:spfe)">
	<xsl:sequence select="/config:spfe"/>
</xsl:variable>

<xsl:param name="synthesis-files"/>
<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>

	
<xsl:template name="main">
	<xsl:apply-templates select="$synthesis"/>
</xsl:template>

<xsl:template match="*">
	<xsl:apply-templates select="//*:fig"/>
</xsl:template>

<xsl:template match="text()"/>

<xsl:template match="*:fig">
		<xsl:variable name="uri" select="string(@uri)"/>
		<xsl:variable name="fig-id" select="string(@id)"/>
	<xsl:value-of select="concat(sf:local-path-from-uri(@href), '&#xA;')"/>
</xsl:template>
	
</xsl:stylesheet>
