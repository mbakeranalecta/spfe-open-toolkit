<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->

<xsl:stylesheet version="2.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:dht="http://spfeopentoolkit.org/spfe-docs/topic-types/docset-home-topic"
xmlns="http://spfeopentoolkit.org/spfe-docs/topic-types/docset-home-topic"
exclude-result-prefixes="#all">
	
	<xsl:template match="dht:docset-home-topic">
		<xsl:variable name="conditions" select="@if"/>
		<xsl:variable name="topic-type" select="tokenize(normalize-space(@xsi:schemaLocation), '\s')[1]"/>

				<ss:topic 
					type="{namespace-uri()}" 
					topic-type-alias="{sf:get-topic-type-alias-singular($topic-type, $config)}"
					full-name="{concat(namespace-uri(), '/', dht:head/dht:id)}"
					local-name="{dht:head/dht:id}"
					title="{dht:body/dht:title}"
					excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::dht:p[1], 30, ' ...'))}">
					<xsl:if test="dht:head/dht:virtual-type">
						<xsl:attribute name="virtual-type" select="dht:head/dht:virtual-type"/>
					</xsl:if>
					<xsl:element name="{local-name()}">
						<xsl:copy-of select="@*" copy-namespaces="no"/>
						<xsl:apply-templates>
						</xsl:apply-templates>
					</xsl:element>
				</ss:topic>
			

		
	</xsl:template>
	
	<!-- This was inserted to get rid of warning that head not matched in synthesis. Unsure why this was not needed for other topic types. -->
	<xsl:template match="dht:*">
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>

