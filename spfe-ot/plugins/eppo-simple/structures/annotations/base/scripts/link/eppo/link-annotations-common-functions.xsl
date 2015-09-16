<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:lc="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/catalog"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xmlns:config="http://spfeopentoolkit.org/ns/spfe-ot/config" 
	exclude-result-prefixes="#all">

	<xsl:param name="catalog-files"/>
	<xsl:variable name="catalogs" >
		<xsl:if test="$catalog-files =''">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">No catalogs found for topic set <xsl:value-of select="$topic-set-id"/>.</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="temp-catalogs" select="sf:get-sources($catalog-files, 'Loading link catalog file:')"/>
		<xsl:if test="count(distinct-values($temp-catalogs/lc:catalog/@topic-set-id)) lt count($temp-catalogs/lc:catalog)">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">
					<xsl:text>Duplicate catalogs detected.&#x000A; There appears to be more than one catalog in scope for the same topics set. Topic set IDs encountered include:&#x000A;</xsl:text>
					<xsl:for-each select="$temp-catalogs/lc:catalog">
						<xsl:value-of select="@topic-set-id,'&#x000A;'"/>
					</xsl:for-each>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="$temp-catalogs"/>
	</xsl:variable>
	
	<xsl:function name="esf:target-exists" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:value-of select="if ($catalogs//lc:target[@type=$type][lc:key=lower-case($target)] or esf:multi-key-match(lower-case($target), $type)) then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="esf:target-exists" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="namespace"/>
		<xsl:value-of select="if ($catalogs//lc:target[@type=$type]
														   [lc:namespace=$namespace]
			                                               [lc:key=lower-case($target)] or esf:multi-key-match(lower-case($target), $type, $namespace)) then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="esf:target-exists-not-self" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="self"/>
		<xsl:value-of select="if ($catalogs//lc:target[parent::lc:page/@full-name ne $self][@type=$type][lc:key=lower-case($target)] or esf:multi-key-match(lower-case($target), $type)) then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="esf:multi-key-match" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>

		<xsl:variable name="in-scope-key-sets-of-this-type">
			<xsl:for-each select="$catalogs//lc:target[@type=$type][lc:key-set]">
				<target>
					<xsl:copy-of select="lc:key-set"/>
				</target>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="matching-keysets" as="xs:boolean*">
			<xsl:for-each select="$in-scope-key-sets-of-this-type/lc:target">	
				<xsl:value-of select="lf:try-key-set(lower-case($target), lc:key-set)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$matching-keysets=true()"/>
	</xsl:function>

	<xsl:function name="esf:multi-key-match" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="namespace"/>
		
		<xsl:variable name="in-scope-key-sets-of-this-type">
			<xsl:for-each select="$catalogs//lc:target[@type=$type][lc:namespace=$namespace][lc:key-set]">
				<target>
					<xsl:copy-of select="lc:key-set"/>
				</target>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="matching-keysets" as="xs:boolean*">
			<xsl:for-each select="$in-scope-key-sets-of-this-type/lc:target">	
				<xsl:value-of select="lf:try-key-set(lower-case($target), lc:key-set)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$matching-keysets=true()"/>
	</xsl:function>
	
	<xsl:function name="lf:try-key-set" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="key-sets"/>
		<xsl:value-of select="lf:try-key-set(lower-case($target), $key-sets, 1)"/>
	</xsl:function>

	<xsl:function name="lf:try-key-set" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="key-sets"/>
		<xsl:param name="index"/>
		<xsl:choose>
			<xsl:when test="count($key-sets) eq 0">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:when test="$index gt count($key-sets)">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="not(lf:contains-any(lower-case($target), $key-sets[$index]/lc:key))">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="lf:try-key-set(lower-case($target), $key-sets, $index + 1)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	 
	<!-- recursive contains-any function -->
	<xsl:function name="lf:contains-any" as="xs:boolean">
	 	<xsl:param name="string"/>
	 	<xsl:param name="list" as="xs:string*"/>
	 	<xsl:value-of select="lf:contains-any($string, $list, 1)"/>
 	</xsl:function>
	
	<xsl:function name="lf:contains-any" as="xs:boolean">
	 	<xsl:param name="string"/>
	 	<xsl:param name="list"/>
	 	<xsl:param name="index"/>
	 	<xsl:choose>
	 		<xsl:when test="$index gt count($list)">
	 			<xsl:value-of select="false()"/>
	 		</xsl:when>
	 		<xsl:when test="$string = tokenize($list[$index], ' ')">
	 			<xsl:value-of select="true()"/>
	 		</xsl:when>
	 		<xsl:otherwise>
	 			<xsl:value-of select="lf:contains-any($string, $list, $index+1)"/>
	 		</xsl:otherwise>
	 	</xsl:choose>
	 </xsl:function>	
	
	<!-- output-link template -->
	<xsl:template name="output-link">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="namespace"/>
		<xsl:param name="class">default</xsl:param>
		<xsl:param name="content"/>
		<xsl:param name="current-page-name" as="xs:string"/>
		<xsl:param name="see-also" as="xs:boolean" select="false()"/>
		
		<xsl:variable name="target-page" as="node()*"> 		
			<!-- single key lookup -->
			<xsl:sequence select="$catalogs/lc:catalog/lc:page[lc:target/@type=$type]
				                  [if($namespace) then lc:target/lc:namespace=$namespace else true()]
				                  [@full-name ne $current-page-name]
				                  [lc:target/lc:key=lower-case($target)]"/>	
			
			<!-- multi-key lookup -->
			<xsl:sequence select="$catalogs/lc:catalog/lc:page[lc:target/@type=$type]
				                                                        [if($namespace) then lc:target/lc:namespace=$namespace else true()]
				                                                        [@full-name ne $current-page-name]/lc:target[lf:try-key-set(lower-case($target), lc:key-set)]/.."/>	
		</xsl:variable>
		
		<!-- FIXME: Update this for namespaces? -->
		<xsl:if test="count($target-page[1]/lc:target[@type=$type][lc:key=lower-case($target)]) gt 1">
			<xsl:call-template name="sf:warning">
				<xsl:with-param name="message" select="'Detected a target page that contains more than one target of the same name and type. The name is: ', string($target), '. The type is: ', string($type), '. The topic is: ', string(ancestor::ss:topic/@full-name), '.'"/>

			</xsl:call-template>

		</xsl:if>
		
		<xsl:choose>
			<!-- No target pages identified, so no link. This takes care of links back to the current page -->
			<xsl:when test="count($target-page) eq 0">
				<xsl:choose>
					<xsl:when test="$content">
						<xsl:sequence select="$content"/>
					</xsl:when>
					<!-- Is this ever the right thing to do. Can cause side effects depending on where called from. -->
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Choose the target page with the highest link priority -->
				<!-- Arbitrarilly picks the first in sequence if more than one page with same priority -->
				<xsl:variable name="highest-priority-page" select="$target-page[number(@link-priority) eq min($target-page/@link-priority)][1]"/>	
				<xsl:if test="count($target-page[number(@link-priority) eq min($target-page/@link-priority)]) > 1">
					<xsl:call-template name="sf:warning">
						<xsl:with-param name="message">
							<xsl:text>More than one target page with the same link priority.&#x000A;</xsl:text>
							<xsl:text>Target pages include:&#x000A;</xsl:text>
							<xsl:value-of select="string-join($target-page[number(@link-priority) eq min($target-page/@link-priority)]/@full-name, ',&#x000A;')"/>
							<xsl:value-of select="'&#x000A;The target is: ', lower-case($target)"/>
							<xsl:value-of select="'&#x000A;The type is: ', $type"/>
							<xsl:value-of select="'&#x000A;The priority is: ', min($target-page/@link-priority)"/>
							<xsl:text>&#x000A;Arbitrarily picking a page to link to.</xsl:text>
						</xsl:with-param>
						
					</xsl:call-template>		
				</xsl:if>

				<xsl:call-template name="make-link">
					<xsl:with-param name="target-page" select="$highest-priority-page"/>
					<xsl:with-param name="target" select="lower-case($target)"/>
					<xsl:with-param name="type" select="$type"/>
					<xsl:with-param name="namespace" select="$namespace"/>
					<xsl:with-param name="current-page-name" select="$current-page-name"/>
					<xsl:with-param name="class" select="$class"/>
					<xsl:with-param name="see-also" as="xs:boolean" select="$see-also"/>
					<xsl:with-param name="content">
						<xsl:choose>
							<xsl:when test="$content">
								<xsl:sequence select="$content"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<!--make-link template-->
	<xsl:template name="make-link">
		<xsl:param name="target-page"/>
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="namespace"/>
		<xsl:param name="current-page-name" as="xs:string"/>
		<xsl:param name="class">default</xsl:param>
		<xsl:param name="content"/>
		<xsl:param name="see-also" as="xs:boolean" select="false()"/>
		
		<xsl:variable name="target-topic-set" select="$target-page/parent::lc:catalog/@topic-set-id"/>	
		<xsl:variable name="target-file"  select="string($target-page/@file)"/>		
		
		<xsl:variable name="target-anchor" select="if ($target-page[1]/lc:target[lc:key=lower-case($target)][lc:namespace=$namespace][@type=$type][1]/@anchor) then concat('#', $target-page[1]/lc:target[lc:key=lower-case($target)][@type=$type][1]/@anchor) else ''"/>

		
		<pe:link hint="{$type}">
			<xsl:variable name="title">
				<xsl:variable name="target-content" select="normalize-space(string($target-page/lc:target[lc:key=lower-case($target)][@type=$type]/lc:label))"/>
				
				<xsl:choose>
					<xsl:when test="$target-content">
						<xsl:value-of select="$target-content"/>
					</xsl:when>
 					<xsl:otherwise>
 						<xsl:value-of select="$target-page/@topic-type-alias"/>
						<xsl:text>: </xsl:text>
						<xsl:value-of select="$target-page/@title"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:attribute name="title" select="$title"/>
			<xsl:attribute name="topic-type" select="$target-page/@topic-type-alias"/>
			<xsl:attribute name="topic-title" select="$target-page/@title"/>
			<xsl:attribute name="class" select="$class"/>
			<xsl:attribute name="topic-id" select="$target-page/@local-name"/>
			<xsl:attribute name="topic-dir" select="$target-page/../@output-directory"/>

			<xsl:choose>
				<xsl:when test="$see-also">
					<xsl:sequence select="$title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$content"/>
				</xsl:otherwise>
			</xsl:choose>
			</pe:link>
	</xsl:template>
	

	<xsl:template name="output-structure-referenceerence">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
				
		<xsl:variable name="target-page" select="$catalogs/lc:catalog/lc:page[lc:target/@type=$type][lc:target/lc:key=lower-case($target)]"/>
				
		<xsl:choose>
			<xsl:when test="(count($target-page/lc:page/@file) > 1) or (count($catalogs/lc:catalog/lc:page[@full-name=$target-page/@full-name]) > 1)">
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">More than one destination found for the cross reference <xsl:value-of select="lower-case($target)"/>. Unable to proceed.</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="make-structure-reference">
					<xsl:with-param name="target-page" select="$target-page"/>
					<xsl:with-param name="target" select="lower-case($target)"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

		<!--make-structure-reference template-->
	<!-- FIXME: needs to be updated for namespaces, if it gets used at all -->
	<xsl:template name="make-structure-reference">
		<xsl:param name="target-page"/>
		<xsl:param name="target"/>
		<xsl:param name="type"/>

		<xsl:variable name="target-topic-set">
			<xsl:value-of select="$catalogs/lc:catalog[lc:page/@full-name=$target-page/@full-name]/@topic-set-id"/>
		</xsl:variable>
		
