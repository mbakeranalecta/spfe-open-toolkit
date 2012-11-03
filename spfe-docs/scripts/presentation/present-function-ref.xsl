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
			
			
			<labeled-item>
				<label>Description</label>
				<item>
					<xsl:if test="not(description)"><p/></xsl:if>
					<xsl:apply-templates select="description"/>
				</item>
			</labeled-item>	
			
			<labeled-item>
				<label>Definition</label>
				<item>
					<code-block>
					  <xsl:sequence select="."/>
					</code-block>
				</item>
			</labeled-item>

			
			<xsl:if test="normalize-space(build-property)">
				<labeled-item>
					<label>Name in build file</label>
					<item>
						<p>
							<xsl:apply-templates select="build-property"/>
						</p>
					</item>
				</labeled-item>
			</xsl:if>	
			
			<xsl:if  test="normalize-space(include-behavior)">			
				<labeled-item>
					<label>Treatment of values in included files</label>
					<!-- FIXME: need a more sophisticated reading of schema groups 
					     to define usage more accurately-->
					<item>
						<xsl:apply-templates select="include-behavior/*"></xsl:apply-templates>
					</item>
				</labeled-item>
			</xsl:if>			
			<xsl:if test="values">
					<!-- not specified -->
		<labeled-item>
			<label>Behavior if not specified</label>
			<item>
				
					<xsl:choose>
						<xsl:when test="not(values/unspecified)"><p>N/A</p></xsl:when> 
						<xsl:otherwise>
							<xsl:apply-templates select="values/unspecified"/>
						</xsl:otherwise>
					</xsl:choose>
				
			</item>
		</labeled-item>
		
		<!-- Special -->
		<labeled-item>
			<label>Values with special meanings</label>
			<item>
				<xsl:choose>
					<xsl:when test="values/value"> 
						<xsl:for-each select="values/value">
							<xsl:sort select="."/>
							<!-- FIXME: this is a hork that will not handle all text-group cases. Need to change to subheads for main headings to use labelled-item here. -->
							<p>
								<value hint="attribute-value">
									<xsl:value-of select="."/>
								</value>
								<xsl:text>: </xsl:text>
								<xsl:apply-templates select="following-sibling::description[1]/p[1]/node()"/>
							</p>
								<xsl:apply-templates select="following-sibling::description[1]/p[preceding-sibling::p]"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise><p>None</p></xsl:otherwise>
				</xsl:choose>
			</item>
		</labeled-item>
		</xsl:if>
			
			<labeled-item>
				<label>Children</label>
				<item>
					<xsl:if test="not(children/*)">
						<p>None</p>
					</xsl:if>
					<xsl:for-each select="children/child">
						<xsl:sort select="."/>
						<xsl:variable name="child-xpath" select="."/>
						<p>
							<name hint="element-name">

							</name>
						</p>
					</xsl:for-each>
				</item>
			</labeled-item>	
			
			<labeled-item>
				<label>Attributes</label>
				<item>
					<xsl:if test="not(attributes/attribute)">
						<p>None</p>
					</xsl:if>
					<xsl:for-each select="attributes/attribute">
						<xsl:sort select="name"/>
						<p>
							<name hint="attribute-name">
								<xref target="#{name}">
									<xsl:value-of select="name"/>
								</xref>
							</name>
						</p>
					</xsl:for-each>
				</item>
			</labeled-item>	
			
			<!-- restrictions -->
			<xsl:call-template name="format-restrictions"/>
			
			<!-- Add the attributes -->
			<xsl:for-each select="attributes/attribute">
				<xsl:sort select="name"/>
				<xsl:call-template name="format-attribute"/>
			</xsl:for-each>
		</page>
	</xsl:template>
	
	<!-- FIXME: redundant ? -->
	<xsl:template	 match="xpath">
		<name hint="xpath">
			
		</name>
	</xsl:template>
	
	<!-- FIXME: Some redundant element names here -->
	<xsl:template match="required-by|verified-by|location|unspecified|special|precis"> 
		<xsl:apply-templates/>	
	</xsl:template>
	
	<xsl:template match="schema-element/type"/>
	<xsl:template match="schema-element/name"/>
	
	<!-- 
		============================
		format-restrictions template
		============================
	-->
	<xsl:template name="format-restrictions">
		<labeled-item>
			<label>Restrictions</label>
			<item>
				<xsl:choose>
					<!-- don't get fooled by an empty restriction element left over from the template -->
					<xsl:when test="not(normalize-space(string-join(restrictions/restriction/*,'')))">
						<p>None</p>
					</xsl:when>
					<xsl:otherwise>
						<ul>
							<xsl:for-each select="restrictions/restriction">
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</xsl:otherwise>
				</xsl:choose>
			</item>
		</labeled-item>
	</xsl:template>
	
	<!-- 
		=========================
		Format Attribute template
		=========================
	-->
	<xsl:template name="format-attribute">
		<anchor name="{name}"/>
		<subhead>Attribute: <xsl:value-of select="name"/></subhead>

		<labeled-item>
			<label>XPath</label>
			<item>
				<p></p>
			</item>
		</labeled-item>	
		
	
		<!-- description -->	
		<labeled-item>
			<label>Description</label>
			<item><!-- no <p> because description contains <p>, but add p if no description -->
				<xsl:if test="not(description)"><p/></xsl:if>
				<xsl:apply-templates select="description"/>
			</item>
		</labeled-item>	
		
		<!-- Use -->
		<labeled-item>
			<label>Use</label>
			<item>
				<p>
					<xsl:choose>
						<xsl:when test="use = 'required'">Required</xsl:when>
						<xsl:otherwise>Optional</xsl:otherwise>
					</xsl:choose>
				</p>
			</item>
		</labeled-item>
		
		<!-- XML data type -->
		<xsl:variable name="type" select="type"/>
		<labeled-item>
			<label>XML data type</label> 
			<item>
				<p>
					<xsl:value-of select="$type"/>
				</p>
			</item>
		</labeled-item>	
		
		<!-- not specified -->
		<labeled-item>
			<label>Behavior if not specified</label>
			<item>
				
					<xsl:choose>
						<xsl:when test="not(values/unspecified)"><p>N/A</p></xsl:when> 
						<xsl:otherwise>
							<xsl:apply-templates select="values/unspecified"/>
						</xsl:otherwise>
					</xsl:choose>
				
			</item>
		</labeled-item>
		
		<!-- Special -->
		<labeled-item>
			<label>Values with special meanings</label>
			<item>
				<xsl:choose>
					<xsl:when test="values/value"> 
						<xsl:for-each select="values/value">
							<xsl:sort select="."/>
							<!-- FIXME: this is a hork that will not handle all text-group cases. Need to change to subheads for main headings to use labelled-item here. -->
							<p>
								<value hint="attribute-value">
									<xsl:value-of select="."/>
								</value>
								<xsl:text>: </xsl:text>
								<xsl:apply-templates select="following-sibling::description[1]/p[1]/node()"/>
							</p>
								<xsl:apply-templates select="following-sibling::description[1]/p[preceding-sibling::p]"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise><p>None</p></xsl:otherwise>
				</xsl:choose>
			</item>
		</labeled-item>
		<!-- restrictions -->
		<xsl:call-template name="format-restrictions"/>
	</xsl:template>

</xsl:stylesheet>
