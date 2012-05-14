<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all">
	
<!-- <xsl:include href="present-toc.xsl"/> -->

<!-- processing directives -->
<xsl:output method="xml" indent="yes"/>
	
	<!-- FIXME: hack -->
	<xsl:variable name="media">online</xsl:variable>

<!-- parameters -->

<xsl:param name="presentation-schema">presentation.xsd</xsl:param>
<xsl:param name="draft">no</xsl:param>

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>

	<xsl:param name="synthesis-files"/>
	<xsl:variable name="synthesis-dir" select="concat($config/config:build/config:build-directory, '/temp/synthesis/')"/>
	
	<xsl:variable name="synthesis">
		<xsl:for-each select="tokenize($synthesis-files, $config/config:dir-separator)">
			<xsl:sequence select="doc(concat('file:///',translate($synthesis-dir,'\','/'), .))"/>	
		</xsl:for-each>
	</xsl:variable>

<!--  
=============
Main template
=============
-->
<xsl:template name="main">
	<xsl:element name="{if ($media='paper') then 'book' else 'web'}" >
		<title><xsl:value-of select="$config/config:publication-info/config:title"/></title>
				
			<!-- create a toc page -->
			<xsl:variable name="toc">
				<xsl:call-template name="toc"/>
			</xsl:variable>
			
			<xsl:sequence select="$toc"/>
			
			<!-- create a page for each topic, ordering according to the toc. -->
			<!-- this ordering is important for correct PDF generation -->
			<xsl:for-each select="$toc//node">
				<xsl:variable name="node-id" select="@id"/>
				<xsl:apply-templates select="$synthesis/ss:synthesis/generic-topic[name=$node-id]"/>
			</xsl:for-each>

			
			<!-- create a toc 
			<xsl:call-template name="toc"/>-->

			<!-- process the topics --> 
			<xsl:apply-templates select="$synthesis/ss:synthesis/*"/>
			<xsl:call-template name="create-generated-topics"/>

	</xsl:element>
</xsl:template>

<xsl:template name="create-generated-topics"/>

<xsl:template match="ss:topic" priority="-1">
	<xsl:call-template name="error">
		<xsl:with-param name="message">
			<xsl:text>A topic of an unregconized topic type was included in the topic set build. The root element name is "</xsl:text>
			<xsl:value-of select="@element-name"/>
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


<!-- show context - experimental -->
<xsl:template name="show-context">
	<xsl:variable name="topic-type" select="if (ancestor::ss:topic/@virtual-type) then ancestor::ss:topic/@virtual-type else ancestor::ss:topic/@type"/>
	
	<!-- copied from present-references - refactor -->
		<xsl:variable name="topic-type-alias">

			<xsl:choose>
				<xsl:when test="$topic-type-alias-list/config:topic-type[config:id=$topic-type]">
					<xsl:value-of select="$topic-type-alias-list/config:topic-type[config:id=$topic-type]/config:alias"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="warning">
						<xsl:with-param name="message">
							<xsl:text>No topic type alias found for topic type </xsl:text>
							<xsl:value-of select="$topic-type"/>
							<xsl:text>. Using the topic type name instead.</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$topic-type"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

	<table hint="context">
		<tr>
			<td><bold>Topic&#160;type</bold></td>
			<td><xsl:value-of select="$topic-type-alias"/></td>
		</tr>
		<tr>
			<td><bold>Product</bold></td>
			<td>
				<xsl:value-of select="$config/config:publication-info/config:product"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$config/config:publication-info/config:release"/>
			</td>
		</tr>
		<xsl:if test="index/reference/key[normalize-space(.) ne '']">
			<tr>
				<td><bold>Tags</bold></td>
				<td>
					<xsl:for-each select="index/reference">
						<xsl:variable name="key-text" select="translate(key[1], '{}', '')"/>
						<xsl:choose>
							<xsl:when test="sf:target-exists-not-self(key[1], type, ancestor::topic/@default-reference-scope, ancestor::topic/name)">
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
			
<!-- 					<xsl:variable name="see-also-links">
				<xsl:for-each select="index/reference[sf:target-exists-not-self(key[1], type, ancestor::topic/@default-reference-scope, ancestor::topic/name)]">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="key[1]"/>
						<xsl:with-param name="type" select="type"/>
						<xsl:with-param name="content" select="translate(key[1], '{}', '')"/>
						<xsl:with-param name="scope" select="ancestor::topic/@default-reference-scope"/> 
					</xsl:call-template>
				</xsl:for-each>	
			</xsl:variable>
			<xsl:if test="$see-also-links/xref | $see-also-links/xref-set">
				<tr>
					<td><bold>See also for</bold></td>
					<td>
						<xsl:for-each select="$see-also-links/xref | $see-also-links/xref-set">
							<xsl:sequence select="."/>
							<xsl:if test="position() != last()">, </xsl:if>
						</xsl:for-each>
					</td>
				</tr>

 			</xsl:if>
-->				</xsl:if>
	</table>
</xsl:template>

<xsl:template name="see-also-footer">		

			<xsl:variable name="see-also-links">
				<xsl:for-each select="index/reference[sf:target-exists(key[1], type, ancestor::topic/@default-reference-scope)]">
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
