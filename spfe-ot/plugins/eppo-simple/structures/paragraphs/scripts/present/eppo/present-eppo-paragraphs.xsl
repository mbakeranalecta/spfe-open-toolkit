<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
 xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
 xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config"
 xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
 exclude-result-prefixes="#all" xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple">

 <xsl:template match="p">
  <!-- suppress empty paragraphs -->
  <xsl:if test="not(normalize-space(.) eq '')">
   <pe:p>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
   </pe:p>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
