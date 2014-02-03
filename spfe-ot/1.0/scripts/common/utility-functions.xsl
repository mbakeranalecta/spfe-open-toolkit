<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all">

<xsl:param name="message-types">info debug warning</xsl:param>
<xsl:param name="terminate-on-error">yes</xsl:param>
<xsl:variable name="verbosity" select="tokenize($message-types, ' ')"/>

<xsl:function name="sf:title2anchor">
	<xsl:param name="title"/>
	<xsl:value-of select='translate( normalize-space($title), " :&apos;[]", "-----")'/>
</xsl:function>

<xsl:function name="sf:get-sources">
	<xsl:param name="file-list"/>
	<xsl:sequence select="sf:get-sources($file-list, '')"></xsl:sequence>
</xsl:function>
	
<xsl:function name="sf:get-sources">
	<xsl:param name="file-list"/>
	<xsl:param name="load-message"/>
<!--  FIXME: This test is firing in spfe-docs even though it is building correctly???
		<xsl:if test="normalize-space($file-list)=''">
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Empty file list passed to sf:get-sources function. This may be because a configuration file is point to a file that does not exist on the system. Check your configuration.</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
-->	
	<xsl:for-each select="tokenize(translate($file-list, '\', '/'), ';')">
		<xsl:variable name="one-file" select="concat('file:///', normalize-space(.))"/>
		<xsl:if test="normalize-space($load-message)">
			<xsl:call-template name="sf:info">
				<xsl:with-param name="message" select="$load-message, $one-file "/>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="document($one-file)"/>
	</xsl:for-each>
