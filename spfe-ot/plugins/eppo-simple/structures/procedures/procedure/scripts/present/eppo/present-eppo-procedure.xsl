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
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>
	
	<xsl:template match="procedure">
		<pe:procedure id="{@id}">
			<xsl:if test="@id">
				<anchor name="procedure:{@id}"/>
			</xsl:if>
			<xsl:apply-templates/>
		</pe:procedure>
	</xsl:template>
	
	<xsl:template match="procedure/title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
	</xsl:template>
	
	<xsl:template match="procedure/intro">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="procedure/admonitions">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="procedure/inputs">
		<pe:subhead>Inputs</pe:subhead>
		<pe:ll>
			<xsl:apply-templates/>
		</pe:ll>
	</xsl:template>
	
	<xsl:template match="procedure/outputs">
		<pe:subhead>Outputs</pe:subhead>
		<pe:ll>
			<xsl:apply-templates/>
		</pe:ll>
	</xsl:template>
	
	<xsl:template match="procedure/inputs/input | procedure/outputs/output">
		<pe:li>
			<pe:label>
				<xsl:apply-templates select="name"/>
			</pe:label>
			<xsl:apply-templates select="p"/>
		</pe:li>
	</xsl:template>

	<xsl:template match="procedure/inputs/input/name | procedure/outputs/output/name">
		<xsl:apply-templates/>
	</xsl:template>

	
	<xsl:template match="procedure/steps">
		<xsl:apply-templates/>
	</xsl:template>	
	
	<xsl:template match="procedure/steps/step">
		<pe:step>
			<xsl:if test="@id">
				<xsl:copy-of select="@id"/>
				<pe:anchor name="step:{@id}"/>
			</xsl:if>
			<xsl:apply-templates/>
		</pe:step>
	</xsl:template>
	
	<xsl:template match="step/title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
	</xsl:template>	

</xsl:stylesheet>
