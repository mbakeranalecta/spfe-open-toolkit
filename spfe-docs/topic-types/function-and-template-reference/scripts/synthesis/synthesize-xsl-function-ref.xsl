<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	synthesize-xsl-function-ref.xsl
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns="http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference"
xpath-default-namespace="http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference"
exclude-result-prefixes="#all" >
	
	
	<xsl:template match="spfe-xslt-function-reference-entries">
		
		<xsl:apply-templates/>
		
	</xsl:template>

	<xsl:template match="spfe-xslt-function-reference-entry">
		
		<xsl:variable name="name" select="xsl-function/name"/>
		
		<ss:topic 
			type="{{http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference}}function-reference" 
			full-name="http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference/{concat(local-prefix, '_', $name)}"
			local-name="{$name}"
			topic-type-alias="{sf:get-topic-type-alias-singular('{http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference}function-reference', $config)}"
			title="{$name}"
			excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::p[1], 30, ' ...'))}">
			
			<ss:index>
				<ss:entry>
					<ss:type>spfe-xslt-function-reference-entry</ss:type>
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
	
	<xsl:template match="spfe-xslt-template-reference-entry">
		
		<xsl:variable name="name" select="xsl-template/name"/>
		
		<ss:topic 
			type="{{http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference}}function-reference" 
			full-name="http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference/{concat(local-prefix, '_', $name)}"
			local-name="{$name}"
			topic-type-alias="{sf:get-topic-type-alias-singular('{http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference}function-reference', $config)}"
			title="{$name}"
			excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::p[1], 30, ' ...'))}">
			
			<ss:index>
				<ss:entry>
					<ss:type>spfe-xslt-function-reference-entry</ss:type>
					<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/functions</ss:namespace>
					<ss:term><xsl:value-of select="$name"/></ss:term>
				</ss:entry>
				<ss:entry>
					<ss:type>xslt-template-name</ss:type>
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

