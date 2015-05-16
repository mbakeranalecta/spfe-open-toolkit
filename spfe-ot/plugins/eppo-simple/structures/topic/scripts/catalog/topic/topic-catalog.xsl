<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
	xmlns="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/catalog" 
	xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/catalog"
	exclude-result-prefixes="#all">

	<xsl:variable name="config" as="element(config:config)">
		<xsl:sequence select="/config:config"/>
	</xsl:variable>

	<xsl:param name="synthesis-files"/>
	<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>

	<xsl:param name="set-id"/>
	<xsl:variable name="topic-set-id" select="$set-id"/>
	<!-- processing directives -->
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:strip-space elements="element-name attribute-name xpath attribute-value code term"/>

	<!-- FIXME: this needs redoing in a way that is compatible with config -->
	<xsl:param name="synonyms-files-names"/>
	<xsl:variable name="synonyms-text" xml:base="synonyms/">
		<xsl:for-each
			select="tokenize(translate($synonyms-files-names,'\','/'), $config/config:dir-separator)">
			<xsl:value-of select="unparsed-text(.)"/>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:param name="output-directory" select="$config/config:catalog-directory"/>

	<xsl:variable name="synonyms">
		<synonyms>
			<xsl:if test="$synonyms-text">
				<xsl:analyze-string select="$synonyms-text" regex="\r\n|\r|\n">
					<xsl:non-matching-substring>
						<synonym>
							<xsl:analyze-string select="." regex="\s*,\s*">
								<xsl:non-matching-substring>
									<word>
										<xsl:value-of select="."/>
									</word>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
						</synonym>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:if>
		</synonyms>
	</xsl:variable>

<!-- 
=============
Main template
=============
-->

	
	<xsl:template name="main" >		
		<xsl:result-document href="file:///{concat($output-directory, '/', $topic-set-id, '.catalog.xml')}" method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no">
			<xsl:apply-templates select="$synthesis"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="ss:synthesis">
		<catalog topic-set-id="{@topic-set-id}"
		output-directory="{$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:output-directory}"		
			title="{@title}"
			time-stamp="{current-dateTime()}">
			<xsl:apply-templates/>
		</catalog>
	</xsl:template>
	
	<!-- FIXME: should this match be qualified by a type parameter? -->
	<xsl:template match="ss:topic" priority="+1">
		<xsl:variable name="name" select="@local-name"/>
		<page local-name="{@local-name}" 
			  full-name="{@full-name}"
			  title="{@title}" 
			  topic-type="{@type}" 
			  topic-type-alias="{@topic-type-alias}"
			  excerpt="{@excerpt}"
			  link-priority="{sf:get-topic-link-priority(@type, parent::ss:synthesis/@topic-set-id, $config)}">
			
			<xsl:choose>
				<xsl:when test="@scope">
					<xsl:attribute name="scope" select="@scope"/>
				</xsl:when>
				<xsl:when test="$config/config:default-topic-scope">
					<xsl:attribute name="scope" select="$config/config:default-topic-scope"/>
				</xsl:when>
			</xsl:choose>
			
			<!-- topic references -->
			<target type="topic">
				<type>topic</type>
				<label>
					<xsl:value-of select="@title"/>
				</label>
				<key>
					<xsl:value-of select="@full-name"/>
				</key>
			</target>
			<!-- read the internal index to locate references in this topic -->
			<xsl:for-each select="descendant::*:index/*:entry[normalize-space(.) ne '']">
				<!-- collect up all the references -->
				<target type="{*:type}">
					<type><xsl:value-of select="*:type"/></type>
					<xsl:if test="*:namespace">					
						<namespace>
							<xsl:value-of select="*:namespace"/>
						</namespace>
					</xsl:if>	
					<xsl:for-each select="*:term">
						<term>
							<xsl:value-of select="."/>
						</term>
						<key>
							<xsl:value-of select="."/>
						</key>
					</xsl:for-each>
					<xsl:for-each select="*:key">
						<key>
							<xsl:value-of select="."/>
						</key>
					</xsl:for-each>
				</target>
			</xsl:for-each>
			<xsl:apply-templates/>
		</page>
	</xsl:template>

<!--	<xsl:template name="construct-index-key">
		<xsl:param name="key" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="matches($key, '\{([^\}]*)\}')">
				<xsl:analyze-string select="$key" regex="\{{([^}}]*)\}}">
					<xsl:matching-substring>
						<xsl:choose>
							<!-\- if empty, ignore -\->
							<xsl:when test="regex-group(1)=''"/>
							<!-\- recognize {{} as escape sequence for { -\->
							<xsl:when test="regex-group(1)='{'">
								<xsl:value-of select="regex-group(1)"/>
							</xsl:when>
							<xsl:otherwise>
								<key-set>
									<key>
										<xsl:value-of select="regex-group(1)"/>
									</key>
									<xsl:for-each
										select="$synonyms/synonyms/synonym[word=regex-group(1)]/word[. ne regex-group(1)]">
										<key>
											<xsl:value-of select="."/>
										</key>
									</xsl:for-each>
								</key-set>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<!-\- throw away any text that is not part if a key -\->
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<xsl:otherwise>
				<key>
					<xsl:value-of select="$key"/>
				</key>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
-->
	<!-- Suppress everything else, but process all templates to allow other link 
		catalog scripts to include this script and process other elements to create 
		other targets. -->
	<xsl:template match="*" >
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="text()" priority="-0.1"/>
</xsl:stylesheet>
