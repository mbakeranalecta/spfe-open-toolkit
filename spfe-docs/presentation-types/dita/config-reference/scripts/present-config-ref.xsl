<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:re="http://spfeopentoolkit.org/ns/spfe-docs" exclude-result-prefixes="#all"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"	xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs">


	<!--================================================
	link-xpath-segments function

	Called recursivly to link the segments of an xpath back 
	to the element named in each segment.
	===================================================-->
	<xsl:function name="lf:link-xpath-segments">
		<xsl:param name="xpath"/>
		<xsl:sequence select="lf:link-xpath-segments($xpath, '', 1)"/>
	</xsl:function>

	<xsl:function name="lf:link-doc-xpath">
		<xsl:param name="doc-xpath"/>
		<!--find the source-->
		<xsl:variable name="xpath"
			select="$synthesis//spfe-configuration-reference-entry[doc-xpath=$doc-xpath]/xpath, $synthesis//spfe-configuration-reference-entry/attributes/attribute[doc-xpath=$doc-xpath]/xpath"/>
		<xsl:variable name="consumed" select="substring-before($xpath,$doc-xpath)"/>
		<xsl:sequence select="lf:link-xpath-segments($xpath, $consumed, 1)"/>
	</xsl:function>

	<xsl:function name="lf:link-xpath-segments">
		<xsl:param name="xpath"/>
		<xsl:param name="consumed"/>
		<xsl:param name="depth"/>

		<!--check depth to make sure it does not run for ever if something else breaks -->
		<xsl:if test="not($xpath=$consumed) and not($depth>10)">

			<!-- calculate this segment of the path -->
			<xsl:variable name="segment">
				<xsl:choose>
					<xsl:when
						test="substring-before(substring($xpath, string-length($consumed)+2),'/')=''">
						<xsl:value-of select="substring($xpath, string-length($consumed)+2)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="substring-before(substring($xpath, string-length($consumed)+2),'/')"
						/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- output this segment with link -->
			<xsl:text>/</xsl:text>
			<!-- call the link template -->
			<xsl:sequence select="lf:link-xpath(concat($consumed, '/', $segment),$segment)"/>
			<!-- recursive call -->
			<xsl:sequence
				select="lf:link-xpath-segments($xpath, concat($consumed, '/', $segment), $depth+1)"
			/>
		</xsl:if>
	</xsl:function>


	<!-- ==========================================================================
	link-xpath function

	link-xpath is called to create a link in the output. It checks that the 
	link target exists. If it is not, it prints an error on the command line.
