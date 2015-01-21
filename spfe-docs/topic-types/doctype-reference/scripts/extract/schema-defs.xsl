<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" exclude-result-prefixes="#all">


	<!-- =============================================================
	schema-defs.xsl
	
	Reads a schema and pulls out the elements, attributes, and simple types 
	Elements and attributes defined in included schemas are read.
	 
	This stylesheet creates a full xpath to every possible combination of elements and 
	attributes. That is, it unfolds all types and references. An element or attribute that is 
	defined once and used many times will appear as a separate element or attribute here,
	distinguished from other instances by the full xpath of the place it is used. In other words,
	the output of this stylesheet lists every context in which each element and attribute can
	possibly occur. For simpleTypes, it just dumps the definitions.
	 
	 Note that it has been tested against all the known schema mechanisms used in the SPFE
	schemas to date, but has not been verified to work with all possible schema mechnanisms.
	  
	 The output of this stylesheet is a simple dump of elements, attributes and types. Nothing
	 is sorted, and elements and attributes are mixed in together in the order they were found.
	 It is up to the next stage of the process to group stuff in an appropriate fashion.
	 
	 The basic approach here is to define a variable "path-so-far" at the root and pass it up as 
	 a parameter to every template. Each template adds to this and passes it on. Natural 
	 recursion of XSLT takes care of the rest. Path is written out for each element and
	attribute encountered.
