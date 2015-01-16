<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config" exclude-result-prefixes="#all">

	<xsl:template match="es:section">
		<xsl:if
			test="$config/config:build-command='draft' or sf:has-content(es:title/following-sibling::*) ">
			<pe:section>
				<pe:anchor name="{sf:title-to-anchor(es:title)}"/>
				<xsl:apply-templates/>
			</pe:section>
		</xsl:if>
	</xsl:template>

	<xsl:template match="es:section/es:title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
	</xsl:template>

</xsl:stylesheet>
