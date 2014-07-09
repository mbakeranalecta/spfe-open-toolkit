<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	xmlns="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/link-catalog" 
	xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/link-catalog"
	exclude-result-prefixes="#all">

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>

	<xsl:param name="synthesis-files"/>
	<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>

	<xsl:param name="topic-set-id"/>
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
	
	<xsl:param name="output-directory" select="$config/config:link-catalog-directory"/>

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
		<!-- Create the root "synthesis element" -->
		<xsl:result-document href="file:///{concat($output-directory, '/', $topic-set-id, '.link-catalog.xml')}" method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no">
			<xsl:apply-templates select="$synthesis"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="ss:synthesis">
		<link-catalog topic-set-id="{@topic-set-id}"
		output-directory="{$config/config:topic-set[config:topic-set-id=$topic-set-id]/config:output-directory}"		
			title="{@title}"
			time-stamp="{current-dateTime()}">
			<xsl:apply-templates/>
		</link-catalog>
	</xsl:template>
	
	<!-- FIXME: should this match be qualified by a type parameter? -->
	<xsl:template match="ss:topic">
		<xsl:variable name="name" select="@local-name"/>
		<page local-name="{@local-name}" 
			  full-name="{@full-name}"
			  title="{@title}" 
			  file="{@local-name}.html"
			  topic-type="{if (@virtual-type) then @virtual-type else @type}" 
			  topic-type-alias="{@topic-type-alias}"
			  link-priority="{sf:get-topic-link-priority(@type,parent::ss:synthesis/@topic-set-id, $config)}"
			  excerpt="{@excerpt}">
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
					<xsl:if test="*:namespace">					
						<namespace>
							<xsl:value-of select="*:namespace"/>
						</namespace>
					</xsl:if>					
					<original-key>
						<xsl:value-of select="translate(*:term[1], '{}', '')"/>
						<xsl:if test="*:term[2]">
							<xsl:call-template name="sf:warning">
								<xsl:with-param name="message">only one term allowed per reference -
									please split up your terms: term 1 is "<xsl:value-of
										select="*:term[1]"/>", term 2 is "<xsl:value-of
										select="*:term[2]"/>" </xsl:with-param>
							</xsl:call-template>
						</xsl:if>
					</original-key>
					<xsl:variable name="references">
						<xsl:for-each-group select="*:term[normalize-space(.) ne '']" group-by=".">
							<xsl:call-template name="construct-index-key">
								<xsl:with-param name="key" select="."/>
							</xsl:call-template>
							<!-- get the synonyms for this key -->
							<xsl:for-each select="$synonyms/synonyms/synonym[word=current()]/word">
								<xsl:call-template name="construct-index-key">
									<xsl:with-param name="key" select="."/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:for-each-group>
					</xsl:variable>
					<!-- eliminate the duplicates -->
					<xsl:for-each-group select="$references/key" group-by=".">
						<xsl:sequence select="."/>
					</xsl:for-each-group>
					<xsl:sequence select="$references/key-set"/>
				</target>
			</xsl:for-each>
			<xsl:apply-templates/>
		</page>
	</xsl:template>

	<xsl:template name="construct-index-key">
		<xsl:param name="key" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="matches($key, '\{([^\}]*)\}')">
				<xsl:analyze-string select="$key" regex="\{{([^}}]*)\}}">
					<xsl:matching-substring>
						<xsl:choose>
							<!-- if empty, ignore -->
							<xsl:when test="regex-group(1)=''"/>
							<!-- recognize {{} as escape sequence for { -->
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
						<!-- throw away any text that is not part if a key -->
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

	<!-- Suppress everything else, but process all templates to allow other link 
		catalog scripts to include this script and process other elements to create 
		other targets. -->
	<xsl:template match="*" >
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="text()" priority="-0.1"/>
</xsl:stylesheet>
