<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<!-- ===================================================
	synthesize-xsl-function-ref.xsl
=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns:fd="http://spfeopentoolkit.org/spfe-docs/schemas/xslt-function-and-template-descriptions"
exclude-result-prefixes="#all" >
	
<xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
<xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/synthesis/common/synthesize-text-structures.xsl"/>
<xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/synthesis/strings/synthesize-strings.xsl"/>
	
	<xsl:variable name="output-namespace">http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-xslt-function-reference-entry</xsl:variable>	
	
<!-- synthesize-strings does not make any presumptions about where to look for strings, so we define $strings here -->
<xsl:variable name="strings">
	<xsl:for-each select="$function-source//fd:string[not(parent::fd:string-ref)], $config/config:string">
		<!-- remove them from source namespace -->
		<string>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="./node()"/>
		</string>
	</xsl:for-each>
</xsl:variable>

<xsl:output method="xml" indent="yes" />

<xsl:param name="synthesis-directory"/>

<xsl:param name="function-defs-file"/>
<xsl:variable name="function-defs" select="sf:get-sources($function-defs-file)"/>

<xsl:param name="function-description-files"/>
<xsl:variable name="function-source" select="sf:get-sources($function-description-files)"/>

<xsl:variable name="config" as="element(config:spfe)">
	<xsl:sequence select="/config:spfe"/>
</xsl:variable>


<!-- 
=============
Main template
=============
-->
	
<xsl:template name="main">
	<xsl:apply-templates select="$function-defs"/>
</xsl:template>

<xsl:template match="function-and-template-definitions">
	<xsl:result-document 
		 method="xml" 
		 indent="yes"
		 omit-xml-declaration="no" 
		 href="file:///{$synthesis-directory}/synthesis.xml">
		<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set-id="{$config/config:topic-set-id}" title="{sf:string($config/config:strings, 'eppo-simple-topic-set-product')} {sf:string($config/config:strings, 'eppo-simple-topic-set-release')}"> 
			<xsl:for-each-group select="function-definition" group-by="concat(namespace-uri, name)">
				<xsl:variable name="name" select="string(name[1])"/>
				<xsl:variable name="namespace-uri" select="string(namespace-uri[1])"/>
				
				<xsl:variable name="topic-type-alias-list" select="$config/config:topic-type-aliases" as="element(config:topic-type-aliases)"/>
				<xsl:variable name="topic-type">http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-xslt-function-reference-entry</xsl:variable> 
				
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
				
				<ss:topic 
					element-name="{name()}" 
					type="http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-xslt-function-reference-entry" 
					full-name="http://spfeopentoolkit.org/spfe-docs/schemas/authoring/spfe-xslt-function-reference-entry/{concat(local-prefix, '_', name)}"
					local-name="{name}"
					topic-type-alias="{$topic-type-alias}"
					title="{name}">
					<ss:index>
						<ss:entry>
							<ss:type>spfe-xslt-function-reference-entry</ss:type>
							<ss:namespace><xsl:value-of select="$namespace-uri"/></ss:namespace>
							<ss:term><xsl:value-of select="$name"/></ss:term>
						</ss:entry>
					</ss:index>
					
					<xsl:element name="spfe-xslt-function-reference-entry" namespace="{$output-namespace}">
						<xsl:element name="xsl-function" namespace="{$output-namespace}">
							
							<xsl:element name="name" namespace="{$output-namespace}">
								<xsl:value-of select="name[1]"/>
							</xsl:element> 
							<xsl:element name="local-prefix" namespace="{$output-namespace}">
								<xsl:value-of select="local-prefix[1]"/>
							</xsl:element>
							<xsl:element name="return-type" namespace="{$output-namespace}">
								<xsl:value-of select="return-type[1]"/>
							</xsl:element>
							<xsl:for-each select="source-file">
								<xsl:element name="source-file" namespace="{$output-namespace}">
									<xsl:value-of select="."/>
								</xsl:element>
							</xsl:for-each>
							<xsl:element name="namespace-uri" namespace="{$output-namespace}">
								<xsl:value-of select="$namespace-uri"/>
							</xsl:element>
							<xsl:for-each select="definition">
								<xsl:element name="definition" namespace="{$output-namespace}">
									<xsl:copy-of select="./*"/>
								</xsl:element>
							</xsl:for-each>
							
							<xsl:variable name="function-description" select="$function-source/fd:function-and-template-descriptions/fd:body[fd:namespace-uri eq $namespace-uri]/fd:function-description[fd:name eq $name]"/>
							
							<!-- Select and copy the authored function info. -->
							<xsl:choose>
								<!-- Test that the information exists. -->
								<xsl:when test="exists($function-description/*)">
									<xsl:apply-templates select="$function-description/fd:description"/>
								</xsl:when>
								<xsl:otherwise><!-- If not found, report warning. -->
									<xsl:call-template name="sf:warning">
										<xsl:with-param name="message" select="'Function description not found ', string($name)"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							
							
							<xsl:element name="parameters" namespace="{$output-namespace}">
								<!-- parameters by name -->
								<!-- FIXME: need to detect optional parameters -->
								<xsl:for-each-group select="parameters/parameter" group-by="name">
									<xsl:variable name="parameter-name" select="name[1]"/>
									<xsl:element name="parameter" namespace="{$output-namespace}">																					<xsl:element name="name" namespace="{$output-namespace}">
											<xsl:value-of select="$parameter-name"/>
										</xsl:element>
										<xsl:element name="type" namespace="{$output-namespace}">
											<xsl:value-of select="type[1]"/>
										</xsl:element>
										
										<xsl:variable name="authored" select="$function-description/fd:parameters/fd:parameter[fd:name = $parameter-name]/*"/>
										<xsl:if test="not($authored)">
											<xsl:call-template name="sf:warning">
												<xsl:with-param name="message" select="'Parameter description not found ', string($parameter-name)"/>
											</xsl:call-template>
										</xsl:if>
										<xsl:apply-templates select="$authored"/>
									</xsl:element>
								</xsl:for-each-group>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</ss:topic>
			</xsl:for-each-group>
			
			<xsl:apply-templates select="$function-defs/function-and-template-definitions/*"/>
		</ss:synthesis>
	</xsl:result-document>
</xsl:template>

<!-- 
=================================
Main content processing templates
=================================
-->

<!-- Schema element template -->
<xsl:template match="function-definition" >

</xsl:template>
	
	<xsl:template match="fd:description">
		<xsl:element name="description" namespace="{$output-namespace}">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>

