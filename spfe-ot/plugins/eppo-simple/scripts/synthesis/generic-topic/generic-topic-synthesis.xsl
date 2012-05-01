<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================
	synthesize-authored-topics.xsl
	
	Reads the collection of topic files and text object files
	for the topic set, processes the topic element, and hands 
	the rest of the processing off to the inculded stylesheets.

	=======================================================-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
xmlns:gt="http://spfeopentoolkit.org/spfe-docs/schemas/topic-types/generic-topic"
exclude-result-prefixes="#all">
	
	<xsl:template match="gt:generic-topic">
		<xsl:variable name="conditions" select="@if"/>
			<xsl:choose>
				<xsl:when test="sf:conditions-met($conditions, $condition-tokens)">
					<ss:topic 
						element-name="{name()}" 
						type="{namespace-uri()}" 
						full-name="{concat(gt:head/gt:base-uri, '/', gt:head/gt:name)}"
						local-name="{gt:head/gt:name}"
						title="{gt:body/gt:title}">
						<xsl:if test="gt:head/gt:virtual-type">
							<xsl:attribute name="virtual-type" select="gt:head/gt:virtual-type"/>
						</xsl:if>
						<xsl:copy>
							<xsl:copy-of select="@*"/>
							<xsl:call-template name="apply-topic-attributes"/>
							<xsl:apply-templates/>
						</xsl:copy>
					</ss:topic>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="info">
						<xsl:with-param name="message">
							<xsl:text>Suppressing topic </xsl:text>
							<xsl:value-of select="name"/>
							<xsl:text> because its conditions (</xsl:text>
							<xsl:value-of select="$conditions"/>
							<xsl:text>) do not match the conditions specified for the build ( </xsl:text>
							<xsl:value-of select="$condition-tokens"/>
							<xsl:text>).</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>
	

</xsl:stylesheet>

