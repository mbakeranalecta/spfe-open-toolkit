<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all">
 
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
<!-- <xsl:import href="present-generic-topic.xsl"/> -->
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-references.xsl"/>
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-text-structures.xsl"/>
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-topic-set.xsl"/>
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-toc.xsl"/>
  <xsl:include href="present-element.xsl"/>
<xsl:param name="draft">no</xsl:param>

  <xsl:variable name="config" as="element(config:spfe)">
    <xsl:sequence select="/config:spfe"/>
  </xsl:variable>
  
<!-- processing directives -->
<xsl:output method="xml" indent="yes"/>

<xsl:param name="media">online</xsl:param>

<xsl:param name="synthesis-files"/>
  <xsl:variable name="synthesis-dir" select="concat($config/config:build/config:build-directory, '/temp/synthesis/')"/>
  
  <xsl:variable name="synthesis">
    <xsl:for-each select="tokenize($synthesis-files, $config/config:dir-separator)">
      <xsl:sequence select="doc(concat('file:///',$synthesis-dir, .))"/>	
    </xsl:for-each>
  </xsl:variable>

<!-- 
========
TOC page
========
-->


  <xsl:template match="topics-of-type[@type='http://spfeopentoolkit.org/spfe-docs/schemas/topic-types/element-reference']" mode="toc">
			<xsl:for-each-group select="//topic" group-by="schema-element/doctype">
				<xsl:sort select="current-grouping-key()"/>
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
