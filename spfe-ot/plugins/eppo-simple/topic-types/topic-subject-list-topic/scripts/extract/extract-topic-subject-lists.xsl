<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 

	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" 
	xmlns:stl="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/subject-topic-list"
	exclude-result-prefixes="#all">
	


	
<!-- =============================================================
	extract-topic-subject-lists.xsl
	
	Reads a set of link catalog files and finds all the references to a given subject and then assembles a list for that subject.
	 
	
===============================================================-->


	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	<xsl:param name="topic-set-id"/>
	
	<xsl:param name="sources-to-extract-content-from"/>	
	<xsl:variable name="sources" select="sf:get-sources($sources-to-extract-content-from)"/>
	
	
	
	<xsl:template name="main" >
		<!-- Create the root "extracted-content element" -->
		<xsl:result-document href="file:///{concat($config/config:doc-set-build, '/', $topic-set-id,'/extracted/lists.xml')}" method="xml" indent="yes" omit-xml-declaration="no">
			<stl:subject-topic-lists>
			<xsl:for-each-group select="$sources//target[@type ne 'topic']" group-by="concat(@type, '+', original-key)">
				<xsl:variable name="this-key" select="original-key"/>
				<xsl:variable name="this-type" select="@type"/>
				<stl:subject-topic-list>
					<stl:subject><xsl:value-of select="$this-key"/></stl:subject>
					<stl:subject-type><xsl:value-of select="$this-type"/></stl:subject-type>
					<stl:topics-on-subject>
						<!-- Select topic on this subject and type, excluding those in subject-topic-list pages. -->
						<xsl:for-each select="$sources//page[target/original-key=$this-key][target/@type=$this-type][@topic-type ne 'http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/subject-topic-list']">
						<stl:topic>
							<stl:title><xsl:value-of select="@title"/></stl:title>
							<stl:full-name><xsl:value-of select="@full-name"/></stl:full-name>
							<stl:topic-type><xsl:value-of select="@topic-type"/></stl:topic-type>
							<stl:topic-type-alias><xsl:value-of select="@topic-type-alias"/></stl:topic-type-alias>
							<stl:excerpt><xsl:value-of select="@excerpt"/></stl:excerpt>
						</stl:topic>
					</xsl:for-each>	
					</stl:topics-on-subject>
				</stl:subject-topic-list>
			</xsl:for-each-group>
 			</stl:subject-topic-lists>
		</xsl:result-document>
	</xsl:template>
	

	

	
	<xsl:template match="link-catalog">
	
	</xsl:template>
	

</xsl:stylesheet>