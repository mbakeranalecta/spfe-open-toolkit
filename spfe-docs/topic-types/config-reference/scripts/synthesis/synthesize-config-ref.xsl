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
xmlns:ed="http://spfeopentoolkit.org/spfe-docs/topic-types/config-reference/schemas/config-setting-descriptions"
          
exclude-result-prefixes="#all" >
	
<xsl:param name="topic-set-id"/>

	
<xsl:variable name="output-namespace">http://spfeopentoolkit.org/spfe-docs/topic-types/config-reference</xsl:variable>	
	
<xsl:variable name="fragments" select="$config-setting-source//*:fragment"/>
	
<!-- synthesize-strings does not make any presumptions about where to look for strings, so we define $strings here -->
<xsl:variable name="strings" as="element()*">
	<xsl:for-each select="
		$config-setting-source//ed:string[not(parent::ed:local-strings)],
		$config/config:topic-set[@topic-set-id=$topic-set-id]/config:strings/config:string, 
		$config/config:doc-set/config:strings/config:string
		">
		<!-- remove them from source namespace -->
		<string>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="./node()"/>
		</string>
	</xsl:for-each>
</xsl:variable>

<xsl:output method="xml" indent="yes" />

<xsl:param name="synthesis-directory"/>

<xsl:param name="extracted-content-files"/>
<xsl:variable name="schema-defs" select="sf:get-sources($extracted-content-files)"/>

<xsl:param name="authored-content-files"/>
<xsl:variable name="config-setting-source" select="sf:get-sources($authored-content-files)"/>

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
		<!-- FIXME: Need a test for the root selection method using schema with more than one doc element. -->
		<xsl:variable name="root" select=".[sf:index-of-shortest-string(@xpath)]/@xpath"/>
		<xsl:variable name="current-doctype" select="@name"/>
		
		<xsl:result-document 
			 method="xml" 
			 indent="yes"
			 omit-xml-declaration="no" 
			 href="file:///{concat($config/config:doc-set-build, '/topic-sets/', $topic-set-id, '/synthesis/synthesis.xml')}">
			<ss:synthesis 
				xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
				topic-set-id="{$topic-set-id}" 
				title="{sf:string($config//config:strings, 'eppo-simple-topic-set-product')} {sf:string($config//config:strings, 'eppo-simple-topic-set-release')}"> 
				<!-- Use for-each-group to filter out duplicate xpaths -->
				<xsl:for-each-group select="$schema-defs/schema-definitions/schema-element[starts-with(xpath, $root) or belongs-to-group]" group-by="xpath">
					<xsl:apply-templates select=".">
						<xsl:with-param name="source" select="$config-setting-source//ed:config-setting-description"/>
						<xsl:with-param name="current-doctype" select="$current-doctype"/>
						<xsl:with-param name="in-scope-strings" select="$strings" as="element()*" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
			</ss:synthesis>
		</xsl:result-document>
	</xsl:for-each-group>
	<!-- Warn if there are any unmatched topics in the authored content. -->
	<!-- FIXME: Should also search for unmatched attribute definitions. -->
	<xsl:for-each select="$config-setting-source//ed:config-setting-description">
		<xsl:if test="not(normalize-space(ed:xpath) = $schema-defs/schema-definitions/schema-element/normalize-space(xpath))">
			<xsl:call-template name="sf:warning">
				<xsl:with-param name="message" select="'Authored element description found for an element not found in the schema:', normalize-space(ed:xpath)"/>
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

	<xsl:variable name="topic-type-alias" select="sf:get-topic-type-alias-singular('http://spfeopentoolkit.org/spfe-docs/topic-types/config-reference', $config)"/>
						 
	<!-- is it this doctype or a group, but not clear we need this check again -->			
	
	<!-- FIXME: Should this be separated into a config specific script? -->
	<xsl:if test="($current-doctype = $doctype) or not($doctype)">		
				
		<ss:topic 
			type="http://spfeopentoolkit.org/spfe-docs/topic-types/config-reference" 
			full-name="http://spfeopentoolkit.org/spfe-docs/topic-types/config-reference/{translate(xpath, '/:', '__')}"
			local-name="{translate(xpath, '/:', '__')}"
			topic-type-alias="{$topic-type-alias}"
			title="{name}"
			excerpt="{if(normalize-space($source[normalize-space(ed:xpath)=$xpath][1]/ed:description/ed:p[1])) then sf:escape-for-xml(sf:first-n-words($source[normalize-space(ed:xpath)=$xpath][1]/ed:description/ed:p[1], 30, ' ...')) else ''}">
			<xsl:variable name="xpath" select="normalize-space(xpath)"/>
			<ss:index>
				<ss:entry>
					<ss:type>config-setting</ss:type>
					<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config</ss:namespace>
					<ss:term><xsl:value-of select="$xpath"/></ss:term>
				</ss:entry>
				
				<xsl:for-each select="//schema-attribute[starts-with(normalize-space(xpath), concat($xpath, '/@'))]">
					<ss:entry>
						<ss:type>config-setting</ss:type>
						<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config</ss:namespace>
						<ss:term><xsl:value-of select="$xpath"/>/@<xsl:value-of select="name"/></ss:term>
						<ss:anchor><xsl:value-of select="name"></xsl:value-of></ss:anchor>
					</ss:entry>
				</xsl:for-each>
				<xsl:if test="normalize-space($source[normalize-space(ed:xpath)=$xpath][1]/ed:build-property)">
					<ss:entry>
						<ss:type>spfe-build-property</ss:type>
						<ss:namespace>http://spfeopentoolkit.org/spfe-ot/1.0/build</ss:namespace>
						<ss:term><xsl:value-of select="normalize-space($source[normalize-space(ed:xpath)=$xpath][1]/ed:build-property)"/></ss:term>
					</ss:entry>					
				</xsl:if>
			</ss:index>
			
			<!-- FIXME: Need to generate an index element for the link catalog -->
		
			<xsl:element name="spfe-configuration-reference-entry" namespace="{$output-namespace}">
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
						<xsl:when test="$source[normalize-space(ed:xpath)=$xpath][2]">
							<xsl:call-template name="sf:error">
								<xsl:with-param name="message" select="'Duplicate configuration setting description found for setting ', $xpath">
									
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<!-- Test that the information exists. -->
						<xsl:when test="exists($source[normalize-space(ed:xpath)=$xpath]/ed:description/*)">
							<xsl:apply-templates select="$source[normalize-space(ed:xpath)=$xpath]">
								<xsl:with-param name="in-scope-strings" select="$strings" as="element()*" tunnel="yes"/>
							</xsl:apply-templates>
