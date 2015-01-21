<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" 
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:lc="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/link-catalog"
	exclude-result-prefixes="#all">
<!-- =============================================================
	extract-topic-subject-lists.xsl
	
	Reads a set of link catalog files and finds all the references to a given subject and then assembles a list for that subject.
	 
	
===============================================================-->


	<xsl:variable name="config" as="element(config:config)">
		<xsl:sequence select="/config:config"/>
	</xsl:variable>
	
	<xsl:param name="topic-set-id"/>
	
	<xsl:param name="sources-to-extract-content-from"/>	
	<xsl:variable name="sources" select="sf:get-sources($sources-to-extract-content-from)"/>
	
	
	
	<xsl:template name="main" >
		<!-- Create the root "extracted-content element" FIXME: Should use $output-directory. -->
		<xsl:result-document href="file:///{concat($config/config:content-set-build, '/topic-sets/', $topic-set-id,'/extract/out/lists.xml')}" method="xml" indent="yes" omit-xml-declaration="no">
			<es:subject-topic-lists>
				<xsl:for-each-group select="$sources//lc:target[@type ne 'topic']" group-by="concat(@type, '+', lc:original-key, '+', lc:namespace)">
					<xsl:variable name="this-key" select="lc:original-key"/>
					<xsl:variable name="this-type" select="@type"/>
					<xsl:variable name="this-namespace" select="lc:namespace"/>
					<es:subject-topic-list>
						<es:subject><xsl:value-of select="$this-key"/></es:subject>
						<es:subject-type><xsl:value-of select="$this-type"/></es:subject-type>
						<es:subject-namespace><xsl:value-of select="$this-namespace"/></es:subject-namespace>
						<es:topics-on-subject>
							<!-- Select topic on this subject and type, excluding those in subject-topic-list pages. -->
							<xsl:for-each select="$sources//lc:page[lc:target/lc:original-key=$this-key]
								                                   [if($this-namespace) then lc:target/lc:namespace=$this-namespace else true()]
								                                   [lc:target/@type=$this-type]
								                                   [not( ends-with(@topic-type, '}subject-topic-list'))]">
								<es:topic>
									<es:title><xsl:value-of select="@title"/></es:title>
									<es:full-name><xsl:value-of select="@full-name"/></es:full-name>
									<es:topic-type><xsl:value-of select="@topic-type"/></es:topic-type>
									<es:topic-type-alias><xsl:value-of select="@topic-type-alias"/></es:topic-type-alias>
									<es:excerpt><xsl:value-of select="@excerpt"/></es:excerpt>
								</es:topic>
							</xsl:for-each>	
						</es:topics-on-subject>
					</es:subject-topic-list>
				</xsl:for-each-group>
 			</es:subject-topic-lists>
		</xsl:result-document>
	</xsl:template>
	

	

	
	<xsl:template match="lc:link-catalog">
	
	</xsl:template>
	

</xsl:stylesheet>