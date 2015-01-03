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
					<xsl:text>.html</xsl:text>
					<xsl:if test="contains($target, '/@')">
						<xsl:text>#</xsl:text>
						<xsl:value-of select="substring-after($target, '/@')"/>
					</xsl:if>
				</xsl:variable>

				<pe:link link="{$href}" title="Link to: {$target}">
					<xsl:value-of select="$link-text"/>
				</pe:link>
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

		<pe:page type="API" name="{translate(xpath, '/:', '__')}">
			<xsl:call-template name="show-header"/>
			<pe:title>Element: <xsl:value-of select="$name"/></pe:title>

			<pe:labeled-item>
				<pe:label>Location</pe:label>
				<pe:item>
					<pe:p>
						<xsl:sequence select="lf:link-doc-xpath(doc-xpath)"/>
					</pe:p>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Description</pe:label>
				<pe:item>
					<xsl:if test="not(description)">
						<pe:p/>
					</xsl:if>
					<xsl:apply-templates select="description"/>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Use</pe:label>
				<!-- FIXME: need a more sophisticated reading of schema groups 
				     to define usage more accurately-->
				<pe:item>
					<pe:p>
						<xsl:choose>
							<xsl:when test="minOccurs='0' or group='choice'">Optional</xsl:when>
							<xsl:otherwise>Required</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="maxOccurs='unbounded'">, unbounded</xsl:if>
					</pe:p>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Name in build file</pe:label>
				<pe:item>
					<pe:p>
						<xsl:choose>
							<xsl:when test="normalize-space(build-property) ne ''">
								<xsl:value-of select="build-property"/>
							</xsl:when>
							<xsl:otherwise>Not used in the build file.</xsl:otherwise>
						</xsl:choose>
					</pe:p>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Default</pe:label>
				<pe:item>

					<xsl:choose>
						<xsl:when test="not(values/default)">
							<pe:p>None</pe:p>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="values/default"/>
						</xsl:otherwise>
					</xsl:choose>

				</pe:item>
			</pe:labeled-item>

			<!-- Special -->
			<pe:labeled-item>
				<pe:label>Values</pe:label>
				<pe:item>
					<xsl:choose>
						<xsl:when test="values/value">
							<xsl:for-each select="values/value">
								<xsl:sort select="."/>
								<!-- FIXME: this is a hork that will not handle all text-group cases. Need to change to subheads for main headings to use labelled-item here. -->
								<pe:p>
									<pe:value hint="attribute-value">
										<xsl:value-of select="."/>
									</pe:value>
									<xsl:text>: </xsl:text>
									<xsl:apply-templates
										select="following-sibling::description[1]/p[1]/node()"/>
								</pe:p>
								<xsl:apply-templates
									select="following-sibling::description[1]/p[preceding-sibling::p]"
								/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<pe:p>N/A</pe:p>
						</xsl:otherwise>
					</xsl:choose>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Children</pe:label>
				<pe:item>
					<xsl:if test="not(children/*)">
						<pe:p>None</pe:p>
					</xsl:if>
					<xsl:for-each select="children/child">
						<xsl:sort select="."/>
						<xsl:variable name="child-xpath" select="."/>
						<pe:p>
							<pe:name hint="element-name">
								<xsl:sequence
									select="lf:link-xpath($child-xpath,//spfe-configuration-reference-entry[xpath eq $child-xpath]/name)"
								/>
							</pe:name>
						</pe:p>
					</xsl:for-each>
				</pe:item>
			</pe:labeled-item>

			<pe:labeled-item>
				<pe:label>Attributes</pe:label>
				<pe:item>
					<xsl:if test="not(attributes/attribute)">
						<pe:p>None</pe:p>
					</xsl:if>
					<xsl:for-each select="attributes/attribute">
						<xsl:sort select="name"/>
						<pe:p>
							<pe:name hint="attribute-name">
								<pe:link href="#{name}">
									<xsl:value-of select="name"/>
								</pe:link>
							</pe:name>
						</pe:p>
					</xsl:for-each>
				</pe:item>
			</pe:labeled-item>

			<!-- restrictions -->
			<xsl:call-template name="format-restrictions"/>

			<!-- Add the attributes -->
			<xsl:for-each select="attributes/attribute">
				<xsl:sort select="name"/>
				<xsl:call-template name="format-attribute"/>
			</xsl:for-each>
			<xsl:call-template name="show-footer"/>
		</pe:page>
	</xsl:template>

	<xsl:template match="description">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- FIXME: redundant ? -->
	<xsl:template match="xpath">
		<pe:name hint="xpath">
			<xsl:sequence select="lf:link-xpath-segments(xpath)"/>
		</pe:name>
	</xsl:template>

	<!-- FIXME: Some redundant element names here -->
	<xsl:template match="required-by|verified-by|location|default|special|precis">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="spfe-configuration-reference-entry/type"/>
	<xsl:template match="spfe-configuration-reference-entry/name"/>
	<xsl:template match="spfe-configuration-reference-entry/build-property"/>

	<!-- 
		============================
		format-restrictions template
		============================
	-->
	<xsl:template name="format-restrictions">
		<pe:labeled-item>
			<pe:label>Restrictions</pe:label>
			<pe:item>
				<xsl:choose>
					<!-- don't get fooled by an empty restriction element left over from the template -->
					<xsl:when
						test="not(normalize-space(string-join(restrictions/restriction/*,'')))">
						<pe:p>None</pe:p>
					</xsl:when>
					<xsl:otherwise>
						<pe:ul>
							<xsl:for-each select="restrictions/restriction">
								<pe:li>
									<xsl:apply-templates/>
								</pe:li>
							</xsl:for-each>
						</pe:ul>
					</xsl:otherwise>
				</xsl:choose>
			</pe:item>
		</pe:labeled-item>
	</xsl:template>

	<!-- 
		=========================
		Format Attribute template
		=========================
	-->
	<xsl:template name="format-attribute">
		<pe:anchor name="{name}"/>
		<pe:subhead>Attribute: <xsl:value-of select="name"/></pe:subhead>

		<pe:labeled-item>
			<pe:label>XPath</pe:label>
			<pe:item>
				<pe:p>
					<xsl:sequence select="lf:link-doc-xpath(doc-xpath)"/>
				</pe:p>
			</pe:item>
		</pe:labeled-item>


		<!-- description -->
		<pe:labeled-item>
			<pe:label>Description</pe:label>
			<pe:item>
				<!-- no <p> because description contains <p>, but add p if no description -->
				<xsl:if test="not(description)">
					<pe:p/>
				</xsl:if>
				<xsl:apply-templates select="description"/>
			</pe:item>
		</pe:labeled-item>

		<!-- Use -->
		<pe:labeled-item>
			<pe:label>Use</pe:label>
			<pe:item>
				<pe:p>
					<xsl:choose>
						<xsl:when test="use = 'required'">Required</xsl:when>
						<xsl:otherwise>Optional</xsl:otherwise>
					</xsl:choose>
				</pe:p>
			</pe:item>
		</pe:labeled-item>

		<!-- XML data type -->
		<xsl:variable name="type" select="type"/>
		<pe:labeled-item>
			<pe:label>XML data type</pe:label>
			<pe:item>
				<pe:p>
					<xsl:value-of select="$type"/>
				</pe:p>
			</pe:item>
		</pe:labeled-item>

		<!-- not specified -->
		<pe:labeled-item>
			<pe:label>Behavior if not specified</pe:label>
			<pe:item>

				<xsl:choose>
					<xsl:when test="not(values/default)">
						<pe:p>N/A</pe:p>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="values/default"/>
					</xsl:otherwise>
				</xsl:choose>

			</pe:item>
		</pe:labeled-item>

		<!-- Special -->
		<pe:labeled-item>
			<pe:label>Values with special meanings</pe:label>
			<pe:item>
				<xsl:choose>
					<xsl:when test="values/value">
						<xsl:for-each select="values/value">
							<xsl:sort select="."/>
							<!-- FIXME: this is a hork that will not handle all text-group cases. Need to change to subheads for main headings to use labelled-item here. -->
							<pe:p>
								<pe:value hint="attribute-value">
									<xsl:value-of select="."/>
								</pe:value>
								<xsl:text>: </xsl:text>
								<xsl:apply-templates
									select="following-sibling::description[1]/p[1]/node()"/>
							</pe:p>
							<xsl:apply-templates
								select="following-sibling::description[1]/p[preceding-sibling::p]"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<pe:p>None</pe:p>
					</xsl:otherwise>
				</xsl:choose>
			</pe:item>
		</pe:labeled-item>
		<!-- restrictions -->
		<xsl:call-template name="format-restrictions"/>
	</xsl:template>



</xsl:stylesheet>