</xsl:function>	
	
	<xsl:template name="sf:info">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='info'">
			<xsl:message select="'Info: ', $message"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="sf:debug">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='debug'">
			<xsl:message select="'Debug: ', $message"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="sf:warning">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='warning'">
			<xsl:message>
				<xsl:text>Warning: </xsl:text>
				<xsl:sequence select="$message"/>
			</xsl:message>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sf:subject-affinity-not-resolved">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='warning'">
			<xsl:message>
				<xsl:text>subject-affinity not resolved: </xsl:text>
				<xsl:sequence select="$message"/>
			</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="sf:error">
		<xsl:param name="message"/>
		<xsl:message>**********************************************************</xsl:message>
		<xsl:message select="'ERROR: ', string-join($message,'')"/>
		<xsl:message>**********************************************************</xsl:message>
		<xsl:message terminate="{$terminate-on-error}"/>
	</xsl:template>
	

	<xsl:function name="sf:path-depth" as="xs:integer">
		<!-- Calculates the depth of an XPath by counting the number of 
		elements in the path. It uses tokenize to count but throws away 
		the empty string item that would be created by a leading or trailing 
		slash. Thus foo/bar, /foo/bar, and /foo/bar/, are all counted as
		having a path depth of 2. Will count a concluding attribute on a 
		path as part of the depth. Presumably works for file paths as well,
		as long as they are in UNIX form. -->
		<xsl:param name="path"/>
		<xsl:value-of select="count(tokenize($path, '/')[. ne ''])"/>
	</xsl:function>

	<xsl:function name="sf:get-file-name-from-path">
		<xsl:param name="path"/>
		<xsl:variable name="tokens" select="tokenize($path, '/')"/>
		<xsl:value-of select="subsequence($tokens, count($tokens))"/>
	</xsl:function>

	<xsl:function name="sf:string" >
		<xsl:param name="strings" as="element()*"/>
		<xsl:param name="id"/>
		<xsl:if test="not($strings/*:string[@id=$id])">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">String lookup failed for string ID <xsl:value-of select="$id"/>. No matching string found.</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="$strings/*:string[@id=$id]/node()"/>
	</xsl:function>

	<!-- returns the index of the longest of a set of strings -->
	<xsl:function name="sf:longest-string" as="xs:integer">
		<xsl:param name="strings"/>
		<xsl:value-of select="sf:longest-string($strings,1,1)"/>
	</xsl:function>
	
	<xsl:function name="sf:longest-string" as="xs:integer">
	<xsl:param name="strings"/>
	<xsl:param name="current"/>
	<xsl:param name="longest"/>
	<xsl:choose>
		<xsl:when test="$current lt count($strings)">
			<xsl:variable name="new-longest">
				<xsl:choose>
					<xsl:when test="string-length($strings[$current]) gt string-length($strings[$longest])">
						<xsl:value-of select="string-length($strings[$current])"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="sf:longest-string($strings,$current + 1, $new-longest)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$longest"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
	
<xsl:function name="sf:conditions-met" as="xs:boolean">
	<xsl:param name="conditions"/>
	<xsl:param name="condition-tokens"/>
	<xsl:variable name="tokens-list" select="tokenize($condition-tokens, '\s+')"/>
	<xsl:variable name="conditions-list" select="tokenize($conditions, '\s+')"/>
	<xsl:choose>
		<xsl:when test="not($conditions)">
			<xsl:value-of select="true()"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="sf:satisfies-condition($conditions-list, $tokens-list)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
	
<xsl:function name="sf:satisfies-condition" as="xs:boolean">
	<xsl:param name="conditions-list"/>
	<xsl:param name="tokens-list"/>
	<xsl:value-of select="sf:satisfies-condition($conditions-list, $tokens-list, 1)"/>
</xsl:function>

<xsl:function name="sf:satisfies-condition" as="xs:boolean">
	<xsl:param name="conditions-list"/>
	<xsl:param name="tokens-list"/>
	<xsl:param name="index"/>
	
	<xsl:variable name="and-tokens" select="tokenize($tokens-list[$index], '\+')"/>
	
	<xsl:choose>
		<xsl:when test="every $item in $and-tokens satisfies $item=$conditions-list">
			<xsl:value-of select="true()"/>
		</xsl:when>
		<xsl:when test="$index lt count($tokens-list)">
			<xsl:value-of select="sf:satisfies-condition($conditions-list, $tokens-list, $index + 1)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

	<xsl:function name="sf:relative-from-absolute-path" as="xs:string">
		<xsl:param name="path"/>
		<xsl:param name="relative-to"/>
		<xsl:value-of select="sf:relative-from-absolute-path($path, $relative-to, '')"/>
	</xsl:function>
	
	<xsl:function name="sf:relative-from-absolute-path" as="xs:string">
		<xsl:param name="path"/>
		<xsl:param name="relative-to"/>
		<xsl:param name="prefix"/>
		
		<xsl:variable name="relative-to-uri" select="sf:path-after-protocol-part(resolve-uri($relative-to))"/>
		<xsl:variable name="path-uri" select="sf:path-after-protocol-part(resolve-uri($path,$relative-to-uri))"/>
		<xsl:value-of select="concat($prefix,substring-after($path-uri, $relative-to-uri))"/>
	</xsl:function>
	
	<xsl:function name="sf:path-after-protocol-part" as="xs:string">
		<xsl:param name="path"/>
		<xsl:analyze-string select="$path" regex="^([a-zA-Z]{{2,}}://?/?)?(.+)">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(2)"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
	<xsl:function name="sf:local-path-from-uri">
		<xsl:param name="local-path"/>
		<xsl:value-of select="sf:pct-decode(sf:path-after-protocol-part($local-path))"/>
	</xsl:function>
	
	<!-- Adapted from code published by James A. Robinson at http://www.oxygenxml.com/archives/xsl-list/200911/msg00300.html -->
	<!-- Function to decode percent-encoded characters  -->
	<xsl:function name="sf:pct-decode" as="xs:string?">
		<xsl:param name="in" as="xs:string"/>
		<xsl:sequence select="sf:pct-decode($in, ())"/>
	</xsl:function>
	<xsl:function name="sf:pct-decode" as="xs:string?">
		<xsl:param name="in" as="xs:string"/>
		<xsl:param name="seq" as="xs:string*"/>
		
		<xsl:choose>
			<xsl:when test="not($in)">
				<xsl:sequence select="string-join($seq, '')"/>
			</xsl:when>
			<xsl:when test="starts-with($in, '%')">
				<xsl:choose>
					<xsl:when test="matches(substring($in, 2, 2), '^[0-9A-Fa-f][0-9A-Fa-f]$')">
						<xsl:variable name="s" as="xs:string" select="substring($in, 2, 2)"/>
						<xsl:variable name="d" as="xs:integer" select="sf:hex-to-dec(upper-case($s))"/>
						<xsl:variable name="c" as="xs:string" select="codepoints-to-string($d)"/>
						<xsl:sequence select="sf:pct-decode(substring($in, 4), ($seq, $c))"/>
					</xsl:when>
					<xsl:when test="contains(substring($in, 2), '%')">
						<xsl:variable name="s" as="xs:string" select="substring-before(substring($in, 2), '%')"/>
						<xsl:sequence select="sf:pct-decode(substring($in, 2 + string-length($s)), ($seq, '%', $s))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="string-join(($seq, $in), '')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($in, '%')">
				<xsl:variable name="s" as="xs:string" select="substring-before($in, '%')"/>
				<xsl:sequence select="sf:pct-decode(substring($in, string-length($s)+1), ($seq, $s))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="string-join(($seq, $in), '')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- Function to convert a hexadecimal string into decimal -->
	<xsl:function name="sf:hex-to-dec" as="xs:integer">
		<xsl:param name="hex" as="xs:string"/>
		
		<xsl:variable name="len" as="xs:integer" select="string-length($hex)"/>
		<xsl:choose>
			<xsl:when test="$len eq 0">
				<xsl:sequence select="0"/>
			</xsl:when>
			<xsl:when test="$len eq 1">
				<xsl:sequence select="
					if ($hex eq '0')       then 0
					else if ($hex eq '1')       then 1
					else if ($hex eq '2')       then 2
					else if ($hex eq '3')       then 3
					else if ($hex eq '4')       then 4
					else if ($hex eq '5')       then 5
					else if ($hex eq '6')       then 6
					else if ($hex eq '7')       then 7
					else if ($hex eq '8')       then 8
					else if ($hex eq '9')       then 9
					else if ($hex = ('A', 'a')) then 10
					else if ($hex = ('B', 'b')) then 11
					else if ($hex = ('C', 'c')) then 12
					else if ($hex = ('D', 'd')) then 13
					else if ($hex = ('E', 'e')) then 14
					else if ($hex = ('F', 'f')) then 15
					else error(xs:QName('sf:hex-to-dec'))
					"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="
					(16 * sf:hex-to-dec(substring($hex, 1, $len - 1)))
					+ sf:hex-to-dec(substring($hex, $len))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- Display first n words -->
	<xsl:function name="sf:first-n-words" as="xs:string">
		<xsl:param name="text"/>
		<xsl:param name="words"/>
		<xsl:param name="suffix"/>
		<xsl:variable name="text-string" select="normalize-space($text)"/>
		<xsl:variable name="regex" select="concat('^([^\s]+\s*){1,', $words, '}')"/>
		<xsl:if test="$text-string">
			<xsl:analyze-string select="$text-string" regex="{$regex}" flags="s">
				<xsl:matching-substring>
					<xsl:value-of select="concat(regex-group(0), $suffix)"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:if>
	</xsl:function>
	
	<!-- Escape string for XML -->
	<xsl:function name="sf:escape-for-xml">
		<xsl:param name="string"/>
		<xsl:analyze-string select="$string" regex="&lt;|&amp;">
			<xsl:matching-substring>
				<xsl:choose>
					<xsl:when test=".='&lt;'">&amp;lt;</xsl:when>
					<xsl:when test=".='&amp;'">&amp;amp;</xsl:when>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
</xsl:stylesheet>
