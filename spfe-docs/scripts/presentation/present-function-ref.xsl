<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 xpath-default-namespace="http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-xslt-function-reference-entry"
 exclude-result-prefixes="#all">
 
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-references.xsl"/>
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-text-structures.xsl"/>
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-topic-set.xsl"/>

<xsl:param name="draft">no</xsl:param>

  <xsl:variable name="config" as="element(config:spfe)">
    <xsl:sequence select="/config:spfe"/>
  </xsl:variable>
  
<!-- processing directives -->
<xsl:output method="xml" indent="yes" cdata-section-elements="codeblock"/>

<xsl:param name="media">online</xsl:param>

<xsl:param name="synthesis-files"/>
<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>
  
  <xsl:template match="ss:topic[@type='http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-xslt-function-reference-entry']">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- spfe-configuration-reference-entry -->
	<xsl:template match="spfe-xslt-function-reference-entry">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- schema-element -->
  <xsl:template match="xsl-function">
		<xsl:variable name="display-name" select="concat(local-prefix, ':', name)"/>
		
		<!-- info -->
		<xsl:call-template name="sf:info">
			<xsl:with-param name="message" select="'Creating page ', $display-name"/>
		</xsl:call-template>
    <!-- FIXME: the page should be created from the ss:topic element by shared code to keep in sync with tocs -->
    <page type="API" name="{name}">
			
		  <title>Function: <xsl:value-of select="$display-name"/></title>
			
			<p>
				<bold>
					<xsl:value-of select="$display-name"/>
					<xsl:text>(</xsl:text>
					<xsl:for-each select="parameters/parameter">
						<xsl:value-of select="name"/>
						<xsl:text> as </xsl:text>
						<xsl:value-of select="type"/>
						<xsl:if test="position() ne last()">, </xsl:if>
					</xsl:for-each>
					<xsl:text>) as </xsl:text>
					<xsl:value-of select="return-value/type"/>
				</bold>
			</p>
			<labeled-item>
				<label>Description</label>
				<item>
					<xsl:if test="not(description)"><p/></xsl:if>
					<xsl:apply-templates select="description"/>
				</item>
			</labeled-item>	
			
    	<labeled-item>
    		<label>Return value</label>
    		<item>
    			<p>Return type: <xsl:value-of select="return-value/type"/></p>
    			<xsl:apply-templates select="return-value/description"/>
    		</item>
    	</labeled-item>
    	
    	<subhead>Parameters</subhead>
    	<xsl:for-each select="parameters/parameter">
    		<labeled-item>
    			<label><xsl:value-of select="name"/></label>
    			<item>
    				<p>Type: <xsl:value-of select="type"/></p>
    				<xsl:apply-templates select="description"/>
    			</item>
    		</labeled-item>
    	</xsl:for-each>
    	
   		<subhead>Definition</subhead>
	    	<codeblock>
	    		<xsl:apply-templates select="definition/*"/>
	    	</codeblock>
    	</page>
  </xsl:template>
	
	<xsl:template match="xsl:*">
		<xsl:variable name="indent">
			<xsl:for-each select="ancestor::xsl:*">
				<xsl:text>&#xa0;&#xa0;</xsl:text>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$indent"/>
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text> </xsl:text>
		<xsl:for-each select="@*">
			<xsl:value-of select="name()"/>
			<xsl:text>="</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
			<xsl:if test="position() ne last()">&#xa0;</xsl:if>
		</xsl:for-each>

		<xsl:choose>
			<xsl:when test="normalize-space(text()[1])">
				<xsl:text>&gt;</xsl:text>				
				<xsl:apply-templates/>
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;&#xa;</xsl:text>					
			</xsl:when>
			<xsl:when test="child::*">
				<xsl:text>&gt;&#xa;</xsl:text>				
				<xsl:apply-templates/>
				<xsl:value-of select="$indent"/>
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;&#xa;</xsl:text>		
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>/&gt;&#xa;</xsl:text>				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="xsl:*/text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

</xsl:stylesheet>
