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
xmlns:fd="http://spfeopentoolkit.org/spfe-docs/topic-types/function-and-template-reference/schemas/xslt-function-and-template-descriptions"
xmlns:xfd="http://spfeopentoolkit.org/spfe-docs/extraction/xslt-function-definitions"
xmlns="http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference"
exclude-result-prefixes="#all" >
	
	<xsl:variable name="output-namespace">http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference</xsl:variable>	
	
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
	
<xsl:param name="topic-set-id"/>

<xsl:param name="synthesis-directory"/>

	<xsl:param name="extracted-content-files"/>
	<xsl:variable name="function-defs" select="sf:get-sources($extracted-content-files)"/>

<xsl:param name="authored-content-files"/>
<xsl:variable name="function-source" select="sf:get-sources($authored-content-files)"/>

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

<xsl:template match="xfd:function-and-template-definitions">
	<xsl:result-document 
		 method="xml" 
		 indent="yes"
		 omit-xml-declaration="no" 
		 href="file:///{concat($config/config:doc-set-build, '/', $topic-set-id, '/synthesis/synthesis.xml')}">
		<ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set-id="{$config/config:topic-set-id}" title="{sf:string($config//config:strings, 'eppo-simple-topic-set-product')} {sf:string($config//config:strings, 'eppo-simple-topic-set-release')}"> 
			
			<xsl:for-each-group select="xfd:function-definition" group-by="concat(xfd:namespace-uri, xfd:name)">
				<xsl:variable name="name" select="string(xfd:name[1])"/>
				<xsl:variable name="namespace-uri" select="string(xfd:namespace-uri[1])"/>
				
				<xsl:variable name="topic-type-alias" select="sf:get-topic-type-alias-singular('http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference')"/>	
				<xsl:variable name="function-description" select="$function-source/fd:function-and-template-descriptions/fd:body[fd:namespace-uri eq $namespace-uri]/fd:function-description[fd:name eq $name]"/>
				<ss:topic 
					type="http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference" 
					full-name="http://spfeopentoolkit.org/spfe-docs/topic-types/function-reference/{concat(xfd:local-prefix, '_', xfd:name)}"
					local-name="{xfd:name}"
					topic-type-alias="{$topic-type-alias}"
					title="{xfd:name}"
					excerpt="{sf:escape-for-xml(sf:first-n-words($function-description/fd:description/fd:p[1], 30, ' ...'))}">
					
					<ss:index>
						<ss:entry>
							<ss:type>spfe-xslt-function-reference-entry</ss:type>
							<ss:namespace><xsl:value-of select="$namespace-uri"/></ss:namespace>
							<ss:term><xsl:value-of select="$name"/></ss:term>
						</ss:entry>
						<ss:entry>
							<ss:type>xslt-function-name</ss:type>
							<ss:namespace><xsl:value-of select="$namespace-uri"/></ss:namespace>
							<ss:term><xsl:value-of select="$name"/></ss:term>
						</ss:entry>
					</ss:index>
					
					<spfe-xslt-function-reference-entry>
						<xsl-function>
							<name><xsl:value-of select="xfd:name[1]"/></name>
							<local-prefix><xsl:value-of select="xfd:local-prefix[1]"/></local-prefix>
							<xsl:for-each select="xfd:source-file">
								<source-file><xsl:value-of select="."/>
									<!--<xsl:value-of select=" sf:relative-from-absolute-path(., $config/config:spfeot-home,'$SPFEOT_HOME')"/>-->
								</source-file>
							</xsl:for-each>
							<namespace-uri><xsl:value-of select="$namespace-uri"/></namespace-uri>
							<xsl:for-each select="current-group()/xfd:definition">
								<definition>
									<xsl:copy-of select="./*"/>
								</definition>
							</xsl:for-each>
							
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
							
							<return-value>
								<type>
									<xsl:value-of select="xfd:return-type"/>
								</type>
								<xsl:apply-templates select="$function-description/fd:return-value/fd:description"/>
							</return-value>
							
							
							<parameters>
								<!-- parameters by name -->
								<!-- FIXME: need to detect optional parameters -->
								<xsl:variable name="parent-group" select="current-group()"/>
								<xsl:for-each-group select="current-group()/xfd:parameters/xfd:parameter" group-by="xfd:name">
									<xsl:variable name="parameter-name" select="xfd:name[1]"/>
									<parameter>	
										<xsl:if test="$parent-group[not(xfd:parameters/xfd:parameter/xfd:name = current-grouping-key())]">
											<xsl:attribute name="optional">yes</xsl:attribute>
										</xsl:if>
										<name><xsl:value-of select="$parameter-name"/></name>
										<type><xsl:value-of select="xfd:type[1]"/></type>
										
										<xsl:variable name="authored" select="$function-description/fd:parameters/fd:parameter[fd:name = $parameter-name]/fd:description"/>
										<xsl:if test="not($authored)">
											<xsl:call-template name="sf:warning">
												<xsl:with-param name="message" select="'Parameter description not found ', string($parameter-name)"/>
											</xsl:call-template>
										</xsl:if>
										
										<xsl:apply-templates select="$authored"/>
										
									</parameter>
								</xsl:for-each-group>
							</parameters>
						</xsl-function>
					</spfe-xslt-function-reference-entry>
				</ss:topic>
			</xsl:for-each-group>
			<xsl:for-each-group select="xfd:template-definition" group-by="concat(xfd:namespace-uri, xfd:name)">
				<xsl:variable name="name" select="string(xfd:name[1])"/>
				<xsl:variable name="namespace-uri" select="string(xfd:namespace-uri[1])"/>
							
				<ss:topic 
					type="http://spfeopentoolkit.org/spfe-docs/topic-types/template-reference" 
					full-name="http://spfeopentoolkit.org/spfe-docs/topic-types/template-reference/{concat(xfd:local-prefix, '_', xfd:name)}"
					local-name="{xfd:name}"
					topic-type-alias=
					"{sf:get-topic-type-alias-singular('http://spfeopentoolkit.org/spfe-docs/topic-types/template-reference')}"
					title="{xfd:name}">
					<ss:index>
						<ss:entry>
							<ss:type>spfe-xslt-template-reference-entry</ss:type>
							<ss:namespace><xsl:value-of select="$namespace-uri"/></ss:namespace>
							<ss:term><xsl:value-of select="$name"/></ss:term>
						</ss:entry>
						<ss:entry>
							<ss:type>xslt-template-name</ss:type>
							<ss:namespace><xsl:value-of select="$namespace-uri"/></ss:namespace>
							<ss:term><xsl:value-of select="$name"/></ss:term>
						</ss:entry>
					</ss:index>
					
					<spfe-xslt-template-reference-entry>
						<xsl-template>
							<name><xsl:value-of select="xfd:name[1]"/></name>
							<local-prefix><xsl:value-of select="xfd:local-prefix[1]"/></local-prefix>
							<xsl:for-each select="xfd:source-file">
								<source-file>
									<xsl:value-of select="."/>
