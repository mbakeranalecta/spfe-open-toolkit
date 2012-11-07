<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	synthesize-config-ref.xsl
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns:ed="http://spfeopentoolkit.org/spfe-docs/schemas/config-element-descriptions"
exclude-result-prefixes="#all" >
	
<xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
<xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/synthesis/common/synthesize-text-structures.xsl"/>
<xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/synthesis/strings/synthesize-strings.xsl"/>
	
<xsl:variable name="output-namespace">http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-configuration-reference-entry</xsl:variable>	
	
<!-- synthesize-strings does not make any presumptions about where to look for strings, so we define $strings here -->
<xsl:variable name="strings">
	<xsl:for-each select="$element-source//ed:string[not(parent::ed:string-ref)], $config/config:string">
		<!-- remove them from source namespace -->
		<string>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="./node()"/>
		</string>
	</xsl:for-each>
</xsl:variable>

<xsl:output method="xml" indent="yes" />

<xsl:param name="synthesis-directory"/>

<xsl:param name="schema-defs-file"/>
<xsl:variable name="schema-defs" select="sf:get-sources($schema-defs-file)"/>

<xsl:param name="element-description-files"/>
<xsl:variable name="element-source" select="sf:get-sources($element-description-files)"/>

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
		<!-- Create the schema element topic set -->
		<xsl:for-each-group select="$doctypes/doctype" group-by="@name">
			<xsl:variable name="root" select=".[sf:longest-string(@xpath)]/@xpath"/>
			<xsl:variable name="current-doctype" select="@name"/>
			
		<xsl:result-document 
			 method="xml" 
			 indent="yes"
			 omit-xml-declaration="no" 
			 href="file:///{$synthesis-directory}/{@name}.xml">
			<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set-id="{$config/config:topic-set-id}" title="{sf:string($config/config:strings, 'eppo-simple-topic-set-product')} {sf:string($config/config:strings, 'eppo-simple-topic-set-release')}"> 
					<!-- Use for-each-group to filter out duplicate xpaths -->
					<xsl:for-each-group select="$schema-defs/schema-definitions/schema-element[starts-with(xpath, $root) or belongs-to-group]" group-by="xpath">
						<xsl:apply-templates select=".">
							<xsl:with-param name="source" select="$element-source//ed:element-description"/>
							<xsl:with-param name="current-doctype" select="$current-doctype"/>
						</xsl:apply-templates>
					</xsl:for-each-group>
				</ss:synthesis>
			</xsl:result-document>
		</xsl:for-each-group>
		
</xsl:template>

<!-- 
=================================
Main content processing templates
=================================
-->

