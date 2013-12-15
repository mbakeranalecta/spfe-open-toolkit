<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
version="2.0"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all"
>
<!--<xsl:output indent="no"/>-->
<xsl:strip-space elements="terminal-session"/>

<xsl:param name="image-directory">images</xsl:param>
<xsl:param name="graphics-catalog-file"/>
<xsl:variable name="graphics-catalog" select="document($graphics-catalog-file)/graphics-catalog"/>

	<xsl:function name="esf:section-has-content" as="xs:boolean">
		<xsl:param name="content"/>
		<xsl:value-of select="(normalize-space
				(string-join
					(($content/text() | $content/*) except ($content/author-note | $content/review-note),''))
				) ne ''"/>
	</xsl:function>

	<!-- FIXME: This needs to be an explicit list or else it overrides present-references.xsl in 
		the import order. Might be fixed by converting individual reference types to subject-affinity or name 
		at the synthesis stage, or by changing the import order. -->
	<xsl:template match="*:title
		| *:subhead
		| *:labeled-item
		| *:label
		| *:item
		| *:tr
		| *:td
		| *:th
		| *:ol
		| *:ul
		| *:li
		| *:note
		| *:warning
		| *:caution
		| *:code
		| *:bold-x
		| *:italic">
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*:body">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="*:p">
		<p>
			<!-- FIXME: will this copy attributes with old namespaces? Make it all explicit.-->
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</p>
		<xsl:for-each select="text-object-ref">
			<xsl:variable name="id" select="@id-ref"/>
			<xsl:variable name="content" select="normalize-space(.)"/>
			<xsl:choose>
				<xsl:when test="//text-object[id=$id]">
					<xsl:choose>
						<xsl:when test="$media='paper'">
							<!-- FIXME: what do we do about paper? -->
						</xsl:when>
						<xsl:otherwise>
							<fold id="{generate-id()}" type="text-object" initial-state="closed" reference-text="{$content}">
								<xsl:apply-templates select="//text-object[id=$id]"/>
							</fold>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
						<xsl:call-template name="sf:warning">
						<xsl:with-param name="message">Text object <xsl:value-of select="$id"/> not found.</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*:text-object">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="*:text-object/*:tracking"/>
	<xsl:template match="*:text-object/*:id"/>
	<xsl:template match="*:text-object/*:title">
		<title><xsl:apply-templates/></title>
	</xsl:template>


	
	<xsl:template match="*:codeblock">
		<codeblock>
		<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</codeblock>
	</xsl:template>

	<xsl:template match="*:terminal-session">
	<!-- do it all here so we can control the whitespace in output -->
		<codeblock>
			<xsl:text/><xsl:apply-templates/><xsl:text/>
		</codeblock>
	</xsl:template>
	
	<xsl:template match="*:terminal-session/prompt">
	<!-- account for the possibility that there is no response between entries -->
	<xsl:if test="preceding-sibling::entry">
			<xsl:text>&#xA;</xsl:text>
	</xsl:if>
		<xsl:if test="normalize-space(.)">
			<xsl:text/><xsl:value-of select="normalize-space(.)"/><xsl:text/>
			<xsl:text>&#160;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*:terminal-session/*:entry">
		<xsl:if test="normalize-space(.)">
			<xsl:sequence select="esf:process-placeholders(., 'code', 'placeholder')"/>
	<!-- 			<bold><xsl:apply-templates/></bold> -->		
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*:terminal-session/*:response">
		<xsl:if test="normalize-space(.)">
			<xsl:text>&#xA;</xsl:text>
			<xsl:text/><xsl:apply-templates/><xsl:text/>
		</xsl:if>
	</xsl:template>

	
	<xsl:template match="*:string-literal">
		<bold><xsl:apply-templates/></bold>
	</xsl:template>
	
	<xsl:template match="*:table">
		<xsl:if test="@id">
			<anchor name="table:{@id}"/>
		</xsl:if>
		<table>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</table>
	</xsl:template>
	
	<xsl:template match="*:code-sample">
	<code-sample id="{@id}">
		<xsl:if test="@id">
			<anchor name="code-sample:{@id}"/>
		</xsl:if>
		<xsl:apply-templates select="*:title"/>
		<xsl:if test="*:file-ref">
			<p>
				<xsl:text>Source file: </xsl:text>
				<xsl:apply-templates select="*:file-ref"/>
			</p>
		</xsl:if>
		<xsl:apply-templates select="*:codeblock"/>
	</code-sample>
	</xsl:template>

	<xsl:template match="*:code-sample/*:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>

	<xsl:template match="*:author-note">
		<xsl:if test="$config/config:build-command='draft'">
			<xsl:element name="{local-name()}">
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*:review-note">
		<xsl:if test="$config/config:build-command='draft'">
			<xsl:element name="{local-name()}">
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*:procedure">
		<procedure id="{@id}">
			<xsl:if test="@id">
				<anchor name="procedure:{@id}"/>
			</xsl:if>
			<xsl:apply-templates/>
		</procedure>
	</xsl:template>
	
	<xsl:template match="*:procedure/*:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>
	
	<xsl:template match="*:procedure/*:intro">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="*:step">
		<step>
			<xsl:if test="@id">
				<xsl:copy-of select="@id"/>
				<anchor name="step:{@id}"/>
			</xsl:if>
			<xsl:apply-templates/>
		</step>
	</xsl:template>
	
	<xsl:template match="*:step/*:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>

	<xsl:template match="*:fig">
		<!-- Note that this function believes what the graphics catalog tells it. It does not check that the graphic the catalog points to exists or is the right size, etc. -->
		<xsl:variable name="fig-id" select="@id"/>
		<xsl:variable name="uri" select="@uri"/>
		<anchor name="fig:{if($uri) then generate-id($uri) else @id}"/>
		
		<xsl:variable name="this-graphic">
			<xsl:choose>
				<xsl:when test="$graphics-catalog/graphic[uri eq $uri]">
					<xsl:sequence select="$graphics-catalog/graphic[uri eq $uri]/*"/>
				</xsl:when>
				<xsl:when test="$graphics-catalog/graphic[id eq $fig-id]">
					<xsl:sequence select="$graphics-catalog/graphic[id eq $fig-id]/*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:warning">
						<xsl:with-param name="message">
							<xsl:text>Figure not found: </xsl:text>
							<xsl:value-of select="if ($uri) then $uri else $fig-id"/>
							<xsl:text>. Referenced in topic </xsl:text>
							<xsl:value-of select="ancestor::*:topic/*:name"/>
							<xsl:text>.</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
			<xsl:choose>
				<xsl:when test="$this-graphic">
					<xsl:choose>
						<xsl:when test="$media='online'">
							<fig id="{if($uri) then generate-id($uri) else $fig-id}" uri="{$uri}">
								<xsl:attribute name="href">
									<xsl:value-of select="$image-directory"/>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="sf:get-file-name-from-path($this-graphic/raster)"/>
								</xsl:attribute>
								<xsl:apply-templates/>
							</fig>
						</xsl:when>
						<xsl:when test="$media='paper'">
							<!-- get the best available format for print -->
							<xsl:variable name="selected-graphic" select=" if ($this-graphic/vector) then $this-graphic/vector else $this-graphic/raster"/>
							<fig id="{if($uri) then generate-id($uri) else $fig-id}" uri="{$uri}">
								<xsl:attribute name="file">
									<xsl:value-of select="$image-directory"/>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="sf:get-file-name-from-path($selected-graphic)"/>
								</xsl:attribute>
								<xsl:attribute name="height" select="$selected-graphic/@height"/>
								<xsl:attribute name="width" select="$selected-graphic/@width"/>
								<xsl:if test="$selected-graphic/@dpi">
									<xsl:attribute name="dpi" select="$selected-graphic/@dpi"/>
								</xsl:if>
								<xsl:apply-templates/>
							</fig>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="sf:error">
								<xsl:with-param name="message" select="'Unknown media speficied: ', $media"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*:fig/*:title">
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>
	
	<xsl:template match="*:qa">
		<labeled-item>
			<xsl:apply-templates/>
		</labeled-item>
	</xsl:template>
	
	<xsl:template match="*:qa/*:q">
		<label>
			<xsl:apply-templates/>
		</label>
	</xsl:template>
	
	<xsl:template match="*:qa/*:a">
		<item>
			<xsl:apply-templates/>
		</item>
	</xsl:template>
	
	<xsl:template match="*:codeblock[@language='C']">
		<xsl:variable name="scope" select="@scope"/>
		<codeblock>
			<xsl:analyze-string select="." regex="([a-zA-z0-9]+)(\s*\()">
				<xsl:matching-substring>
					<xsl:choose>
						<xsl:when test="esf:target-exists(regex-group(1), 'routine', $scope)">
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
