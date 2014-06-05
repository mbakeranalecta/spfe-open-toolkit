<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2013 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 xpath-default-namespace="http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference"
 exclude-result-prefixes="#all">
  
	<!-- processing directives -->
	<xsl:output method="xml" indent="yes" cdata-section-elements="codeblock"/>

	
	<!-- spfe-function-reference-entry -->
	<xsl:template match="spfe-xslt-function-reference-entry">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- XSL function -->
	<xsl:template match="xsl-function">
		<xsl:variable name="display-name" select="name/text()"/>
		
		<!-- info
		<xsl:call-template name="sf:info">
			<xsl:with-param name="message" select="'Creating page ', $display-name"/>
		</xsl:call-template> -->
		<!-- FIXME: the page should be created from the ss:topic element by shared code to keep in sync with tocs -->
		<page type="API" name="{name}">
			

			<xsl:call-template name="show-header"/>
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
			
			<labeled-item>
				<label>Source file</label>
				<item>
					<p><xsl:value-of select="source-file"/></p>
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
			<xsl:for-each select="definition">
				<codeblock language="XSLT">
    			<!-- select="*" here so as not to pick up the whitespace in the definition element -->
    			<xsl:apply-templates select="*"/>
    		</codeblock>
			</xsl:for-each>
			<xsl:call-template name="show-footer"/>		
		</page>
	</xsl:template>
	
	<!-- spfe-template-reference-entry -->
	<xsl:template match="spfe-xslt-template-reference-entry">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- XSL template -->
	<xsl:template match="xsl-template">
		<xsl:variable name="display-name" select="name/text()"/>
		
		<!-- info 
		<xsl:call-template name="sf:info">
			<xsl:with-param name="message" select="'Creating page ', $display-name"/>
		</xsl:call-template>-->
		<!-- FIXME: the page should be created from the ss:topic element by shared code to keep in sync with tocs -->
		<!-- FIXME: Is the page type attribute used for anything? Should it be? -->
		<page type="API" name="{name}">
			
			<title>Template: <xsl:value-of select="$display-name"/></title>
			
			<labeled-item>
				<label>Description</label>
				<item>
					<xsl:if test="not(description)"><p/></xsl:if>
					<xsl:apply-templates select="description"/>
				</item>
			</labeled-item>	
			
			<labeled-item>
				<label>Source file</label>
				<item>
					<p><xsl:value-of select="source-file"/></p>
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
			<xsl:for-each select="definition">
				<codeblock language="XSLT">
    			<!-- select="*" here so as not to pick up the whitespace in the definition element -->
    			<xsl:apply-templates select="*"/>
    		</codeblock>
			</xsl:for-each>
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
