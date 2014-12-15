<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:re="http://spfeopentoolkit.org/ns/spfe-docs"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple" exclude-result-prefixes="#all"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"	
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs">

<xsl:output indent="yes" method="xml"/>
	
	<!-- FIXME: See revised link-xpath-segments in the eppo version of this script -->

	<!--================================================
	link-xpath-segments function

	Called recursivly to link the segments of an xpath back 
	to the element named in each segment.
	===================================================-->
	<xsl:function name="lf:link-xpath-segments">
		<xsl:param name="xpath" as="xs:string"/>
		<xsl:sequence select="lf:link-xpath-segments($xpath, '')"/>
	</xsl:function>

	<xsl:function name="lf:link-xpath-segments">
		<xsl:param name="xpath"/>
		<xsl:param name="consumed"/>
		<xsl:if test="$consumed ne $xpath">
		<xsl:variable name="is-root-xpath" select="starts-with($xpath, '/')"/>
	
		<xsl:variable name="xpath-segments" select="tokenize(if ($is-root-xpath) then substring($xpath,2) else $xpath, '/')"/>
		<xsl:variable name="consumed-segments" select="tokenize(if (starts-with($consumed, '/')) then substring($consumed,2) else $consumed, '/')"/>
		<xsl:variable name="segment" select="$xpath-segments[count($consumed-segments)+1]"/>
		
		<!-- output this segment with link -->
			<xsl:if test="not($consumed='' and not($is-root-xpath))">/</xsl:if>
			<!-- call the link template -->
			<xsl:sequence select="lf:link-xpath(
				concat(
					if($is-root-xpath) then '/' else '',
					string-join($xpath-segments[position() le count($consumed-segments)+1], '/')
				),
				$segment)"/>
			<!-- recursive call -->
			
				<xsl:sequence select="lf:link-xpath-segments($xpath, concat($consumed, if($consumed='' and not($is-root-xpath)) then '' else '/', $segment))"/>
			</xsl:if>
	</xsl:function>


	<!-- ==========================================================================
	link-xpath function

	link-xpath is called to create a link in the output. It checks that the 
	link target exists. If it does not, it prints an error on the command line.
