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
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"
 exclude-result-prefixes="#all" 
 xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
>
<!--<xsl:output indent="no"/>-->
<xsl:strip-space elements="terminal-session"/>




	<!-- FIXME: This needs to be an explicit list or else it overrides subject-templates.xsl in 
		the import order. Might be fixed by converting individual reference types to subject or name 
		at the synthesis stage, or by changing the import order. -->
	<xsl:template match="title
		| subhead
		| labeled-item
		| label
		| item
		| tr
		| td
		| th
		| ol
		| ul
		| li
		| note
		| warning
		| caution
		| code
		| bold
		| italic">
		
		<xsl:element name="pe:{local-name()}" namespace="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="body">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="p">
		<pe:p>
			<!-- FIXME: will this copy attributes with old namespaces? Make it all explicit.-->
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:p>
		<xsl:for-each select="text-object-ref">
			<xsl:variable name="id" select="@id-ref"/>
			<xsl:variable name="content" select="normalize-space(.)"/>
			<xsl:choose>
				<xsl:when test="//text-object[id=$id]">
					<pe:fold id="{generate-id()}" type="text-object" initial-state="closed" reference-text="{$content}">
						<xsl:apply-templates select="//text-object[id=$id]"/>
					</pe:fold>		
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:warning">
						<xsl:with-param name="message">Text object <xsl:value-of select="$id"/> not found.</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="text-object">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="text-object/tracking"/>
	<xsl:template match="text-object/id"/>
	<xsl:template match="text-object/title">
		<pe:title><xsl:apply-templates/></pe:title>
	</xsl:template>


	
	<xsl:template match="codeblock">
		<pe:codeblock>
		<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:codeblock>
	</xsl:template>

	<xsl:template match="terminal-session">
	<!-- do it all here so we can control the whitespace in output -->
		<pe:codeblock>
			<xsl:text/><xsl:apply-templates/><xsl:text/>
		</pe:codeblock>
	</xsl:template>
	
	<xsl:template match="terminal-session/prompt">
	<!-- account for the possibility that there is no response between entries -->
	<xsl:if test="preceding-sibling::entry">
			<xsl:text>&#xA;</xsl:text>
	</xsl:if>
		<xsl:if test="normalize-space(.)">
			<xsl:text/><xsl:value-of select="normalize-space(.)"/><xsl:text/>
			<xsl:text>&#160;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="terminal-session/entry">
		<xsl:if test="normalize-space(.)">
			<xsl:sequence select="esf:process-placeholders(., 'code', 'placeholder')"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="terminal-session/response">
		<xsl:if test="normalize-space(.)">
			<xsl:text>&#xA;</xsl:text>
			<xsl:text/><xsl:apply-templates/><xsl:text/>
		</xsl:if>
	</xsl:template>

	
	<xsl:template match="string-literal">
		<pe:bold><xsl:apply-templates/></pe:bold>
	</xsl:template>
	
	<xsl:template match="table">
		<xsl:if test="@id">
			<pe:anchor name="table:{@id}"/>
		</xsl:if>
		<pe:table>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</pe:table>
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

	<xsl:template match="author-note">
		<xsl:if test="$config/config:build-command='draft'">
			<xsl:element name="{local-name()}">
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="review-note">
		<xsl:if test="$config/config:build-command='draft'">
			<xsl:element name="{local-name()}">
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
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
	
	<xsl:template match="step">
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

	<xsl:template match="qa">
		<pe:labeled-item>
			<xsl:apply-templates/>
		</pe:labeled-item>
	</xsl:template>
	
	<xsl:template match="qa/q">
		<pe:label>
			<xsl:apply-templates/>
		</pe:label>
	</xsl:template>
	
	<xsl:template match="qa/a">
		<pe:item>
			<xsl:apply-templates/>
		</pe:item>
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
								<routine-name scope="{$scope}"><xsl:value-of select="regex-group(1)"/></routine-name>
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
