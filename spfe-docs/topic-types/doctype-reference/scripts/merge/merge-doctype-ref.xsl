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
		$config/config:topic-set[@topic-set-id=$topic-set-id]/config:strings/config:string, 
		$config/config:doc-set/config:strings/config:string"
		as="element()*"/>

	<xsl:output method="xml" indent="yes"/>

	<xsl:param name="output-directory"/>

	<xsl:param name="extracted-content-files"/>
	<xsl:variable name="schema-defs" select="sf:get-sources($extracted-content-files)"/>

	<xsl:param name="authored-content-files"/>
	<xsl:variable name="doctype-source" select="sf:get-sources($authored-content-files)"/>

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
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

				<!-- Use for-each-group to filter out duplicate xpaths FIXME: there may not be duplictes if we use names-->
				<xsl:for-each-group select="$schema-defs/schema-definitions/schema-element"
					group-by="name">
					<xsl:apply-templates select=".">
						<xsl:with-param name="source"
							select="$doctype-source//ed:doctype-element-description"/>
						<xsl:with-param name="in-scope-strings" select="$strings" as="element()*"
							tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
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
		<xsl:variable name="xpath" select="xpath"/>
		<xsl:variable name="group" select="belongs-to-group"/>
		<xsl:variable name="name" select="name"/>
		<!-- determine the doctype by comparing the xpath of this element to the 
			 xpath of each of the document root elements -->
		<xsl:variable name="doctype"
			select="$doctypes/doctype[starts-with($xpath[1], @xpath)][1]/@name"/>
		<!--		<xsl:variable name="doc-xpath"
			select=" if ($doctype) 
					 then concat('/',$doctype,  substring-after($xpath, $doctype))
					 else $xpath"/>-->

		<xsl:variable name="topic-type-alias"
			select="sf:get-topic-type-alias-singular('{http://spfeopentoolkit.org/ns/spfe-docs}doctype-reference-entry', $config)"/>

		<cr:doctype-reference-entry>
			<cr:subject-namespace>
				<xsl:value-of select="concat(xml-namespace, '#', if (normalize-space(parent[1])) then tokenize(parent[1],'/')[. ne ''][1] else $name)"/>
			</cr:subject-namespace>
			<cr:name>
				<xsl:value-of select="name"/>
			</cr:name>
			<cr:type>
				<xsl:value-of select="type"/>
			</cr:type>
			<cr:xml-namespace>
				<xsl:value-of select="xml-namespace"/>
			</cr:xml-namespace>
			<cr:doctype>
				<xsl:value-of select="$doctype"/>
			</cr:doctype>
			<xsl:choose>
				<xsl:when test="xpath = name">
					<cr:parents>
						<xsl:for-each
							select="$schema-defs//schema-sequence[child=$name], $schema-defs//schema-choice[child=$name], $schema-defs//schema-all[child=$name]">
							<cr:parent>
								<xsl:value-of select="parent"/>
							</cr:parent>
						</xsl:for-each>
					</cr:parents>
				</xsl:when>
				<xsl:otherwise>
					<cr:parents>
						<xsl:for-each select="$xpath">
						<cr:parent>
							<xsl:value-of select="string-join(tokenize(., '/')[position() ne last()],'/')"/>
						</cr:parent>
						</xsl:for-each>
					</cr:parents>
				</xsl:otherwise>
			</xsl:choose>
<!--			<cr:xpath>
				<xsl:value-of select="$xpath"/>
			</cr:xpath>-->
			<cr:group>
				<xsl:value-of select="$group"/>
			</cr:group>

			<cr:use>
				<xsl:value-of select="use"/>
			</cr:use>
			<cr:default>
				<xsl:value-of select="default"/>
			</cr:default>
			<!-- Select and copy the authored element info. -->
			<xsl:variable name="authored-content" select="$source[normalize-space(ed:xpath)=$name]"/>
			<xsl:choose>
				<xsl:when test="$authored-content[2]">
					<xsl:call-template name="sf:error">
						<xsl:with-param name="message"
							select="'Duplicate doctype element description found for setting ', $name"
						/> 
					</xsl:call-template>
				</xsl:when>
				<!-- Test that the information exists. -->

				<xsl:when test="exists($authored-content/ed:description/*)">
					<xsl:apply-templates
						select="$authored-content/ed:description, $authored-content/ed:values, $authored-content/ed:restrictions, $authored-content/ed:build-property">
						<xsl:with-param name="in-scope-strings" select="$strings" as="element()*"
							tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:when>

				<xsl:otherwise>
					<!-- If not found, report warning. -->
					<xsl:call-template name="sf:warning">
						<xsl:with-param name="message"
							select="'Doctype element description not found ', string($name)"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>


			<cr:model>
				<xsl:sequence
					select="$schema-defs//schema-sequence[parent = $xpath], //schema-choice[parent = $xpath], //schema-all[parent = $xpath]"
				/>
			</cr:model>
			
			<cr:children>
				<xsl:for-each select="$schema-defs//schema-element[parent = $xpath]">
					<cr:child child-namespace="{xml-namespace}"><xsl:value-of select="name"/></cr:child>
				</xsl:for-each>
			</cr:children>
		