===============================================================-->

	<xsl:param name="topic-set-id"/>
	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="config" as="element(config:config)">
		<xsl:sequence select="/config:config"/>
	</xsl:variable>

	<xsl:variable name="xsd-prefix">
		<xsl:variable name="prefix-string"
			select="/xs:schema/name(namespace::*[.='http://www.w3.org/2001/XMLSchema'])"/>
		<xsl:if test="string-length($prefix-string) > 0">
			<xsl:value-of select="$prefix-string"/>
			<xsl:text>:</xsl:text>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="target-prefix">
		<xsl:variable name="target-ns" select="/xs:schema/@targetNamespace"/>
		<xsl:variable name="prefix-string" select="/xs:schema/name(namespace::*[.=$target-ns])"/>
		<xsl:if test="string-length($prefix-string) > 0">
			<xsl:value-of select="$prefix-string"/>
			<xsl:text>:</xsl:text>
		</xsl:if>
	</xsl:variable>

	<xsl:param name="sources-to-extract-content-from"/>
	<xsl:variable name="schema" select="sf:get-sources($sources-to-extract-content-from)"/>

	<xsl:variable name="combined-schemas">
		<xsl:apply-templates select="$schema" mode="combine-schemas"/>
	</xsl:variable>


	<xsl:template match="xs:include" mode="combine-schemas">
		<xsl:if test="not(doc-available(resolve-uri(@schemaLocation,base-uri(.))))">
			
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">
					<xsl:text>Unable to load included schema when extracting schema defs. Include @schemaLocation is: </xsl:text>
					<xsl:value-of select="@schemaLocation"/>
					<xsl:text>.</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="in" select="base-uri()"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="document(@schemaLocation)" mode="combine-schemas"/>
	</xsl:template>

	<xsl:template match="xs:*" mode="combine-schemas" priority="-1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="combine-schemas"/>
		</xsl:copy>
	</xsl:template>

	<xsl:variable name="all-paths">
		<!-- trace the definition of every element and attribute -->
		<!-- trace each root element definition... -->
		<xsl:for-each select="$combined-schemas//xs:schema/xs:element">
			<xsl:variable name="element-name" select="@name"/>
			<xsl:variable name="isp" select="in-scope-prefixes(/xs:schema)"/>
			<xsl:variable name="namespace-prefix">
				<xsl:variable name="schema-element" select="/xs:schema"/>
				<xsl:for-each select="$isp">
					<xsl:if
						test="namespace-uri-for-prefix(., $schema-element )=$schema-element/@targetNamespace">
						<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<!-- ...unless it is invoked by a reference in another element. -->
			<xsl:if
				test="not($combined-schemas//xs:schema/xs:element[@ref=concat($namespace-prefix, ':', $element-name)])">
				<xsl:apply-templates select=".">
					<xsl:with-param name="path-so-far"/>
				</xsl:apply-templates>
				<xsl:text>&#xA;&#xA;</xsl:text>
			</xsl:if>
		</xsl:for-each>

		<!-- get the definitions of all the types that are defined -->
		<xsl:call-template name="get-type-definitions"/>

		<!-- get the names of all the base types that are used -->
		<xsl:call-template name="get-base-type-references"/>
	</xsl:variable>

	<xsl:variable name="consolidated-paths">
		<xsl:for-each-group select="$all-paths/schema-element" group-by="concat(name,'+', xml-namespace, '+', type)">
			<xsl:copy>
				<xsl:copy-of select="name"/>
				<xsl:for-each-group select="current-group()" group-by="parent">
					<xsl:copy-of select="parent"/>
				</xsl:for-each-group>
				<xsl:for-each-group select="current-group()" group-by="xpath">
					<xsl:copy-of select="xpath"/>
				</xsl:for-each-group>
				<xsl:for-each-group select="belongs-to-group" group-by="text()">
					<xsl:copy-of select="."/>
				</xsl:for-each-group>
				<xsl:copy-of select="xml-namespace"/>
				<xsl:copy-of select="type"/>
				<xsl:copy-of select="minOccurs"/>
				<xsl:copy-of select="maxOccurs"/>
				<xsl:copy-of select="schema-documentation"/>
			</xsl:copy>
		</xsl:for-each-group>
		<xsl:for-each-group select="$all-paths/schema-group-ref" group-by="concat(referenced-group, '+', xml-namespace)">
			<xsl:copy>
				<xsl:copy-of select="referenced-group"/>
				<xsl:copy-of select="xml-namespace"/>
				<xsl:copy-of select="path-so-far"></xsl:copy-of>
				<xsl:for-each-group select="current-group()" group-by="referenced-in-xpath">
					<xsl:copy-of select="referenced-in-xpath"/>
				</xsl:for-each-group>
				<xsl:for-each-group select="current-group()" group-by="referenced-in-group">
					<xsl:copy-of select="referenced-in-group"/>
				</xsl:for-each-group>
			</xsl:copy>
		</xsl:for-each-group>
		<xsl:for-each-group select="$all-paths/schema-group" group-by="concat(name, '+', xml-namespace)">
			<xsl:sequence select="."/>
		</xsl:for-each-group>
		<xsl:for-each-group select="$all-paths/schema-sequence" group-by="concat(parent, '+', xml-namespace)">
			<xsl:sequence select="."/>
		</xsl:for-each-group>
		<xsl:for-each-group select="$all-paths/schema-choice" group-by="concat(parent, '+', xml-namespace)">
			<xsl:sequence select="."/>
		</xsl:for-each-group>
		<xsl:for-each-group select="$all-paths/schema-all" group-by="concat(parent, '+', xml-namespace)">
			<xsl:sequence select="."/>
		</xsl:for-each-group>
		<xsl:for-each-group select="$all-paths/schema-attribute" group-by="concat(xpath, '+', xml-namespace)">
			<xsl:sequence select="."/>
		</xsl:for-each-group>
	</xsl:variable>

	<xsl:template name="main">

		<!-- Create the root "extracted-content element" -->
		<xsl:result-document
			href="file:///{concat($config/config:content-set-build, '/topic-sets/', $topic-set-id, '/extract/out/schema-defs.xml')}"
			method="xml" indent="yes" omit-xml-declaration="no">

			<schema-definitions>
				<xsl:sequence select="$consolidated-paths"/>
			</schema-definitions>

		</xsl:result-document>
	</xsl:template>

	<xsl:template match="xs:schema">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:function name="sf:get-parents" as="xs:string*">
		<xsl:param name="segments" as="xs:string*"/>
		<xsl:param name="parent-prefix" as="xs:string"/>
		<xsl:if test="starts-with($segments[last()], $parent-prefix)">
			<xsl:value-of select="substring-after($segments[last()], $parent-prefix)"/> 
			<xsl:value-of select="sf:get-parents($segments[position() ne last()], $parent-prefix)"/>
		</xsl:if>
	</xsl:function>

	<!-- element definitions that have types -->
	<!-- FIXME: This will not detect that no type is the same as xs:string -->
	<xsl:template match="xs:element">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:variable name="type" select="@type"/>
		<xsl:variable name="name" select="@name"/>
