<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:template match="gr:graphic-record">
        <gr:graphic-record>
            <!-- copy everything except the default caption -->
            <xsl:copy-of  select="gr:name" copy-namespaces="no"/>
            <xsl:copy-of  select="gr:alt" copy-namespaces="no"/>
            <xsl:copy-of  select="gr:uri" copy-namespaces="no"/>
            <xsl:copy-of select="gr:formats" copy-namespaces="no"/>
            <xsl:copy-of select="gr:source" copy-namespaces="no"/>
        </gr:graphic-record>
    </xsl:template>
    
    <xsl:template match="gr:*" />
    
</xsl:stylesheet>