<!-- Schema element template -->
<xsl:template match="schema-element" >
	<xsl:param name="source"/>
	<xsl:param name="current-doctype"/>
	
	<xsl:variable name="xpath" select="xpath"/>
	<xsl:variable name="group" select="belongs-to-group"/>
	<!-- determine the doctype by comparing the xpath of this element to the 
			 xpath of each of the document root elements -->
	<xsl:variable name="doctype" select="$doctypes/doctype[starts-with($xpath, @xpath)][1]/@name"/>
	<xsl:variable name="doc-xpath" 
	select=" if ($doctype) 
					 then concat('/',$doctype,  substring-after($xpath, $doctype))
					 else $xpath"/> 
	
	<!-- FIXME: this is mostly generic code, should be refactored. -->
	<xsl:variable name="topic-type-alias-list" select="$config/config:topic-type-aliases" as="element(config:topic-type-aliases)"/>
	<xsl:variable name="topic-type">http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-configuration-reference-entry</xsl:variable> 
	<xsl:variable name="topic-type-alias">
		<xsl:choose>
			<xsl:when test="$topic-type-alias-list/config:topic-type[config:id=$topic-type]">
				<xsl:value-of select="$topic-type-alias-list/config:topic-type[config:id=$topic-type]/config:alias"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">
						<xsl:text>No topic type alias found for topic type </xsl:text>
						<xsl:value-of select="$topic-type"/>
						<xsl:text>.</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$topic-type"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
						 
	<!-- is it this doctype or a group, but not clear we need this check again -->			
	
	<!-- FIXME: Should this be separated into a config specific script? -->
	<xsl:if test="($current-doctype = $doctype) or not($doctype)">		
				
		<ss:topic 
			type="http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-configuration-reference-entry" 
			full-name="http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-configuration-reference-entry/{translate(xpath, '/:', '__')}"
			local-name="{translate(xpath, '/:', '__')}"
			topic-type-alias="{$topic-type-alias}"
			title="{name}">
			<xsl:variable name="xpath" select="normalize-space(xpath)"/>
			<ss:index>
				<ss:entry>
					<ss:type>xpath</ss:type>
					<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config</ss:namespace>
					<ss:term><xsl:value-of select="$xpath"/></ss:term>
				</ss:entry>
				
				<xsl:for-each select="//schema-attribute[starts-with(normalize-space(xpath), concat($xpath, '/@'))]">
					<ss:entry>
						<ss:type>xpath</ss:type>
						<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config</ss:namespace>
						<ss:term><xsl:value-of select="xpath"/></ss:term>
						<ss:anchor><xsl:value-of select="name"></xsl:value-of></ss:anchor>
					</ss:entry>
				</xsl:for-each>
				<xsl:if test="normalize-space($source[ed:xpath=$xpath]/ed:build-property)">
					<ss:entry>
						<ss:type>spfe-build-property</ss:type>
						<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/build</ss:namespace>
						<ss:term><xsl:value-of select="normalize-space($source[ed:xpath=$xpath]/ed:build-property)"/></ss:term>
					</ss:entry>					
				</xsl:if>
			</ss:index>
			
			<!-- FIXME: Need to generate an index element for the link catalog -->
		
			<xsl:element name="spfe-configuration-reference-entry" namespace="{$output-namespace}">
				

				<xsl:element name="schema-element" namespace="{$output-namespace}">

					<xsl:element name="namespace" namespace="{$output-namespace}">
						<xsl:value-of select="ancestor::schema-definitions/@namespace"/>
					</xsl:element> 
					<xsl:element name="doctype" namespace="{$output-namespace}">
						<xsl:value-of select="$doctype"/>
					</xsl:element>
					<xsl:element name="doc-xpath" namespace="{$output-namespace}">
						<xsl:value-of select="$doc-xpath"/>
					</xsl:element>
					<xsl:element name="xpath" namespace="{$output-namespace}">
						<xsl:value-of select="$xpath"/>
					</xsl:element>
					<xsl:element name="group" namespace="{$output-namespace}">
						<xsl:value-of select="$group"/>
					</xsl:element>
					<xsl:element name="allowed-in" namespace="{$output-namespace}">
						<xsl:variable name="allowed-in-list"> 
							<xsl:call-template name="create-allowed-in-list">
								<xsl:with-param name="group" select="$group"/>
								<xsl:with-param name="xpath" select="$xpath"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:for-each-group select="$allowed-in-list/xpath" group-by="text()">
							<xsl:sequence select="current-group()[1]"/>
						</xsl:for-each-group>
					</xsl:element>

					<!-- Copy the extracted element info. -->
					<xsl:element name="name" namespace="{$output-namespace}">
						<xsl:value-of select="name"/>
					</xsl:element>
					<xsl:element name="type" namespace="{$output-namespace}">
						<xsl:value-of select="type"/>
					</xsl:element>
					<xsl:element name="use" namespace="{$output-namespace}">
						<xsl:value-of select="use"/>
					</xsl:element>
					<xsl:element name="default" namespace="{$output-namespace}">
						<xsl:value-of select="default"/>
					</xsl:element>
					<xsl:element name="minOccurs" namespace="{$output-namespace}">
						<xsl:value-of select="minOccurs"/>
					</xsl:element>
					<xsl:element name="maxOccurs" namespace="{$output-namespace}">
						<xsl:value-of select="maxOccurs"/>
					</xsl:element>
					
					<!-- Select and copy the authored element info. -->
					<xsl:choose>
						<!-- Test that the information exists. -->
						<xsl:when test="exists($source[ed:xpath=$xpath]/*)">
							<xsl:apply-templates select="$source[ed:xpath=$xpath]/ed:description"/>
							<xsl:apply-templates select="$source[ed:xpath=$xpath]/ed:build-property"/>
							<xsl:apply-templates select="$source[ed:xpath=$xpath]/ed:include-behavior"/>
						</xsl:when>
						<xsl:otherwise><!-- If not found, report warning. -->
							<xsl:call-template name="sf:warning">
								<xsl:with-param name="message" select="'Element description not found ', string($xpath)"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				
					<!-- Calculate children -->
					<xsl:variable name="xpath" select="xpath"/>
					<xsl:element name="children" namespace="{$output-namespace}">
						<!-- children by xpath -->
						<xsl:for-each-group select="/schema-definitions/schema-element  
							[starts-with(xpath, concat($xpath, '/'))]
							[not(contains(substring(xpath,string-length($xpath)+2),'/'))]" group-by="xpath">
							<xsl:element name="child" namespace="{$output-namespace}">
								<xsl:value-of select="xpath"/>
							</xsl:element>
						</xsl:for-each-group>
						<!-- children by group -->
						<xsl:call-template name="get-group-children">
							<xsl:with-param name="xpath" select="$xpath"/>
						</xsl:call-template>
					</xsl:element>
					
					<xsl:element name="attributes" namespace="{$output-namespace}">
						<xsl:for-each select="root()/schema-definitions/schema-attribute[starts-with(xpath, concat($xpath, '/@'))]"> 
							<xsl:element name="attribute" namespace="{$output-namespace}">
								
								<!-- Copy the extracted element info. -->
								<xsl:element name="xpath" namespace="{$output-namespace}">
									<xsl:value-of select="xpath"/>
								</xsl:element>
								<xsl:element name="type" namespace="{$output-namespace}">
									<xsl:value-of select="type"/>
								</xsl:element>
								<xsl:element name="use" namespace="{$output-namespace}">
									<xsl:value-of select="use"/>
								</xsl:element>
								<xsl:element name="default" namespace="{$output-namespace}">
									<xsl:value-of select="default"/>
								</xsl:element>
								<xsl:element name="minOccurs" namespace="{$output-namespace}">
									<xsl:value-of select="minOccurs"/>
								</xsl:element>
								<xsl:element name="maxOccurs" namespace="{$output-namespace}">
									<xsl:value-of select="maxOccurs"/>
								</xsl:element>
								
								<xsl:variable name="attribute-name" select="name"/>
								<xsl:element name="doc-xpath" namespace="{$output-namespace}">
									<xsl:value-of select="concat($doc-xpath, '/@', $attribute-name)"/>
								</xsl:element>
								<xsl:variable name="authored" select="$source[ed:xpath=$xpath]/ed:attributes/ed:attribute[ed:name=$attribute-name]/*"/>
								<xsl:if test="not($authored)">
									<xsl:call-template name="sf:warning">
										<xsl:with-param name="message" select="'Attribute description not found ', string(xpath)"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:apply-templates select="$authored"/>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</ss:topic>
	</xsl:if>
