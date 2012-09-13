<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	text-structures.xsl

	This stylesheet is designed to be included in other stylesheets to
	process common text structures used in all SPFE schemas.
	
  This stylesheet implements conditional elements using a global template match
  xsl:template match="*". Any templates added to this stylesheet to do special
  processing of text structures must also implement the conditional element 
  logic, since any specific template match will override the global match, 
  meaning that the conditional logic will not be applied to it.
	
=======================================================-->
<xsl:stylesheet version="2.0"  
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema" 
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all"
>
	<xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
	
<xsl:param name="condition-tokens"/>
<xsl:param name="default-reference-scope"/>

	<xsl:param name="fragment-files"/>
	<xsl:variable name="unresolved-fragments" select="sf:get-sources($fragment-files)"/>
	<xsl:variable name="fragments">
		<xsl:apply-templates mode="process-fragments" select="$unresolved-fragments"/>
	</xsl:variable>


	<xsl:template match="/">
		<xsl:if test="normalize-space($condition-tokens)">
			<xsl:call-template name="sf:info">
				<xsl:with-param name="message" select="'Applying condition tokens:', $condition-tokens"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>
	


	<!-- conditional elements -->
	<xsl:template match="*" mode="process-fragments">
		<xsl:call-template name="apply-conditions"/>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:call-template name="apply-conditions"/>
	</xsl:template>

	<xsl:template name="apply-conditions">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:choose>
			<xsl:when test="sf:conditions-met($conditions, $condition-tokens)">
				<xsl:element name="{local-name()}" namespace="{$output-namespace}">
					<xsl:copy-of select="@*" copy-namespaces="no"/>
					
					<xsl:if test="(parent::*:p and not(@scope)) or name()='code-block'">
						<xsl:choose>
							<xsl:when test="ancestor::ss:topic/@default-reference-scope">
								<xsl:attribute name="scope" select="ancestor::ss:topic/@default-reference-scope"/>
							</xsl:when>
							<xsl:when test="$default-reference-scope">
								<xsl:attribute name="scope" select="$default-reference-scope"/>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					
					<xsl:apply-templates mode="#current"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<!-- suppress the element -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- changed code-block to code-block/text() to ensure conditions are applied to code-block -->
	<xsl:template match="code-block/text() | terminal-session/*">
		<xsl:choose>
			<xsl:when test="contains(., '&#09;')">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">Tab character found in <xsl:value-of select="parent::*/name()"/> element. Tabs cannot be formatted reliably. Replace tabs with spaces.</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy copy-namespaces="no">
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	

	
	<xsl:template match="fragment-internal">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:if test="sf:conditions-met($conditions, $condition-tokens)">
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>

	
	<xsl:template match="fragment-id">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:if test="sf:conditions-met($conditions, $condition-tokens)">
			<xsl:variable name="id" select="@id-ref"/>
			<xsl:variable name="matching-fragment">
				<xsl:apply-templates select="$fragments//fragment[@id=$id]"/>
			</xsl:variable>
			<xsl:variable name="fragment-count" select="count($matching-fragment/fragment)"/>
			<xsl:choose>
				<xsl:when test="$fragment-count = 1">
					<xsl:sequence select="$matching-fragment/fragment/*"/>
				</xsl:when>
				<xsl:when test="$fragment-count gt 1">
					<xsl:call-template name="sf:error">
						<xsl:with-param name="message">
							<xsl:text>More than one fragment matching the fragment id </xsl:text>
							<xsl:value-of select="$id"/>
							<xsl:text> was found. Check that fragment ids are unique and that conditions applied to the build do not result in multiple fragments with the same name being available.</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:error">
						<xsl:with-param name="message">
							<xsl:text>No fragment was found matching the fragment id </xsl:text>
							<xsl:value-of select="$id"/>
							<xsl:text>.</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
										 
	
</xsl:stylesheet>

