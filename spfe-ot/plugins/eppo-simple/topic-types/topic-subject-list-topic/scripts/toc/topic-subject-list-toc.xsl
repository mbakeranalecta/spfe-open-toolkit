<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
    exclude-result-prefixes="#all"
    >
    
    <xsl:template match="topics-of-type[@type='{http://spfeopentoolkit.org/ns/eppo-simple}subject-topic-list']" mode="toc">
        <xsl:for-each-group select="//es:subject-topic-list" group-by="es:subject-type">
            <node topic-type="{es:subject-type}"  name="{sf:get-subject-type-alias-plural(es:subject-type,$config)}">
                <xsl:for-each select="current-group()">
                    <node id="{ancestor::ss:topic/@local-name}"
                        name="{es:subject}"/>
                </xsl:for-each>
            </node>
        </xsl:for-each-group>
    </xsl:template>
    
</xsl:stylesheet>