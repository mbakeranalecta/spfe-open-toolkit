<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	exclude-result-prefixes="#all">
	
	<xsl:output indent="yes" method="xml"/>

	
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
 			<topic-subject-lists>
			<xsl:for-each-group select="$sources//target[@type ne 'topic']" group-by="concat(@type, '+', original-key)">
				<xsl:variable name="this-key" select="original-key"/>
				<xsl:variable name="this-type" select="@type"/>
				<topic-subject-list>
					<subject><xsl:value-of select="$this-key"/></subject>
					<subject-type><xsl:value-of select="$this-type"/></subject-type>
					<topics-on-subject>

					<xsl:for-each select="$sources//page[target/original-key=$this-key][target/@type=$this-type]">
						<topic>
							<title><xsl:value-of select="@title"/></title>
							<full-name><xsl:value-of select="@full-name"/></full-name>
							<topic-type><xsl:value-of select="@topic-type"/></topic-type>
							<topic-type-alias><xsl:value-of select="@topic-type-alias"/></topic-type-alias>
							<excerpt><xsl:value-of select="@excerpt"/></excerpt>
						</topic>
					</xsl:for-each>	
					</topics-on-subject>
				</topic-subject-list>
			</xsl:for-each-group>
 			</topic-subject-lists>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:output method="xml" indent="yes"/>
	
	<xsl:key name="attribute-type" match="xs:attribute" use="@type"/>
	
	<xsl:template match="link-catalog">
	
	</xsl:template>
	

</xsl:stylesheet>