<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<!-- ===================================================
	merge-doctype-ref.xsl
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:ed="http://spfeopentoolkit.org/ns/spfe-docs"
	xmlns:cr="http://spfeopentoolkit.org/ns/spfe-docs" exclude-result-prefixes="#all">

	<xsl:param name="topic-set-id"/>

	<xsl:variable name="strings"
		select="
		$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:strings/config:string, 
		$config/config:content-set/config:strings/config:string"
		as="element()*"/>

	<xsl:output method="xml" indent="yes"/>

	<xsl:param name="output-directory"/>

	<xsl:param name="extracted-content-files"/>
	<xsl:variable name="schema-defs" select="sf:get-sources($extracted-content-files)"/>

	<xsl:param name="authored-content-files"/>
	<xsl:variable name="doctype-source" select="sf:get-sources($authored-content-files)"/>

	<xsl:variable name="config" as="element(config:config)">
		<xsl:sequence select="/config:config"/>
	</xsl:variable>

	<!-- Build a list of doctype xpaths 
     Note: This supposes that the doctype names are unique across all 
		 schemas in the set (which they *should* be).-->
	<xsl:variable name="doctypes">
		<xsl:for-each select="$schema-defs/schema-definitions/schema-element[@doc-element='true']">
			<xsl:sort select="string-length(xpath)" order="descending"/>
			<doctype name="{name}" xpath="{xpath}"/>
		</xsl:for-each>
	</xsl:variable>

	<!-- 
=============
Main template
=============
-->

	<xsl:template name="main">
		<xsl:result-document method="xml" indent="yes" omit-xml-declaration="no"
			href="file:///{$output-directory}/merge.xml">
			<cr:doctype-reference-entries>
				<xsl:apply-templates select="$schema-defs/schema-definitions/schema-element">
					<xsl:with-param name="source"
						select="$doctype-source//ed:doctype-element-description"/>
					<xsl:with-param name="in-scope-strings" select="$strings" as="element()*"
						tunnel="yes"/>
				</xsl:apply-templates>
			</cr:doctype-reference-entries>
		</xsl:result-document>
		<!-- Warn if there are any unmatched topics in the authored content. -->
		<!-- FIXME: Should also search for unmatched attribute definitions. -->
		<xsl:for-each select="$doctype-source//ed:doctype-element-description">
			<xsl:if
				test="not(normalize-space(ed:xpath) = $schema-defs/schema-definitions/schema-element/normalize-space(name))">
				<xsl:call-template name="sf:warning">
					<xsl:with-param name="message"
						select="'Authored element description found for an element not found in the schema:', normalize-space(ed:xpath)"
					/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- 
=================================
Main content processing templates
=================================
-->

	<!-- Schema element template -->
	<xsl:template match="schema-element">
		<xsl:param name="source"/>
		<xsl:variable name="this-element" select="."/>
		<xsl:variable name="xpath" select="xpath"/>
		<xsl:variable name="group" select="belongs-to-group"/>
		<xsl:variable name="name" select="name"/>
		<!-- determine the doctype by comparing the xpath of this element to the 
			 xpath of each of the document root elements -->
		<xsl:variable name="doctype"
			select="$doctypes/doctype[starts-with($xpath[1], @xpath)][1]/@name"/>

		<xsl:variable name="topic-type-alias"
			select="sf:get-topic-type-alias-singular($topic-set-id, '{http://spfeopentoolkit.org/ns/spfe-docs}doctype-reference-entry', $config)"/>
		

		<xsl:choose>
			<!-- content file contains entry matching by name alone -->
			<xsl:when test="count($source[normalize-space(ed:name)=$name]) le 1">
				<xsl:call-template name="doctype-reference-entry">
					<xsl:with-param name="this-element" select="$this-element"/>
					<xsl:with-param name="source" select="$source"/>
				</xsl:call-template>
			</xsl:when>
			<!-- content file contains entries matching by full or partial xpath -->
			<xsl:otherwise>
				<xsl:for-each select="$source[normalize-space(ed:name)=$name]/ed:parent">
					<xsl:variable name="p" select="normalize-space(.)"/>
					<xsl:if test="$this-element/parent[ends-with(.,$p)]">
						<xsl:call-template name="doctype-reference-entry">
							<xsl:with-param name="parent" select="$p"/>
							<xsl:with-param name="this-element" select="$this-element"/>
							<xsl:with-param name="source" select="$source"/>
						</xsl:call-template>
					</xsl:if>
					<!-- Need to check for not matched parents -->
					<!-- Need to check for parents matched more than once -->
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="doctype-reference-entry">
		<xsl:param name="parent"/>
		<xsl:param name="source"/>
		<xsl:param name="this-element"/>
		<xsl:variable name="xpath" select="$this-element/xpath"/>
		<xsl:variable name="group" select="$this-element/belongs-to-group"/>
		<xsl:variable name="name" select="$this-element/name"/>
		
		<!-- determine the doctype by comparing the xpath of this element to the 
			 xpath of each of the document root elements -->
		<xsl:variable name="doctype"
			select="$doctypes/doctype[starts-with($xpath[1], @xpath)][1]/@name"/>		
		
		<cr:doctype-reference-entry>

			<cr:name>
				<xsl:value-of select="$this-element/name"/>
			</cr:name>
			<cr:type>
				<xsl:value-of select="$this-element/type"/>
			</cr:type>
			<cr:xml-namespace>
				<xsl:value-of select="$this-element/xml-namespace"/>
			</cr:xml-namespace>
			<cr:doctype>
				<xsl:value-of select="$doctype"/>
			</cr:doctype>
			
			<cr:parents>
				<xsl:for-each
					select="if (normalize-space($parent)) then $this-element/parent[ends-with(.,$parent)] else $this-element/parent">
					<cr:parent>
						<xsl:value-of select="."/>
					</cr:parent>
				</xsl:for-each>
			</cr:parents>
