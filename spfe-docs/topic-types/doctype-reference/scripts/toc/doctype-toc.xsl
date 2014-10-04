<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:re="http://spfeopentoolkit.org/ns/spfe-docs" exclude-result-prefixes="#all">
    
    <xsl:function name="sf:first-step-of-xpath">
        <xsl:param name="xpath"/>
        <xsl:variable name="steps" select="tokenize($xpath, '/')"/>
        <xsl:value-of select="if (starts-with($xpath, '/')) then concat('/', $steps[2]) else $steps[1]"/>
    </xsl:function>
    
    <xsl:template match="topics-of-type[@type='{http://spfeopentoolkit.org/ns/spfe-docs}doctype-reference-entry']" mode="toc">
        
        <xsl:for-each-group select="//re:doctype-reference-entry" group-by="sf:first-step-of-xpath(re:expath)">
            <xsl:sort select="re:xpath"/>
            <xsl:call-template name="make-doctype-toc">
                <xsl:with-param name="level" select="1"/>
                <xsl:with-param name="items" select="current-group()"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="make-doctype-toc">
        <xsl:param name="level"/>
        <xsl:param name="items"/>
        <xsl:message select="$level, ' ' , count($items)"></xsl:message>
        
        <xsl:for-each-group select="$items[sf:path-depth(re:xpath)=$level]" group-by="re:xpath">
            <xsl:variable name="xpath" select="re:xpath"/>
            <!-- FIXME: the node id should probably be read from the ss:topic/@local-name rather than recalculated like this -->
            <node id="{translate(re:xpath, '/:', '__')}" name="{re:name}">
                <xsl:call-template name="make-doctype-toc">
                    <xsl:with-param name="level" select="$level+1"/>
                    <xsl:with-param name="items" select="$items[starts-with(re:xpath, concat($xpath, '/'))]"/>
                </xsl:call-template>
            </node>
        </xsl:for-each-group>
    </xsl:template> 
    
</xsl:stylesheet>