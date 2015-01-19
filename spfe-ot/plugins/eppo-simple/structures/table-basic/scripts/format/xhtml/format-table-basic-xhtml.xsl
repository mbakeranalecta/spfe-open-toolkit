<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
    version="2.0">
    
    <!-- TABLE -->
    
    <xsl:template match="table">
        <!-- Move the title outside the table -->
        <xsl:if test="title">
            <h4>
                <xsl:text>Table&#160;</xsl:text>
                <xsl:value-of
                    select="count(ancestor::page//table/title intersect preceding::table/title)+1"/>
                <xsl:text>&#160;&#160;&#160;</xsl:text>
                <xsl:value-of select="title"/>
            </h4>
        </xsl:if>
        <table>
            <xsl:attribute name="class" select="if (@hint) then @hint else 'simple'"/>
            <xsl:apply-templates>
                <xsl:with-param name="column-width-weights" select="@column-width-weights"
                    tunnel="yes"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>
    
    <xsl:template match="tr">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    
    <xsl:template match="thead">
        <thead>
            <xsl:apply-templates/>
        </thead>
    </xsl:template>
    
    <xsl:template match="tbody">
        <tbody>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>
    
    <xsl:template match="th">
        <th align="left">
            <xsl:call-template name="get-column-width"/>
            <xsl:apply-templates/>
        </th>
    </xsl:template>
    
    <xsl:template match="td">
        <td align="left" valign="top">
            <!-- FIXME: Hack to get if-the-tables working. -->
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="get-column-width"/>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    
    <xsl:template name="get-column-width">
        <xsl:param name="column-width-weights" tunnel="yes"/>
        <xsl:if test="$column-width-weights">
            <xsl:variable name="weights" as="xs:integer*">
                <xsl:for-each select="tokenize(normalize-space($column-width-weights), ' ' )">
                    <xsl:value-of select="number(.)"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="total-weights" select="sum($weights)"/>
            <xsl:variable name="col-num" select="count(preceding-sibling::*)+1"/>
            <xsl:attribute name="style">
                <xsl:text>width:</xsl:text>
                <xsl:value-of select="$weights[$col-num] div $total-weights * 100"/>
                <xsl:text>%</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>