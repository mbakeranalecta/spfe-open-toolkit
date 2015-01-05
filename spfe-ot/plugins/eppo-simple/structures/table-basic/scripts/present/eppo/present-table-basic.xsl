<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>

	<xsl:template match="table">
		<pe:table>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:table>
	</xsl:template>
	
	<xsl:template match="table/caption">
		<pe:caption>
			<xsl:apply-templates/>
		</pe:caption>
	</xsl:template>
	
	<xsl:template match="table/title">
		<pe:title>
			<xsl:apply-templates/>
		</pe:title>
	</xsl:template>
	
	<xsl:template match="table/thead">
		<pe:thead>
			<xsl:apply-templates/>
		</pe:thead>
	</xsl:template>
	
	<xsl:template match="table/tbody">
		<pe:tbody>
			<xsl:apply-templates/>
		</pe:tbody>
	</xsl:template>
	
	<xsl:template match="table/thead/tr">
		<pe:tr>
			<xsl:apply-templates/>
		</pe:tr>
	</xsl:template>
	
	<xsl:template match="table/thead/tr/td">
		<pe:td>
			<xsl:apply-templates/>
		</pe:td>
	</xsl:template>
	
	<xsl:template match="table/tbody/tr">
		<pe:tr>
			<xsl:apply-templates/>
		</pe:tr>
	</xsl:template>
	
	<xsl:template match="table/tbody/tr/td">
		<pe:td>
			<!-- FIXME: Hack to get the if-then-tables working. -->
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:td>
	</xsl:template>
	
	<xsl:template match="p/table-id">
		<xsl:variable name="table-id" select="@id-ref"/>
		<xsl:if test="not(ancestor::ss:topic//table[@id=$table-id]/title)">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message" select="'No table/title element found for referenced table:', $table-id, '. A title is required for all referenced tables.'"/>
			</xsl:call-template>
		</xsl:if>
		<pe:structure-reference target="{@id-ref}" type="table"/>
		<xsl:variable name="target-table" select="ancestor::ss:topic//table[@id=$table-id]"/>
		<pe:reference type="table">
			<pe:link href="#table:{$table-id}">
				<!-- Insert a zero-width-non-breaking-space so indenter recognizes 
						this as a text node and does not indent it (which would add spurious
						white space to output -->
				<xsl:text>Table&#160;</xsl:text>
				<xsl:value-of
					select="count(ancestor::page//table/title intersect $target-table/preceding::table/title)+1"
				/>
			</pe:link>
		</pe:reference>
		
	</xsl:template>
	
</xsl:stylesheet>
