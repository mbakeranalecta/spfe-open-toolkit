<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>

	<xsl:template match="admonition">
		<xsl:element name="pe:{local-name()}" namespace="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo">
			<xsl:attribute name="class" select="lower-case(signal-word)"/>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="admonition/title">
		<xsl:element name="pe:{local-name()}" namespace="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo">
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="../signal-word"/>
			<xsl:text>: </xsl:text>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="admonition/signal-word"/>
	
</xsl:stylesheet>
