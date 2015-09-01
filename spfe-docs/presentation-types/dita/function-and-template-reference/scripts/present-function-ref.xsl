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
		<xsl:result-document href="file:///{$output-directory}/{$topic-set-id}/{ancestor::ss:topic/@local-name}.dita" 
			method="xml" 
			indent="yes" 
			omit-xml-declaration="no" 
			doctype-public="-//OASIS//DTD DITA Topic//EN" 
			doctype-system="topic.dtd">
		<!-- FIXME: the page should be created from the ss:topic element by shared code to keep in sync with tocs -->
		<topic id="{name}">
			<title>Function: <xsl:value-of select="$display-name"/></title>
<body>
			<p>
				<b>
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
				</b>
			</p>
	<dl>
			<dlentry>
				<dt>Description</dt>
				<dd>
					<xsl:if test="not(description)">
						<p/>
					</xsl:if>
					<xsl:apply-templates select="description"/>
				</dd>
			</dlentry>

			<dlentry>
				<dt>Return value</dt>
				<dd>
					<p>Return type: <xsl:value-of select="return-value/type"/></p>
					<xsl:apply-templates select="return-value/description"/>
				</dd>
			</dlentry>

			<dlentry>
				<dt>Source file</dt>
				<dd>
					<p>
						<xsl:value-of select="source-file"/>
					</p>
				</dd>
			</dlentry>
</dl>
			<section><title>Parameters</title>
			<xsl:for-each select="parameters/parameter">
				<dl>
				<dlentry>
					<dt>
						<xsl:value-of select="name"/>
					</dt>
					<dd>
						<p>Type: <xsl:value-of select="type"/></p>
						<xsl:apply-templates select="description"/>
					</dd>
				</dlentry></dl>
			</xsl:for-each>
</section>
			<section><title>Definition</title>
			<xsl:for-each select="definition">
				<codeblock> <!-- FIXME: No obvious way to specify the language in DITA, so omitting that. -->
    			<!-- select="*" here so as not to pick up the whitespace in the definition element -->
    			<xsl:apply-templates select="*"/>
    		</codeblock>
			</xsl:for-each>
	</section>
</body>
		</topic>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="description">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- XSL template -->
	<xsl:template match="xsl-template">
		<xsl:variable name="display-name" select="name/text()"/>

		<!-- FIXME: the page should be created from the ss:topic element by shared code to keep in sync with tocs -->
		<!-- FIXME: Is the page type attribute used for anything? Should it be? -->
		<xsl:result-document href="file:///{$output-directory}/{$topic-set-id}/{ancestor::ss:topic/@local-name}.dita" 
			method="xml" 
			indent="yes" 
			omit-xml-declaration="no" 
			doctype-public="-//OASIS//DTD DITA Topic//EN" 
			doctype-system="topic.dtd">
			<topic id="{name}">
			<title>Template: <xsl:value-of select="$display-name"/></title>
	<body>
		<dl>
			<dlentry>
				<dt>Description</dt>
					<dd>
					<xsl:if test="not(description)">
						<p/>
					</xsl:if>
					<xsl:apply-templates select="description"/>
				</dd>
			</dlentry>

			<dlentry>
				<dt>Source file</dt>
				<dd>
					<p>
						<xsl:value-of select="source-file"/>
					</p>
				</dd>
			</dlentry>
		</dl>
			<section><title>Parameters</title><dl>
			<xsl:for-each select="parameters/parameter">
				
				<dlentry>
					<dt>
						<xsl:value-of select="name"/>
					</dt>
					<dd>
						<p>Type: <xsl:value-of select="type"/></p>
						<xsl:apply-templates select="description"/>
					</dd>
				</dlentry>
			</xsl:for-each>
			</dl></section>

			<section><title>Definition</title>
			<xsl:for-each select="definition">
				<codeblock> <!-- FIXME: No obvious way to specify the language in DITA, so omitting that. -->
    			<!-- select="*" here so as not to pick up the whitespace in the definition element -->
    			<xsl:apply-templates select="*"/>
    		</codeblock>
			</xsl:for-each>
		</section>
	</body>
			</topic>
		</xsl:result-document>
	</xsl:template>

	<!-- Add links to code samples -->
	<xsl:template match="xsl:*">
		<xsl:variable name="function-prefix" select="string(ancestor::ss:topic//local-prefix)"/>
		<xsl:variable name="current-page-name" select="ancestor::ss:topic/@full-name"/>
		<xsl:variable name="indent">
			<xsl:for-each select="ancestor::xsl:*">
				<xsl:text>&#xa0;&#xa0;</xsl:text>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$indent"/>
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text> </xsl:text>
		<xsl:for-each select="@*">
			<xsl:value-of select="name()"/>
			<xsl:text>="</xsl:text>

			<xsl:analyze-string select="string(.)" regex="{$function-prefix}:[a-zA-Z0-9._-]+">
				<xsl:matching-substring>
					<xsl:call-template name="output-link">
						<xsl:with-param name="target"
							select="substring-after(regex-group(0), concat($function-prefix,':'))"/>
						<xsl:with-param name="type">spfe-xslt-function</xsl:with-param>
						<xsl:with-param name="content" select="regex-group(0)"/>
						<xsl:with-param name="current-page-name" select="$current-page-name"/>
					</xsl:call-template>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:value-of select="."/>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
			<xsl:text>"</xsl:text>
			<xsl:if test="position() ne last()">&#xa0;</xsl:if>
		</xsl:for-each>

		<xsl:choose>
			<xsl:when test="normalize-space(text()[1])">
				<xsl:text>&gt;</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;&#xa;</xsl:text>
			</xsl:when>
			<xsl:when test="child::*">
				<xsl:text>&gt;&#xa;</xsl:text>
				<xsl:apply-templates/>
				<xsl:value-of select="$indent"/>
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;&#xa;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>/&gt;&#xa;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xsl:*/text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

</xsl:stylesheet>
