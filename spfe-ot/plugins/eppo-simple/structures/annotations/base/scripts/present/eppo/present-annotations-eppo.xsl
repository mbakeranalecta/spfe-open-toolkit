<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <!-- FIXME: Should this be in a "link" structure? It is not an annotation at this point. -->

    <xsl:template match="link | name">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>



    
    
</xsl:stylesheet>