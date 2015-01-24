<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<!-- ===================================================
	resolve-xsl-function-ref.xsl
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns="http://spfeopentoolkit.org/ns/spfe-docs"
xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs"
exclude-result-prefixes="#all" >
	
	
	<xsl:template match="xslt-function-reference-entries">
		<xsl:apply-templates/>	
	</xsl:template>

	<xsl:template match="xslt-library-reference-entry">
		
		<xsl:variable name="name" select="xsl-function/name |xsl-template/name"/>
		<xsl:variable name="type" select="sf:name-in-clark-notation(.)"/>
		
		<ss:topic 
			type="{$type}" 
			full-name="{$type}#{$name}"
			local-name="{$name}"
			topic-type-alias="{sf:get-topic-type-alias-singular($topic-set-id, $type, $config)}"
			title="{$name}"
			excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::p[1], 30, ' ...'))}">
			
			<ss:index>
				<ss:entry>
					<ss:type>xslt-library-reference-entry</ss:type>
					<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/functions</ss:namespace>
					<ss:term><xsl:value-of select="$name"/></ss:term>
				</ss:entry>
				<ss:entry>
					<ss:type>xslt-function-name</ss:type>
					<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/functions</ss:namespace>
					<ss:term><xsl:value-of select="$name"/></ss:term>
				</ss:entry>
			</ss:index>
			
			<xsl:copy>
				<xsl:copy-of select="@*" copy-namespaces="no"/>
				<xsl:apply-templates/>
			</xsl:copy>
			
		</ss:topic>
		
	</xsl:template>	
	
	<!-- IdentityTransform -->
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

