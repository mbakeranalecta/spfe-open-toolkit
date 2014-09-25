<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	exclude-result-prefixes="#all">

	
<!-- =============================================================
	schema-defs.xsl
	
	Reads a schema and pulls out the elements, attributes, and simple types 
	 This stylesheet starts from the element named in the "start-from" variable. 
	 This variable can be set from the command line to build a report for one of
	 the sub-schemas. Elements and attributes defined in included schemas are 
	 read.
	 
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
	<!-- get the namespace prefix used in the source  
	<xsl:variable name="xsd-prefix" select="substring-before(name(xs:schema), local-name(xs:schema))"/> -->
	
	<xsl:param name="topic-set-id"/>
	<xsl:output indent="yes"/>

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	
	<xsl:variable name="xsd-prefix">
		<xsl:variable name="prefix-string" select="/xs:schema/name(namespace::*[.='http://www.w3.org/2001/XMLSchema'])"/>
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

	<!-- default to starting from the first element defined -->
	<xsl:param name="start-from">
		<xsl:value-of select="xs:schema/xs:element[1]/@name"/>
	</xsl:param>
	
	<xsl:param name="sources-to-extract-content-from"/>	
	<xsl:variable name="schema" select="sf:get-sources($sources-to-extract-content-from)"/>
	
	<xsl:template name="main" >
		<!-- Create the root "extracted-content element" -->
		<xsl:result-document href="file:///{concat($config/config:doc-set-build, '/topic-sets/', $topic-set-id, '/extract/out/schema-defs.xml')}" method="xml" indent="no" omit-xml-declaration="no">
 
			<xsl:apply-templates select="$schema"/>

		</xsl:result-document>
	</xsl:template>
	
	
	<xsl:template name="read-schema">
		<xsl:param name="file-name"/>
		<xsl:sequence select="document(sf:local-to-url($file-name))"/>
		<xsl:for-each select="document(sf:local-to-url($file-name))/xs:schema/xs:include/@schemaLocation">
			<xsl:call-template name="read-schema">
				<xsl:with-param name="file-name" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:output method="xml" indent="yes"/>
	
	<xsl:key name="attribute-type" match="xs:attribute" use="@type"/>
	
	<xsl:template match="xs:schema">
	
		<schema-definitions 
		 namespace="{@targetNamespace}">
			<!-- trace the definition of every element and attribute -->
			<!-- trace each root element definition... -->
			<!-- FIXME: this search for roots is not recursive past the first include. Make it general -->
			<xsl:for-each select="xs:element, /xs:include/document(@schemaLocation)/xs:schema/xs:element">
				<xsl:variable name="element-name" select="@name"/>
				<xsl:variable name="isp" select="in-scope-prefixes(/xs:schema)"/>
				<xsl:variable name="namespace-prefix">
					<xsl:variable name="schema-element" select="/xs:schema"/>
					<xsl:for-each select="$isp">
						<xsl:if test="namespace-uri-for-prefix(., $schema-element )=$schema-element/@targetNamespace"> 
							<xsl:value-of select="."/>
						</xsl:if> 
					</xsl:for-each>
				</xsl:variable>
				<!-- ...unless it is invoked by a reference in another element. -->
				<xsl:if test="not(//xs:element[@ref=concat($namespace-prefix, ':', $element-name)])">
					<xsl:apply-templates select=".">
						<xsl:with-param name="path-so-far"/>
					</xsl:apply-templates>
					<xsl:text>&#xA;&#xA;</xsl:text>
				</xsl:if>
			</xsl:for-each>
			
			<xsl:call-template name="get-included-group-defs"/>
			
			<!-- get the definitions of all groups that are defined
			<xsl:apply-templates select="/xs:schema/xs:group"/> -->
			
			<!-- get the definitions from included files and their included files 
			<xsl:for-each select="/xs:schema/xs:include/document(@schemaLocation)">
				<xsl:apply-templates select="/xs:schema/xs:group"/>
				<xsl:for-each select="/xs:schema/xs:include/document(@schemaLocation)">
					<xsl:apply-templates select="/xs:schema/xs:group"/>
				</xsl:for-each>
			</xsl:for-each>-->
		
			
			
			<!-- get the definitions of all the types that are defined -->
			<xsl:call-template name="get-type-definitions"/>
			<xsl:text>&#xA;&#xA;</xsl:text>

			<!-- get the names of all the base types that are used -->
			<xsl:call-template name="get-base-type-references"/>
		</schema-definitions>
	</xsl:template>
	
	<!-- recursively search all included schemas -->
	<xsl:template name="get-included-group-defs">
		<xsl:apply-templates select="/xs:schema/xs:group"/>
		<xsl:for-each select="/xs:schema/xs:include/document(@schemaLocation)">
			<xsl:call-template name="get-included-group-defs"/>
		</xsl:for-each>
	</xsl:template>

	<!-- element definitions that have types -->
	<xsl:template match="xs:element[@type]">
		<xsl:param name="path-so-far"/>
		<xsl:variable name="psf" select="concat($path-so-far, '/', @name)"/>	
		<xsl:call-template name="element-info">
			<xsl:with-param name="path-so-far" select="$psf"/>
		</xsl:call-template>
		<xsl:variable name="type" select="substring-after(@type, $target-prefix)"/>
		<!-- check the included schemas -->
		<xsl:for-each select="/xs:schema/xs:include">
			<xsl:apply-templates select="document(@schemaLocation)/xs:schema/xs:complexType[@name=$type]">
				<xsl:with-param name="path-so-far" select="$psf"/>
			</xsl:apply-templates>
		</xsl:for-each>
		<!-- check this schema -->
		<xsl:message select="$path-so-far"></xsl:message>
		<xsl:choose>
			<!-- deal with recursively defined elements -->
		
			<xsl:when test="not(tokenize($path-so-far, '/') = @name)">
				<xsl:apply-templates select="//xs:complexType[@name=$type]">
					<xsl:with-param name="path-so-far" select="$psf"/>
				</xsl:apply-templates>	
			</xsl:when>
			
			<xsl:otherwise>
				<!-- this is a recursive definition, so grab the attributes but don't keep recursing. -->
				<xsl:apply-templates select="//xs:complexType[@name=$type]/xs:attribute">
					<xsl:with-param name="path-so-far" select="$psf"/>
				</xsl:apply-templates>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
  <!-- element definitions that have references -->
	<xsl:template match="xs:element[@ref]">
		<xsl:param name="path-so-far"/>
		<xsl:variable name="ref" select="substring-after(@ref,$target-prefix)"/>
		<xsl:variable name="referenced-element"> 

		<!-- check the included schemas -->
			<xsl:for-each select="/xs:schema/xs:include">
				<xsl:apply-templates select="document(@schemaLocation)/xs:schema/xs:element[@name=$ref]">
					<xsl:with-param name="path-so-far" select="$path-so-far"/>
				</xsl:apply-templates>
			</xsl:for-each>
			<!-- check this schema -->	
			<xsl:apply-templates select="/xs:schema/xs:element[@name=$ref]">
				<xsl:with-param name="path-so-far" select="$path-so-far"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$referenced-element > ''"> 
				<xsl:copy-of select="$referenced-element"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="element-name" select="concat($path-so-far, '/', @ref)"/> 
				<schema-element doc-element="false">
					<xpath><xsl:value-of select="$element-name"/></xpath>
					<name><xsl:value-of select="@ref"/></name>
				</schema-element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
  <!-- attribute definitions that have references -->
	<xsl:template match="xs:attribute[@ref]">
		<xsl:param name="path-so-far"/>
		<xsl:variable name="ref" select="substring-after(@ref,$target-prefix)"/>
		<xsl:variable name="referenced-attribute"> 

		<!-- check the included schemas -->
			<xsl:for-each select="/xs:schema/xs:include">
				<xsl:apply-templates select="document(@schemaLocation)/xs:schema/xs:attribute[@name=$ref]">
					<xsl:with-param name="path-so-far" select="$path-so-far"/>
				</xsl:apply-templates>
			</xsl:for-each>
			<!-- check this schema -->	
			<xsl:apply-templates select="/xs:schema/xs:attribute[@name=$ref]">
				<xsl:with-param name="path-so-far" select="$path-so-far"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$referenced-attribute > ''"> 
				<xsl:copy-of select="$referenced-attribute"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="attribute-name" select="concat($path-so-far, '/', @ref)"/> 
				<schema-attribute >
					<xpath><xsl:value-of select="$attribute-name"/></xpath>
					<name><xsl:value-of select="@ref"/></name>
