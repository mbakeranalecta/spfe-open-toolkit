<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	synthesize-schema-docs.xsl

	The stylesheet pulls in element, attribute, and type definitions from the file 
	created by schema-read.xsl and pulls in information from the authored files
	to create a complete set of reference topics that can then be output to 
	different media.
	
	Also uses the authored file componet-source to build component reference,
	pulling definitions generated from CDF files from component-defs-file.

	Revisions:

	2005-07-15 gmb First version
	2005-12-08 gmb Added support for component reference
	2006-04-25 gmb Blended updates from 1.4.3
	2006-07-04 gmb Added support for shared library API schema
	2006-08-21 gmb Changed copy method and added docs
	2006-10-22 gmb Changed to support doctype instead of schema-based docs
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns:ed="http://spfeopentoolkit.org/spfe-ot/plugins/config-schema-docs/schemas/element-descriptions"
exclude-result-prefixes="#all">
	<xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
<xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/synthesis/common/synthesize-text-structures.xsl"/>
	<xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/synthesis/strings/synthesize-strings.xsl"/>
	
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

<xsl:output method="xml" indent="yes"/>

<xsl:param name="topic-set-id"/>
<xsl:param name="synthesis-directory"/>

<xsl:param name="schema-defs-file"/>
<xsl:variable name="schema-defs">
	<xsl:message select="$schema-defs-file"/>
	<xsl:call-template name="attach-source">
		<xsl:with-param name="source" select="$schema-defs-file"/>
	</xsl:call-template>
</xsl:variable>

<xsl:param name="element-description-files"/>

	<!-- FIXME: Generalize the load function -->

	<xsl:variable name="element-description-dir" select="concat($config/config:build/config:build-directory, '/temp/')"/>
	
	<xsl:variable name="element-source" as="element(ed:element-description)*">
		<xsl:for-each select="tokenize($element-description-files, $config/config:dir-separator)">
			<xsl:sequence select="doc(concat('file:///', $element-description-dir, .))//ed:element-description"/>	
		</xsl:for-each>
	</xsl:variable>
	
<xsl:variable name="config" as="element(config:spfe)">
	<xsl:sequence select="/config:spfe"/>
</xsl:variable>

<xsl:param name="optional-product"/>

<!-- 	<xsl:param name="intros-files"/>
	<xsl:variable name="introductions" xml:base="topics/" >
	<xsl:sequence select="document(tokenize($intros-files, $config/config:dir-separator))//g:topic"/>
	</xsl:variable>
 -->

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
			<xsl:variable name="root" select=".[sf:get-longest(@xpath)]/@xpath"/>
			<xsl:variable name="current-doctype" select="@name"/>
			
		<xsl:result-document 
			 method="xml" 
			 indent="yes"
			 omit-xml-declaration="no" 
			 href="file:///{$synthesis-directory}/{@name}.xml">
			<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set="{$config/config:topic-set-id}"> 
					<!-- Use for-each-group to filter out duplicate xpaths -->
					<xsl:for-each-group select="$schema-defs/schema-definitions/schema-element[starts-with(xpath, $root) or belongs-to-group]" group-by="xpath">
						<xsl:apply-templates select=".">
							<xsl:with-param name="source" select="$element-source"/>
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
					 
	
					 
	<!-- is it this doctype or a group, but not clear we need this check again -->				 
	<xsl:if test="($current-doctype = $doctype) or not($doctype)">		
		
		
		<ss:topic 
			element-name="{name()}" 
			type="http://spfeopentoolkit.org/spfe-docs/schemas/topic-types/element-reference" 
			full-name="http://spfeopentoolkit.org/spfe-docs/schemas/topic-types/element-reference/{translate(xpath, '/:', '__')}"
			local-name="{translate(xpath, '/:', '__')}"
			title="{name}">




		
		
		<topic type="schema-element">
			<xsl:if test="$optional-product">
				<xsl:attribute name="optional-product" select="$optional-product"/>
			</xsl:if>
			<name><xsl:value-of select="translate(xpath, '/:', '__')"/></name> 
			<schema-element>
				<schema>
					<xsl:value-of select="ancestor::schema-definitions/@namespace"/>
				</schema> 
				<doctype><xsl:value-of select="$doctype"/></doctype>
				<doc-xpath><xsl:value-of select="$doc-xpath"/></doc-xpath>
				<xpath><xsl:value-of select="$xpath"/></xpath>
				<group><xsl:value-of select="$group"/></group>
					<xsl:variable name="allowed-in-list"> 
						<xsl:call-template name="create-allowed-in-list">
							<xsl:with-param name="group" select="$group"/>
							<xsl:with-param name="xpath" select="$xpath"/>
						</xsl:call-template>
					</xsl:variable>
					<allowed-in>
					<xsl:variable name="allowed-in-list"> 
						<xsl:call-template name="create-allowed-in-list">
							<xsl:with-param name="group" select="$group"/>
							<xsl:with-param name="xpath" select="$xpath"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:for-each-group select="$allowed-in-list/xpath" group-by="text()">
						<xsl:sequence select="current-group()[1]"/>
					</xsl:for-each-group>
				</allowed-in>
