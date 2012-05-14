<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 exclude-result-prefixes="#all">
 
<xsl:import href="utility-functions.xsl"/> 
<!-- <xsl:import href="present-generic-topic.xsl"/> -->
<xsl:import href="present-text-structures.xsl"/>
<xsl:import href="present-references.xsl"/>
<xsl:import href="present-topic-set.xsl"/>
<xsl:import href="present-toc.xsl"/>
<xsl:include href="present-element.xsl"/>

<!-- processing directives -->
<xsl:output method="xml" indent="yes"/>

<xsl:param name="schema-synthesis-files">synthesis.xml</xsl:param>
<xsl:param name="media">online</xsl:param>

<xsl:variable name="synthesis" >
	<xsl:call-template name="info">
		<xsl:with-param name="message" select="'Reading schema synthesis files: ', $schema-synthesis-files"/>
	</xsl:call-template>
  <xsl:for-each select="tokenize($schema-synthesis-files, $config/config:dir-separator)">
		<xsl:sequence select="document(translate(.,'\','/'), document(''))"/>
	</xsl:for-each>
</xsl:variable>

  <xsl:template match="topics-of-type[@type='schema-element']"  mode="toc">
		<xsl:for-each-group select="$synthesis/synthesis/topic" group-by="tokenize(schema-element/xpath, '/')[. ne ''][1]">
			<xsl:sort select="name"/>
			<xsl:call-template name="make-schema-toc">
				<xsl:with-param name="level" select="1"/>
				<xsl:with-param name="items" select="current-group()"/>
			</xsl:call-template>
		</xsl:for-each-group>
	</xsl:template>


	<xsl:template name="make-schema-toc">
    <xsl:param name="level"/>
    <xsl:param name="items"/>
    <xsl:for-each-group select="$items[sf:path-depth(schema-element/doc-xpath)=$level]" group-by="schema-element/doc-xpath">
      <node id="{translate(name, '/:', '__')}"
          name="{schema-element/name}">
				<xsl:call-template name="make-schema-toc">
					<xsl:with-param name="level" select="$level+1"/>
					<xsl:with-param name="items" select="$items[starts-with(schema-element/xpath, concat(current()/schema-element/xpath, '/'))]"/>
				</xsl:call-template>
      </node>
    </xsl:for-each-group>
  </xsl:template>
		
</xsl:stylesheet>
