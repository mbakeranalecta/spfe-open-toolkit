<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    version="2.0">
    
    <xsl:template match="
        p/directory-name  | string/directory-name
        | p/document-name  | string/document-name
        | p/file-name  | string/file-name
        | p/product-name  | string/product-name
        | p/tool-name  | string/tool-name
        | p/xml-namespace-uri  | string/xml-namespace-uri
                       ">
        <name>
            <xsl:attribute name="type" select="local-name()"/>
            <xsl:attribute name="key" select="if (@specifically) then @specifially else normalize-space(.)"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>

</xsl:stylesheet>