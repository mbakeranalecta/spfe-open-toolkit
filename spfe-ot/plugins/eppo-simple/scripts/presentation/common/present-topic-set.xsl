<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 	
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
 	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 	exclude-result-prefixes="#all">
	
<!-- processing directives -->
<xsl:output method="xml" indent="yes"/>
	
	<!-- FIXME: hack -->
	<xsl:variable name="media">online</xsl:variable>

<!-- parameters -->

<xsl:param name="presentation-schema">eppo-simple-web-presentation.xsd</xsl:param>
<xsl:param name="draft">no</xsl:param>

<xsl:variable name="config" as="element(config:spfe)">
	<xsl:sequence select="/config:spfe"/>
</xsl:variable>

<xsl:param name="synthesis-files"/>
<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>

<xsl:variable name="topic-set-title">
	<xsl:value-of select="sf:string($config/config:strings, 'eppo-simple-topic-set-title')"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="sf:string($config/config:strings, 'eppo-simple-topic-set-release')"/>
</xsl:variable>
	
<xsl:variable name="doc-set-title">
	<xsl:value-of select="$config/config:doc-set/config:title"/>
</xsl:variable>
	
<xsl:variable name="topic-set-id">
	<xsl:value-of select="$config/config:topic-set-id"/>
</xsl:variable>
	
	
<!--  
=============
Main template
=============
-->
<xsl:template name="main">
	<xsl:result-document href="file:///{concat($config/config:build/config:build-directory, '/temp/presentation/presentation.xml')}" method="xml" indent="no" omit-xml-declaration="no">
		<xsl:element name="{if ($media='paper') then 'book' else 'web'}" >
			<title><xsl:value-of select="sf:string($config/config:strings, 'eppo-simple-topic-set-title')"/></title>
				
			<!-- process the topics --> 
			<xsl:apply-templates select="$synthesis/ss:synthesis/*"/>
			<xsl:call-template name="create-generated-topics"/>

		</xsl:element>
	</xsl:result-document>
</xsl:template>

<xsl:template name="create-generated-topics"/>
	
<xsl:template match="ss:topic" priority="-1">
	<xsl:call-template name="sf:error">
		<xsl:with-param name="message">
			<xsl:text>A topic of an unrecognised topic type was included in the topic set build. The root element name is "</xsl:text>
			<xsl:value-of select="name(descendant::*[namespace-uri() ne 'http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis'][1])"/>
			<xsl:text>". The topic name is "</xsl:text>
			<xsl:value-of select="@local-name"/>
			<xsl:text>". The topic type is "</xsl:text>
			<xsl:value-of select="@type"/>
			<xsl:text>".</xsl:text>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="topic/name" mode="#all"/>	
<xsl:template match="tracking" mode="#all"/>

<xsl:template name="show-header">
	<xsl:variable name="topic-type" select="if (ancestor::ss:topic/@virtual-type) then ancestor::ss:topic/@virtual-type else ancestor::ss:topic/@type"/>
	<header>
		<p>
			<xsl:value-of select="$doc-set-title"/>   
			>      
			<xref target="{concat(normalize-space($topic-set-id), '-toc.html')}" class="toc">
				<xsl:value-of select="$topic-set-title"/>
			</xref>
			</p>
	<table>
		<tr>
			<td><bold>Topic&#160;type</bold></td>
			<td><xsl:value-of select="ancestor::ss:topic/@topic-type-alias"/></td>
		</tr>
		<tr>
			<td><bold>Product</bold></td>
			<td>
				<xsl:value-of select="sf:string($config/config:strings, 'eppo-simple-topic-set-product')"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="sf:string($config/config:strings, 'eppo-simple-topic-set-release')"/>
			</td>
		</tr>
		<xsl:if test="index/reference/key[normalize-space(.) ne '']">
			<tr>
				<td><bold>Tags</bold></td>
				<td>
					<xsl:for-each select="index/reference">
						<xsl:variable name="key-text" select="translate(key[1], '{}', '')"/>
						<xsl:choose>
							<xsl:when test="esf:target-exists-not-self(key[1], type, ancestor::topic/@default-reference-scope, ancestor::topic/name)">
								<xsl:call-template name="output-link">
									<xsl:with-param name="target" select="key[1]"/>
									<xsl:with-param name="type" select="type"/>
									<xsl:with-param name="content" select="$key-text"/>
									<xsl:with-param name="scope" select="ancestor::topic/@default-reference-scope"/> 
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$key-text"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="position() != last()">, </xsl:if>
					</xsl:for-each>
				</td>
			</tr>
			
		</xsl:if>
	</table>
	</header>
</xsl:template>

<xsl:template name="show-footer">		
	
			<xsl:variable name="see-also-links">
				<xsl:for-each select="index/reference[esf:target-exists(key[1], type, ancestor::topic/@default-reference-scope)]">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="key[1]"/>
						<xsl:with-param name="type" select="type"/>
						<xsl:with-param name="content" select="translate(key[1], '{}', '')"/>
						<xsl:with-param name="see-also" select="true()"/>
						<xsl:with-param name="scope" select="ancestor::topic/@default-reference-scope"/> 
					</xsl:call-template>
				</xsl:for-each>	
			</xsl:variable>
			
			<xsl:if test="$see-also-links/xref | $see-also-links/xref-set">
				<table hint="context">
					<tr>
						<td><bold>See also</bold></td>
						<td>
							<ul>
								<xsl:for-each-group select="$see-also-links/xref | $see-also-links/xref-set/xref" group-by="@target">
									<li><xsl:sequence select="."/></li>
								</xsl:for-each-group>
							</ul>
						</td>
					</tr>
				</table>
			</xsl:if>
		
	</xsl:template>
	
</xsl:stylesheet>
