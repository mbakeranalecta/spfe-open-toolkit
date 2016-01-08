<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"	
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">
	
	<xsl:template match="link-external">
	<!-- FIXME: support other protocols -->
		<pe:link href="sf:fixup-url(@href)">
			<xsl:apply-templates/>
		</pe:link>	
	</xsl:template>

	<xsl:template match="url">
	<!-- FIXME: support other protocols -->
		<pe:link href="{sf:fixup-url(.)}">
		 <xsl:apply-templates/>
		</pe:link>	
	</xsl:template>
	
</xsl:stylesheet>
