<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:lf="local-functions"
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	xmlns:gr="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/object-types/graphic-record"
	exclude-result-prefixes="#all">
	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	<!-- FIXME: The preferred formats should be settable outside the script -->
	<xsl:variable name="preferred-format-list">svg,png,jpg,jpeg,gif</xsl:variable>
	<xsl:variable name="preferred-formats" as="xs:string*" select="tokenize($preferred-format-list , ',')"/>
	
	<xsl:variable name="draft" as="xs:boolean" select="$config/config:build-command='draft'"/>

	<xsl:param name="presentation-files"/>
	<xsl:param name="topic-set-id"/>
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
			<xsl:for-each select="$config/config:format/config:html/config:css">
				<link rel="STYLESHEET" href="{.}" type="text/css" media="all"/>
			</xsl:for-each>
			<xsl:for-each select="$config/config:format/config:html/config:java-script">
				<script type="text/javascript" src="{.}">&#160;</script>
			</xsl:for-each>

			<link rel="stylesheet" type="text/css" href="style/eppo-simple.css"/>
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
			href="file:///{$config/config:doc-set-output}/{$config/config:topic-set[config:topic-set-id=$topic-set-id]/config:output-directory}{$file-name}"
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
						<xsl:text>Creating a draft format because build command was "draft".</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Creating a final format.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:apply-templates select="$presentation/web/page"/>
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
						<xsl:if test=".//review-note">
							<p>
								<b>Index of review notes: </b>
								<xsl:for-each select=".//review-note">
									<a href="#review-note:{position()}"> [<xsl:value-of
											select="position()"/>] </a>
									<xsl:text> </xsl:text>
								</xsl:for-each>
							</p>
						</xsl:if>
						<xsl:if test=".//author-note">
							<p>
								<b>Index of author notes: </b>
								<xsl:for-each select=".//author-note">
									<a href="#author-note:{position()}"> [<xsl:value-of
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

				<xsl:call-template name="output-xref-sets"/>
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

	<xsl:template match="th">
		<th align="left">
			<xsl:call-template name="get-column-width"/>
			<xsl:apply-templates/>
		</th>
	</xsl:template>

	<xsl:template match="td">
		<td align="left" valign="top">
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
		<xsl:variable name="graphic-file-name" select="sf:get-file-name-from-path($available-preferred-formats[1]//gr:href)"/>
		<!-- FIXME: image directory location should probably be configurable -->
		<img src="images/{$graphic-file-name}" alt="{gr:graphic-record/gr:alt}" title="{gr:graphic-record/gr:name}"/>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template name="generate-graphics-list">
		<xsl:variable name="graphic-file-list" as="xs:string*">
			<xsl:for-each select="$presentation/web/page//gr:graphic-record">	                                 
				<xsl:variable name="available-preferred-formats">
					<xsl:variable name="gr" select="."/>
					<xsl:for-each select="$preferred-formats">
						<xsl:variable name="format" select="."/>
						<xsl:sequence select="$gr//gr:format[gr:type/text() eq $format]"/>
					</xsl:for-each>
				</xsl:variable>
				<!-- FIXME: should test for no match, and decide what to do if unexpected format provided -->
				<xsl:value-of select="$available-preferred-formats[1]//gr:href"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:result-document
			href="file:///{$config/config:doc-set-build}/topic-sets/{$topic-set-id}/image-list.txt"
			method="text">
			<xsl:for-each-group select="$graphic-file-list" group-by=".">
				<xsl:value-of select="concat(sf:local-path-from-uri(current-grouping-key()), '&#xa;')"/>
			</xsl:for-each-group>

		</xsl:result-document>
	</xsl:template>
	

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
		<!-- page toc -->
		<xsl:if test="count(../section/title) gt 1">
			<ul>
				<xsl:for-each select="../section/title">
					<li>
						<a href="#{sf:title-to-anchor(normalize-space(.))}">
							<xsl:value-of select="."/>
						</a>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<xsl:template match="section/title">
		<h2>
			<xsl:apply-templates/>
		</h2>
	</xsl:template>



	<xsl:template match="qa/title">
		<h2>
			<xsl:apply-templates/>
		</h2>
	</xsl:template>

	<xsl:template match="qa/question">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="qa/answer">
		<xsl:apply-templates/>
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

	<xsl:template match="ul|ol|li">
		<!-- Note that we can't use xsl:copy here as that creates a
	     copy in the same namespace as the source. Here we need 
			 to create an element of the same name but in the XHTML 
			 namespace. xsl:element creates elements in the default
			 namespace declared in xsl:stylesheet. -->
		<xsl:element name="{name()}">
			<xsl:if test="@hint">
				<xsl:attribute name="class" select="@hint"/>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="author-note ">
		<xsl:variable name="my-page" select="ancestor::page"/>
		<xsl:variable name="my-position"
			select="count(preceding::author-note[ancestor::page is $my-page])+1"/>
		<xsl:if test="$draft">
			<a name="author-note:{$my-position}">&#8194;</a>
			<span class="author-note">
				<xsl:value-of select="$my-position"/>
				<xsl:text> - </xsl:text>
				<xsl:apply-templates/>
			</span>
		</xsl:if>
	</xsl:template>

	<xsl:template match="review-note">
		<xsl:variable name="my-page" select="ancestor::page"/>
		<xsl:variable name="my-position"
			select="count(preceding::review-note[ancestor::page is $my-page])+1"/>
		<xsl:if test="$draft">
			<a name="review-note:{$my-position}">&#8194;</a>
			<span class="review-note">
				<xsl:value-of select="$my-position"/>
				<xsl:text> - </xsl:text>
				<xsl:apply-templates/>
			</span>
		</xsl:if>
	</xsl:template>

	<!-- LINKS -->

	<xsl:template match="xref">
		<xsl:variable name="class" select="if (@class) then @class else 'default'"/>
		<xsl:variable name="target" select="@target"/>
		<a href="{$target}" class="{$class}"
			title="{if(ancestor::context) then 'See also - ' else ''}{@title}">
			<xsl:if test="@onclick">
				<xsl:attribute name="onClick" select="@onclick"/>
			</xsl:if>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="xref[@hint='term']">
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

	<xsl:template match="xref-set">
		<!-- FIXME: This should have a title, but it interferes with colorbox. Fix? Alternative? -->
		<!-- title="{if(ancestor::context) then 'See also - ' else ''}{string-join(xref/@title, '; ')}" -->
		<a class="inline" href="#{generate-id()}">
			<xsl:value-of select="content"/>
		</a>
	</xsl:template>

	<xsl:template name="output-xref-sets">
		<div style="display:none">
			<xsl:for-each select="//xref-set">

				<div id="{generate-id()}" style="padding:10px; background:#fff;">

					<xsl:variable name="class"
						select="if (xref/@class = 'gloss') then 'gloss' else 'default'"/>
					<h4>Resources on "<xsl:value-of select="content"/>"</h4>



					<div style="display:list; list-style-type:disc; list-style-position: inside; ">
						<xsl:for-each select="xref">
							<span style="display:list-item">
								<xsl:value-of select="@topic-type"/>
								<xsl:text>: </xsl:text>
								<a href="{@target}" class="default">
									<xsl:if test="@onclick">
										<xsl:attribute name="onClick" select="@onclick"/>
									</xsl:if>
									<xsl:value-of select="@topic-title"/>
								</a>
								<!--
							<xsl:text> (</xsl:text>
							<xsl:value-of select="@topic-product"/>
							<xsl:text>)</xsl:text>-->
							</span>
						</xsl:for-each>
					</div>

				</div>
			</xsl:for-each>
		</div>


	</xsl:template>

	<xsl:template match="xlink">
		<a href="{@href}" target="_blank">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="tool-tip">
		<xsl:variable name="class" select="if (@class) then @class else 'default'"/>
		<xsl:element name="a">
			<xsl:attribute name="class" select="$class"/>
			<xsl:attribute name="title" select="@title"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="cross-ref">
		<xsl:variable name="target" select="@target"/>
		<xsl:variable name="type" select="@type"/>
		<xsl:choose>

			<xsl:when test="$type='procedure'">
				<xsl:variable name="target-procedure"
					select="ancestor::page//procedure[@id=$target]"/>
				<a href="#procedure:{$target-procedure/@id}">
					<i>
						<xsl:value-of select="$target-procedure/title"/>
					</i>
				</a>
			</xsl:when>

			<xsl:when test="$type='step'">
				<xsl:variable name="target-step" select="ancestor::page//step[@id=$target]"/>
				<a href="#step:{$target-step/id}">
					<xsl:value-of
						select="concat('Step ', count(//step[@id=current()/$target]/preceding-sibling::step)+1)"/>
					<xsl:value-of select="//step[@id=current()/@id-ref]/title"/>
				</a>
			</xsl:when>

			<xsl:when test="$type='fig'">
				<xsl:variable name="target-fig" select="ancestor::page//fig[@id=$target]"/>
				<a href="#fig:{$target}">
					<xsl:text>Figure&#160;</xsl:text>
					<xsl:value-of
						select="count(ancestor::page//fig/title intersect $target-fig/preceding::fig/title)+1"
					/>
				</a>
			</xsl:when>

			<xsl:when test="$type='table'">
				<xsl:variable name="target-table" select="ancestor::page//table[@id=$target]"/>
				<a href="#table:{$target}">
					<!-- Insert a zero-width-non-breaking-space so indenter recognizes 
					this as a text node and does not indent it (which would add spurious
					white space to output -->
					<xsl:text>Table&#160;</xsl:text>
					<xsl:value-of
						select="count(ancestor::page//table/title intersect $target-table/preceding::table/title)+1"
					/>
				</a>
			</xsl:when>

			<xsl:when test="$type='code-sample'">
				<xsl:variable name="target-sample" select="ancestor::page//code-sample[@id=$target]"/>
				<a href="#code-sample:{$target}">
					<!-- Insert a zero-width-non-breaking-space so indenter recognizes 
					this as a text node and does not indent it (which would add spurious
					white space to output -->
					<xsl:text>Example&#160;</xsl:text>
					<xsl:value-of
						select="count(ancestor::page//code-sample/title intersect $target-sample/preceding::code-sample/title)+1"
					/>
				</a>

			</xsl:when>

			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">Unknown cross-reference type "<xsl:value-of
							select="$type"/>.</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- CHARACTERS -->

	<xsl:template match="name|value|gui-label|bold|code">
		<b class="decoration-bold">
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	

	<xsl:template match="placeholder|italic">
		<em>
			<xsl:apply-templates/>
		</em>
	</xsl:template>

	<xsl:template match="procedure">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="step">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="qa">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*" >
		<xsl:call-template name="sf:warning">
			<xsl:with-param name="message">
				<xsl:text>Unknown element found in presentation: </xsl:text>
				<xsl:value-of select="concat('/', string-join(ancestor::*/name(), '/'),'/', '{', namespace-uri(), '}',name())"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:apply-templates/>
	</xsl:template>
</xsl:stylesheet>
