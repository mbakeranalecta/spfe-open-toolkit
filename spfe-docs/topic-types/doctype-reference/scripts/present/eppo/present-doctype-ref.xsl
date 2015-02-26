<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns="http://spfeopentoolkit.org/ns/spfe-docs"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple" exclude-result-prefixes="#all"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"	
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs">

<xsl:output indent="yes" method="xml"/>

	<!-- 
		=================
		Element templates
		=================
	-->


	<!-- doctype-reference-entry -->
	<xsl:template match="doctype-reference-entry">
		<xsl:variable name="name" select="name"/>
		<xsl:variable name="namespace" select="xml-namespace"/>
		<xsl:variable name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
		<xsl:variable name="this" select="."/>
		<xsl:variable name="one-possible-xpath" select="concat(parents/parent[1], '/', name)"/>
		<xsl:if test="$namespace = ''">
		</xsl:if>
		<pe:page type="API" name="{ancestor::ss:topic/@local-name}">
			<xsl:call-template name="show-header"/>
			<pe:title>Element: <xsl:value-of select="$name"/></pe:title>
			
			<xsl:if test="pe:ambiguities">
				<pe:labeled-item>
					<pe:label>See also</pe:label>
					<pe:item>
						<pe:ul>
							<xsl:for-each select="ambiguity">
							<pe:li>
								<pe:p>
									<xsl:apply-templates/>
								</pe:p>
							</pe:li>
						</xsl:for-each>
						</pe:ul>
					</pe:item>
				</pe:labeled-item>
			</xsl:if>
			<pe:labeled-item>
				<pe:label>XML Namespace</pe:label>
				<pe:item>
					<pe:p><xsl:value-of select="$namespace"/></pe:p>
				</pe:item>
			</pe:labeled-item>
			

			<pe:labeled-item>
				<pe:label>Description</pe:label>
				<pe:item>
					<xsl:if test="not(description)">
						<pe:p/>
					</xsl:if>
					<xsl:apply-templates select="description"/>
				</pe:item>
			</pe:labeled-item>

			<xsl:if test="parents/parent">
				<pe:labeled-item>
					<pe:label><xsl:value-of select="if (parents/parent[2]) then 'Parents' else 'Parent'"/></pe:label>
					<pe:item>
						<xsl:for-each select="parents/parent">
							<pe:p>
								<xsl:apply-templates/>
							</pe:p>
						</xsl:for-each>
					</pe:item>
				</pe:labeled-item>
			</xsl:if>
			
			<pe:labeled-item>
				<pe:label>Children</pe:label>
				<pe:item>
					<xsl:if test="not(children/*)">
						<pe:p>None</pe:p>
					</xsl:if>
					<xsl:for-each select="children/child">
						<xsl:sort select="."/>
						<xsl:variable name="child-name" select="./text()"/>
						<pe:p>
							<pe:name hint="element-name">
								<xsl:apply-templates/>
							</pe:name>
						</pe:p>
					</xsl:for-each>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Attributes</pe:label>
				<pe:item>
					<xsl:if test="not(attributes/attribute)">
						<pe:p>None</pe:p>
					</xsl:if>
					<xsl:for-each select="attributes/attribute">
						<xsl:sort select="name"/>
						<pe:p>
							<pe:name hint="attribute-name">
								<pe:link href="#{name}">
									<xsl:value-of select="name"/>
								</pe:link>
							</pe:name>
						</pe:p>
					</xsl:for-each>
				</pe:item>
			</pe:labeled-item>

			<!-- Add the attributes -->
			<xsl:for-each select="attributes/attribute">
				<xsl:sort select="name"/>
				<xsl:call-template name="format-attribute"/>
			</xsl:for-each>
			<xsl:call-template name="show-footer"/>
		</pe:page>
	</xsl:template>

	<xsl:template match="description">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- FIXME: Some redundant element names here -->
	<xsl:template match="required-by|verified-by|default|special|precis">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="doctype-reference-entry/type"/>
	<xsl:template match="doctype-reference-entry/name"/>
	<!-- 
		=========================
		Format Attribute template
		=========================
	-->
	<xsl:template name="format-attribute">
		<pe:anchor name="{name}"/>
		<pe:subhead>Attribute: <xsl:value-of select="name"/></pe:subhead>

		<!-- description -->
		<pe:labeled-item>
			<pe:label>Description</pe:label>
			<pe:item>
				<!-- no <p> because description contains <p>, but add p if no description -->
				<xsl:if test="not(description)">
					<pe:p/>
				</xsl:if>
				<xsl:apply-templates select="description"/>
			</pe:item>
		</pe:labeled-item>

		<!-- Use -->
		<pe:labeled-item>
			<pe:label>Use</pe:label>
			<pe:item>
				<pe:p>
					<xsl:choose>
						<xsl:when test="use = 'required'">Required</xsl:when>
						<xsl:otherwise>Optional</xsl:otherwise>
					</xsl:choose>
				</pe:p>
			</pe:item>
		</pe:labeled-item>

		<!-- XML data type -->
		<xsl:variable name="type" select="type"/>
		<pe:labeled-item>
			<pe:label>XML data type</pe:label>
			<pe:item>
				<pe:p>
					<xsl:value-of select="$type"/>
				</pe:p>
			</pe:item>
		</pe:labeled-item>

		<!-- not specified -->
		<pe:labeled-item>
			<pe:label>Behavior if not specified</pe:label>
			<pe:item>

				<xsl:choose>
					<xsl:when test="not(values/default)">
						<pe:p>N/A</pe:p>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="values/default"/>
					</xsl:otherwise>
				</xsl:choose>

			</pe:item>
		</pe:labeled-item>

		<!-- Special -->
		<pe:labeled-item>
			<pe:label>Values with special meanings</pe:label>
			<pe:item>
				<xsl:choose>
					<xsl:when test="values/value">
						<xsl:for-each select="values/value">
							<xsl:sort select="."/>
							<!-- FIXME: this is a hork that will not handle all text-group cases. Need to change to subheads for main headings to use labelled-item here. -->
							<pe:p>
								<pe:value hint="attribute-value">
									<xsl:value-of select="."/>
								</pe:value>
								<xsl:text>: </xsl:text>
								<xsl:apply-templates
									select="following-sibling::description[1]/p[1]/node()"/>
							</pe:p>
							<xsl:apply-templates
								select="following-sibling::description[1]/p[preceding-sibling::p]"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<pe:p>None</pe:p>
					</xsl:otherwise>
				</xsl:choose>
			</pe:item>
		</pe:labeled-item>
		<!-- restrictions -->
	</xsl:template>



</xsl:stylesheet>