=============================================================================-->

	<xsl:function name="lf:link-xpath">
		<xsl:param name="target" as="xs:string"/>
		<xsl:param name="link-text" as="xs:string"/>
		<xsl:variable name="targets"
			select="$synthesis//spfe-configuration-reference-entry, $synthesis//attribute"/>
		<!--Determine whether or not the target exists. -->
		<xsl:choose>
			<xsl:when test="count($targets[xpath = $target]) > 1">
				<xsl:call-template name="sf:warning">
					<xsl:with-param name="message" select="'Ambiguous xpath ', $target"/>
				</xsl:call-template>
				<!-- output plain text -->
				<xsl:value-of select="$link-text"/>
			</xsl:when>
			<xsl:when test="not($targets[xpath = $target])">
				<!-- if it does not exist, report the error but continue, outputting plain text -->
				<xsl:call-template name="sf:warning">
					<xsl:with-param name="message" select="'Unknown xpath', $target"/>
				</xsl:call-template>
				<!-- output plain text -->
				<xsl:value-of select="$link-text"/>
			</xsl:when>

			<xsl:otherwise>
				<!-- it does exist so output a link -->
				<xsl:variable name="href">
					<xsl:value-of
						select="if (contains($target, '/@')) 
				then 		
					translate(substring-before($target, '/@'), '/:', '__' )
				else
					translate($target, '/:', '__' )"/>
					<xsl:text>.dita</xsl:text>
					<xsl:if test="contains($target, '/@')">
						<xsl:text>#</xsl:text>
						<xsl:value-of select="substring-after($target, '/@')"/>
					</xsl:if>
				</xsl:variable>
				<!-- FIXME: This should go through the link catalog instead. -->
				<xref href="{$href}">
					<xsl:value-of select="$link-text"/>
				</xref>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- 
		=================
		Element templates
		=================
	-->


	<!-- spfe-configuration-reference-entry -->
	<xsl:template match="spfe-configuration-reference-entry">
		<xsl:variable name="xpath" select="xpath"/>
		<xsl:variable name="name" select="name"/>
		<xsl:variable name="topic-id" select="ancestor::ss:topic/@local-name"></xsl:variable>

		<xsl:result-document href="file:///{$output-directory}/{$topic-set-id}/{$topic-id}.dita" 
			method="xml" 
			indent="yes" 
			omit-xml-declaration="no" 
			doctype-public="-//OASIS//DTD DITA Topic//EN" 
			doctype-system="topic.dtd">
			
		<topic id="{translate(xpath, '/:', '__')}">
			<title>Element: <xsl:value-of select="$name"/></title>
			<body>
				<dl>
				<dlentry>
					<dt>Location</dt>
					<dd>
						<p>
							<xsl:sequence select="lf:link-doc-xpath(doc-xpath)"/>
						</p>
					</dd>
				</dlentry>
	
				<dlentry>
					<dt>Description</dt>
					<dd>
						<xsl:if test="not(description)">
							<p/>
						</xsl:if>
						<xsl:apply-templates select="description"/>
					</dd>
				</dlentry>
	
				<dlentry>
					<dt>Use</dt>
					<!-- FIXME: need a more sophisticated reading of schema groups 
					     to define usage more accurately-->
					<dd>
						<p>
							<xsl:choose>
								<xsl:when test="minOccurs='0' or group='choice'">Optional</xsl:when>
								<xsl:otherwise>Required</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="maxOccurs='unbounded'">, unbounded</xsl:if>
						</p>
					</dd>
				</dlentry>
	
				<dlentry>
					<dt>Default</dt>
					<dd>
	
						<xsl:choose>
							<xsl:when test="not(values/default)">
								<p>None</p>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="values/default"/>
							</xsl:otherwise>
						</xsl:choose>
	
					</dd>
				</dlentry>
	
				<!-- Special -->
				<dlentry>
					<dt>Values</dt>
					<dd>
						<xsl:choose>
							<xsl:when test="values/value">
								<xsl:for-each select="values/value">
									<xsl:sort select="."/>
									<!-- FIXME: this is a hork that will not handle all text-group cases. Need to change to subheads for main headings to use labelled-item here. -->
									<p>
										<keyword>
											<xsl:value-of select="."/>
										</keyword>
										<xsl:text>: </xsl:text>
										<xsl:apply-templates
											select="following-sibling::description[1]/p[1]/node()"/>
									</p>
									<xsl:apply-templates
										select="following-sibling::description[1]/p[preceding-sibling::p]"
									/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<p>N/A</p>
							</xsl:otherwise>
						</xsl:choose>
					</dd>
				</dlentry>
	
				<dlentry>
					<dt>Children</dt>
					<dd>
						<xsl:if test="not(children/*)">
							<p>None</p>
						</xsl:if>
						<xsl:for-each select="children/child">
							<xsl:sort select="."/>
							<xsl:variable name="child-xpath" select="."/>
							<p>
								<b><!-- FIXME: changed keyword to bold here because can't nest xref in keyword in DITA. Needs to be other way round.  -->
									<xsl:sequence
										select="lf:link-xpath($child-xpath,//spfe-configuration-reference-entry[xpath eq $child-xpath]/name)"
									/>
								</b>
							</p>
						</xsl:for-each>
					</dd>
				</dlentry>
	
				<dlentry>
					<dt>Attributes</dt>
					<dd>
						<xsl:if test="not(attributes/attribute)">
							<p>None</p>
						</xsl:if>
						<xsl:for-each select="attributes/attribute">
							<xsl:sort select="name"/>
							<p>
								<keyword>
									<xref href="#{$topic-id}/{name}">
										<xsl:value-of select="name"/>
									</xref>
								</keyword>
							</p>
						</xsl:for-each>
					</dd>
				</dlentry>
				
				<!-- restrictions -->
				<xsl:call-template name="format-restrictions"/>
				</dl>
				<!-- Add the attributes -->
				<xsl:for-each select="attributes/attribute">
					<xsl:sort select="name"/>
					<xsl:call-template name="format-attribute"/>
				</xsl:for-each>
			</body>
		</topic>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="description">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- FIXME: redundant ? -->
	<xsl:template match="xpath">
		<codeph hint="xpath">
			<xsl:sequence select="lf:link-xpath-segments(xpath)"/>
		</codeph>
	</xsl:template>

	<!-- FIXME: Some redundant element names here -->
	<xsl:template match="required-by|verified-by|location|default|special|precis">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="spfe-configuration-reference-entry/type"/>
	<xsl:template match="spfe-configuration-reference-entry/name"/>

	<!-- 
		============================
		format-restrictions template
		============================
	-->
	<xsl:template name="format-restrictions">
		<dlentry>
			<dt>Restrictions</dt>
			<dd>
				<xsl:choose>
					<!-- don't get fooled by an empty restriction element left over from the template -->
					<xsl:when
						test="not(normalize-space(string-join(restrictions/restriction/*,'')))">
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
			</dd>
		</dlentry>
	</xsl:template>

	<!-- 
		=========================
		Format Attribute template
		=========================
	-->
	<xsl:template name="format-attribute">
		<section id="{name}">
			<title>Attribute: <xsl:value-of select="name"/></title>
		<dl>
		<dlentry>
			<dt>XPath</dt>
			<dd>
				<p>
					<xsl:sequence select="lf:link-doc-xpath(doc-xpath)"/>
				</p>
			</dd>
		</dlentry>


		<!-- description -->
		<dlentry>
			<dt>Description</dt>
			<dd>
				<!-- no <p> because description contains <p>, but add p if no description -->
				<xsl:if test="not(description)">
					<p/>
				</xsl:if>
				<xsl:apply-templates select="description"/>
			</dd>
		</dlentry>

		<!-- Use -->
		<dlentry>
			<dt>Use</dt>
			<dd>
				<p>
					<xsl:choose>
						<xsl:when test="use = 'required'">Required</xsl:when>
						<xsl:otherwise>Optional</xsl:otherwise>
					</xsl:choose>
				</p>
			</dd>
		</dlentry>

		<!-- XML data type -->
		<xsl:variable name="type" select="type"/>
		<dlentry>
			<dt>XML data type</dt>
			<dd>
				<p>
					<xsl:value-of select="$type"/>
				</p>
			</dd>
		</dlentry>

		<!-- not specified -->
		<dlentry>
			<dt>Behavior if not specified</dt>
			<dd>

				<xsl:choose>
					<xsl:when test="not(values/default)">
						<p>N/A</p>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="values/default"/>
					</xsl:otherwise>
				</xsl:choose>

			</dd>
		</dlentry>

		<!-- Special -->
		<dlentry>
			<dt>Values with special meanings</dt>
			<dd>
				<xsl:choose>
					<xsl:when test="values/value">
						<xsl:for-each select="values/value">
							<xsl:sort select="."/>
							<!-- FIXME: this is a hork that will not handle all text-group cases. Need to change to subheads for main headings to use labelled-item here. -->
							<p>
								<keyword>
									<xsl:value-of select="."/>
								</keyword>
								<xsl:text>: </xsl:text>
								<xsl:apply-templates
									select="following-sibling::description[1]/p[1]/node()"/>
							</p>
							<xsl:apply-templates
								select="following-sibling::description[1]/p[preceding-sibling::p]"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<p>None</p>
					</xsl:otherwise>
				</xsl:choose>
			</dd>
			
			</dlentry>
			<!-- restrictions -->
			<xsl:call-template name="format-restrictions"/>	
		</dl>
		</section>

	</xsl:template>



</xsl:stylesheet>