=============================================================================-->

	<xsl:function name="lf:link-xpath">
		<xsl:param name="target" as="xs:string"/>
		<xsl:param name="link-text" as="xs:string"/>
		<xsl:variable name="targets"
			select="$synthesis//doctype-reference-entry, $synthesis//attribute"/>
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
						select="
				if (contains($target, '/@')) 
				then translate(substring-before($target, '/@'), '/:', '__' )
				else translate($target, '/:', '__' )"/>
					<xsl:text>.html</xsl:text>
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


	<!-- doctype-reference-entry -->
	<xsl:template match="doctype-reference-entry">
		<xsl:variable name="name" select="name"/>
		<xsl:variable name="namespace" select="xml-namespace"/>
		<xsl:variable name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
		<xsl:variable name="this" select="."/>
		<xsl:variable name="one-possible-xpath" select="concat(parents/parent[1], '/', name)"/>
		<xsl:variable name="topic-id" select="ancestor-or-self::ss:topic/@local-name"/>
		
		<xsl:result-document href="file:///{$output-directory}/{$topic-set-id}/{$topic-id}.dita" 
			method="xml" 
			indent="yes" 
			omit-xml-declaration="no" 
			doctype-public="-//OASIS//DTD DITA Topic//EN" 
			doctype-system="topic.dtd">
			
		<topic id="{$topic-id}">
			<title>Element: <xsl:value-of select="$name"/></title>
			<body>
			<dl>
			<xsl:if test="../../*/doctype-reference-entry[name=$name][not(. is $this)]">
				<dlentry>
					<dt>See also</dt>
					<dd>
						<ul>
							<xsl:for-each select="../../*/doctype-reference-entry[name=$name][not(. is $this)]">
							<li>
								<p>
									<xsl:call-template name="output-link">
										<xsl:with-param name="target" select="parent::ss:topic/@full-name"/>
										<xsl:with-param name="type" select="'topic'"/>
										<xsl:with-param name="namespace" select="$namespace"/>
										<xsl:with-param name="content" select="string(name)"/>
										<xsl:with-param name="current-page-name" select="$current-page-name"/>
									</xsl:call-template>
								</p>
							</li>
						</xsl:for-each>
						</ul>
					</dd>
				</dlentry>
			</xsl:if>
			<dlentry>
				<dt>XML Namespace</dt>
				<dd>
					<p><xsl:value-of select="$namespace"/></p>
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

			<xsl:if test="parents/parent[1]/text() ne ''">
				<dlentry>
					<dt><xsl:value-of select="if (parents/parent[2]) then 'Parents' else 'Parent'"/></dt>
					<dd>
						<xsl:for-each select="parents/parent">
							<p>
								<xsl:variable name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
								<xsl:for-each select="tokenize(.,'/')[. ne '']">
									<xsl:variable name="element-name" select="."/>
									<xsl:text>/</xsl:text>
									<xsl:choose>
										<!-- FIXME: This does not take accout of namespace of the link. -->
										
										<xsl:when test="esf:target-exists($element-name, 'xml-element-name', $namespace)">
											<xsl:call-template name="output-link">
												<xsl:with-param name="target" select="$element-name"/>
												<xsl:with-param name="type" select="'xml-element-name'"/>
												<!-- FIXME: Should use parent element's subject namespace rather than current element subject namespace. -->
												<xsl:with-param name="namespace" select="$namespace"/>
												<xsl:with-param name="content" select="$element-name"/>
												<xsl:with-param name="current-page-name" select="$current-page-name"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="sf:subject-not-resolved">
												<xsl:with-param name="message" select="concat('xml-element-name &quot;', $element-name, '&quot; in topic ', $current-page-name)"/> 
											</xsl:call-template>
											<xsl:value-of select="$element-name"/>								
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</p>
						</xsl:for-each>
					</dd>
				</dlentry>
			</xsl:if>
			
			<dlentry>
				<dt>Children</dt>
				<dd>
					<xsl:if test="not(children/*)">
						<p>None</p>
					</xsl:if>
					<xsl:for-each select="children/child">
						<xsl:sort select="."/>
						<xsl:variable name="child-name" select="./text()"/>
						<p>
							<b> <!-- FIXME: be more specific. -->
								<xsl:choose>
									<xsl:when test="@child-namespace ne $namespace">
										<!-- We don't know if the child element is a root or not in the foreign namespace, so try both. -->
										<xsl:variable name="unprefixed-child-name" 
											select="local-name-from-QName(QName (@child-namespace, $child-name))"/>
										<xsl:variable name="unprefixed-child-name-as-root" 
											select="concat('/',$child-name)"/>
										<xsl:choose>
																					
											<xsl:when test="esf:target-exists($unprefixed-child-name-as-root, 'xml-element-name')">
												<xsl:call-template name="output-link">
													<xsl:with-param name="target" select="$unprefixed-child-name-as-root"/>
													<xsl:with-param name="type" select="'xml-element-name'"/>
													<xsl:with-param name="namespace" select="@child-namespace"/>
													<xsl:with-param name="content" select="$child-name"/>
													<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:when test="esf:target-exists($unprefixed-child-name, 'xml-element-name')">
												<xsl:call-template name="output-link">
													<xsl:with-param name="target" select="$unprefixed-child-name"/>
													<xsl:with-param name="type" select="'xml-element-name'"/>
													<xsl:with-param name="namespace" select="@child-namespace"/>
													<xsl:with-param name="content" select="$child-name"/>
													<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="sf:subject-not-resolved">
													<xsl:with-param name="message" select="concat('xml-element-name &quot;', $child-name, '&quot; in topic ', ancestor::ss:topic/@full-name)"/> 
												</xsl:call-template>
												<xsl:value-of select="$child-name"/>								
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="child-xpath" select="concat($one-possible-xpath,'/',$child-name)"></xsl:variable>
										<!-- FIXME: This is silly. could just be $child-xpath, $child-xpath. but is it doing the right thing? -->
										<!--<xsl:sequence
											select="lf:link-xpath(concat($one-possible-xpath,'/',$child-name),$child-name)"/>-->
										<xsl:choose>
											<xsl:when test="esf:target-exists($child-xpath, 'xml-element-name', @child-namespace)">
												<xsl:call-template name="output-link">
													<xsl:with-param name="target" select="$child-xpath"/>
													<xsl:with-param name="type" select="'xml-element-name'"/>
													<xsl:with-param name="namespace" select="@child-namespace"/>
													<xsl:with-param name="content" select="$child-name"/>
													<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="sf:subject-not-resolved">
													<xsl:with-param name="message" select="concat('xml-element-name &quot;', $child-name, '&quot; in topic ', ancestor::ss:topic/@full-name)"/> 
												</xsl:call-template>
												<xsl:value-of select="$child-name"/>								
											</xsl:otherwise>
										</xsl:choose>
										
									</xsl:otherwise>
								</xsl:choose>
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
							<xref href="#{$topic-id}/{name}">
								<keyword><xsl:value-of select="name"/></keyword>
							</xref>
						</p>
					</xsl:for-each>
				</dd>
			</dlentry>
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

	<!-- FIXME: Some redundant element names here -->
	<xsl:template match="required-by|verified-by|default|special|precis">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="doctype-reference-entry/type"/>
	<xsl:template match="doctype-reference-entry/name"/>
	<!-- 
		=========================
		Format Attribute template
		=========================
	-->
	<xsl:template name="format-attribute">
		<section id="{name}">
			<title>Attribute: <xsl:value-of select="name"/></title>
<dl>
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
</dl>
		</section>
		<!-- restrictions -->
	</xsl:template>



</xsl:stylesheet>
