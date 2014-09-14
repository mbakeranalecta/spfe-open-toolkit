<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:re="http://spfeopentoolkit.org/ns/spfe-docs">
    
    <xsl:template match="topics-of-type[@type='{http://spfeopentoolkit.org/ns/spfe-docs}doctype-reference-entry']" mode="toc">
        
        <xsl:for-each-group select="//re:doctype-reference-entry" group-by="re:doctype">
            <xsl:sort select="current-grouping-key()"/>
            <xsl:call-template name="make-doctype-toc">
                <xsl:with-param name="level" select="1"/>
                <xsl:with-param name="items" select="current-group()"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="make-doctype-toc">
        <xsl:param name="level"/>
        <xsl:param name="items"/>
        
        <xsl:for-each-group select="$items[sf:path-depth(re:doc-xpath)=$level]" group-by="re:doc-xpath">
            <!-- FIXME: the node id should probably be read from the ss:topic/@local-name rather than recalculated like this -->
            <node id="{translate(re:xpath, '/:', '__')}"
                name="{re:name}">
                <xsl:call-template name="make-doctype-toc">
                    <xsl:with-param name="level" select="$level+1"/>
                    <xsl:with-param name="items" select="$items[starts-with(re:xpath, concat(current()/re:xpath, '/'))]"/>
                </xsl:call-template>
            </node>
        </xsl:for-each-group>
    </xsl:template> 
    
</xsl:stylesheet>