<!--							<xsl:apply-templates select="$source[normalize-space(ed:xpath)=$xpath]/ed:build-property">
								<xsl:with-param name="in-scope-strings" select="$strings" as="element()*" tunnel="yes"/>	
							</xsl:apply-templates>
							<xsl:apply-templates select="$source[normalize-space(ed:xpath)=$xpath]/ed:values">
								<xsl:with-param name="in-scope-strings" select="$strings" as="element()*" tunnel="yes"/>				
							</xsl:apply-templates>
							<xsl:apply-templates select="$source[normalize-space(ed:xpath)=$xpath]/ed:restrictions">
								<xsl:with-param name="in-scope-strings" select="$strings" as="element()*" tunnel="yes"/>				
							</xsl:apply-templates>-->
						</xsl:when>
						<xsl:otherwise><!-- If not found, report warning. -->
							<xsl:call-template name="sf:warning">
								<xsl:with-param name="message" select="'Configuration setting description not found ', string($xpath)"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				
					<!-- Calculate children -->
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
								<xsl:variable name="authored" select="$source[normalize-space(ed:xpath)=$xpath]/ed:attributes/ed:attribute[ed:name=$attribute-name]"/>
								<xsl:if test="not($authored/ed:description/*)">
									<xsl:call-template name="sf:warning">
										<xsl:with-param name="message" select="'Configuration setting description not found ', string(xpath)"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:apply-templates select="$authored">
									<xsl:with-param name="in-scope-strings" select="$strings" as="element()*" tunnel="yes"/>
								</xsl:apply-templates>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				
			</xsl:element>
		</ss:topic>
	</xsl:if>
</xsl:template>
	
	<xsl:template match="ed:config-setting-description">
		<xsl:apply-templates/>
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
	
	<xsl:template match="ed:restrictions | ed:restriction | ed:values | ed:default | ed:value">
		<xsl:element name="{local-name()}" namespace="{$output-namespace}">
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

<!-- Fix up element name xpaths -->
	<xsl:template match="ed:config-setting">
	<xsl:variable name="context-element" select="ancestor::ed:config-setting-description/normalize-space(ed:xpath)"/>
	<xsl:variable name="data-content" select="."/>
	<xsl:variable name="xpath" select="@xpath"/>
	<xsl:variable name="all-elements" select="
	$schema-defs/schema-definitions/schema-element/xpath"/>
	<xsl:element name="name" namespace="{$output-namespace}">
		<xsl:attribute name="type">config-setting</xsl:attribute>		
		<xsl:choose>
			<!-- check the cases where there is no 'xpath' attribute -->
			<xsl:when test="not(@xpath)">
				
				<xsl:variable name="parent-of-context-element" select="string-join(tokenize($context-element,'/')[position()!=last()],'/')"/>
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
					
					<!-- Is it the name of a sibling of the current element?--> 
					
					<xsl:when test="$all-elements=concat($parent-of-context-element, '/', $data-content)">
						<xsl:attribute name="key" select="concat($parent-of-context-element, '/', $data-content)"/>
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