<!--			<cr:xpaths>
				<xsl:for-each select="$this-element/xpath">
					<cr:xpath><xsl:apply-templates/></cr:xpath>
				</xsl:for-each>
			</cr:xpaths>-->
			<cr:group>
				<xsl:value-of select="$group"/>
			</cr:group>
			<cr:use>
				<xsl:value-of select="$this-element/use"/>
			</cr:use>
			<cr:default>
				<xsl:value-of select="$this-element/default"/>
			</cr:default>
			<!-- Select and copy the authored element info. -->
	
			<xsl:variable name="authored-content">
				<xsl:choose>
					<xsl:when test="normalize-space($parent)">
						<xsl:sequence select="$source[normalize-space(ed:name)=$name][ed:parent=$parent]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$source[normalize-space(ed:name)=$name]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:copy-of select=" $authored-content"/>
			<xsl:choose>
				<xsl:when test="$authored-content[2]">
					<xsl:call-template name="sf:error">
						<xsl:with-param name="message"
							select="'Duplicate doctype element description found for setting ', $name"
						/> 
					</xsl:call-template>
				</xsl:when>
				<!-- Test that the information exists. -->
				<xsl:when test="exists($authored-content/ed:doctype-element-description/ed:description/*)">
					<xsl:apply-templates select="$authored-content/ed:doctype-element-description/ed:description">
						<xsl:with-param name="in-scope-strings" select="$strings" as="element()*"
							tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:when>
				
				<xsl:otherwise>
					<!-- If not found, report unresolved. -->
					<xsl:call-template name="sf:unresolved">
						<xsl:with-param name="message"
							select="'Doctype element description not found ', string($name)"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			
	
			<xsl:variable name="children">
				<xsl:for-each-group 
					select="$schema-defs//schema-sequence[parent = $xpath]/child, //schema-choice[parent = $xpath]/child, //schema-all[parent = $xpath]/child"
					group-by="text()">
					<xsl:if test="@child-type='xs:group'">
						<xsl:variable name="group-name" select="current-grouping-key()"/>
						<xsl:for-each-group select="$schema-defs//schema-element[belongs-to-group = $group-name]" group-by="name">
							<cr:child child-namespace="{xml-namespace}">
								<xsl:value-of select="name"/>
							</cr:child>
						</xsl:for-each-group>
						<xsl:call-template name="get-nested-groups">
							<xsl:with-param name="referenced-group" select="$group-name"/>
						</xsl:call-template>					
					</xsl:if>
					
					<xsl:if test="@child-type='xs:element'" >
						<xsl:variable name="child" select="current-grouping-key()"/>
						<cr:child child-namespace="{@child-namespace}">
							<xsl:value-of select="$child"/>
						</cr:child>	
					</xsl:if>
				</xsl:for-each-group>
			</xsl:variable>
			<cr:children>
				<xsl:for-each-group select="$children" group-by="cr:child">
					<xsl:copy-of select="cr:child[text() eq current-grouping-key()][1]"/>
				</xsl:for-each-group>
			</cr:children>
			<cr:attributes>
				<xsl:for-each
					select="$schema-defs//schema-attribute[starts-with(xpath, concat($xpath[1], '/@'))]">
					<cr:attribute>
						
						<!-- Copy the extracted element info. -->
						<cr:name>
							<xsl:value-of select="name"/>
						</cr:name>
						<cr:xpath>
							<xsl:value-of select="xpath"/>
						</cr:xpath>
						<cr:type>
							<xsl:value-of select="type"/>
						</cr:type>
						<cr:use>
							<xsl:value-of select="use"/>
						</cr:use>
						<cr:default>
							<xsl:value-of select="default"/>
						</cr:default>
						<cr:minOccurs>
							<xsl:value-of select="minOccurs"/>
						</cr:minOccurs>
						<cr:maxOccurs>
							<xsl:value-of select="maxOccurs"/>
						</cr:maxOccurs>
						
						<xsl:variable name="attribute-name" select="name"/>
						
						<xsl:variable name="authored"
			       	select="$source[normalize-space(ed:name)=$name]/ed:attributes/ed:attribute[ed:name=$attribute-name]"/>
						<xsl:if test="not($authored/ed:description/*)">
							<xsl:call-template name="sf:unresolved">
								<xsl:with-param name="message"
									select="'Attribute description not found ', string(xpath)"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:apply-templates select="$authored/*">
							<xsl:with-param name="in-scope-strings" select="$strings"
								as="element()*" tunnel="yes"/>
						</xsl:apply-templates>
					</cr:attribute>
				</xsl:for-each>
			</cr:attributes>
		</cr:doctype-reference-entry>
		
	</xsl:template>

	<xsl:template match="ed:doctype-description">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="ed:*">
		<xsl:element name="cr:{local-name()}" namespace="http://spfeopentoolkit.org/ns/spfe-docs">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<!-- Suppress xpath from authored content as it duplicates xpath from extracted content. -->
	<xsl:template match="ed:xpath"/>

	<xsl:template name="get-group-children">
		<xsl:param name="xpath"/>
		<xsl:for-each select="/schema-definitions/schema-group-ref[referenced-in-xpath = $xpath]">
			<xsl:variable name="referenced-group" select="referenced-group"/>
			<!-- each element that is in the group and has only one step in its path (so not the children of the element at the group level -->
			<xsl:for-each-group
				select="/schema-definitions/schema-element[belongs-to-group = $referenced-group][not(contains(xpath, '/'))]"
				group-by="xpath">
				<cr:child child-namespace="{xml-namespace}">
					<xsl:value-of select="xpath"/>
				</cr:child>
			</xsl:for-each-group>
			<xsl:if test="count($referenced-group) gt 1">
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">
						<xsl:text>More than one referenced group found. This probably indicates an error in the schemas. Check schema validity and try again. </xsl:text>
						<xsl:text>The referenced groups found are: </xsl:text>
						<xsl:value-of select="$referenced-group"/>
					</xsl:with-param>
					<xsl:with-param name="in" select="base-uri(document(''))"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="get-nested-groups">
				<xsl:with-param name="referenced-group" select="$referenced-group"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get-nested-groups">
		<xsl:param name="referenced-group"/>
		<xsl:for-each
			select="/schema-definitions/schema-group-ref[referenced-in-group = $referenced-group]">
			<xsl:variable name="referenced-group" select="referenced-group"/>
			<!-- each element that is in the group and has only one step in its path (so not the children of the element at the group level -->
			<xsl:for-each-group
				select="/schema-definitions/schema-element[belongs-to-group = $referenced-group]"
				group-by="name">
				<cr:child child-namespace="{xml-namespace}">
					<xsl:value-of select="name"/>
				</cr:child>
			</xsl:for-each-group>
			<xsl:call-template name="get-nested-groups">
				<xsl:with-param name="referenced-group" select="$referenced-group"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<!-- prevent getting two copies of name one from source, one from authored content -->
	<xsl:template match="ed:attribute/ed:name"/>


</xsl:stylesheet>
