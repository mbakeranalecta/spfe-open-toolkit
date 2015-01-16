<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	synthesize-config-ref.xsl
=======================================================-->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"   
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" >
	
<xsl:param name="topic-set-id"/>
	<!-- FIXME: This should not be defaulted. -->
	<xsl:param name="output-directory"/>
	
<xsl:output method="xml" indent="yes" />


<xsl:param name="authored-content-files"/>
<xsl:variable name="authored-content" select="sf:get-sources($authored-content-files)"/>

<xsl:variable name="config" as="element(config:spfe)">
	<xsl:sequence select="/config:spfe"/>
</xsl:variable>
	
	<xsl:variable name="draft" as="xs:boolean" select="$config/config:build-command='draft'"/>
<!-- 
=============
Main template
=============
-->
	
<xsl:template name="main">
	
	<!-- Create the topic set -->
		<xsl:result-document 
			 method="xml" 
			 indent="yes"
			 omit-xml-declaration="no" 
			 href="file:///{$output-directory}/synthesis.xml">
			<ss:synthesis 
				xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
				topic-set-id="{$topic-set-id}" 
				title="{sf:string($config//config:strings, 'product')} {sf:string($config//config:strings, 'product-release')}"> 
				<!-- Only build list pages for subjects with more than one topic -->
				<xsl:apply-templates select="$authored-content//es:subject-topic-list[es:topics-on-subject/es:topic[2]]"/>
			</ss:synthesis>
		</xsl:result-document>
</xsl:template>
	


<!-- 
=================================
Main content processing templates
=================================
-->

<!-- Topic subject list template -->
	<xsl:template match="es:subject-topic-list" >
		
		
		<xsl:variable name="subject-topic-name" select="concat(es:subject-type, '_', es:subject)"/>
						 
		<xsl:variable name="name" select="sf:title-to-anchor($subject-topic-name)"/>
		<xsl:variable name="type" select="sf:name-in-clark-notation(.)"/>

		<ss:topic 
			type="{$type}" 
			full-name="{$type}#{$name}"
			local-name="{$name}"			
			topic-type-alias="{sf:get-topic-type-alias-singular($topic-set-id, $type, $config)}"
			title="{sf:get-subject-type-alias-singular(es:subject-type, $config)}: {es:subject}"
			excerpt="A list of topics related to the {sf:get-subject-type-alias-singular(es:subject-type, $config)} {es:subject}.">
			
			<!-- FIXME: Need to reproduce the entire index term markup here so it is passed through to the link catalog -->
			<ss:index>
				<ss:entry>
					<ss:type><xsl:value-of select="es:subject-type"/></ss:type>
					<ss:namespace><xsl:value-of select="es:subject-namespace"/></ss:namespace>
					<ss:term><xsl:value-of select="es:subject"/></ss:term>
				</ss:entry>
			</ss:index>
			<xsl:copy>
				<xsl:apply-templates/>
			</xsl:copy>
			
			
		</ss:topic>
</xsl:template>

</xsl:stylesheet>