<!--		<xsl:variable name="target-directory" select="$catalogs/lc:catalog/lc:page[@full-name=$target-page/@full-name]/parent::lc:catalog/@output-directory"/>
-->
		
<!--		<xsl:variable name="target-directory-path" >
			<xsl:for-each select="tokenize($target-directory, '/')">
				<xsl:if test="position()!=last()">
					<xsl:text>../</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$target-directory"/>
		</xsl:variable>
-->	
		<xsl:variable name="target-file"  select="string($target-page/@file)"/>		
		
		<xsl:variable name="target-anchor" select="if ($target-page[1]/lc:target[lc:key=lower-case($target)][@type=$type]/@anchor) then concat('#', $target-page[1]/lc:target[lc:key=lower-case($target)][@type=$type]/@anchor) else ''"/>

		<xsl:choose>
			<!-- this book -->
			<xsl:when test="$topic-set-id eq $target-topic-set">
				<pe:structure-reference 
					type="{$type}"
					target="{lower-case($target)}"/>
			</xsl:when>
			
			<!-- outside this book -->
			<xsl:otherwise>
				<pe:decoration class="bold">
					<xsl:value-of select="$target-page/@title"/>
				</pe:decoration>
				<xsl:text> in </xsl:text>
				<pe:decoration class="italic">
					<xsl:value-of select="$catalogs/lc:catalog[@topic-set-id=$target-topic-set]/@title"/>
				</pe:decoration> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
</xsl:stylesheet>
