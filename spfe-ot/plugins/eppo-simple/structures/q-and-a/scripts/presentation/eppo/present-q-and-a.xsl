<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>
	
	<xsl:template match="qa">
		<pe:labeled-item>
			<xsl:apply-templates/>
		</pe:labeled-item>
	</xsl:template>
	
	<xsl:template match="qa/q">
		<pe:label>
			<xsl:apply-templates/>
		</pe:label>
	</xsl:template>
	
	<xsl:template match="qa/a">
		<pe:item>
			<xsl:apply-templates/>
		</pe:item>
	</xsl:template>
	

</xsl:stylesheet>
