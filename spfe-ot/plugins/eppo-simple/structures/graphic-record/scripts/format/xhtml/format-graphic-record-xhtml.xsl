<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <xsl:template match="gr:graphic-record">
        <!-- Select preferred format -->
        <xsl:variable name="available-preferred-formats">
            <xsl:variable name="graphic" select="."/>
            <xsl:for-each select="$preferred-formats">
                <xsl:variable name="format" select="."/>
                <xsl:sequence select="$graphic//gr:format[gr:type/text() eq $format]"/>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- FIXME: should test for no match, and decide what to do if unexpected format provided -->
        <xsl:variable name="graphic-file-name" select="sf:get-file-name-from-path($available-preferred-formats/gr:format[1]/gr:href)"/>
        <!-- FIXME: image directory location should probably be configurable -->
        <img src="images/{$graphic-file-name}" alt="{gr:graphic-record/gr:alt}" title="{gr:graphic-record/gr:name}"/>
    </xsl:template>
    
    <xsl:template match="gr:*"/>
</xsl:stylesheet>