<!-- Not sure how to get this stuff - or if it matters 					
					<type><xsl:value-of select="$type"/></type>
					<use><xsl:value-of select="@use"/></use>
					<default><xsl:value-of select="@default"/></default>
					<fixed><xsl:value-of select="@fixed"/></fixed>
					<xsl:if test="xs:annotation/xs:documentation">
						<schema-documentation>
							<xsl:value-of select="xs:annotation/xs:documentation"/>
						</schema-documentation>
					</xsl:if>
 -->					
				</schema-attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	

	  <!-- group definitions that have references -->
	<xsl:template match="xs:group[@ref]">
		<xsl:param name="path-so-far"/>
		<xsl:variable name="ref" select="substring-after(@ref,$target-prefix)"/>
		<schema-group-ref>
			<referenced-group><xsl:value-of select="@ref"/></referenced-group>
			<xsl:choose>
			
 				<xsl:when test="starts-with($path-so-far, 'group_') and contains($path-so-far, '/')">
 				
					<referenced-in-xpath><xsl:value-of select="substring-after($path-so-far, '/')"/></referenced-in-xpath>
 				</xsl:when>

 				<xsl:when test="starts-with($path-so-far, 'group_') and not(contains($path-so-far, '/'))">
					<referenced-in-group><xsl:value-of select="substring-after($path-so-far, 'group_')"/></referenced-in-group>
 				</xsl:when>
 				
 				<xsl:when test="starts-with($path-so-far, 'group_')">
 					<!-- avoid infinite loops -->
 					<xsl:if test="substring-before(substring-after($path-so-far, 'group_'),'/') ne @ref"> 
						<referenced-in-group><xsl:value-of select="substring-before(substring-after($path-so-far, 'group_'), '/')"/></referenced-in-group>
					</xsl:if>
				</xsl:when>
				
				<xsl:otherwise>
					<referenced-in-xpath><xsl:value-of select="$path-so-far"/></referenced-in-xpath>
				</xsl:otherwise>
			</xsl:choose>
		</schema-group-ref>
		
	</xsl:template>

	
	<!-- just pass on the path-so-far -->
	<xsl:template match="xs:group">
		<xsl:param name="path-so-far"/>
		<schema-group>
			<name><xsl:value-of select="@name"/></name>
		</schema-group>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="concat('group_',@name)"/>
		</xsl:apply-templates>
	</xsl:template>


	
	
	<!-- plain vanilla element definition -->
	<xsl:template match="xs:element">
		<xsl:param name="path-so-far"/>
		<xsl:variable name="psf" select="concat($path-so-far, '/', @name)"/>
		<xsl:message select="'$psf ', $psf"></xsl:message>
		<xsl:call-template name="element-info">
			<xsl:with-param name="path-so-far" select="$psf"/>
		</xsl:call-template>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$psf"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- complexType definition - just call apply-templates to pick up definitions -->
	<xsl:template match="xs:complexType">
		<xsl:param name="path-so-far"/>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- extensions - get base, then extension -->
	<xsl:template match="xs:extension[@base]">
		<xsl:param name="path-so-far"/>
		<xsl:variable name="base" select="@base"/>		 
    <!-- get the base -->
		<!-- check the included schemas -->
		<xsl:for-each select="/xs:schema/xs:include">
			<xsl:apply-templates select="document(@schemaLocation)/xs:schema/xs:complexType[@name=$base]">
				<xsl:with-param name="path-so-far" select="$path-so-far"/>
			</xsl:apply-templates>
		</xsl:for-each>
		<!-- check this schema -->
		<xsl:apply-templates select="/xs:schema/xs:complexType[@name=$base]">
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
		</xsl:apply-templates>
    <!-- get the extension -->
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
		</xsl:apply-templates>
	</xsl:template>


	<xsl:template match="xs:sequence">
		<xsl:param name="path-so-far"/>
		<schema-sequence>
			<parent><xsl:value-of select="$path-so-far"/></parent>
			<xsl:for-each select="child::*">
				<child type="{name()}"><xsl:value-of select="if (@name) then @name else @ref"/></child>
			</xsl:for-each>
		</schema-sequence>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="xs:choice">
		<xsl:param name="path-so-far"/>
		<schema-choice>
			<parent><xsl:value-of select="$path-so-far"/></parent>
			<xsl:for-each select="child::*">
				<child type="{name()}"><xsl:value-of select="if (@name) then @name else @ref"/></child>
			</xsl:for-each>
		</schema-choice>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="xs:all">
		<xsl:param name="path-so-far"/>
		<schema-all>
			<parent><xsl:value-of select="$path-so-far"/></parent>
			<xsl:for-each select="child::*">
				<child type="{name()}"><xsl:value-of select="if (@name) then @name else @ref"/></child>
			</xsl:for-each>
		</schema-all>
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- attribute definition -->
	<xsl:template match="xs:attribute">
		<xsl:param name="path-so-far"/>
		<xsl:variable name="xpath" select="concat($path-so-far, '/@', @name)"/>
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
		<xsl:text>&#xA;&#xA;&#xA;</xsl:text>
