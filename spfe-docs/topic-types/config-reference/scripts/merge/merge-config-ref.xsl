<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<!-- ===================================================
	merge-config-ref.xsl
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:ed="http://spfeopentoolkit.org/ns/spfe-docs"
	xmlns:cr="http://spfeopentoolkit.org/ns/spfe-docs"
	exclude-result-prefixes="#all">

	<xsl:param name="set-id"/>
	<xsl:variable name="topic-set-id" select="$set-id"/>

	<xsl:variable 
		name="strings" 
		select="
		$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:strings/config:string, 
		$config/config:content-set/config:strings/config:string"
		as="element()*"/>

	<xsl:output method="xml" indent="yes"/>

	<xsl:param name="output-directory"/>

	<xsl:param name="extracted-content-files"/>
	<xsl:variable name="schema-defs" select="sf:get-sources($extracted-content-files)"/>

	<xsl:param name="authored-content-files"/>
	<xsl:variable name="config-setting-source" select="sf:get-sources($authored-content-files)"/>

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
				<cr:spfe-configuration-reference-entries>	
					<!-- Create the schema element topic set -->
		<xsl:for-each-group select="$doctypes/doctype" group-by="@name">
			<!-- FIXME: Need a test for the root selection method using schema with more than one doc element. -->
			<xsl:variable name="root" select=".[sf:index-of-shortest-string(@xpath)]/@xpath"/>
			<xsl:variable name="current-doctype" select="@name"/>


					<!-- Use for-each-group to filter out duplicate xpaths -->
					<xsl:for-each-group
						select="$schema-defs/schema-definitions/schema-element[starts-with(xpath, $root) or belongs-to-group]"
						group-by="xpath">
						<xsl:apply-templates select=".">
							<xsl:with-param name="source"
								select="$config-setting-source//ed:config-setting-description"/>
							<xsl:with-param name="current-doctype" select="$current-doctype"/>
							<xsl:with-param name="in-scope-strings" select="$strings"
								as="element()*" tunnel="yes"/>
						</xsl:apply-templates>
					</xsl:for-each-group>
				
		
		</xsl:for-each-group>	
				</cr:spfe-configuration-reference-entries>
			</xsl:result-document>
		<!-- Warn if there are any unmatched topics in the authored content. -->
		<!-- FIXME: Should also search for unmatched attribute definitions. -->
		<xsl:for-each select="$config-setting-source//ed:config-setting-description">
			<xsl:if
				test="not(normalize-space(ed:xpath) = $schema-defs/schema-definitions/schema-element/normalize-space(xpath))">
				<xsl:call-template name="sf:unresolved">
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
		<xsl:param name="current-doctype"/>

		<xsl:variable name="xpath" select="xpath"/>
		<xsl:variable name="group" select="belongs-to-group"/>
		<!-- determine the doctype by comparing the xpath of this element to the 
			 xpath of each of the document root elements -->
		<xsl:variable name="doctype"
			select="$doctypes/doctype[starts-with($xpath, @xpath)][1]/@name"/>
		<xsl:variable name="doc-xpath"
			select=" if ($doctype) 
					 then concat('/',$doctype,  substring-after($xpath, $doctype))
					 else $xpath"/>

		<xsl:variable name="topic-type-alias"
			select="sf:get-topic-type-alias-singular($topic-set-id, '{http://spfeopentoolkit.org/ns/spfe-docs}spfe-configuration-reference-entry', $config)"/>

		<!-- is it this doctype or a group, but not clear we need this check again -->

		<!-- FIXME: Should this be separated into a config specific script? -->
		<xsl:if test="($current-doctype = $doctype) or not($doctype)">

				<cr:spfe-configuration-reference-entry>
						<cr:namespace>
						<xsl:value-of select="ancestor::schema-definitions/@namespace"/>
					</cr:namespace>
					<cr:doctype>
						<xsl:value-of select="$doctype"/>
					</cr:doctype>
					<cr:doc-xpath>
						<xsl:value-of select="$doc-xpath"/>
					</cr:doc-xpath>
					<cr:xpath>
						<xsl:value-of select="$xpath"/>
					</cr:xpath>
					<cr:group>
						<xsl:value-of select="$group"/>
					</cr:group>

					<!-- Copy the extracted element info. -->
					<cr:name>
						<xsl:value-of select="name"/>
					</cr:name>
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

					<!-- Select and copy the authored element info. -->
					<xsl:variable name="authored-content"
						select="$source[normalize-space(ed:xpath)=$xpath]"/>
					<xsl:choose>
						<xsl:when test="$authored-content[2]">
							<xsl:call-template name="sf:error">
								<xsl:with-param name="message"
									select="'Duplicate configuration setting description found for setting ', $xpath"
								> </xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<!-- Test that the information exists. -->

						<xsl:when test="exists($authored-content/ed:description/*)">
							<xsl:apply-templates
								select="$authored-content/ed:description, $authored-content/ed:values, $authored-content/ed:restrictions, $authored-content/ed:build-property">
								<xsl:with-param name="in-scope-strings" select="$strings"
									as="element()*" tunnel="yes"/>
							</xsl:apply-templates>
						</xsl:when>

						<xsl:otherwise>
							<!-- If not found, report unresolved. -->
							<xsl:call-template name="sf:unresolved">
								<xsl:with-param name="message"
									select="'Configuration setting description not found ', string($xpath)"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>

					<!-- Calculate children -->
					<cr:children>
						<!-- children by xpath -->
						<xsl:for-each-group
							select="/schema-definitions/schema-element  
							[starts-with(xpath, concat($xpath, '/'))]
							[not(contains(substring(xpath,string-length($xpath)+2),'/'))]"
							group-by="xpath">
							<cr:child>
								<xsl:value-of select="xpath"/>
							</cr:child>
						</xsl:for-each-group>
						<!-- children by group -->
						<xsl:call-template name="get-group-children">
							<xsl:with-param name="xpath" select="$xpath"/>
						</xsl:call-template>
					</cr:children>

					<cr:attributes>
						<xsl:for-each
							select="root()/schema-definitions/schema-attribute[starts-with(xpath, concat($xpath, '/@'))]">
							<attribute>

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
								<cr:doc-xpath>
									<xsl:value-of select="concat($doc-xpath, '/@', $attribute-name)"
									/>
								</cr:doc-xpath>
								<xsl:variable name="authored"
									select="$source[normalize-space(ed:xpath)=$xpath]/ed:attributes/ed:attribute[ed:name=$attribute-name]"/>
								<xsl:if test="not($authored/ed:description/*)">
									<xsl:call-template name="sf:unresolved">
										<xsl:with-param name="message"
											select="'Configuration setting description not found ', string(xpath)"
										/>
									</xsl:call-template>
								</xsl:if>
								<xsl:apply-templates select="$authored/*">
									<xsl:with-param name="in-scope-strings" select="$strings"
										as="element()*" tunnel="yes"/>
								</xsl:apply-templates>
							</attribute>
						</xsl:for-each>
					</cr:attributes>
				</cr:spfe-configuration-reference-entry>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ed:config-setting-description">
			<xsl:apply-templates/>
</xsl:template>

	<xsl:template
		match="ed:*">
		<xsl:element name="cr:{local-name()}" namespace="http://spfeopentoolkit.org/ns/spfe-docs">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<!-- Suppress xpath from authored content as it duplicates xpath from extracted content. -->
	<xsl:template match="ed:xpath"/>

	<xsl:template name="get-group-children">
		<xsl:param name="xpath"/>
		<xsl:for-each select="/schema-definitions/schema-group-ref[referenced-in-xpath eq $xpath]">
			<xsl:variable name="referenced-group" select="referenced-group"/>
			<!-- each element that is in the group and has only one step in its path (so not the children of the element at the group level -->
			<xsl:for-each-group
				select="/schema-definitions/schema-element[belongs-to-group eq $referenced-group][not(contains(xpath, '/'))]"
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
				select="/schema-definitions/schema-element[belongs-to-group eq $referenced-group][not(contains(xpath, '/'))]"
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


	<!-- prevent getting two copies of name one from source, one from authored content -->
	<xsl:template match="ed:attribute/ed:name"/>


</xsl:stylesheet>
