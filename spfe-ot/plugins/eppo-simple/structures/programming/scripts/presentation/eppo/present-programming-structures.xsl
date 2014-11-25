<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>

	<xsl:template match="codeblock">
		<pe:codeblock>
		<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:codeblock>
	</xsl:template>

	<xsl:template match="code-sample">
		<pe:code-sample id="{@id}">
			<xsl:if test="@id">
				<anchor name="code-sample:{@id}"/>
			</xsl:if>
			<xsl:apply-templates select="title"/>
			<xsl:if test="file-ref">
				<pe:p>
					<xsl:text>Source file: </xsl:text>
					<xsl:apply-templates select="file-ref"/>
				</pe:p>
			</xsl:if>
			<xsl:apply-templates select="codeblock"/>
		</pe:code-sample>
	</xsl:template>

	<xsl:template match="code-sample/title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
	</xsl:template>

	<xsl:template match="codeblock[@language='C']">
		<xsl:variable name="scope" select="@scope"/>
		<pe:codeblock>
			<xsl:analyze-string select="." regex="([a-zA-z0-9]+)(\s*\()">
				<xsl:matching-substring>
					<xsl:choose>
						<!-- FIXME: can we avoid enbedding "routine" here? -->
						<xsl:when test="esf:target-exists(regex-group(1), 'routine')">
							<xsl:variable name="routine">
								<function-name scope="{$scope}"><xsl:value-of select="regex-group(1)"/></function-name>
							</xsl:variable>
							<xsl:apply-templates select="$routine"/>
							<xsl:value-of select="regex-group(2)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:value-of select="."/>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</pe:codeblock>
	</xsl:template>

</xsl:stylesheet>