<!-- 		<xsl:comment>
			<xsl:value-of select="$xpath"/>
		</xsl:comment>
 -->		<xsl:text>&#xA;</xsl:text>
		<schema-attribute>
 			<xsl:choose>
 				<xsl:when test="starts-with($xpath, 'group_')">
<!-- 					<group><xsl:value-of select="substring-before(substring-after($xpath, 'group_'), '/')"/></group>
 -->					<xpath><xsl:value-of select="replace($xpath, 'group_.*?/','')"/></xpath>
				</xsl:when>
				<xsl:otherwise>
					<xpath><xsl:value-of select="$xpath"/></xpath>
				</xsl:otherwise>
			</xsl:choose>
			<name><xsl:value-of select="@name"/></name>
			<type><xsl:value-of select="$type"/></type>
			<use><xsl:value-of select="@use"/></use>
			<default><xsl:value-of select="@default"/></default>
			<fixed><xsl:value-of select="@fixed"/></fixed>
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
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>&#xA;</xsl:text>
<!-- 		<xsl:comment>
			<xsl:value-of select="$path-so-far"/>
		</xsl:comment>
 -->		<xsl:text>&#xA;</xsl:text>
 		<schema-element doc-element="{if (parent::xs:schema) then 'true' else 'false'}"> 
 			<xsl:choose>
 			
 				<xsl:when test="starts-with($path-so-far, 'group_')">
 					<xsl:variable name="group" select="substring-before(substring-after($path-so-far, 'group_'), '/')"/>
 					<xsl:variable name="path" select="replace($path-so-far, 'group_.*?/','')"/>
 					<belongs-to-group><xsl:value-of select="$group"/></belongs-to-group>
					<xpath><xsl:value-of select="$path"/></xpath>
				</xsl:when>
				
				<xsl:otherwise>
					<xpath><xsl:value-of select="$path-so-far"/></xpath>
				</xsl:otherwise>
			</xsl:choose>
			<name><xsl:value-of select="@name"/></name>
			<type><xsl:value-of select="substring-after(@type, $target-prefix)"/></type>
			<xsl:if test="@minOccurs">
				<minOccurs><xsl:value-of select="@minOccurs"/></minOccurs>
			</xsl:if>
			<xsl:if test="@maxOccurs">
				<maxOccurs><xsl:value-of select="@maxOccurs"/></maxOccurs>
			</xsl:if>
			<!-- the following is to improve required/optional detection
			     full extraction of group information is still TBD 
					 FIXME: not working though-->
			<xsl:if test="parent::choice">
				<group>choice</group>
			</xsl:if>
			<xsl:if test="xs:annotation/xs:documentation">
				<schema-documentation>
					<xsl:value-of select="xs:annotation/xs:documentation"/>
				</schema-documentation>
			</xsl:if>
		</schema-element>
	</xsl:template>
	
	<xsl:template name="type-info">
		<schema-type>
			<xsl:choose><!-- make default type explicit -->
				<xsl:when test="@name">
					<name><xsl:value-of select="@name"/></name>
				</xsl:when>
				<xsl:otherwise><name>xs:string</name></xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates mode="type"/>
		</schema-type>
	</xsl:template>
	
	<!-- catch all - must pass on path-so-far each time -->
	<xsl:template match="xs:*">
		<xsl:param name="path-so-far"/>
		
		<xsl:apply-templates>
			<xsl:with-param name="path-so-far" select="$path-so-far"/>
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
				<xsl:otherwise><xsl:value-of select="@base"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<based-on>
			<xsl:value-of select="$base"/>
		</based-on>
		<xsl:apply-templates mode="type"/>
		<xsl:if test="xs:enumeration">
			<enumeration>
				<xsl:for-each select="xs:enumeration">
					<value><xsl:value-of select="@value"/></value>
				</xsl:for-each>
			</enumeration>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="type" match="xs:pattern">
		<pattern><xsl:value-of select="@value"/></pattern>
	</xsl:template>
	
	<xsl:template mode="type" match="xs:union">
		<union><xsl:apply-templates mode="type"/></union>
	</xsl:template>
	
	<xsl:template mode="type" match="xs:simpleType">
		<base-type><xsl:apply-templates mode="type"/>	</base-type>
	</xsl:template>
	
	<xsl:template mode="type" match="xs:minLength">
		<minLength><xsl:value-of select="value"/></minLength>
	</xsl:template>

	<xsl:template mode="type" match="xs:maxLength">
		<maxLength><xsl:value-of select="value"/></maxLength>
	</xsl:template>

	<xsl:template mode="type" match="xs:minInclusive">
		<minInclusive><xsl:value-of select="value"/></minInclusive>
	</xsl:template>
	
	<xsl:template mode="type" match="xs:maxInclusive">
		<maxInclusive><xsl:value-of select="value"/></maxInclusive>
	</xsl:template>

	<xsl:template name="get-type-definitions">
		<!-- dump the definitions of every simpleType -->
		<xsl:for-each select="/xs:schema/xs:simpleType[@name]">
			<xsl:call-template name="type-info"/>
			<xsl:text>&#xA;</xsl:text>
			<xsl:text>&#xA;</xsl:text>
		</xsl:for-each>
		<xsl:call-template name="get-included-type-definitions"/>
	</xsl:template>
	
	<xsl:template name="get-included-type-definitions">
		<!-- dump types from included schemas -->
		<xsl:for-each select="/xs:schema/xs:include">
			<xsl:for-each select="document(@schemaLocation)/xs:schema/xs:simpleType[@name]">
				<xsl:call-template name="type-info"/>
			</xsl:for-each>
			<xsl:for-each select="document(@schemaLocation)/xs:schema/xs:include"> 
				<xsl:call-template name="get-included-type-definitions"/> 
			</xsl:for-each>
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
								<xsl:value-of select="concat('xs:',substring-after(@type, $xsd-prefix))"/>
							</xsl:otherwise>
						</xsl:choose>
					</name>
				</schema-type>
				<xsl:text>&#xA;</xsl:text>
				<xsl:text>&#xA;</xsl:text>
			</xsl:for-each>
			<xsl:call-template name="get-included-base-type-references"/> 
	</xsl:template>
	
	<xsl:template name="get-included-base-type-references">
			<!-- Now read them from all the included files -->
			<xsl:for-each select="/xs:schema/xs:include">
				<xsl:for-each select="document(@schemaLocation)//xs:attribute[substring-before(@type, ':') eq $xsd-prefix]">
					<!-- this is a test to pick up only the first instance of any particular declared name -->
					<xsl:if test="generate-id(key('attribute-type',@type)[1])=generate-id()">
						<schema-type>
							<name>
								<!-- Normalize the XSD prefix to 'xs:'. -->
								<xsl:value-of select="concat('xs:',substring-after(@type, $xsd-prefix))"/>
							</name>
						</schema-type>
						<xsl:text>&#xA;</xsl:text>
						<xsl:text>&#xA;</xsl:text>
					</xsl:if>
				</xsl:for-each>		
				<xsl:for-each select="document(@schemaLocation)/xs:schema/xs:include"> 
					<xsl:call-template name="get-included-base-type-references"/> 
				</xsl:for-each>
			</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>