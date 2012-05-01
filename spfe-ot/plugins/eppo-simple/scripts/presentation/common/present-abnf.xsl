<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> <!--
=============================
Present expanded ABNF
=============================
-->

<xsl:template name="format-expanded-abnf">
	<xsl:param name="production"/>
	<xsl:apply-templates select="$production" mode="format-expanded-abnf"/>
</xsl:template>

<xsl:template match="production" mode="format-expanded-abnf">
	<xsl:apply-templates mode="format-expanded-abnf"/>
</xsl:template>


<xsl:template match="expansion" mode="format-expanded-abnf">
	<xsl:text> = </xsl:text>
	<xsl:apply-templates mode="format-expanded-abnf"/>
	<xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="description" mode="format-expanded-abnf">
	<!-- <xsl:value-of select="."/> -->
</xsl:template>

<xsl:template match="*" mode="format-expanded-abnf">
	<xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<xsl:template match="ws" mode="format-expanded-abnf">
	<xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="or" mode="format-expanded-abnf">
	<xsl:text>/</xsl:text>
</xsl:template>

<xsl:template match="abnf-symbol-ref" mode="format-expanded-abnf">
	<xsl:variable name="symbol" select="."/>
	<xsl:choose>
		<xsl:when test="ancestor::syntax/production[symbol=$symbol]/description/p/text()">
			<tool-tip class="gloss" title="{ancestor::syntax/production[symbol=$symbol]/description/p/text()}">
				<xsl:value-of select="."/>
			</tool-tip>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="symbol" mode="format-expanded-abnf">
	<xsl:variable name="symbol" select="."/>
	<!-- Insert a zero-width-non-breaking-space so indenter recognizes 
	this as a text node and does not indent it (which would add spurious
	white space to output -->
	<xsl:text>&#8288;</xsl:text>
	<xsl:choose>
		<xsl:when test="../description/p/text()">	
			<tool-tip class="gloss" title="{../description/p/text()}">
				<xsl:value-of select="."/>
			</tool-tip>
		</xsl:when>
		<xsl:otherwise>
				<xsl:value-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="text()" mode="format-expanded-abnf">
	<xsl:value-of select="normalize-space(.)"/>
</xsl:template>
</xsl:stylesheet>
