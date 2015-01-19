<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:lf="local-functions"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	exclude-result-prefixes="#all">
	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	<!-- FIXME: The preferred formats should be settable outside the script -->
	<xsl:variable name="preferred-format-list">svg,png,jpg,jpeg,gif</xsl:variable>
	<xsl:variable name="preferred-formats" as="xs:string*" select="tokenize($preferred-format-list , ',')"/>
	
	<xsl:variable name="draft" as="xs:boolean" select="$config/config:build-command='draft'"/>
	
	<xsl:param name="topic-set-id"/>
	<xsl:param name="output-directory"/>
	
	<xsl:param name="presentation-files"/>
	<xsl:variable name="presentation" select="sf:get-sources($presentation-files)"/>


	<xsl:strip-space elements="name"/>

	<xsl:function name="lf:html-header">
		<xsl:param name="title"/>
		<head>
			<title>
				<xsl:value-of select="$title"/>
			</title>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
			<xsl:if test="$config/config:build-command eq 'draft'">
				<meta http-equiv="Cache-Control" content="no-cache"/>
				<meta http-equiv="Pragma" content="no-cache"/>
				<meta http-equiv="expires" content="FRI, 13 APR 1999 01:00:00 GMT"/>
			</xsl:if>

			<link rel="stylesheet" type="text/css" href="style/eppo-simple.css"/>
			<link rel="stylesheet" type="text/css" href="style/css-tree.css"/>
		</head>
	</xsl:function>

	<xsl:variable name="html-page-footer">
		<div id="footer">
			<br/>
			<br/>
			<hr/>
			<!-- Timestamp and options DRAFT notice -->
			<p>
				<xsl:value-of
					select="format-dateTime(current-dateTime(),'Generated on [Y0001]-[M01]-[D01] [H01]:[m01]:[s01].')"/>
				<xsl:if test="$config/config:build-command eq 'draft'">
					<span class="draft">
						<xsl:text>***** DRAFT ***** ***** DRAFT ***** ***** DRAFT *****</xsl:text>
					</span>
				</xsl:if>
			</p>
		</div>
	</xsl:variable>

	<xsl:template name="output-html-page">
		<xsl:param name="file-name" as="xs:string"/>
		<xsl:param name="title"/>
		<xsl:param name="content"/>
		<!-- info -->
		<xsl:call-template name="sf:info">
			<xsl:with-param name="message" select="concat('Formatting page: ', $file-name)"/>
		</xsl:call-template>

		<xsl:result-document
			href="file:///{$output-directory}/{$file-name}"
			method="html" indent="no" omit-xml-declaration="no"
			doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xml:lang="en" lang="en">
				<xsl:sequence select="lf:html-header($title)"/>
				<xsl:choose>
					<xsl:when test="$content/*:frameset">
						<xsl:sequence select="$content"/>
					</xsl:when>
					<xsl:otherwise>
						<body>
							<xsl:sequence select="$content"/>
							<xsl:sequence select="$html-page-footer"/>
						</body>
					</xsl:otherwise>
				</xsl:choose>
			</html>
		</xsl:result-document>
	</xsl:template>


	<xsl:template name="main">
		<xsl:call-template name="sf:info">
			<xsl:with-param name="message">
				<xsl:choose>
					<xsl:when test="$config/config:build-command eq 'draft'">
						<xsl:text>Creating a draft HTML format of </xsl:text>
						<xsl:value-of select="$topic-set-id"/>
						<xsl:text> because build command was "draft".</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Creating a final HTML format of </xsl:text>
						<xsl:value-of select="$topic-set-id"/>
						<xsl:text> because build command was "final".</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:apply-templates select="$presentation/pages/page"/>
		<xsl:call-template name="generate-graphics-list"/>
	</xsl:template>


	<xsl:template match="header">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="footer">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template name="generate-graphics-list">
		<xsl:variable name="graphic-file-list" as="xs:string*">
			<xsl:for-each select="$presentation/pages/page//gr:graphic-record">	                                 
				<xsl:variable name="available-preferred-formats">
					<xsl:variable name="gr" select="."/>
					<xsl:for-each select="$preferred-formats">
						<xsl:variable name="format" select="."/>
						<xsl:sequence select="$gr//gr:format[gr:type/text() eq $format]"/>
					</xsl:for-each>
				</xsl:variable>
				<!-- FIXME: should test for no match, and decide what to do if unexpected format provided -->
				<xsl:value-of select="$available-preferred-formats/gr:format[1]/gr:href"/>
			</xsl:for-each>
		</xsl:variable>
		<!-- FIXME: Get this in sync with config file settings. -->
		<xsl:result-document
			href="file:///{$config/config:content-set-build}/topic-sets/{$topic-set-id}/image-list.txt"
			method="text">
			<xsl:for-each-group select="$graphic-file-list" group-by=".">
				<xsl:value-of select="concat(sf:local-path-from-uri(current-grouping-key()), '&#xa;')"/>
			</xsl:for-each-group>

		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="byline">
		<p>
			<i><xsl:value-of select="by-label"/></i>
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	
	<xsl:template match="byline/authors">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="by-label"/>

	


	<!-- TITLES -->







	<xsl:template match="precis">
		<div class="precis">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="precis/title">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>



	<xsl:template match="subhead">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>
	

		
	<xsl:template match="comment-author-to-author ">
		<xsl:variable name="my-page" select="ancestor::page"/>
		<xsl:variable name="my-position"
			select="count(preceding::comment-author-to-author[ancestor::page is $my-page])+1"/>
		<xsl:if test="$draft">
			<a name="comment-author-to-author:{$my-position}">&#8194;</a>
			<span class="comment-author-to-author">
				<xsl:value-of select="$my-position"/>
				<xsl:text> - </xsl:text>
				<xsl:apply-templates/>
			</span>
		</xsl:if>
	</xsl:template>

	<!-- LINKS -->

	<xsl:template match="link">
		<xsl:variable name="class" select="if (@class) then @class else 'default'"/>
		<xsl:variable name="href" select="@href"/>
		<a href="{$href}" class="{$class}"
			title="{if(ancestor::context) then 'See also - ' else ''}{@title}">
			<xsl:if test="@onclick">
				<xsl:attribute name="onClick" select="@onclick"/>
			</xsl:if>
			<xsl:if test="@external = 'true'">
				<xsl:attribute name="target">_blank</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template match="context-nav">
		<p>
			<xsl:apply-templates select="home"/>   
			| 
			<xsl:for-each select="breadcrumbs/breadcrumb">
				<xsl:apply-templates select="."/>
				<xsl:if test="position() ne last()"> > </xsl:if>
			</xsl:for-each>
		</p>
	</xsl:template>
	
	<xsl:template match="context-nav/home">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="context-nav/breadcrumbs/breadcrumb">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<!-- CHARACTERS -->

	<xsl:template match="name|value|gui-label">
		<b class="decoration-bold">
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	
	<xsl:template match="inline-comment">
		<span class="{@class}">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<xsl:template match="block-comment">
		<div class="{@class}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="*" >
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Unknown element found in presentation: </xsl:text>
				<xsl:value-of select="concat('/', string-join(ancestor::*/name(), '/'),'/', '{', namespace-uri(), '}',name())"/>
			</xsl:with-param>
			<xsl:with-param name="in">
				<xsl:value-of select="base-uri(.)"></xsl:value-of>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:apply-templates/>
	</xsl:template>
</xsl:stylesheet>