<!--		<xsl:variable name="namespace" select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
-->		<xsl:variable name="namespace" select="/xs:schema/@target-namespace"/>
		
		<xsl:variable name="times-type-used" select="count($combined-schemas//xs:element[(@type = $type) and (@name = $name)])"/>
		<xsl:variable name="psf" select="concat($path-so-far, '/', $name)"/>
		<xsl:variable name="parent-group" select="substring-after(tokenize($path-so-far, '/')[last()], 'group#')"/>
		<xsl:variable name="group-times-used" select="count($combined-schemas//xs:group[@ref = $parent-group])"/>
		<xsl:variable name="group-set" select="sf:get-parents(tokenize($path-so-far, '/'), 'group#')"/>
		<xsl:variable name="group-set-times-used" select="for $i in $group-set return count($combined-schemas//xs:group[@ref = normalize-space($i)])"/>
		
		<!-- Need to detect the parent type, and see how often it is used, including as an extension base. -->
		<!-- It an element is the child of the same parent type, we treat it as the same element, even if it has a different parent -->
			
		<!-- OR is this much simpler and we just treat every element with the same name as the same element? But in that case,
		what happens to the parent calculation? Is it just immediate parents, which you then have to trace back if you 
		want the structure? -->	
			
		<xsl:variable name="path-to-record" select="concat($path-to-record, '/', $name)"/>
		<xsl:call-template name="element-info">
			<xsl:with-param name="path-to-record" select="$path-to-record"/>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
			<xsl:with-param name="namespace" select="$namespace"/>
		</xsl:call-template>
		<xsl:variable name="type" select="substring-after(@type, $target-prefix)"/>
		<xsl:choose>
			<xsl:when test="not(@type)">
				<xsl:apply-templates>
					<xsl:with-param name="path-so-far" select="$psf"/>
					<xsl:with-param name="path-to-record" select="$path-to-record"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- deal with recursively defined elements -->

			<xsl:when test="not(tokenize($path-so-far, '/') = @name)">
				<xsl:apply-templates select="$combined-schemas//xs:complexType[@name=$type]">
					<xsl:with-param name="path-so-far" select="$psf"/>
					<xsl:with-param name="path-to-record" select="$path-to-record"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:otherwise>
				<!-- this is a recursive definition, so grab the attributes but don't keep recursing. -->
				<xsl:apply-templates
					select="$combined-schemas//xs:complexType[@name=$type]/xs:attribute">
					<xsl:with-param name="path-so-far" select="$psf"/>
					<xsl:with-param name="path-to-record" select="$path-to-record"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- element definitions that have references -->
	<xsl:template match="xs:element[@ref]">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:variable name="ref" select="substring-after(@ref,$target-prefix)"/>
		<xsl:variable name="referenced-element">
			<xsl:apply-templates select="$combined-schemas//xs:schema/xs:element[@name=$ref]">
				<xsl:with-param name="path-so-far" select="$path-so-far"/>
				<xsl:with-param name="path-to-record" select="$path-to-record"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="namespace" select="namespace-uri-for-prefix(substring-before(@ref, ':'), .)"/>
		<xsl:variable name="namespace-of-root" select="namespace-uri-for-prefix(substring-before(/*, ':'), .)"/>
		<xsl:if test="$namespace-of-root eq $namespace">
			<xsl:choose>
				<xsl:when test="$referenced-element > ''">
					<xsl:copy-of select="$referenced-element"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="element-name" select="concat($path-to-record, '/', @ref)"/>
					<schema-element doc-element="false">
						<xpath>
							<xsl:value-of select="$element-name"/>
						</xpath>
						<name>
							<xsl:value-of select="@ref"/>
						</name>
						<xml-namespace>
							<xsl:value-of select="$namespace"/>
						</xml-namespace>
					</schema-element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- attribute definitions that have references -->
	<xsl:template match="xs:attribute[@ref]">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:variable name="ref" select="substring-after(@ref,$target-prefix)"/>
		<xsl:variable name="referenced-attribute">
			<xsl:apply-templates select="$combined-schemas//xs:schema/xs:attribute[@name=$ref]">
				<xsl:with-param name="path-so-far" select="$path-so-far"/>
				<xsl:with-param name="path-to-record" select="$path-to-record"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$referenced-attribute > ''">
				<xsl:copy-of select="$referenced-attribute"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="attribute-name" select="concat($path-so-far, '/', @ref)"/>
				<schema-attribute>
					<xpath>
						<xsl:value-of select="$attribute-name"/>
					</xpath>
					<name>
						<xsl:value-of select="@ref"/>
					</name>
				</schema-attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- group definitions that have references -->
	<xsl:template match="xs:group[@ref]">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:variable name="ref" select="substring-after(@ref,$target-prefix)"/>
		<xsl:variable name="path-segments" select="tokenize($path-so-far, '/')"/>
		<schema-group-ref>
			<referenced-group>
				<xsl:value-of select="@ref"/>
			</referenced-group>
			<xml-namespace>
				<xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
			</xml-namespace>
			<path-so-far><xsl:value-of select="$path-so-far"/></path-so-far>
			<xsl:choose>

				<xsl:when
					test="starts-with($path-so-far, 'group#') and not(contains($path-so-far, '/'))">
					<referenced-in-group>
						<xsl:value-of select="substring-after($path-so-far, 'group#')"/>
					</referenced-in-group>
				</xsl:when>

				<xsl:when test="starts-with($path-segments[last()], 'group#')">
						<referenced-in-group>
							<xsl:value-of
								select="substring-after($path-segments[last()], 'group#')"/>
						</referenced-in-group>
				</xsl:when>

				<xsl:otherwise>
					<referenced-in-xpath>
						<xsl:value-of select="$path-so-far"/>
					</referenced-in-xpath>
				</xsl:otherwise>
			</xsl:choose>
		</schema-group-ref>
		<xsl:apply-templates select="$combined-schemas//xs:schema/xs:group[@name=$ref]">
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
			<xsl:with-param name="path-to-record" select="$path-to-record"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="xs:group">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<schema-group>
			<name>
				<xsl:value-of select="@name"/>
			</name>
			<xml-namespace>
				<xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
			</xml-namespace>
		</schema-group>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="concat($path-so-far, '/group#',@name)"/>
			<xsl:with-param name="path-to-record" select="$path-to-record"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- complexType definition -->
	<xsl:template match="xs:complexType[@name]">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:variable name="name" select="@name"/>
		<xsl:variable name="times-used" select="count($combined-schemas//xs:element[@type = $name]) 
			+ count($combined-schemas//xs:extension[@base = $name])"/>
		<xsl:variable name="extending" select="substring-after(tokenize($path-so-far, '/')[last()], 'extending#')"/>
	
		<!-- guard against recusion -->
		<xsl:if test="not(tokenize($path-so-far, '/') = concat('complexType#',@name))">
			<xsl:choose>
				<!-- If the type is only used once, ignore and treat element as if defined inline. -->
				<xsl:when test="$times-used gt 1">
					<xsl:apply-templates>
						<xsl:with-param name="path-so-far"
							select="concat($path-so-far,'/complexType#',@name)"/>
						<xsl:with-param name="path-to-record" select="$path-to-record"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="path-so-far"
							select="$path-so-far"/>
						<xsl:with-param name="path-to-record" select="$path-to-record"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- complexType definition - just call apply-templates to pick up definitions -->
	<xsl:template match="xs:complexType">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
			<xsl:with-param name="path-to-record" select="$path-to-record"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- extensions - get base, then extension -->
	<xsl:template match="xs:extension[@base]">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:variable name="base" select="@base"/>
		
		<xsl:choose>
			<!-- deal with recursively defined elements -->	
			<xsl:when test="not(tokenize($path-so-far, '/') = @base)">
				<xsl:apply-templates select="$combined-schemas//xs:complexType[@name=$base]">
					<xsl:with-param name="path-so-far" select="concat($path-so-far, '/extending#', @base)"/>
					<xsl:with-param name="path-to-record" select="$path-to-record"/>
				</xsl:apply-templates>
				<!-- get the extension -->
				<xsl:apply-templates>
					<xsl:with-param name="path-so-far" select="$path-so-far"/>
					<xsl:with-param name="path-to-record" select="$path-to-record"/>
				</xsl:apply-templates>
			</xsl:when>
			
			<xsl:otherwise>
				<!-- this is a recursive definition, so grab the attributes but don't keep recursing. -->
				<xsl:apply-templates
					select="$combined-schemas//xs:complexType[@name=$base]/xs:attribute">
					<xsl:with-param name="path-so-far" select="$path-so-far"/>
					<xsl:with-param name="path-to-record" select="$path-to-record"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xs:sequence">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<schema-sequence>
			<xsl:copy-of select="@*"/>
			<parent>
				<xsl:value-of select="$path-to-record"/>
			</parent>
			<xml-namespace>
				<xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
			</xml-namespace>
			<xsl:for-each select="child::*">
				<child child-type="{name()}" 
					child-namespace="{namespace-uri-for-prefix(substring-before(if (@name) then @name else @ref, ':'), .)}">
					<xsl:copy-of select="@*"/>
					<xsl:value-of select="if (@name) then @name else @ref"/>
				</child>
			</xsl:for-each>
		</schema-sequence>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
			<xsl:with-param name="path-to-record" select="$path-to-record"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="xs:choice">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<schema-choice>
			<xsl:copy-of select="@*"/>
			<parent>
				<xsl:value-of select="$path-to-record"/>
			</parent>
			<xml-namespace>
				<xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
			</xml-namespace>
			<xsl:for-each select="child::*">
				<child child-type="{name()}" child-namespace="{namespace-uri-for-prefix(substring-before(if (@name) then @name else @ref, ':'), .)}">
					<xsl:copy-of select="@*"/>
					<xsl:value-of select="if (@name) then @name else @ref"/>
				</child>
			</xsl:for-each>
		</schema-choice>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
			<xsl:with-param name="path-to-record" select="$path-to-record"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="xs:all">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<schema-all>
			<xsl:copy-of select="@*"/>
			<parent>
				<xsl:value-of select="$path-to-record"/>
			</parent>
			<xml-namespace>
				<xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
			</xml-namespace>
			<xsl:for-each select="child::*">
				<child child-type="{name()}" child-namespace="{namespace-uri-for-prefix(substring-before(if (@name) then @name else @ref, ':'), .)}">
					<xsl:copy-of select="@*"/>
					<xsl:value-of select="if (@name) then @name else @ref"/>
				</child>
			</xsl:for-each>
		</schema-all>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
			<xsl:with-param name="path-to-record" select="$path-to-record"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- attribute definition -->
	<xsl:template match="xs:attribute">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:variable name="xpath" select="concat($path-to-record, '/@', @name)"/>
		<!-- Normalize the type prefix -->
		<xsl:variable name="type">
			<xsl:choose>
				<!-- make default type explicit if not specified-->
				<xsl:when test="not(@type)">xs:string</xsl:when>

				<!-- normalize the xsd prefix to 'xs:' -->
				<xsl:when test="substring-before(@type, ':') eq $xsd-prefix">
					<xsl:value-of select="concat('xs:',(substring-after(@type, $xsd-prefix)))"/>
				</xsl:when>

				<!-- otherwise it is a locally defined type -->
				<xsl:otherwise>
					<xsl:value-of select="substring-after(@type, $target-prefix)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:text>&#xA;</xsl:text>
		<schema-attribute>
			<xml-namespace>
				<xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
			</xml-namespace>
			<parent>
				<xsl:value-of select="$path-to-record"/>
			</parent>
			<xsl:choose>
				<xsl:when test="starts-with($xpath, 'group#')">
					<xpath>
						<xsl:value-of select="replace($xpath, 'group#.*?/','')"/>
					</xpath>
				</xsl:when>
				<xsl:otherwise>
					<xpath>
						<xsl:value-of select="$xpath"/>
					</xpath>
				</xsl:otherwise>
			</xsl:choose>
			<name>
				<xsl:value-of select="@name"/>
			</name>
			<type>
				<xsl:value-of select="$type"/>
			</type>
			<use>
				<xsl:value-of select="@use"/>
			</use>
			<default>
				<xsl:value-of select="@default"/>
			</default>
			<fixed>
				<xsl:value-of select="@fixed"/>
			</fixed>
			<xsl:if test="xs:annotation/xs:documentation">
				<schema-documentation>
					<xsl:value-of select="xs:annotation/xs:documentation"/>
				</schema-documentation>
			</xsl:if>
		</schema-attribute>

	</xsl:template>

	<!-- display element information -->
	<xsl:template name="element-info">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:param name="namespace"/>
		<xsl:variable name="path-segments" select="tokenize($path-so-far, '/')"/>

		<schema-element doc-element="{if (parent::xs:schema) then 'true' else 'false'}">
			
			<xsl:if test="starts-with($path-segments[last()], 'group#')">
				<belongs-to-group>
					<xsl:value-of select="substring-after(., 'group#')"/>
				</belongs-to-group>	
			</xsl:if>

			<xsl:if test="starts-with($path-segments[last()], 'group#')">
				<xsl:variable name="group"
					select="substring-after($path-segments[last()], 'group#')"/>
				<belongs-to-group>
					<xsl:value-of select="$group"/>
				</belongs-to-group>	
			</xsl:if>
			
			<parent>
				<xsl:value-of select="string-join(tokenize($path-to-record, '/')[position() ne last()],'/')"/>
			</parent>
			
			<xpath>
				<xsl:value-of select="$path-to-record"/>
			</xpath>
			<name>
				<xsl:value-of select="@name"/>
			</name>
			<xml-namespace>
				<xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
			</xml-namespace>
			<type>
				<xsl:value-of select="substring-after(@type, $target-prefix)"/>
			</type>
			<xsl:if test="xs:annotation/xs:documentation">
				<schema-documentation>
					<xsl:value-of select="xs:annotation/xs:documentation"/>
				</schema-documentation>
			</xsl:if>
		</schema-element>
	</xsl:template>

	<xsl:template name="type-info">
		<schema-type>
			<xsl:choose>
				<!-- make default type explicit -->
				<xsl:when test="@name">
					<name>
						<xsl:value-of select="@name"/>
					</name>
				</xsl:when>
				<xsl:otherwise>
					<name>xs:string</name>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates mode="type"/>
		</schema-type>
	</xsl:template>

	<!-- catch all - must pass on path-so-far each time -->
	<xsl:template match="xs:*">
		<xsl:param name="path-so-far"/>
		<xsl:param name="path-to-record"/>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
			<xsl:with-param name="path-to-record" select="$path-to-record"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- ignore annotations - prevents extraneous text in output -->
	<xsl:template match="xs:annotation"/>

	<!-- "type" mode templates -->
	<xsl:template mode="type" match="xs:annotation/xs:documentation">
		<schema-documentation>
			<xsl:apply-templates mode="type"/>
		</schema-documentation>
	</xsl:template>

	<xsl:template mode="type" match="xs:restriction">
		<!-- Normalize the type prefix -->
		<xsl:variable name="base">
			<xsl:choose>
				<xsl:when test="starts-with(@base, $xsd-prefix)">
					<xsl:value-of select="concat('xs:',(substring-after(@base, $xsd-prefix)))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@base"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<based-on>
			<xsl:value-of select="$base"/>
		</based-on>
		<xsl:apply-templates mode="type"/>
		<xsl:if test="xs:enumeration">
			<enumeration>
				<xsl:for-each select="xs:enumeration">
					<value>
						<xsl:value-of select="@value"/>
					</value>
				</xsl:for-each>
			</enumeration>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="type" match="xs:pattern">
		<pattern>
			<xsl:value-of select="@value"/>
		</pattern>
	</xsl:template>

	<xsl:template mode="type" match="xs:union">
		<union>
			<xsl:apply-templates mode="type"/>
		</union>
	</xsl:template>

	<xsl:template mode="type" match="xs:simpleType">
		<base-type>
			<xsl:apply-templates mode="type"/>
		</base-type>
	</xsl:template>

	<xsl:template mode="type" match="xs:minLength">
		<minLength>
			<xsl:value-of select="value"/>
		</minLength>
	</xsl:template>

	<xsl:template mode="type" match="xs:maxLength">
		<maxLength>
			<xsl:value-of select="value"/>
		</maxLength>
	</xsl:template>

	<xsl:template mode="type" match="xs:minInclusive">
		<minInclusive>
			<xsl:value-of select="value"/>
		</minInclusive>
	</xsl:template>

	<xsl:template mode="type" match="xs:maxInclusive">
		<maxInclusive>
			<xsl:value-of select="value"/>
		</maxInclusive>
	</xsl:template>

	<xsl:template name="get-type-definitions">
		<!-- dump the definitions of every simpleType -->
		<xsl:for-each select="//xs:schema/xs:simpleType[@name]">
			<xsl:call-template name="type-info"/>
			<xsl:text>&#xA;</xsl:text>
			<xsl:text>&#xA;</xsl:text>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get-base-type-references">
		<!-- pick up built-in types used to define attributes -->
		<xsl:for-each select="//xs:attribute[substring-before(@type, ':') eq $xsd-prefix]">
			<schema-type>
				<name>
					<xsl:choose>
						<!-- make the default explicit -->
						<xsl:when test="not(@type)">xs:string</xsl:when>
						<!-- Normalize the XSD prefix to 'xs:'. -->
						<xsl:otherwise>
							<xsl:value-of select="concat('xs:',substring-after(@type, $xsd-prefix))"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</name>
			</schema-type>
			<xsl:text>&#xA;</xsl:text>
			<xsl:text>&#xA;</xsl:text>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
