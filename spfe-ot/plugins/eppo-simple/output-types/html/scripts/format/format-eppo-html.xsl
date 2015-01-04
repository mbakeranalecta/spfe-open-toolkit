<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
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

	<xsl:template match="page">
		<xsl:variable name="page-name" select="string(@name)"/>
		<xsl:call-template name="output-html-page">
			<xsl:with-param name="file-name" select="concat(normalize-space(@name), '.html')"/>
			<xsl:with-param name="title" select="title"/>
			<xsl:with-param name="content">
				<xsl:if test="$draft">
					<div id="draft-header">
						<p class="status-{translate(@status,' ', '_')}">
							<b class="decoration-bold">Topic Name: </b>
							<xsl:value-of select="@name"/>
							<b class="decoration-bold"> Topic Status: </b>
							<xsl:value-of select="@status"/>
						</p>
						<xsl:if test=".//comment-author-to-author">
							<p>
								<b>Index of author notes: </b>
								<xsl:for-each select=".//comment-author-to-author">
									<a href="#comment-author-to-author:{position()}"> [<xsl:value-of
											select="position()"/>] </a>
									<xsl:text> </xsl:text>
								</xsl:for-each>
							</p>
						</xsl:if>
						<hr/>
					</div>
				</xsl:if>

				<div id="main-container">
					<div id="main">
						<xsl:apply-templates/>
					</div>
				</div>

				<xsl:call-template name="output-link-sets"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="header">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="footer">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="section">
		<xsl:apply-templates/>
	</xsl:template>

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

	<!-- FIG -->
	<!-- FIXME: alt should be supplied from the default caption if not present in source -->
	<xsl:template match="fig">
		<xsl:if test="title">
			<h4>
				<xsl:text>Figure&#160;</xsl:text>
				<xsl:value-of
					select="count(ancestor::page//fig/title intersect preceding::fig/title)+1"/>
				<xsl:text>&#160;&#160;&#160;</xsl:text>
				<xsl:value-of select="title"/>
			</h4>
		</xsl:if>
		<!-- Select preferred format -->
		<xsl:variable name="available-preferred-formats">
			<xsl:variable name="fig" select="."/>
			<xsl:for-each select="$preferred-formats">
				<xsl:variable name="format" select="."/>
				<xsl:sequence select="$fig//gr:format[gr:type/text() eq $format]"/>
			</xsl:for-each>
		</xsl:variable>

		<!-- FIXME: should test for no match, and decide what to do if unexpected format provided -->
		<xsl:variable name="graphic-file-name" select="sf:get-file-name-from-path($available-preferred-formats/gr:format[1]/gr:href)"/>
		<!-- FIXME: image directory location should probably be configurable -->
		<img src="images/{$graphic-file-name}" alt="{gr:graphic-record/gr:alt}" title="{gr:graphic-record/gr:name}"/>
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
	

	<xsl:template match="gr:*"/>
	
	<xsl:template match="caption">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="caption/p">
		<p class="fig-caption">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!-- TITLES -->

	<xsl:template match="fig/title"/>

	<xsl:template match="page/title">
		<h1>
			<xsl:apply-templates/>
		</h1>
	</xsl:template>

	<xsl:template match="section/title">
		<h2>
			<xsl:apply-templates/>
		</h2>
	</xsl:template>

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

	<xsl:template match="procedure/title">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>


	<xsl:template match="subhead">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>

	<xsl:template match="li/title">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>

	<xsl:template match="step/title">
		<h4>
			<xsl:text>Step&#160;</xsl:text>
			<xsl:value-of select="count(../preceding-sibling::*:step)+1"/>
			<xsl:text>:&#160;</xsl:text>
			<xsl:apply-templates/>
		</h4>
	</xsl:template>

	<xsl:template match="code-sample">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="code-sample/title">
		<h4>
			<xsl:text>Example&#160;</xsl:text>
			<xsl:value-of
				select="count(ancestor::page//code-sample/title intersect preceding::code-sample/title)+1"/>
			<xsl:text>&#160;&#160;&#160;</xsl:text>
			<xsl:apply-templates/>
		</h4>
	</xsl:template>

	<!-- FIXME: Procedures and steps??? -->

	<!-- suppress fig and table titles because they are handled in  the parent -->
	<xsl:template match="table/title"/>




	<!-- PARAGRAPHS -->

	<xsl:template match="p">
		<p>
			<xsl:if test="@hint">
				<xsl:attribute name="class" select="@hint"/>
			</xsl:if>
			<xsl:if test="$draft">
				<xsl:variable name="my-page" select="ancestor::page"/>
				<span class="draft">
					<b class="decoration-bold">
						<xsl:value-of select="count(preceding::p[ancestor::page is $my-page])+1"/>
					</b>
				</span>
			</xsl:if>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="codeblock">
		<pre><xsl:apply-templates/></pre>
	</xsl:template>

	<xsl:template match="codeblock/text()">
		<!--filter out the zero-width NBS used to preserve formatting -->
		<xsl:value-of select="replace(., '&#8288;', '')"/>
	</xsl:template>

	<xsl:template match="labeled-item">
		<xsl:if test="anchor">
			<a name="{anchor/@name}">&#8194;</a>
		</xsl:if>
		<dl>
			<xsl:apply-templates/>
		</dl>
	</xsl:template>

	<xsl:template match="label">
		<dt>
			<xsl:apply-templates/>
		</dt>
	</xsl:template>

	<xsl:template match="item">
		<dd>
			<xsl:apply-templates/>
		</dd>
	</xsl:template>

	<xsl:template match="note">
		<div align="left">
			<table class="note" border="0" cellpadding="0" cellspacing="6">
				<tr align="left" valign="top">
					<td/>
					<td class="note-content">
						<xsl:apply-templates/>
					</td>
				</tr>
				<tr align="left" valign="top">
					<td>&#160;</td>
					<td>&#160;</td>
				</tr>
			</table>
		</div>
	</xsl:template>

	<xsl:template match="note/p[1]">
		<p class="note-body">
			<b class="decoration-bold">NOTE: </b>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="caution/p[1]">
		<p class="caution-body">
			<b class="decoration-bold">CAUTION: </b>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="warning/p[1]">
		<p class="warning-body">
			<b class="decoration-bold">WARNING: </b>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="caution">
		<div align="left">
			<table class="caution" border="0" cellpadding="0" cellspacing="6">
				<tr align="left" valign="top">
					<td/>
					<td class="caution-content">
						<xsl:apply-templates/>
					</td>
				</tr>
				<tr align="left" valign="top">
					<td>&#160;</td>
					<td>&#160;</td>
				</tr>
			</table>
		</div>
	</xsl:template>

	<xsl:template match="anchor">
		<!-- insert non-breaking space to work round firefox rendering bug with empty elements-->
		<a name="{@name}">&#8194;</a>
	</xsl:template>

	<xsl:template match="warning">
		<div align="left">
			<table class="warning" border="0" cellpadding="0" cellspacing="6">
				<tr align="left" valign="top">
					<td/>
					<td class="warning-content">
						<xsl:apply-templates/>
					</td>
				</tr>
				<tr align="left" valign="top">
					<td>&#160;</td>
					<td>&#160;</td>
				</tr>
			</table>
		</div>
	</xsl:template>

	<!--- ANCHORS -->

	<!-- anchors have to be pulled outside labled items in XHTML -->
	<xsl:template match="labeled-item/anchor"/>


	<!-- LISTS -->

	<xsl:template match="ul">
		<ul>
			<xsl:if test="@hint">
				<xsl:attribute name="class" select="@hint"/>
			</xsl:if>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>
	
	<xsl:template match="ol">
		<ol>
			<xsl:if test="@hint">
				<xsl:attribute name="class" select="@hint"/>
			</xsl:if>
			<xsl:apply-templates/>
		</ol>
	</xsl:template>
	
	<xsl:template match="li">
		<li>
			<xsl:if test="@hint">
				<xsl:attribute name="class" select="@hint"/>
			</xsl:if>
			<xsl:apply-templates/>
		</li>
	</xsl:template>
	
	<xsl:template match="ll">
		<ol class="labeled-list">
			<xsl:apply-templates/>
		</ol>
	</xsl:template>
	
	<xsl:template match="ll/li">
		<li>
			<p>
				<b>
					<xsl:apply-templates select="label"/>
					<xsl:text> - </xsl:text>
				</b>
				<xsl:apply-templates select="p"/>
			</p>
		</li>
	</xsl:template>
	
	<xsl:template match="ll/li/label">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="ll/li/p">
		<xsl:apply-templates/>
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

	<!-- FIXME: gloss not implemented at presentation level yet -->
	<xsl:template match="gloss">
		<xsl:variable name="target" select="@target"/>
		<a class="gloss-fold" onclick="toggle_visibility('gloss-fold-{generate-id()}');"
			title="Definition of: {.}">
			<xsl:if test="@onclick">
				<xsl:attribute name="onClick" select="@onclick"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</a>
		<span style="display: none;" class="fold" id="gloss-fold-{generate-id()}">
			<span style="display:block; font-weight:bold">Definition of: <xsl:value-of select="."/>
				<a style="float:right" class="fold"
					onclick="toggle_visibility('gloss-fold-{generate-id()}');">[x]</a>
			</span>
			<span style="display:block;">
				<xsl:value-of select="@title"/>
			</span>
		</span>
	</xsl:template>

	<xsl:template match="fold">
		<xsl:variable name="id" select="@id"/>
		<div style="display: none;" class="fold" id="text-fold-{$id}">
			<span style="display:block; font-weight:bold">More on: <xsl:value-of
					select="@reference-text"/>
				<a style="float:right" class="fold" onclick="toggle_visibility('text-fold-{$id}');"
					>[x]</a>
			</span>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="fold-toggle">
		<a class="fold" onclick="toggle_visibility('text-fold-{@id}');" title="more...">
			<xsl:apply-templates/>
		</a>
	</xsl:template>


	<xsl:template match="tool-tip">
		<xsl:variable name="class" select="if (@class) then @class else 'default'"/>
		<a class="{$class}" title="{@title}">
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
	
	<xsl:template match="page/toc">
		<ul class="page-toc">
			<xsl:apply-templates/>
		</ul>
	</xsl:template>
	
	<xsl:template match="page/toc/toc-entry">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>
	
	<xsl:template match="p/reference">
		<i class="reference-{@type}">
			<xsl:apply-templates/>
		</i>
	</xsl:template>

	<!-- CHARACTERS -->

	<xsl:template match="name|value|gui-label">
		<b class="decoration-bold">
			<xsl:apply-templates/>
		</b>
	</xsl:template>

	<xsl:template match="decoration[@class='code']">
		<tt class="decoration-code">
			<xsl:apply-templates/>
		</tt>
	</xsl:template>
	
	<xsl:template match="decoration[@class='bold']">
		<b class="decoration-bold">
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	
	<xsl:template match="placeholder">
		<em class="decoration-italic">
			<xsl:apply-templates/>
		</em>
	</xsl:template>
	
	<xsl:template match="decoration[@class='italic']">
		<em class="decoration-italic">
			<xsl:apply-templates/>
		</em>
	</xsl:template>
	
	<xsl:template match="procedure">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="step">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- TREES -->
	
	<xsl:template match="tree[@class='toc']">
		<ol class="tree">
			<xsl:apply-templates/>
		</ol>
	</xsl:template>
	
	<xsl:template match="tree//branch">
		<li>
			<xsl:choose>
				<xsl:when test="branch">
					<label for="{generate-id()}">
						<xsl:if test="not(content/link)">
							<xsl:attribute name="class">folder</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates select="content"/>
					</label> 
					<input type="checkbox" id="{generate-id()}" >
						<!-- FIXME: How should we handle class="fixed"?-->
						<xsl:if test="@state='open'">
							<xsl:attribute name="checked"/>
						</xsl:if>
					</input> 				
					<ol>			
						<xsl:apply-templates select="branch"/>
					</ol>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">file</xsl:attribute>
					<xsl:apply-templates select="content"/>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>
	
	<xsl:template match="tree//branch/content">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="admonition">
		<div class="admonition-{@class}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="admonition/title">
		<p class="admonition-title">
			<xsl:apply-templates/>
		</p>
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
	
	<xsl:template name="output-link-sets">
		<div style="display:none">
			<xsl:for-each select="//link-set">
				
				<div id="{generate-id()}" style="padding:10px; background:#fff;">
					
					<xsl:variable name="class"
						select="if (link/@class = 'gloss') then 'gloss' else 'default'"/>
					<h4>Resources on "<xsl:value-of select="content"/>"</h4>
					
					
					
					<div style="display:list; list-style-type:disc; list-style-position: inside; ">
						<xsl:for-each select="link">
							<span style="display:list-item">
								<xsl:value-of select="@topic-type"/>
								<xsl:text>: </xsl:text>
								<a href="{@href}" class="default">
									<xsl:if test="@onclick">
										<xsl:attribute name="onClick" select="@onclick"/>
									</xsl:if>
									<xsl:value-of select="@topic-title"/>
								</a>
							</span>
						</xsl:for-each>
					</div>
					
				</div>
			</xsl:for-each>
		</div>
		
		
	</xsl:template>
	
	
	
	<xsl:template match="*" >
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Unknown element found in presentation: </xsl:text>
				<xsl:value-of select="concat('/', string-join(ancestor::*/name(), '/'),'/', '{', namespace-uri(), '}',name())"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:apply-templates/>
	</xsl:template>
</xsl:stylesheet>
