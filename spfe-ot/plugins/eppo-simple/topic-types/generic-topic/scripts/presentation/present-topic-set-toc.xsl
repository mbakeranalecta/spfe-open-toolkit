<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
    xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    exclude-result-prefixes="#all">
    
    <!-- processing directives -->
    <xsl:output method="xml" indent="yes"/> 
    
    <!-- FIXME: Why is this script reading all the TOC files? Only actually processing the file for this topic-set. -->
    <xsl:param name="toc-files"/>
    <xsl:variable name="unsorted-toc" >
        <xsl:variable name="temp-tocs" select="sf:get-sources($toc-files, 'Loading toc file: ')"/>
        <xsl:if test="count(distinct-values($temp-tocs/toc/@topic-set-id)) lt count($temp-tocs/toc)">
            <xsl:call-template name="sf:error">
                <xsl:with-param name="message">
                    <xsl:text>Duplicate TOCs detected.&#x000A; There appears to be more than one TOC in scope for the same topic set. Topic set IDs encountered include:&#x000A;</xsl:text>
                    <xsl:for-each select="$temp-tocs/toc">
                        <xsl:value-of select="@topic-set-id,'&#x000A;'"/>
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:sequence select="$temp-tocs"/>
    </xsl:variable>
    
    <xsl:variable name="toc">
        <xsl:choose>
            <xsl:when test="$config/config:doc-set/config:topic-set-type-order/config:topic-set-type">
                
                <!-- Make sure there is an entry on the topic set type order list for every topic set type. -->
                <xsl:variable name="topic-set-types-found" select="distinct-values($unsorted-toc/toc/@topic-set-type)"/>
                
                <!-- FIXME: Why is topic-set-type order being tested here? -->
                <!-- Make sure all the topic set types appear on the topic type order list -->
                <xsl:call-template name="sf:info">
                    <xsl:with-param name="message">
                        <xsl:text>Ordering the TOC according to the topic set type list:</xsl:text>
                        <xsl:value-of select="string-join($config/config:doc-set/config:topic-set-type-order/config:topic-set-type, ', ')"/>
                    </xsl:with-param>
                </xsl:call-template>				
                
                <xsl:if test="count($topic-set-types-found[not(.=$config/config:doc-set/config:topic-set-type-order/config:topic-set-type)])">
                    <xsl:call-template name="sf:error">
                        <xsl:with-param name="message" select="'Topic type(s) missing from topic type order list: ', string-join($topic-set-types-found[not(.=$config/config:doc-set/config:topic-set-type-order/config:topic-set-type)], ', ')"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:for-each select="$config/config:doc-set/config:topic-set-type-order/config:topic-set-type">
                    <xsl:variable name="this-topic-set-type" select="."/>
                    <xsl:for-each select="$unsorted-toc/toc[@topic-set-type eq $this-topic-set-type]">
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </xsl:for-each>
                
            </xsl:when>
            <xsl:when test="$config/config:doc-set/config:topic-sets">
                <xsl:call-template name="sf:warning">
                    <xsl:with-param name="message">
                        <!-- FIXME: Should test for the two conditions subject-affinityed below. -->
                        <xsl:text>Topic set type order not specified. TOC will be in the order topic sets are listed in the /spfe/doc-set configuration setting. External TOC files will be ignored. If topic set IDs specified in doc set configuration do not match those defined in the topic set, that topic set will not be included.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:for-each select="$config/config:doc-set/config:topic-sets/config:topic-set">
                    <xsl:variable name="id" select="config:id"/>
                    <xsl:sequence select="$unsorted-toc/toc[@topic-set-id eq $id]"/>
                </xsl:for-each>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="sf:warning">
                    <xsl:with-param name="message">
                        <xsl:text>Doc set configuration not found in config file. TOC will be in alphabetical order by topic-set-type.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:for-each select="$unsorted-toc/toc">
                    <xsl:sort select="@topic-set-type"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- TOC templates -->
    <xsl:template name="create-toc-page">
        
        <xsl:variable name="topic-set-title" select="sf:string($config/config:topic-set[config:topic-set-id=$topic-set-id]/config:strings, 'eppo-simple-topic-set-title')"/>

        <page status="generated" name="{$topic-set-id}-toc">
            <xsl:call-template name="show-header"/>
            <title>List of topics in <xsl:value-of select="$topic-set-title"></xsl:value-of></title>        
            <xsl:apply-templates select="$toc"/>
            <xsl:call-template name="show-footer"/>		
        </page>
    </xsl:template>
    
    <xsl:template match="toc[@topic-set-id=$topic-set-id]">
        <ul>
         <xsl:apply-templates/>
        </ul> 
    </xsl:template>
    <xsl:template match="toc"/>
    
    <xsl:template match="node[@topic-type]">
        <!-- FIXME: title may not be the right markup here, or may need explicit handling at format stage -->
        <li>
          <title><xsl:value-of select="@name"/></title>
          <ul>
              <xsl:apply-templates/>
          </ul>
        </li>
    </xsl:template>
    
    <xsl:template match="node">
        <li>
            <p><xref target="{normalize-space(@id)}.html"><xsl:value-of select="@name"/></xref></p>
            <xsl:if test="node">
                <ul>
                    <xsl:apply-templates/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>
    
</xsl:stylesheet>