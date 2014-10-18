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
	link target exists. If it is not, it prints an error on the command line.
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
					<xsl:with-param name="message" select="'#Unknown xpath', $target"/>
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

				<pe:xref target="{$href}" title="Link to: {$target}">
					<xsl:value-of select="$link-text"/>
				</pe:xref>
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
		<xsl:variable name="xpath" select="xpath"/>
		<xsl:variable name="name" select="name"/>

		<pe:page type="API" name="{translate(name, '/:', '__')}">
			<xsl:call-template name="show-header"/>
			<pe:title>Element: <xsl:value-of select="$name"/></pe:title>

			<pe:labeled-item>
				<pe:label>Namespace</pe:label>
				<pe:item>
					<pe:p><xsl:value-of select="namespace"/></pe:p>
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

			<xsl:if test="parents/parent[1]/text() ne ''">
				<pe:labeled-item>
					<pe:label><xsl:value-of select="if (parents/parent[2]) then 'Parents' else 'Parent'"/></pe:label>
					<pe:item>
						<xsl:for-each select="parents/parent">
							<pe:p>
								<xsl:variable name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
								<xsl:for-each select="tokenize(.,'/')[. ne '']">
									<xsl:variable name="element-name" select="."/>
									<xsl:text>/</xsl:text>
									<xsl:choose>
										<!-- FIXME: This does not take accout of namespace of the link. -->
										
										<xsl:when test="esf:target-exists($element-name, 'xml-element-name')">
											<xsl:call-template name="output-link">
												<xsl:with-param name="target" select="$element-name"/>
												<xsl:with-param name="type" select="'xml-element-name'"/>
												<xsl:with-param name="content" select="$element-name"/>
												<xsl:with-param name="current-page-name" select="$current-page-name"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:message>not resolved</xsl:message>
											<xsl:call-template name="sf:subject-not-resolved">
												<xsl:with-param name="message" select="concat('xml-element-name &quot;', $element-name, '&quot; not resolved in topic ', $current-page-name)"/> 
											</xsl:call-template>
											<xsl:value-of select="$element-name"/>								
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</pe:p>
						</xsl:for-each>
					</pe:item>
				</pe:labeled-item>
			</xsl:if>
			
			<pe:labeled-item>
				<pe:label>Children</pe:label>
				<pe:item>
					<xsl:if test="not(children/*)">
						<pe:p>None</pe:p>
					</xsl:if>
					<xsl:for-each select="children/child">
						<xsl:sort select="."/>
						<xsl:variable name="child-xpath" select="./text()"/>
						<pe:p>
							<pe:name hint="element-name">
								<xsl:choose>
									<xsl:when test="@child-namespace">
										<!-- We don't know if the child element is a root or not in the foreign namespace, so try both. -->
										<xsl:variable name="child-name" select="local-name-from-QName(QName (@child-namespace, $child-xpath))"/>
										<xsl:variable name="child-name-as-root" select="concat('/',$child-name)"/>
										<xsl:choose>
											<!-- FIXME: This does not take accout of namespace of the link. -->
											
											<xsl:when test="esf:target-exists($child-name-as-root, 'xml-element-name')">
												<xsl:call-template name="output-link">
													<xsl:with-param name="target" select="$child-name-as-root"/>
													<xsl:with-param name="type" select="'xml-element-name'"/>
													<xsl:with-param name="content" select="$child-xpath"/>
													<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:when test="esf:target-exists($child-name, 'xml-element-name')">
												<xsl:call-template name="output-link">
													<xsl:with-param name="target" select="$child-name"/>
													<xsl:with-param name="type" select="'xml-element-name'"/>
													<xsl:with-param name="content" select="$child-xpath"/>
													<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:message>not resolved</xsl:message>
												<xsl:call-template name="sf:subject-not-resolved">
													<xsl:with-param name="message" select="concat('xml-element-name &quot;', $child-xpath, '&quot; not resolved in topic ', ancestor::ss:topic/@full-name)"/> 
												</xsl:call-template>
												<xsl:value-of select="$child-xpath"/>								
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
<!--										<xsl:message select="$child-xpath, '|', //doctype-reference-entry[name eq $child-xpath]"/>-->
										<xsl:sequence
											select="lf:link-xpath($child-xpath,//doctype-reference-entry[name eq $child-xpath]/name)"/>
									</xsl:otherwise>
								</xsl:choose>
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
								<pe:xref target="#{name}">
									<xsl:value-of select="name"/>
								</pe:xref>
							</pe:name>
						</pe:p>
					</xsl:for-each>
				</pe:item>
			</pe:labeled-item>

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

	<!-- FIXME: redundant ?
	<xsl:template match="xpath">
		<pe:name hint="xpath">
			<xsl:sequence select="lf:link-xpath-segments(xpath)"/>
		</pe:name>
	</xsl:template> -->

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
		<pe:anchor name="{name}"/>
		<pe:subhead>Attribute: <xsl:value-of select="name"/></pe:subhead>

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
	</xsl:template>



</xsl:stylesheet>
