<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
 exclude-result-prefixes="#all" 
 xpath-default-namespace=""
>
<!--<xsl:output indent="no"/>-->
<xsl:strip-space elements="terminal-session"/>




	<!-- FIXME: This needs to be an explicit list or else it overrides subject-templates.xsl in 
		the import order. Might be fixed by converting individual reference types to subject or name 
		at the synthesis stage, or by changing the import order. -->
	<xsl:template match="es:title
		| es:tr
		| es:td
		| es:th
		| es:ol
		| es:ul
		| es:li
		| es:note
		| es:warning
		| es:caution
">
		
		<xsl:element name="{local-name()}" namespace="">
			<!--<xsl:copy-of select="@*"/> Can't blindly copy attributes since DITA atrributes don't match.-->
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="es:body">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="es:code">
		<codeph><xsl:apply-templates/></codeph>
	</xsl:template>

	<xsl:template match="es:italic">
		<i><xsl:apply-templates/></i>
	</xsl:template>
	
	<xsl:template match="es:subhead">
		<p><decoration class="bold"><xsl:apply-templates/></decoration></p>
	</xsl:template>
	
	<xsl:template match="es:bold">
		<decoration class="bold"><xsl:apply-templates/></decoration>
	</xsl:template>
	
	<xsl:template match="es:labeled-item">
		<dl>
			<dlentry>
				<xsl:apply-templates/>
			</dlentry>
		</dl>
	</xsl:template>
	
	<xsl:template match="es:item">
		<dd><xsl:apply-templates/></dd>
	</xsl:template>

	<xsl:template match="es:label">
		<dt><xsl:apply-templates/></dt>
	</xsl:template>

	<xsl:template match="es:p">
		<p>
			<!-- FIXME: will this copy attributes with old namespaces? Make it all explicit.-->
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</p>
		
	</xsl:template>


	<xsl:template match="es:codeblock">
		<codeblock>
			<xsl:apply-templates/>
		</codeblock>
	</xsl:template>

	<xsl:template match="es:terminal-session">
	<!-- do it all here so we can control the whitespace in output -->
		<!-- FIXME: Use dita terminal markup -->
		<codeblock>
			<xsl:text/><xsl:apply-templates/><xsl:text/>
		</codeblock>
	</xsl:template>
	
	<xsl:template match="es:terminal-session/es:prompt">
	<!-- account for the possibility that there is no response between entries -->
	<xsl:if test="preceding-sibling::entry">
			<xsl:text>&#xA;</xsl:text>
	</xsl:if>
		<xsl:if test="normalize-space(.)">
			<xsl:text/><xsl:value-of select="normalize-space(.)"/><xsl:text/>
			<xsl:text>&#160;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="es:terminal-session/es:entry">
		<xsl:if test="normalize-space(.)">
			<xsl:sequence select="esf:process-placeholders(., 'code', 'placeholder')"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="es:terminal-session/es:response">
		<xsl:if test="normalize-space(.)">
			<xsl:text>&#xA;</xsl:text>
			<xsl:text/><xsl:apply-templates/><xsl:text/>
		</xsl:if>
	</xsl:template>

	

	<xsl:template match="es:table">
		<table id="{if (@id) then @id else generate-id()}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</table>
	</xsl:template>
	
	<xsl:template match="es:comment-author-to-author">
		<xsl:if test="$config/config:build-command='draft'">
			<xsl:element name="{local-name()}">
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="es:procedure">
		<procedure id="{if (@id) then @id else generate-id()}">
			<xsl:apply-templates/>
		</procedure>
	</xsl:template>
	
	<xsl:template match="es:procedure/es:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>
	
	<xsl:template match="es:procedure/es:intro">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="es:step">
		<step id="{if (@id) then @id else generate-id()}">
			<xsl:apply-templates/>
		</step>
	</xsl:template>
	
	<xsl:template match="es:step/es:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>

	<xsl:template match="es:qa">
		<labeled-item>
			<xsl:apply-templates/>
		</labeled-item>
	</xsl:template>
	
	<xsl:template match="es:qa/es:q">
		<label>
			<xsl:apply-templates/>
		</label>
	</xsl:template>
	
	<xsl:template match="es:qa/es:a">
		<item>
			<xsl:apply-templates/>
		</item>
	</xsl:template>
	
	<xsl:template match="es:codeblock[@language='C']">
		<xsl:variable name="scope" select="@scope"/>
		<codeblock>
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
		</codeblock>
	</xsl:template>

</xsl:stylesheet>
