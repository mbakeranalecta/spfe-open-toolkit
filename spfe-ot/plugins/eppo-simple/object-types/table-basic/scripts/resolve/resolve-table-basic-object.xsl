<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
    exclude-result-prefixes="#all" 
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/objects">
    
    <xsl:template match="table-basic-object">
        <xsl:variable name="name" select="head/id"/>
        <xsl:variable name="type" select="sf:name-in-clark-notation(.)"/>
        <!-- FIXME: This assumes that IDs are unique, which is not guaranteed. Should detect duplicate IDs or randomize names. -->
        <xsl:result-document href="file:///{$output-directory}/{$name}.xml" method="xml" indent="no" omit-xml-declaration="no">
            <ss:synthesis xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" topic-set-id="spfe.objects" title="{sf:string($config//config:strings, 'product')} {sf:string($config//config:strings, 'product-release')}"> 
                <ss:object 
                    type="{$type}" 
                    full-name="{$type}#{$name}"
                    local-name="{$name}"
                    title="{body/title}"
                    excerpt="{sf:escape-for-xml(sf:first-n-words(descendant::p[1], 30, ' ...'))}">
                    <xsl:copy>
                        <xsl:copy-of select="@*" copy-namespaces="no"/>
                        <xsl:apply-templates/>
                    </xsl:copy>
                </ss:object>
            </ss:synthesis>
        </xsl:result-document>
        

    </xsl:template>
</xsl:stylesheet>