</xsl:template>
	
	<xsl:template match="ed:description">
		<xsl:element name="description" namespace="{$output-namespace}">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ed:build-property">
		<xsl:element name="build-property" namespace="{$output-namespace}">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ed:include-behavior">
		<xsl:element name="include-behavior" namespace="{$output-namespace}">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
<xsl:template name="get-group-children">
	<xsl:param name="xpath"/>
	<xsl:for-each select="/schema-definitions/schema-group-ref[referenced-in-xpath eq $xpath]">
		<xsl:variable name="referenced-group" select="referenced-group"/>
<!-- each element that is in the group and has only one step in its path (so not the children of the element at the group level -->
		<xsl:for-each-group select="/schema-definitions/schema-element[belongs-to-group eq $referenced-group][not(contains(xpath, '/'))]" group-by="xpath">
			<xsl:element name="chils" namespace="{$output-namespace}">
				<xsl:value-of select="xpath"/>
			</xsl:element>
		</xsl:for-each-group>
		<xsl:call-template name="get-nested-groups">
			<xsl:with-param name="referenced-group" select="$referenced-group"/>
		</xsl:call-template>
	</xsl:for-each>
</xsl:template>

<xsl:template name="get-nested-groups">
	<xsl:param name="referenced-group"/>
	<xsl:for-each select="/schema-definitions/schema-group-ref[referenced-in-group eq $referenced-group]">
		<xsl:variable name="referenced-group" select="referenced-group"/>
		<!-- each element that is in the group and has only one step in its path (so not the children of the element at the group level -->
		<xsl:for-each-group select="/schema-definitions/schema-element[belongs-to-group eq $referenced-group][not(contains(xpath, '/'))]" group-by="xpath">
			<xsl:element name="child" namespace="{$output-namespace}">
				<xsl:value-of select="xpath"/>
			</xsl:element>
		</xsl:for-each-group>
		<xsl:call-template name="get-nested-groups">
			<xsl:with-param name="referenced-group" select="$referenced-group"/>
		</xsl:call-template>
	</xsl:for-each>
</xsl:template>


<!-- prevent getting two copies of name one from source, one from authored content -->
<xsl:template match="ed:attribute/name"/>

<!-- 
=================================
Content fix-up templates
=================================
-->

<!-- FIXME: Are these in the right namespace to match?" -->

<!-- Fix up attribute name xpaths -->
<xsl:template match="ed:spfe-config-attribute-name">
	<xsl:variable name="context-element" select="ancestor::ed:element-description/ed:xpath"/>
	<xsl:variable name="data-content" select="."/>
	<xsl:variable name="xpath" select="@xpath"/>
	<xsl:variable name="all-attributes" select="
	$schema-defs/schema-definitions/schema-attribute/xpath"/>
	
	<xsl:element name="name" namespace="{$output-namespace}" >
		<xsl:attribute name="type">xpath</xsl:attribute>
		<xsl:choose>
			<!-- check the cases where there is no 'xpath' attribute -->
			<xsl:when test="not(@xpath)">
				<xsl:choose>
				
					<!-- Is it a full attribute path? -->
					<xsl:when test="contains($data-content, '/@')">
						<!-- make the xpath explicit -->
						<xsl:attribute name="key" select="$data-content"/>
						<xsl:apply-templates/>
					</xsl:when>
					
					<!-- Is it an unambiguous partial attribute path? -->
					<xsl:when test="count($all-attributes[ends-with(., $data-content)])=1">
						<!-- make the xpath explicit -->
						<xsl:attribute name="key" select="$all-attributes[ends-with(., $data-content)]"/>
						<xsl:apply-templates/>
					</xsl:when>
					
					<!-- Is it the name of an attribute of the current element? -->
					<!-- FIXME: This is using the ed source rather than the schema defs -->
<!--					<xsl:when test="ancestor::ed:element-description/ed:attributes/ed:attribute[ends-with(ed:name, $data-content)]">-->
					<xsl:when test="concat($context-element, '/@', $data-content) = $all-attributes">
							<xsl:attribute name="key" select="concat($context-element, '/@', $data-content)"/>
						<xsl:apply-templates/>
					</xsl:when>
					
					<!-- If not, we have a problem -->
					<xsl:otherwise>
						<xsl:attribute name="key" select="$data-content"/>
						<xsl:call-template name="sf:warning">
							<xsl:with-param name="message">
								<xsl:text>Ambiguous SPFE config attribute name "</xsl:text>
								<xsl:value-of select="$data-content"/>
								<xsl:text>". Context element is:</xsl:text>
								<xsl:value-of select="$context-element"/>
								<xsl:text> Attributes are: </xsl:text>
								<xsl:value-of select="$all-attributes[starts-with(., $context-element)]"/>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="key" select="@xpath"/>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- Fix up element name xpaths -->
	<xsl:template match="ed:spfe-config-element-name">
	<xsl:variable name="context-element" select="ancestor::ed:element-description/ed:xpath"/>
	<xsl:variable name="data-content" select="."/>
	<xsl:variable name="xpath" select="@xpath"/>
	<xsl:variable name="all-elements" select="
	$schema-defs/schema-definitions/schema-element/xpath"/>
	<xsl:element name="name" namespace="{$output-namespace}">
		<xsl:attribute name="type">xpath</xsl:attribute>		
		<xsl:choose>
			<!-- check the cases where there is no 'xpath' attribute -->
			<xsl:when test="not(@xpath)">
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
						<xsl:attribute name="key" select="$all-elements[ends-with(., $data-content)]"/>
					</xsl:when>
					
					<!-- Is it the name of a child of the current element? -->
					<xsl:when test="$all-elements=concat($context-element, '/', $data-content)">
						<xsl:attribute name="key" select="concat($context-element, '/', $data-content)"/>
					</xsl:when>

					
					<!-- If not, we have a problem -->
					<xsl:otherwise>
						<xsl:attribute name="key" select="$data-content"/>
						<xsl:call-template name="sf:warning">
							<xsl:with-param name="message">
								<xsl:text>Ambiguous SPFE config element name "</xsl:text>
								<xsl:value-of select="$data-content"/>
								<xsl:text>". Context element is:</xsl:text>
								<xsl:value-of select="$context-element"/>
								<xsl:text> Elements are: </xsl:text>
								<xsl:value-of select="$all-elements[ends-with(., $data-content)]"/>
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
	</xsl:element>
</xsl:template>

<xsl:template name="create-allowed-in-list">
	<xsl:param name="group"/>
	<xsl:param name="xpath"/>
	<!-- include the containing element if there is one -->
	<xsl:if test="contains($xpath, '/')">
		<xsl:element name="xpath" namespace="{$output-namespace}">
			<xsl:value-of select="string-join(tokenize($xpath, '/')[position() != last()], '/')"/>
		</xsl:element>
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

		<xsl:variable name="ref-group" select="//schema-group-ref[referenced-group=$group]/referenced-in-group"/>

		<xsl:choose>
		
			<xsl:when test="referenced-in-xpath">
				<xsl:element name="xpath" namespace="{$output-namespace}">
					<xsl:value-of select="referenced-in-xpath"/>
				</xsl:element>
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