<!--									<xsl:value-of select=" sf:relative-from-absolute-path(., $config/config:spfeot-home,'$SPFEOT_HOME')"/>
-->								</source-file>
							</xsl:for-each>
							<namespace-uri><xsl:value-of select="$namespace-uri"/></namespace-uri>
							<xsl:for-each select="current-group()/xfd:definition">
								<definition>
									<xsl:copy-of select="./*"/>
								</definition>
							</xsl:for-each>
							
							<xsl:variable name="template-description" select="$function-source/fd:function-and-template-descriptions/fd:body[fd:namespace-uri eq $namespace-uri]/fd:template-description[fd:name eq $name]"/>
							
							<!-- Select and copy the authored template info. -->
							<xsl:choose>
								<!-- Test that the information exists. -->
								<xsl:when test="exists($template-description/*)">
									<xsl:apply-templates select="$template-description/fd:description"/>
								</xsl:when>
								<xsl:otherwise><!-- If not found, report warning. -->
									<xsl:call-template name="sf:warning">
										<xsl:with-param name="message" select="'Template description not found ', string($name)"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							
							<parameters>
								<!-- parameters by name -->
								<!-- FIXME: need to detect optional parameters -->
								<xsl:variable name="parent-group" select="current-group()"/>
								<xsl:for-each-group select="current-group()/xfd:parameters/xfd:parameter" group-by="xfd:name">
									<xsl:variable name="parameter-name" select="xfd:name[1]"/>
									<parameter>	
										<xsl:if test="$parent-group[not(xfd:parameters/xfd:parameter/xfd:name = current-grouping-key())]">
											<xsl:attribute name="optional">yes</xsl:attribute>
										</xsl:if>
										<name><xsl:value-of select="$parameter-name"/></name>
										<type><xsl:value-of select="xfd:type[1]"/></type>
										
										<xsl:variable name="authored" select="$template-description/fd:parameters/fd:parameter[fd:name = $parameter-name]/fd:description"/>
										<xsl:if test="not($authored)">
											<xsl:call-template name="sf:warning">
												<xsl:with-param name="message" select="'Parameter description not found ', string($parameter-name)"/>
											</xsl:call-template>
										</xsl:if>
										
										<xsl:apply-templates select="$authored"/>
										
									</parameter>
								</xsl:for-each-group>
							</parameters>
						</xsl-template>
					</spfe-xslt-template-reference-entry>
				</ss:topic>
			</xsl:for-each-group>
		</ss:synthesis>
	</xsl:result-document>
</xsl:template>

<xsl:template match="xfd:template-definition" />

<xsl:template match="fd:description">
	<description>
		<xsl:apply-templates/>
	</description>
</xsl:template>
</xsl:stylesheet>

