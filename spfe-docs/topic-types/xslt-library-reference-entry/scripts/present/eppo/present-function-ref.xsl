<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2013 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs"
	exclude-result-prefixes="#all">

	<!-- processing directives -->
	<xsl:output method="xml" indent="yes" cdata-section-elements="codeblock"/>


	<!-- spfe-function-reference-entry -->
	<xsl:template match="xslt-library-reference-entry">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- XSL function -->
	<xsl:template match="xsl-function">
		<xsl:variable name="display-name" select="name/text()"/>

		<!-- FIXME: the page should be created from the ss:topic element by shared code to keep in sync with tocs -->
		<pe:page type="API" name="{name}">


			<xsl:call-template name="show-header"/>
			<pe:title>Function: <xsl:value-of select="$display-name"/></pe:title>

			<pe:p>
				<pe:decoration class="bold">
					<xsl:value-of select="$display-name"/>
					<xsl:text>(</xsl:text>
					<xsl:for-each select="parameters/parameter">
						<xsl:value-of select="name"/>
						<xsl:text> as </xsl:text>
						<xsl:value-of select="type"/>
						<xsl:if test="position() ne last()">, </xsl:if>
					</xsl:for-each>
					<xsl:text>) as </xsl:text>
					<xsl:value-of select="return-value/type"/>
				</pe:decoration>
			</pe:p>
			<pe:labeled-item>
				<pe:label>Description</pe:label>
				<pe:item>
					<xsl:if test="not(description)">
						<pe:p/>
					</xsl:if>
					<xsl:apply-templates select="description"/>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Return value</pe:label>
				<pe:item>
					<pe:p>Return type: <xsl:value-of select="return-value/type"/></pe:p>
					<xsl:apply-templates select="return-value/description"/>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Source file</pe:label>
				<pe:item>
					<pe:p>
						<xsl:value-of select="source-file"/>
					</pe:p>
				</pe:item>
			</pe:labeled-item>

			<pe:subhead>Parameters</pe:subhead>
			<xsl:for-each select="parameters/parameter">
				<pe:labeled-item>
					<pe:label>
						<xsl:value-of select="name"/>
					</pe:label>
					<pe:item>
						<pe:p>Type: <xsl:value-of select="type"/></pe:p>
						<xsl:apply-templates select="description"/>
					</pe:item>
				</pe:labeled-item>
			</xsl:for-each>

			<pe:subhead>Definition</pe:subhead>
			<xsl:for-each select="definition">
				<pe:codeblock language="XSLT">
    			<!-- select="*" here so as not to pick up the whitespace in the definition element -->
    			<xsl:apply-templates select="*"/>
    		</pe:codeblock>
			</xsl:for-each>
			<xsl:call-template name="show-footer"/>
		</pe:page>
	</xsl:template>

	<xsl:template match="description">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- XSL template -->
	<xsl:template match="xsl-template">
		<xsl:variable name="display-name" select="name/text()"/>

		<!-- FIXME: the page should be created from the ss:topic element by shared code to keep in sync with tocs -->
		<!-- FIXME: Is the page type attribute used for anything? Should it be? -->
		<pe:page type="API" name="{name}">
			<xsl:call-template name="show-header"/>
			<pe:title>Template: <xsl:value-of select="$display-name"/></pe:title>

			<pe:labeled-item>
				<pe:label>Description</pe:label>
					<pe:item>
					<xsl:if test="not(description)">
						<pe:p/>
					</xsl:if>
					<xsl:apply-templates select="description"/>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Source file</pe:label>
				<pe:item>
					<pe:p>
						<xsl:value-of select="source-file"/>
					</pe:p>
				</pe:item>
			</pe:labeled-item>

			<pe:subhead>Parameters</pe:subhead>
			<xsl:for-each select="parameters/parameter">
				<pe:labeled-item>
					<pe:label>
						<xsl:value-of select="name"/>
					</pe:label>
					<pe:item>
						<pe:p>Type: <xsl:value-of select="type"/></pe:p>
						<xsl:apply-templates select="description"/>
					</pe:item>
				</pe:labeled-item>
			</xsl:for-each>

			<pe:subhead>Definition</pe:subhead>
			<xsl:for-each select="definition">
				<pe:codeblock language="XSLT">
    			<!-- select="*" here so as not to pick up the whitespace in the definition element -->
    			<xsl:apply-templates select="*"/>
    		</pe:codeblock>
			</xsl:for-each>
			<xsl:call-template name="show-footer"/>
		</pe:page>
	</xsl:template>
	
	<xsl:template match="xsl:*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xsl:*/text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

</xsl:stylesheet>
