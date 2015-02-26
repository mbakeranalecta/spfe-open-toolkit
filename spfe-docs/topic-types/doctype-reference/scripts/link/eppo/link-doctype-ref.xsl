<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns="http://spfeopentoolkit.org/ns/spfe-docs"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple" exclude-result-prefixes="#all"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs">

	<xsl:output indent="yes" method="xml"/>

	<!-- Copy everything we don't explicitly modify -->
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>


	<!--================================================
	link-xpath-segments function

	Called recursivly to link the segments of an xpath back 
	to the element named in each segment.
	===================================================-->
	<xsl:template name="lf:link-xpath-segments">
		<xsl:param name="xpath" as="xs:string"/>
		<xsl:param name="namespace"/>
		<xsl:call-template name="lf:link-next-xpath-segment">
			<xsl:with-param name="xpath" select="$xpath"/>
			<xsl:with-param name="namespace" select="$namespace"/>
			<xsl:with-param name="consumed"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="lf:link-next-xpath-segment">
		<xsl:param name="xpath"/>
		<xsl:param name="namespace"/>
		<xsl:param name="consumed"/>
		<xsl:if test="$consumed ne $xpath">
			<xsl:variable name="is-root-xpath" select="starts-with($xpath, '/')"/>
			<xsl:variable name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
			<xsl:variable name="xpath-segments"
				select="tokenize(if ($is-root-xpath) then substring($xpath,2) else $xpath, '/')"/>
			<xsl:variable name="consumed-segments"
				select="tokenize(if (starts-with($consumed, '/')) then substring($consumed,2) else $consumed, '/')"/>
			<xsl:variable name="segment" select="$xpath-segments[count($consumed-segments)+1]"/>
			<xsl:variable name="segment-xpath" select="concat($consumed, if($consumed='' and not($is-root-xpath)) then '' else '/', $segment)"/>

			<!-- output this segment with link -->
			<xsl:if test="not($consumed='' and not($is-root-xpath))">/</xsl:if>
			<xsl:choose>
				<xsl:when test="esf:target-exists($segment-xpath, 'xml-element-name', $namespace)">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="$segment-xpath"/>
						<xsl:with-param name="type" select="'xml-element-name'"/>
						<!-- FIXME: Should use parent element's subject namespace rather than current element subject namespace. -->
						<xsl:with-param name="namespace" select="$namespace"/>
						<xsl:with-param name="content" select="$segment"/>
						<xsl:with-param name="current-page-name" select="$current-page-name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:unresolved">
						<xsl:with-param name="message"
							select="concat('No content to link to on xml-element-name &quot;', $segment-xpath, '&quot;')"/>
						<xsl:with-param name="in" select="$current-page-name"/>
					</xsl:call-template>
					<xsl:value-of select="$xpath"/>
				</xsl:otherwise>
			</xsl:choose>

			<!-- recursive call -->
			<xsl:call-template name="lf:link-next-xpath-segment">
				<xsl:with-param name="xpath" select="$xpath"/>
				<xsl:with-param name="namespace" select="$namespace"/>
				<xsl:with-param name="consumed"
					select="$segment-xpath"
				/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


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
			<xsl:when test="count($targets[xpaths/xpath = $target]) > 1">
				<xsl:call-template name="sf:warning">
					<xsl:with-param name="message" select="'Ambiguous xpath ', $target"/>
				</xsl:call-template>
				<!-- output plain text -->
				<xsl:value-of select="$link-text"/>
			</xsl:when>
			<xsl:when test="not($targets[xpaths/xpath = $target])">
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
				then translate(substring-before($targets[xpaths/xpath = $target]/parent::ss:topic/@local-name, '/@'), '/:', '__' )
				else translate($targets[xpaths/xpath = $target]/parent::ss:topic/@local-name, '/:', '__' )"/>
					<xsl:text>.html</xsl:text>
					<xsl:if test="contains($target, '/@')">
						<xsl:text>#</xsl:text>
						<xsl:value-of select="substring-after($target, '/@')"/>
					</xsl:if>
				</xsl:variable>

				<pe:link href="{$href}" title="Link to: {$target}">
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


	<!-- doctype-reference-entry -->
	<xsl:template match="doctype-reference-entry">
		<xsl:variable name="name" select="name"/>
		<xsl:variable name="namespace" select="xml-namespace"/>
		<xsl:variable name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
		<xsl:variable name="this" select="."/>
		<xsl:variable name="one-possible-xpath" select="concat(parents/parent[1], '/', name)"/>
		<xsl:if test="$namespace = ''"> </xsl:if>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="../../*/doctype-reference-entry[name=$name][not(. is $this)]">
				<pe:ambiguities>
					<xsl:for-each
						select="../../*/doctype-reference-entry[name=$name][not(. is $this)]">
						<pe:ambiguity>
							<xsl:call-template name="output-link">
								<xsl:with-param name="target" select="parent::ss:topic/@full-name"/>
								<xsl:with-param name="type" select="'topic'"/>
								<xsl:with-param name="namespace" select="$namespace"/>
								<xsl:with-param name="content" select="string(name)"/>
								<xsl:with-param name="current-page-name" select="$current-page-name"
								/>
							</xsl:call-template>
						</pe:ambiguity>
					</xsl:for-each>
				</pe:ambiguities>
			</xsl:if>
			<xsl:apply-templates>
				<xsl:with-param name="namespace" select="$namespace" tunnel="yes"/>
				<xsl:with-param name="one-possible-xpsth" select="$one-possible-xpath" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="parents/parent">
		<xsl:param name="namespace" tunnel="yes"/>
		<xsl:copy>
			<xsl:call-template name="lf:link-xpath-segments">
				<xsl:with-param name="xpath" select="."/>
				<xsl:with-param name="namespace" select="$namespace"/>
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="children/child">
		<xsl:param name="namespace" tunnel="yes"/>
		<xsl:param name="one-possible-xpath" tunnel="yes"/>
		<xsl:variable name="child-name" select="./text()"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="@child-namespace ne $namespace">
					<!-- We don't know if the child element is a root or not in the foreign namespace, so try both. -->
					<xsl:variable name="unprefixed-child-name"
						select="local-name-from-QName(QName (@child-namespace, $child-name))"/>
					<xsl:variable name="unprefixed-child-name-as-root"
						select="concat('/',$child-name)"/>
					<xsl:choose>

						<xsl:when
							test="esf:target-exists($unprefixed-child-name-as-root, 'xml-element-name')">
							<xsl:call-template name="output-link">
								<xsl:with-param name="target"
									select="$unprefixed-child-name-as-root"/>
								<xsl:with-param name="type" select="'xml-element-name'"/>
								<xsl:with-param name="namespace" select="@child-namespace"/>
								<xsl:with-param name="content" select="$child-name"/>
								<xsl:with-param name="current-page-name"
									select="ancestor-or-self::ss:topic/@full-name"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when
							test="esf:target-exists($unprefixed-child-name, 'xml-element-name')">
							<xsl:call-template name="output-link">
								<xsl:with-param name="target" select="$unprefixed-child-name"/>
								<xsl:with-param name="type" select="'xml-element-name'"/>
								<xsl:with-param name="namespace" select="@child-namespace"/>
								<xsl:with-param name="content" select="$child-name"/>
								<xsl:with-param name="current-page-name"
									select="ancestor-or-self::ss:topic/@full-name"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="sf:unresolved">
								<xsl:with-param name="message"
									select="concat('No content to link to for xml-element-name &quot;', $child-name, '&quot;')"/>
								<xsl:with-param name="in" select="ancestor::ss:topic/@full-name"/>
							</xsl:call-template>
							<xsl:value-of select="$child-name"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="child-xpath"
						select="concat($one-possible-xpath,'/',$child-name)"/>
					<!-- FIXME: This is silly. could just be $child-xpath, $child-xpath. but is it doing the right thing? -->
					<!--<xsl:sequence
											select="lf:link-xpath(concat($one-possible-xpath,'/',$child-name),$child-name)"/>-->
					<xsl:choose>
						<xsl:when
							test="esf:target-exists($child-xpath, 'xml-element-name', @child-namespace)">
							<xsl:call-template name="output-link">
								<xsl:with-param name="target" select="$child-xpath"/>
								<xsl:with-param name="type" select="'xml-element-name'"/>
								<xsl:with-param name="namespace" select="@child-namespace"/>
								<xsl:with-param name="content" select="$child-name"/>
								<xsl:with-param name="current-page-name"
									select="ancestor-or-self::ss:topic/@full-name"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="sf:unresolved">
								<xsl:with-param name="message"
									select="concat('No content to link to on xml-element-name &quot;', $child-name, '&quot;')"/>
								<xsl:with-param name="in" select="ancestor::ss:topic/@full-name"/>
							</xsl:call-template>
							<xsl:value-of select="$child-name"/>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
