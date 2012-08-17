<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all">
 
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-references.xsl"/>
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-text-structures.xsl"/>
  <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-topic-set.xsl"/>

  <xsl:include href="present-element.xsl"/>
<xsl:param name="draft">no</xsl:param>

  <xsl:variable name="config" as="element(config:spfe)">
    <xsl:sequence select="/config:spfe"/>
  </xsl:variable>
  
<!-- processing directives -->
<xsl:output method="xml" indent="yes"/>

<xsl:param name="media">online</xsl:param>

<xsl:param name="synthesis-files"/>
<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>
  	
</xsl:stylesheet>
