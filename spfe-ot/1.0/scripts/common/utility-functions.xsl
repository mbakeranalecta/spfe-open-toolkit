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

	<xsl:param name="strings-files"/>

	<xsl:variable name="strings">
		<xsl:if test="not($strings-files)">
			<xsl:call-template name="error">
				<xsl:with-param name="message">The parameter "strings-files" was not specified.</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<strings>
			<xsl:for-each select="tokenize($strings-files, $config/config:dir-separator)" xml:base="strings/">
				<xsl:sequence select="document(translate(.,'\','/'))/strings/string"/>
			</xsl:for-each>
		</strings>
	</xsl:variable>

	<xsl:function name="sf:file-set">
		<xsl:param name="file-list"/>
		<xsl:sequence select="document(tokenize(translate($file-list,'\','/'), $config/config:dir-separator))"/>
	</xsl:function>
	
	<xsl:function name="sf:get-base-routine-name" as="xs:string">
		<xsl:param name="routine-name"/>
		<xsl:value-of select="string(if (contains($routine-name, '(')) then normalize-space(normalize-space(substring-before($routine-name,'('))) else $routine-name)"/>
	</xsl:function>
	

<xsl:function name="sf:title2anchor">
	<xsl:param name="title"/>
	<xsl:value-of select='translate( normalize-space($title), " :&apos;[]", "-----")'/>
</xsl:function>

	<xsl:function name="sf:fix-up-path-string" as="xs:string">
		<xsl:param name="path-string"/>
		<!-- add leading slash -->
		<xsl:choose>
			<xsl:when test="not(matches($path-string, '^/'))">
				<xsl:value-of select="concat('/',$path-string)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$path-string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

<!-- print count: transform a number to a word -->
<xsl:function name="sf:print-count">
	<xsl:param name="count"/>
	<xsl:choose>
		<xsl:when test="$count = 1">one</xsl:when>
		<xsl:when test="$count = 2">two</xsl:when>
		<xsl:when test="$count = 3">three</xsl:when>
		<xsl:when test="$count = 4">four</xsl:when>
		<xsl:when test="$count = 5">five</xsl:when>
		<xsl:when test="$count = 6">six</xsl:when>
		<xsl:when test="$count = 7">seven</xsl:when>
		<xsl:when test="$count = 8">eight</xsl:when>
		<xsl:when test="$count = 9">nine</xsl:when>
		<xsl:when test="$count = 10">ten</xsl:when>
		<xsl:when test="$count = 11">eleven</xsl:when>
		<xsl:when test="$count = 12">twelve</xsl:when>
		<xsl:otherwise><xsl:value-of select="$count"/></xsl:otherwise>
	</xsl:choose>
</xsl:function>
	 
<!-- FIXME: this is outmoded and not used consistently -->
<xsl:template name="attach-source">
	<xsl:param name="source"/>
	<xsl:choose>
		<xsl:when test="doc-available(concat('file:///',$source))">
			<xsl:sequence select="document(concat('file:///',$source))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="error">
				<xsl:with-param name="message" select="'Source not found', $source"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:function name="sf:lookup">
	<xsl:param name="value"/>
	<xsl:param name="table"/>
	<xsl:variable name="result"  select="document('')/xsl:stylesheet/sf:lookup-table[@name=$table]/sf:lookup[@value=$value]/@result"/>
	<xsl:choose>
		<xsl:when test="$result">
			<xsl:value-of select="$result"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="warning">
				<xsl:with-param name="message" select="'Look up failed for', concat($value, ' in ', $table)"/>
			</xsl:call-template>
			<xsl:value-of select="$value"/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

	<sf:lookup-table name="data-type">
		<sf:lookup value="boolean" result="Boolean"/>
		<sf:lookup value="int" result="Signed 32 bit integer"/>
		<sf:lookup value="uint" result="Unsigned 32 bit integer"/>
		<sf:lookup value="ulong" result="Unsigned 32 bit integer"/>
		<sf:lookup value="string" result="String"/>
		<sf:lookup value="PORT_DIRECTION_TYPE" result="PORT_DIRECTION_TYPE, as defined in apex/apexType.h"/>
	</sf:lookup-table>
	
	
	<xsl:param name="trademark-list-file"/>
	<xsl:variable name="trademark-list" select="document($trademark-list-file)/trademark-list"/>
	
	<xsl:function name="sf:matching-substring">
		<xsl:param name="string" as="xs:string"/>
		<xsl:param name="regex"  as="xs:string"/>
		
		<xsl:if test="$string = ''">
			<xsl:message>WARNING: Empty string supplied to sf:matching-substring.</xsl:message>
		</xsl:if>
		
		<xsl:analyze-string select="$string" regex="{$regex}">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(0)"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
			
	<xsl:function name="sf:starts-with-regex" as="xs:boolean">
		<xsl:param name="string" as="xs:string"/>
		<xsl:param name="regex" as="xs:string"/>
		<xsl:variable name="foo" select="matches($string, concat('^(', $regex, ').*'))"/>
		<xsl:value-of select="$foo"/>
	</xsl:function>
	
	<xsl:function name="sf:substring-after-regex">
		<xsl:param name="string" as="xs:string"/>
		<xsl:param name="regex" as="xs:string"/>
		<!-- <xsl:value-of select="replace($string, concat('^',$regex), '')"/>-->
		<xsl:variable name="foo" select="replace($string, concat('^',$regex), '')"/>
		<xsl:value-of select="$foo"/>
	</xsl:function>

	
	<xsl:template name="info">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='info'">
			<xsl:message select="'Info: ', $message"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="debug">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='debug'">
			<xsl:message select="'Debug: ', $message"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="warning">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='warning'">
			<xsl:message>
				<xsl:text>Warning: </xsl:text>
				<xsl:sequence select="$message"/>
			</xsl:message>
		</xsl:if>
	</xsl:template>

	<xsl:template name="mention-not-resolved">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='warning'">
			<xsl:message>
				<xsl:text>Mention not resolved: </xsl:text>
				<xsl:sequence select="$message"/>
			</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="error">
		<xsl:param name="message"/>
		<xsl:message select="'ERROR: ', string-join($message,'')" terminate="{$terminate-on-error}"/>
	</xsl:template>
	
	<xsl:function name="sf:lower-case">
		<xsl:param name="text"/>
		<xsl:value-of
select="translate($text,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
	</xsl:function>

	<xsl:function name="sf:title-case">
		<xsl:param name="text"/>
		<xsl:variable name="words" select="tokenize($text, '\s')"/>
		<xsl:for-each select="$words">
			<xsl:value-of select="translate(substring($words, 1, 1),'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/> 
			<xsl:value-of select="translate(substring($words,2),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
		</xsl:for-each>	
	</xsl:function>

	<xsl:function name="sf:path-depth">
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
		<xsl:param name="name"/>
		<xsl:if test="not($strings/strings/string[@name=$name])">
			<xsl:call-template name="error">
				<xsl:with-param name="message">String lookup failed for string name <xsl:value-of select="$name"/>. No matching name found in strings file.</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="$strings/strings/string[@name=$name]/node()"/>
	</xsl:function>

	<!-- returns the index of the longest of a set of strings -->
	<xsl:function name="sf:get-longest" as="xs:integer">
		<xsl:param name="strings"/>
		<xsl:value-of select="sf:get-longest($strings,1,1)"/>
	</xsl:function>
	
	<xsl:function name="sf:get-longest" as="xs:integer">
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
			<xsl:value-of select="sf:get-longest($strings,$current + 1, $new-longest)"/>
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
</xsl:stylesheet>
