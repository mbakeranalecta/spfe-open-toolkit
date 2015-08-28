<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<!-- ===================================================
	resolve-config-ref.xsl
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns="http://spfeopentoolkit.org/ns/spfe-docs"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs"
	exclude-result-prefixes="#all">



	<!-- 
=================================
Main content processing templates
=================================
-->

	<!-- Schema element template -->
	<xsl:template match="spfe-configuration-reference-entry">
		<xsl:variable name="name" select="translate(xpath, '/:', '__')"/>
		<xsl:variable name="type" select="sf:name-in-clark-notation(.)"/>
		
		<ss:topic 
			type="{$type}" 
			full-name="{$type}#{$name}"
			local-name="{$name}"
			topic-type-alias="{sf:get-topic-type-alias-singular($topic-set-id, $type, $config)}"
			title="{name}"
			excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::p[1], 30, ' ...'))}">
				<xsl:variable name="xpath" select="normalize-space(xpath)"/>
				<ss:index>
					<ss:entry>
						<ss:type>config-setting</ss:type>
						<ss:namespace>http://spfeopentoolkit.org/ns/spfe-ot/config</ss:namespace>
						<ss:term>
							<xsl:value-of select="$xpath"/>
						</ss:term>
					</ss:entry>

					<xsl:for-each select="attributes/attribute">
						<ss:entry>
							<ss:type>config-setting</ss:type>
							<ss:namespace>http://spfeopentoolkit.org/ns/spfe-ot/config</ss:namespace>
							<ss:term><xsl:value-of select="$xpath"/>/@<xsl:value-of select="name"/></ss:term>
							<ss:anchor>
								<xsl:value-of select="name"/>
							</ss:anchor>
						</ss:entry>
					</xsl:for-each>
				</ss:index>

				<xsl:copy>
					<xsl:copy-of select="@*" copy-namespaces="no"/>
					<xsl:apply-templates/>
				</xsl:copy>
					

			</ss:topic>
	</xsl:template>


	<xsl:template match="spfe-configuration-reference-entries">

			<xsl:apply-templates/>

	</xsl:template>
	
	<!-- IdentityTransform -->
 <xsl:template match="@* | node()">
      <xsl:copy>
             <xsl:apply-templates select="@* | node()" />
         </xsl:copy>
 </xsl:template>
	
	<!-- Avoid xpath being matched by subject affinity markup rules. -->
	<xsl:template match="spfe-configuration-reference-entry/xpath">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
	<!-- 
=================================
Content fix-up templates
=================================
-->

	<!-- FIXME: Are these in the right namespace to match?" -->

	<!-- Fix up element name xpaths. Raise priority to avoid collision with default config-setting template -->
	<xsl:template match="config-setting" priority="1">
		<xsl:variable name="context-element"
			select="ancestor::spfe-configuration-reference-entry/normalize-space(xpath)"/>
		<xsl:variable name="data-content" select="."/>
		<xsl:variable name="xpath" select="@xpath"/>
		<xsl:variable name="all-elements"
			select="//spfe-configuration-reference-entry/xpath"/>
		<name>
			<xsl:attribute name="type">config-setting</xsl:attribute>
			<xsl:choose>
				<!-- check the cases where there is no 'xpath' attribute -->
				<xsl:when test="not(@xpath)">

					<xsl:variable name="parent-of-context-element"
						select="string-join(tokenize($context-element,'/')[position()!=last()],'/')"/>
					<xsl:choose>

						<!-- Is it a full element path? -->
						<xsl:when test="$all-elements=$data-content">
							<!-- make the xpath explicit -->
							<xsl:attribute name="key" select="$data-content"/>
						</xsl:when>

						<!-- Is it the name of the current element? -->
						<xsl:when test="$context-element[ends-with(., $data-content)]">
							<xsl:attribute name="key" select="$context-element"/>
						</xsl:when>

						<!-- Is it an unambiguous partial element path? -->
						<xsl:when test="count($all-elements[ends-with(., $data-content)])=1">
							<!-- make the xpath explicit -->
							<xsl:attribute name="key"
								select="$all-elements[ends-with(., $data-content)]"/>
						</xsl:when>

						<!-- Is it the name of a child of the current element? -->
						<xsl:when test="$all-elements=concat($context-element, '/', $data-content)">
							<xsl:attribute name="key"
								select="concat($context-element, '/', $data-content)"/>
						</xsl:when>

						<!-- Is it the name of a sibling of the current element?-->

						<xsl:when
							test="$all-elements=concat($parent-of-context-element, '/', $data-content)">
							<xsl:attribute name="key"
								select="concat($parent-of-context-element, '/', $data-content)"/>
						</xsl:when>


						<!-- If not, we have a problem -->
						<xsl:otherwise>
							<xsl:attribute name="key" select="$data-content"/>
							<xsl:call-template name="sf:warning">
								<xsl:with-param name="message">
									<xsl:text>Unknown or ambiguous SPFE config element name "</xsl:text>
									<xsl:value-of select="$data-content"/>
									<xsl:text>". Context element is:</xsl:text>
									<xsl:value-of select="$context-element"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>

					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="key" select="@xpath"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates/>
		</name>
	</xsl:template>

	<xsl:template name="create-allowed-in-list">
		<xsl:param name="group"/>
		<xsl:param name="xpath"/>
		<!-- include the containing element if there is one -->
		<xsl:if test="contains($xpath, '/')">
			<xpath>
				<xsl:value-of select="string-join(tokenize($xpath, '/')[position() != last()], '/')"
				/>
			</xpath>
		</xsl:if>
		<xsl:call-template name="recurse-allowed-in-list">
			<xsl:with-param name="group" select="$group"/>
			<xsl:with-param name="xpath" select="$xpath"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="recurse-allowed-in-list">
		<xsl:param name="group"/>
		<xsl:param name="xpath"/>

		<xsl:for-each select="//schema-group-ref[referenced-group=$group]">

			<xsl:variable name="ref-group"
				select="//schema-group-ref[referenced-group=$group]/referenced-in-group"/>

			<xsl:choose>

				<xsl:when test="referenced-in-xpath">
					<xpath>
						<xsl:value-of select="referenced-in-xpath"/>
					</xpath>
				</xsl:when>

				<xsl:when test="//schema-group-ref[referenced-group=$group]">
					<xsl:call-template name="recurse-allowed-in-list">
						<xsl:with-param name="group" select="$ref-group"/>
						<xsl:with-param name="xpath" select="$xpath"/>
					</xsl:call-template>
				</xsl:when>

				<xsl:otherwise>
					<xsl:call-template name="sf:error">
						<xsl:with-param name="message">
							<xsl:text>Unable to figure out which elements the element </xsl:text>
							<xsl:value-of select="$xpath"/>
							<xsl:text> is allowed in. This may be due to the use of some feature of W3C schemas that synthesize-schema-docs.xsl was not designed to handle.</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>

			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
