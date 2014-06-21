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
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	xmlns:es="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/topic-types/generic-topic"
	xmlns:test="http://spfeopentoolkit.org/spfe-ot/1.0/test-failed"
	exclude-result-prefixes="#all">

	<xsl:param name="condition-tokens"/>
	<xsl:param name="default-reference-scope"/>

	<xsl:template match="/">
		<xsl:if test="normalize-space($condition-tokens)">
			<xsl:call-template name="sf:info">
				<xsl:with-param name="message"
					select="'Applying condition tokens:', $condition-tokens"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*">
		<xsl:param name="output-namespace" tunnel="yes"/>
		<!-- FIXME: Need to decide if default-reference-scope is still valid and if so whether this is the right way to do it. -->
		<xsl:choose>
			<xsl:when test="$output-namespace=''"> 
				<xsl:copy>
					<xsl:copy-of select="@*" copy-namespaces="no"/>
					<xsl:if test="(parent::*:p and not(@scope)) or name()='code-block'">
						<xsl:choose>
							<xsl:when test="ancestor::ss:topic/@default-reference-scope">
								<xsl:attribute name="scope"
									select="ancestor::ss:topic/@default-reference-scope"/>
							</xsl:when>
							<xsl:when test="$default-reference-scope">
								<xsl:attribute name="scope" select="$default-reference-scope"/>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					
					<xsl:apply-templates mode="#current"/>
					
				</xsl:copy>
			</xsl:when>

			<xsl:otherwise>
				<xsl:element name="{local-name()}" namespace="{$output-namespace}">
					<xsl:copy-of select="@*" copy-namespaces="no"/>
					<xsl:if test="(parent::*:p and not(@scope)) or name()='code-block'">
						<xsl:choose>
							<xsl:when test="ancestor::ss:topic/@default-reference-scope">
								<xsl:attribute name="scope"
									select="ancestor::ss:topic/@default-reference-scope"/>
							</xsl:when>
							<xsl:when test="$default-reference-scope">
								<xsl:attribute name="scope" select="$default-reference-scope"/>
							</xsl:when>
						</xsl:choose>
					</xsl:if>

					<xsl:apply-templates mode="#current"/>

				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Apply if conditions -->
	<xsl:template match="*[@if]" priority="1">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:choose>
			<xsl:when test="sf:conditions-met($conditions, $condition-tokens)">
				<xsl:next-match/>
			</xsl:when>
			<xsl:otherwise>
				<!-- suppress the element -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*:code-block | *:terminal-session/*">
		<xsl:choose>
			<xsl:when test="contains(., '&#09;')">
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">Tab character found in <xsl:value-of
							select="parent::*/name()"/> element. Tabs cannot be formatted reliably.
						Replace tabs with spaces.</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy copy-namespaces="no">
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates>
						<xsl:with-param name="output-namespace" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<xsl:template match="*:fragment">
		<xsl:param name="in-scope-strings" as="element()*" tunnel="yes" />
		<xsl:variable name="conditions" select="@if"/>
		<xsl:if test="sf:conditions-met($conditions, $condition-tokens)">
			<xsl:apply-templates>
				<xsl:with-param name="in-scope-strings" select="*:local-strings/*:string, $in-scope-strings" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>


	<xsl:template match="*:fragment-ref">
		<xsl:param name="in-scope-strings" as="element()*" tunnel="yes" />
		<xsl:variable name="conditions" select="@if"/>
		<xsl:if test="sf:conditions-met($conditions, $condition-tokens)">
			<xsl:variable name="fragment-id" select="@id-ref"/>
			<xsl:variable name="matching-fragment" select="$fragments[@id=$fragment-id]"/>
			<xsl:variable name="fragment-count" select="count($matching-fragment)"/>
			
			<xsl:choose>
				<xsl:when test="$fragment-count = 1">
					<xsl:apply-templates select="$matching-fragment/*">
						<xsl:with-param name="in-scope-strings" select="*:local-strings/*:string, $matching-fragment/*:local-strings/*:string, $in-scope-strings" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$fragment-count gt 1">
					<xsl:call-template name="sf:error">
						<xsl:with-param name="message">
							<xsl:text>More than one fragment matching the fragment-id </xsl:text>
							<xsl:value-of select="$fragment-id"/>
							<xsl:text> was found. Check that fragment ids are unique and that conditions applied to the build do not result in multiple fragments with the same name being available.</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:error">
						<xsl:with-param name="message">
							<xsl:text>No fragment was found matching the fragment id </xsl:text>
							<xsl:value-of select="$fragment-id"/>
							<xsl:text>.</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>



</xsl:stylesheet>