<!-- 					<xsl:if test="starts-with($xpath, 'group_')">
						<xsl:value-of select="substring-before(substring-after($xpath, 'group_'), '/')"/>
					</xsl:if>
			</group>
 -->					
				
				<!-- Copy the extracted element info. -->
				<xsl:copy-of copy-namespaces="no" select="name,type,use,default, minOccurs, maxOccurs"/>
				
				<!-- Select and copy the authored element info. -->
				<xsl:choose>
					<!-- Test that the information exists. -->
					<xsl:when test="exists($source[ed:xpath=$xpath]/*)">
						<xsl:apply-templates select="$source[ed:xpath=$xpath]/ed:description"/>
						<xsl:apply-templates select="$source[ed:xpath=$xpath]/ed:build-property"/>
						<xsl:apply-templates select="$source[ed:xpath=$xpath]/ed:include-behavior"/>
					</xsl:when>
					<xsl:otherwise><!-- If not found, report warning. -->
						<xsl:call-template name="warning">
							<xsl:with-param name="message" select="'Element description not found ', string($xpath)"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- Calculate children -->
				<xsl:variable name="xpath" select="xpath"/>
				<children>
					<!-- children by xpath -->
					<xsl:for-each-group select="/schema-definitions/schema-element  
						[starts-with(xpath, concat($xpath, '/'))]
						[not(contains(substring(xpath,string-length($xpath)+2),'/'))]" group-by="xpath">
						<child>
							<xsl:value-of select="xpath"/>
						</child>
					</xsl:for-each-group>
					<!-- children by group -->
					<xsl:call-template name="get-group-children">
						<xsl:with-param name="xpath" select="$xpath"/>
					</xsl:call-template>
				</children>
				
				<attributes>
					<xsl:for-each select="root()/schema-definitions/schema-attribute[starts-with(xpath, concat($xpath, '/@'))]"> 
						<attribute>
							<!-- copy the extracted attribute info -->
							<xsl:copy-of select="*" copy-namespaces="no"/>


							<xsl:variable name="attribute-name" select="name"/>
							<doc-xpath><xsl:value-of select="concat($doc-xpath, '/@', $attribute-name)"/></doc-xpath>
							<xsl:variable name="authored" select="$source[ed:xpath=$xpath]/ed:attributes/ed:attribute[ed:name=$attribute-name]/*"/>
							<xsl:if test="not($authored)">
								<xsl:call-template name="warning">
									<xsl:with-param name="message" select="'Attribute description not found ', string(xpath)"/>
								</xsl:call-template>
							</xsl:if>
							<xsl:apply-templates select="$authored"/>
						</attribute>
					</xsl:for-each>
				</attributes>
			</schema-element>
		</topic>
				
		</ss:topic>
	</xsl:if>
</xsl:template>
	
	<xsl:template match="ed:description">
		<description>
			<xsl:apply-templates/>
		</description>
	</xsl:template>
	
	<xsl:template match="ed:build-property">
		<build-property>
			<xsl:apply-templates/>
		</build-property>
	</xsl:template>
	
	<xsl:template match="ed:include-behavior">
		<include-behavior>
			<xsl:apply-templates/>
		</include-behavior>
	</xsl:template>
	
<xsl:template name="get-group-children">
	<xsl:param name="xpath"/>
	<xsl:for-each select="/schema-definitions/schema-group-ref[referenced-in-xpath eq $xpath]">
		<xsl:variable name="referenced-group" select="referenced-group"/>
