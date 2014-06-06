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
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"   
	xmlns:stl="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/subject-topic-list"
	exclude-result-prefixes="#all" >
	
<xsl:param name="topic-set-id"/>
	
<xsl:output method="xml" indent="yes" />

<xsl:param name="extracted-content-files"/>
<xsl:variable name="list-of-topic-subjects" select="sf:get-sources($extracted-content-files)"/>

<!-- There is currently no authored content for the subject list topic set -->
<xsl:param name="authored-content-files"/>
<xsl:variable name="authored-content" select="sf:get-sources($authored-content-files)"/>

<xsl:variable name="config" as="element(config:spfe)">
	<xsl:sequence select="/config:spfe"/>
</xsl:variable>


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
			 href="file:///{concat($config/config:doc-set-build, '/', $topic-set-id, '/synthesis/synthesis.xml')}">
			<ss:synthesis 
				xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
				topic-set-id="{$topic-set-id}" 
				title="{sf:string($config//config:strings, 'eppo-simple-topic-set-product')} {sf:string($config//config:strings, 'eppo-simple-topic-set-release')}"> 
				<!-- Only build list pages for subjects with more than one topic -->
				<xsl:apply-templates select="$list-of-topic-subjects//stl:subject-topic-list[stl:topics-on-subject/stl:topic[2]]"/>
			</ss:synthesis>
		</xsl:result-document>
</xsl:template>
	


<!-- 
=================================
Main content processing templates
=================================
-->

<!-- Topic subject list template -->
	<xsl:template match="stl:subject-topic-list" >
		<xsl:variable name="output-namespace">http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/subject-topic-list</xsl:variable>	
		
	<xsl:variable name="topic-type-alias" select="sf:get-topic-type-alias-singular($output-namespace)"/>
		<xsl:variable name="subject-topic-name" select="concat(stl:subject-type, '_', stl:subject)"/>
						 
			
		<ss:topic 
			type="{$output-namespace}" 
			full-name="{$output-namespace}/{sf:title2anchor($subject-topic-name)}"
			local-name="{sf:title2anchor($subject-topic-name)}"
			topic-type-alias="{$topic-type-alias}"
			title="{sf:get-subject-type-alias-singular(stl:subject-type)}: {stl:subject}"
			excerpt="A list of topics related to the {sf:get-subject-type-alias-singular(stl:subject-type)} {stl:subject}.">
			
			<!-- FIXME: Need to reproduce the entire index term markup here so it is passed through to the link catalog -->
			<ss:index>
				<ss:entry>
					<ss:type><xsl:value-of select="stl:subject-type"/></ss:type>
					<ss:namespace>http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/subject-topic-list</ss:namespace>
					<ss:term><xsl:value-of select="stl:subject"/></ss:term>
				</ss:entry>
			</ss:index>
			<xsl:copy>
				<xsl:apply-templates>
					<!--<xsl:with-param name="output-namespace" tunnel="yes">http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/subject-topic-list</xsl:with-param>-->
				</xsl:apply-templates>
			</xsl:copy>
			
		</ss:topic>
</xsl:template>
	

	

	

</xsl:stylesheet>
