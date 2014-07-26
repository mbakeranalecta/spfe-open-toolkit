<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/topic-types/generic-task-topic"
exclude-result-prefixes="#all">
	
	<xsl:template match="generic-task-topic">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:variable name="topic-type" select="tokenize(normalize-space(@xsi:schemaLocation), '\s')[1]"/>

				<ss:topic 
					type="{namespace-uri()}" 
					topic-type-alias="{sf:get-topic-type-alias-singular($topic-type, $config)}"
					full-name="{concat(namespace-uri(), '/', head/id)}"
					local-name="{head/id}"
					title="{body/title}"
					excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::p[1], 30, ' ...'))}">		

					<xsl:copy>
						<xsl:copy-of select="@*" copy-namespaces="no"/>
						<xsl:apply-templates/>
					</xsl:copy>
				</ss:topic>
			
	</xsl:template>
</xsl:stylesheet>

