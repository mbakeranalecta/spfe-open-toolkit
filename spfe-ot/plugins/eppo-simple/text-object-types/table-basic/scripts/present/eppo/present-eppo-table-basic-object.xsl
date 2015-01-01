<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple/text-objects"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/text-objects"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:template match="table-basic-object">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="table-basic-object/head"/>
    
    <xsl:template match="table-basic-object/body">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>