<!-- This is unfinished, but attempts to determine if the child is required and how many times it may occur. -->		
<!--			<cr:children>
				<xsl:for-each-group 
					select="$schema-defs//schema-sequence[parent = $xpath], //schema-choice[parent = $xpath], //schema-all[parent = $xpath]"
					group-by="child">
					<xsl:for-each select="child[@child-type='xs:group']">
						<xsl:variable name="group-name" select="."/>
						<xsl:for-each-group select="$schema-defs//schema-element[belongs-to-group = $group-name]" group-by="name">
							<cr:child><xsl:value-of select="name"/></cr:child>
						</xsl:for-each-group>
						<xsl:call-template name="get-nested-groups">
							<xsl:with-param name="referenced-group" select="$group-name"/>
						</xsl:call-template>					
					</xsl:for-each>

					<xsl:for-each select="child[@child-type='xs:element']">
						<xsl:variable name="child" select="."/>
						<xsl:variable name="child-xpath" select="$child"/>
<!-\-						<xsl:variable name="child-xpath" select="concat($xpath, '/', $child)"/>
-\->						<xsl:variable name="required">
							<xsl:choose>
								<xsl:when test="parent::schema-choice">no</xsl:when>
								<xsl:when test="@minOccurs='0'">no</xsl:when>
								<xsl:otherwise>yes</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="count">
							<!-\- FIXME: cosider cases of schema-sequence and combinations of parent and child maxOccurs value -\->
							<xsl:choose>
								<xsl:when test="parent::schema-choice/@maxOccurs">
									<xsl:value-of select="parent::schema-choice/@maxOccurs"/>
								</xsl:when>
								<xsl:when test="parent::schema-all/@maxOccurs">
									<xsl:value-of select="parent::schema-all/@maxOccurs"/>
								</xsl:when>
								<xsl:when test="@maxOccurs">
									<xsl:value-of select="@maxOccurs"/>
								</xsl:when>
								<xsl:otherwise>1</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$schema-defs//schema-element[xpath = $child-xpath]">
								<cr:child required="{$required}" count="{$count}">
									<xsl:value-of select="$child"/>
									<!-\-<xsl:value-of select="concat($xpath[1], '/', .)"/>-\->
								</cr:child>
							</xsl:when>
							<xsl:when test="$schema-defs//schema-element[xpath = $child]">
								<cr:child required="{$required}" count="{$count}">
									<xsl:value-of select="$child"/>
								</cr:child>
							</xsl:when>
							<xsl:when test="@child-namespace ne parent::*/namespace">
								<cr:child required="{$required}" count="{$count}" child-namespace="{@child-namespace}">
									<xsl:value-of select="$child"/>
								</cr:child>								
							</xsl:when>
							<xsl:otherwise>
<!-\-								<xsl:call-template name="sf:error">-\->
									<xsl:call-template name="sf:warning">
									<xsl:with-param name="message">
										<xsl:text>Unable to locate element definition for element child </xsl:text>
										<xsl:value-of select="$child"/>
										<xsl:text>.</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:for-each-group>
			</cr:children>

-->			<cr:attributes>
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
							select="$source[normalize-space(ed:xpath)=$name]/ed:attributes/ed:attribute[ed:name=$attribute-name]"/>
						<xsl:if test="not($authored/ed:description/*)">
							<xsl:call-template name="sf:warning">
								<xsl:with-param name="message"
									select="'Attribute description not found ', string(xpath)"
								/>
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
				<cr:child>
					<xsl:value-of select="xpath"/>
				</cr:child>
			</xsl:for-each-group>
			<xsl:call-template name="get-nested-groups">
				<xsl:with-param name="referenced-group" select="$referenced-group"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get-nested-groups">
		<xsl:param name="referenced-group"/>
		<xsl:for-each
			select="/schema-definitions/schema-group-ref[referenced-in-group eq $referenced-group]">
			<xsl:variable name="referenced-group" select="referenced-group"/>
			<!-- each element that is in the group and has only one step in its path (so not the children of the element at the group level -->
			<xsl:for-each-group
				select="/schema-definitions/schema-element[belongs-to-group eq $referenced-group]"
				group-by="name">
				<cr:child>
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
