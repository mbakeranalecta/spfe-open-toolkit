<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->

<xsl:stylesheet version="2.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
exclude-result-prefixes="#all">
	
	<xsl:variable name="output-namespace">http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/topic-types/generic-topic</xsl:variable>
	
	<xsl:template match="*:generic-topic">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:variable name="topic-type" select="tokenize(normalize-space(@xsi:schemaLocation), '\s')[1]"/>
				
		<xsl:variable name="topic-type-alias">
			<xsl:choose>
				<xsl:when test="$topic-type-alias-list/config:topic-type[config:id=$topic-type]">
					<xsl:value-of select="$topic-type-alias-list/config:topic-type[config:id=$topic-type]/config:alias"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:error">
						<xsl:with-param name="message">
							<xsl:text>No topic type alias found for topic type </xsl:text>
							<xsl:value-of select="$topic-type"/>
							<xsl:text>.</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$topic-type"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="sf:conditions-met($conditions, $condition-tokens)">
				<ss:topic 
					type="{namespace-uri()}" 
					topic-type-alias="{$topic-type-alias}"
					full-name="{concat(namespace-uri(), '/', *:head/*:id)}"
					local-name="{*:head/*:id}"
					title="{*:body/*:title}">
					<xsl:if test="*:head/*:virtual-type">
						<xsl:attribute name="virtual-type" select="*:head/*:virtual-type"/>
					</xsl:if>
					<xsl:element name="{local-name()}" namespace="{$output-namespace}">
						<xsl:copy-of select="@*"/>
						<xsl:call-template name="apply-topic-attributes"/>
						<xsl:apply-templates>
							<xsl:with-param name="output-namespace" tunnel="yes" select="$output-namespace"/>
						</xsl:apply-templates>
					</xsl:element>
				</ss:topic>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:info">
					<xsl:with-param name="message">
						<xsl:text>Suppressing topic </xsl:text>
						<xsl:value-of select="name"/>
						<xsl:text> because its conditions (</xsl:text>
						<xsl:value-of select="$conditions"/>
						<xsl:text>) do not match the conditions specified for the build ( </xsl:text>
						<xsl:value-of select="$condition-tokens"/>
						<xsl:text>).</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>