<!-- each element that is in the group and has only one step in its path (so not the children of the element at the group level -->
		<xsl:for-each-group select="/schema-definitions/schema-element[belongs-to-group eq $referenced-group][not(contains(xpath, '/'))]" group-by="xpath">
			<child>
				<xsl:value-of select="xpath"/>
			</child>
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
			<child>
				<xsl:value-of select="xpath"/>
			</child>
		</xsl:for-each-group>
		<xsl:call-template name="get-nested-groups">
			<xsl:with-param name="referenced-group" select="$referenced-group"/>
		</xsl:call-template>
	</xsl:for-each>
</xsl:template>


<!-- prevent getting two copies of name one from source, one from authored content -->
<xsl:template match="attribute/name"/>


<!-- Schema type template -->
<xsl:key name="attribute-type" match="schema-type" use="name"/>

	
<!-- 
========================
List generator templates
========================
-->


<!-- ARINC schema xpath list template -->
<xsl:template name="xpath-list">
	<xsl:variable name="root" select="$schema-defs/schema-definitions/@namespace"/>	
	<list name="{$root}-xpath-list">
		<xsl:for-each select = "$schema-defs/schema-definitions/schema-element/xpath,  $schema-defs/schema-definitions/schema-attribute/xpath">
			<item><xsl:apply-templates/></item>
		</xsl:for-each>
	</list>
</xsl:template>



<xsl:template name="doctype-list">
	<doctype>
		<xsl:sequence select="$doctypes"/>
	</doctype>
</xsl:template>

<!-- 
=================================
Content fix-up templates
=================================
-->

<!-- Fix up attribute name xpaths -->
<xsl:template match="attribute-name">
	<xsl:variable name="context-element" select="ancestor::element/name"/>
	<xsl:variable name="data-content" select="."/>
	<xsl:variable name="xpath" select="@xpath"/>
	<xsl:variable name="all-attributes" select="
	$schema-defs/schema-definitions/schema-attribute/xpath"/>
	
	<xsl:element name="attribute-name">
		<xsl:choose>
			<!-- check the cases where there is no 'xpath' attribute -->
			<xsl:when test="not(@xpath)">
				<xsl:choose>
				
					<!-- Is it a full attribute path? -->
					<xsl:when test="contains($data-content, '/@')">
						<!-- make the xpath explicit -->
						<xsl:attribute name="xpath" select="$data-content"/>
						<xsl:apply-templates/>
					</xsl:when>
					
					<!-- Is it an unambiguous partial attribute path? -->
					<xsl:when test="count($all-attributes[ends-with(., $data-content)])=1">
						<!-- make the xpath explicit -->
						<xsl:attribute name="xpath" select="$all-attributes[ends-with(., $data-content)]"/>
						<xsl:apply-templates/>
					</xsl:when>
					
					<!-- Is it the name of an attribute of the current element? -->
					<xsl:when test="ancestor::element/attributes/attribute[ends-with(name, $data-content)]">
						<xsl:attribute name="xpath" select="concat($context-element, '/@', $data-content)"/>
						<xsl:apply-templates/>
					</xsl:when>
					
					<!-- If not, we have a problem -->
					<xsl:otherwise>
						<xsl:call-template name="warning">
							<xsl:with-param name="message">
								<xsl:text>Ambiguous attribute name </xsl:text>
								<xsl:value-of select="$data-content"/>
								<xsl:text> Context element is:</xsl:text>
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
				<xsl:copy-of select="@xpath"/>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<!-- Fix up element name xpaths -->
<xsl:template match="element-name">
	<xsl:variable name="context-element" select="ancestor::element/name"/>
	<xsl:variable name="data-content" select="."/>
	<xsl:variable name="xpath" select="@xpath"/>
	<xsl:variable name="all-elements" select="
	$schema-defs/schema-definitions/schema-element/xpath"/>
	<xsl:element name="element-name">
		<xsl:choose>
			<!-- check the cases where there is no 'xpath' attribute -->
			<xsl:when test="not(@xpath)">
				<xsl:choose>
				
					<!-- Is it a full element path? -->
					<xsl:when test="$all-elements=$data-content">
						<!-- make the xpath explicit -->
						<xsl:attribute name="xpath" select="$data-content"/>
					</xsl:when>
					
					<!-- Is it the name of the current element? -->
					<xsl:when test="$context-element[ends-with(., $data-content)]">
						<xsl:attribute name="xpath" select="$context-element"/>
					</xsl:when>
					
					<!-- Is it an unambiguous partial element path? -->
					<xsl:when test="count($all-elements[ends-with(., $data-content)])=1">
						<!-- make the xpath explicit -->
						<xsl:attribute name="xpath" select="$all-elements[ends-with(., $data-content)]"/>
					</xsl:when>
					
					<!-- Is it the name of a child of the current element? -->
					<xsl:when test="$all-elements=concat($context-element, '/', $data-content)">
						<xsl:attribute name="xpath" select="concat($context-element, '/', $data-content)"/>
					</xsl:when>

					
					<!-- If not, we have a problem -->
					<xsl:otherwise>
						<xsl:call-template name="warning">
							<xsl:with-param name="message">
								<xsl:text>Ambiguous element name </xsl:text>
								<xsl:value-of select="$data-content"/>
								<xsl:text> Context element is:</xsl:text>
								<xsl:value-of select="$context-element"/>
								<xsl:text> Elements are: </xsl:text>
								<xsl:value-of select="$all-elements[ends-with(., $data-content)]"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
					
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="@xpath"/>
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
		<xpath><xsl:value-of select="string-join(tokenize($xpath, '/')[position() != last()], '/')"/></xpath>
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
				<xpath><xsl:value-of select="referenced-in-xpath"/></xpath>
			</xsl:when>
			
			<xsl:when test="//schema-group-ref[referenced-group=$group]">
				<xsl:call-template name="recurse-allowed-in-list">
					<xsl:with-param name="group" select="$ref-group"/>
					<xsl:with-param name="xpath" select="$xpath"/>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:call-template name="error">
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

