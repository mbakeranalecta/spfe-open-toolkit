<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:include href="utility-functions.xsl"/>
	<xsl:output method="xml" indent="yes" />
	<xsl:param name="output-dir"/>

<xsl:template match="schema-definitions">
	<xsl:for-each select="schema-element[@doc-element='true']">
		<xsl:variable name="file-name" select="concat(name, '-doctype-elements.xml')"/>
		<xsl:call-template name="info">
			<xsl:with-param name="message" select="'Creating template:', $file-name, 'in', $output-dir"/>
		</xsl:call-template>
		<xsl:result-document href="file:///{$output-dir}/{$file-name}" method="xml" indent="yes" omit-xml-declaration="no">
		<element-descriptions 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:noNamespaceSchemaLocation="http://internal.windriver.com/engineering/engops/techpubs/schemas/Hypervisor/elementdescriptions.xsd" type="IBLL-element-descriptions">
			<tracking>
				<status>Not started</status>
				<history>
					<revision>
						<xsl:text>1a,</xsl:text>
						<xsl:value-of select="format-date(current-date(),'[D01][MN,3-3][Y01]')"/>,
						<xsl:text>you Generated update from schema definitions</xsl:text>
					</revision>
				</history>
			</tracking>
			<schema-namespace><xsl:value-of select="@namespace"/></schema-namespace>
			<xsl:variable name="xpath-root" select="xpath"/>
			<xsl:apply-templates select="/schema-definitions/schema-element[starts-with(xpath,$xpath-root)]"/>
			<xsl:apply-templates select="/schema-definitions/schema-element[starts-with(xpath, 'group_')]"/>
		</element-descriptions>
	</xsl:result-document>
	</xsl:for-each>
</xsl:template>
	
	<xsl:template match="schema-element"> 
		<xsl:variable name="xpath" select="xpath"/>
		<element>
			<name><xsl:value-of select="$xpath"/></name>
			<description>
				<p>Enter description here.</p>
			</description>
			<restrictions>
				<restriction>
					<p>Enter description of the first restriction.</p>
				</restriction>
			</restrictions>
			<xsl:if test="/schema-definitions/schema-attribute[starts-with(xpath, concat($xpath, '/@'))]">
				<attributes>
					<xsl:apply-templates select="/schema-definitions/schema-attribute[starts-with(xpath, concat($xpath, '/@'))]" mode="attributes"/>
				</attributes>
			</xsl:if>
		</element>
	</xsl:template>
	
	<xsl:template match="schema-attribute"/>
	<xsl:template match="schema-attribute" mode="attributes">
		<attribute>
			<name><xsl:value-of select="name"/></name>
			<description>
				<p>Enter description of the attribute</p>
			</description>
			<values>
				<unspecified>
					<p>Describe the behavior if the value is not specified. (Omit if the attribute is required.)</p>
				</unspecified>
				<value>0</value>
				<description>
					<p>Describe the behavior if this value is specified.</p>
				</description>
				<value>1</value>
				<description>
					<p>Describe the behavior if this value is specified.</p>
				</description>
			</values>
			<restrictions>
				<restriction>
					<p>Enter the description of the first restriction here.</p>
				</restriction>
			</restrictions>
		</attribute>
	</xsl:template>
	
	<xsl:template match="schema-type"/>
	
</xsl:stylesheet>
