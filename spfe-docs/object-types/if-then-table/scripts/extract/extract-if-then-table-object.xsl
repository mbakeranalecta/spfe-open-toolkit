<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->

<!-- FIXME: does this belong with the data type or with the text object type??? -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sdto="http://spfeopentoolkit.org/ns/spfe-docs/objects"
    xmlns:sd="http://spfeopentoolkit.org/ns/spfe-docs"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/spfe-docs" exclude-result-prefixes="#all"
    version="2.0">

    <xsl:param name="topic-set-id"/>

    <xsl:variable name="config" as="element(config:spfe)">
        <xsl:sequence select="/config:spfe"/>
    </xsl:variable>

    <xsl:param name="sources-to-extract-content-from"/>
    <xsl:param name="output-directory"/>
    <xsl:variable name="state-detection" select="sf:get-sources($sources-to-extract-content-from)"/>

    <xsl:template name="main">
        <!-- FIXME: Should check for duplicate IDs. -->
        <xsl:apply-templates select="$state-detection"/>
    </xsl:template>

    <xsl:template match="state-detection">
        <xsl:result-document
            href="file:///{$output-directory}/{id}.xml"
            method="xml" indent="yes" omit-xml-declaration="no">
           <sdto:if-then-table-object>
               <sdto:head>
                   <sdto:id>
                       <xsl:value-of select="id"/>
                   </sdto:id>
               </sdto:head>
               <sdto:body>
                   <xsl:if test="title">
                       <sdto:title>
                           <xsl:apply-templates select="title"/>
                       </sdto:title>
                   </xsl:if>
                   <xsl:if test="caption">
                       <sdto:caption>
                           <sdto:p>
                               <xsl:apply-templates select="caption"/>
                           </sdto:p>
                       </sdto:caption>
                   </xsl:if>
                   <sdto:if-then-table>
                       <sdto:if-then-table-head>
                           <xsl:for-each select="signs/sign">
                               <sdto:td>
                                   <sdto:p>
                                   <xsl:choose>
                                       <xsl:when test="position()=1">
                                           <xsl:text>When </xsl:text>
                                       </xsl:when>
                                       <xsl:otherwise>
                                           <xsl:text>And </xsl:text>
                                       </xsl:otherwise>
                                   </xsl:choose>
                                   <xsl:value-of select="caption"/>
                                   <xsl:text> ...</xsl:text>
                                   </sdto:p>
                               </sdto:td>
                           </xsl:for-each>
                           <sdto:td>
                               <sdto:p>Then ...</sdto:p>
                           </sdto:td>
                       </sdto:if-then-table-head>
                       <sdto:if-then-table-body>
                           <xsl:call-template name="process-signs">
                               <xsl:with-param name="signs" select="signs/sign"/>
                               <xsl:with-param name="sign-number" select="1"/>
                               <xsl:with-param name="states" select="states/state"/>
                           </xsl:call-template>
                       </sdto:if-then-table-body>
                   </sdto:if-then-table>
               </sdto:body>
           </sdto:if-then-table-object>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="state-detection/*" priority="-1"/> 
    
    <xsl:template match="state-detection/title">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="state-detection/caption">
        <xsl:apply-templates/>
    </xsl:template>
    

    <xsl:template name="process-signs">
        <xsl:param name="signs"/>
        <xsl:param name="sign-number"/>
        <xsl:param name="states"/>
        <!--<xsl:sequence select="$states"/>-->
        <xsl:variable name="this-sign" select="$signs[$sign-number]"/>
        <xsl:for-each select="$this-sign/signals/signal[. = $states/signs/sign[name = $this-sign/name]/signal]">
            <xsl:variable name="this-signal" select="."/>
            <sdto:if-then-row>
                <sdto:if>
                    <sdto:p>
                        <xsl:value-of select="$this-signal"/>
                    </sdto:p>
                </sdto:if>
                <sdto:then>
                    <xsl:choose>
                        <xsl:when test="count($signs) = $sign-number">
                            <xsl:if test="$states[signs/sign[name = $this-sign/name][signal = $this-signal]][2]">
                                <xsl:call-template name="sf:error">
                                    <xsl:with-param name="message">Found more than one state matching the same sign/signal combination. <xsl:value-of select="$states"/></xsl:with-param>
                                    <xsl:with-param name="in" select="base-uri(document(''))"/>
                                </xsl:call-template>
                            </xsl:if>
                         
                            <sdto:do>
                                <sdto:p>
                                    <xsl:value-of select="$states[signs/sign[name = $this-sign/name][signal = $this-signal]]/action"/>
                                </sdto:p>
                            </sdto:do>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="process-signs">
                                <xsl:with-param name="signs" select="$signs"/>
                                <xsl:with-param name="sign-number" select="$sign-number + 1"/>
                                <xsl:with-param name="states" select="$states[signs/sign[name = $this-sign/name][signal = $this-signal]]"></xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </sdto:then>
            </sdto:if-then-row>            
        </xsl:for-each>

        
    </xsl:template>


</xsl:stylesheet>
