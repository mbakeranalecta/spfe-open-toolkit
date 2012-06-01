<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    >
    <xsl:import href="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/scripts/presentation/common/present-toc.xsl"/>
    <xsl:template match="topics-of-type[@type='http://spfeopentoolkit.org/spfe-docs/schemas/topic-types/element-reference']" mode="toc">
        <xsl:for-each-group select="//topic" group-by="schema-element/doctype">
            <xsl:sort select="current-grouping-key()"/>
            <xsl:call-template name="make-schema-toc">
                <xsl:with-param name="level" select="1"/>
                <xsl:with-param name="items" select="current-group()"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="make-schema-toc">
        <xsl:param name="level"/>
        <xsl:param name="items"/>
        <xsl:for-each-group select="$items[sf:path-depth(schema-element/doc-xpath)=$level]" group-by="schema-element/doc-xpath">
            <node id="{translate(name, '/:', '__')}"
                name="{schema-element/name}">
                <xsl:call-template name="make-schema-toc">
                    <xsl:with-param name="level" select="$level+1"/>
                    <xsl:with-param name="items" select="$items[starts-with(schema-element/xpath, concat(current()/schema-element/xpath, '/'))]"/>
                </xsl:call-template>
            </node>
        </xsl:for-each-group>
    </xsl:template> 
    
</xsl:stylesheet>