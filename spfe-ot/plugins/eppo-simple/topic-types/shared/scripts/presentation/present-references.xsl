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
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	exclude-result-prefixes="#all">

	<xsl:param name="link-catalog-files"/>
	<xsl:variable name="link-catalogs" >
		<xsl:variable name="temp-link-catalogs" select="sf:get-sources($link-catalog-files, 'Loading link catalog file:')"/>
		<xsl:if test="count(distinct-values($temp-link-catalogs/link-catalog/@topic-set-id)) lt count($temp-link-catalogs/link-catalog)">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">
					<xsl:text>Duplicate link catalogs detected.&#x000A; There appears to be more than one link catalog in scope for the same topics set. Topic set IDs encountered include:&#x000A;</xsl:text>
					<xsl:for-each select="$temp-link-catalogs/link-catalog">
						<xsl:value-of select="@topic-set-id,'&#x000A;'"/>
					</xsl:for-each>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="$temp-link-catalogs"/>
	</xsl:variable>
	
	<xsl:function name="esf:target-exists" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:value-of select="esf:target-exists($target, $type, '')"/>
	</xsl:function> 
	
	<xsl:function name="esf:target-exists" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="scope"/>
		<xsl:value-of select="if ($link-catalogs//target[@type=$type][key=$target][esf:in-scope(parent::page,$scope)] or esf:multi-key-match($target, $type, $scope)) then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="esf:target-exists-not-self" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="self"/>
		<xsl:value-of select="esf:target-exists-not-self($target, $type, '', $self)"/>
	</xsl:function> 
	
	<xsl:function name="esf:target-exists-not-self" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="scope"/>
		<xsl:param name="self"/>
		<xsl:value-of select="if ($link-catalogs//target[parent::page/@full-name ne $self][@type=$type][key=$target][esf:in-scope(parent::page,$scope)] or esf:multi-key-match($target, $type, $scope)) then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="esf:multi-key-match" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="scope"/>
		

		<xsl:variable name="in-scope-key-sets-of-this-type">
			<xsl:for-each select="$link-catalogs//target[@type=$type][esf:in-scope(parent::page, $scope)][key-set]">
				<target>
					<xsl:copy-of select="key-set"/>
				</target>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="matching-keysets" as="xs:boolean*">
			<xsl:for-each select="$in-scope-key-sets-of-this-type/target">	
				<xsl:value-of select="lf:try-key-set($target, key-set)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$matching-keysets=true()"/>
	</xsl:function>
	
	<xsl:function name="lf:try-key-set" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="key-sets"/>
		<xsl:value-of select="lf:try-key-set($target, $key-sets, 1)"/>
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
			<xsl:when test="not(lf:contains-any($target, $key-sets[$index]/key))">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="lf:try-key-set($target, $key-sets, $index + 1)"/>
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
	 		<xsl:when test="contains($string, $list[$index])">
	 			<xsl:value-of select="true()"/>
	 		</xsl:when>
	 		<xsl:otherwise>
	 			<xsl:value-of select="lf:contains-any($string, $list, $index+1)"/>
	 		</xsl:otherwise>
	 	</xsl:choose>
	 </xsl:function>
	 		
	
	<!-- in-scope function
	A page is considered to be in scope for a reference if:
	a. the page is unscoped
	b. the reference is unscoped
	c. the page and the reference are scoped and have a scope token in common
	-->
	<xsl:function name="esf:in-scope" as="xs:boolean">
		<xsl:param name="page"/>
		<xsl:param name="scope"/>
		<xsl:variable name="page-scope-list" select="tokenize($page/@scope, '\s+')"/>
		<xsl:variable name="scope-list" select="tokenize($scope, '\s+')"/>
		<xsl:value-of select="if ( 
									$page-scope-list = $scope-list
									or
									count($page-scope-list) = 0
									or
									count($scope-list) = 0
								 ) 
								 then true() 
								 else false()"/>
	</xsl:function>
	
	
	<!-- output-link template -->
	<xsl:template name="output-link">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="class">default</xsl:param>
		<xsl:param name="content"/>
		<xsl:param name="current-page-name" as="xs:string"/>
		<xsl:param name="see-also" as="xs:boolean" select="false()"/>
		<xsl:param name="scope"/>
		<!-- check that we are not linking to the current page
		<xsl:variable name="current-page" select="if (. instance of node() and ancestor::ss:topic/@full-name) then ancestor::ss:topic/@full-name else 'no-current-page'"/> -->
		
		<xsl:variable name="target-page" as="node()*"> 		
			<!-- single key lookup -->
			<xsl:sequence select="$link-catalogs/link-catalog/page[target/@type=$type][@full-name ne $current-page-name][esf:in-scope(ancestor-or-self::page,$scope)][target/key=$target]"/>	
			
			<!-- multi-key lookup -->
			<xsl:sequence select="$link-catalogs/link-catalog/page[target/@type=$type][@full-name ne $current-page-name][esf:in-scope(ancestor-or-self::page,$scope)]/target[lf:try-key-set($target, key-set)]/.."/>	
		</xsl:variable>
		
		<xsl:if test="count($target-page[1]/target[@type=$type][key=$target]) gt 1">
			<xsl:call-template name="sf:warning">
				<xsl:with-param name="message" select="'Detected a target page that contains more than one target of the same name and type. The target is:', $target, '. The type is:', $type, '.'"/>

			</xsl:call-template>
		</xsl:if>
		
		<xsl:choose>
			<!-- No target pages identified, so no link. This takes care of links back to the current page -->
			<xsl:when test="count($target-page) eq 0">
				<xsl:choose>
					<xsl:when test="$content">
						<xsl:sequence select="$content"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Choose the target page with the highest link priority -->
				<!-- Arbitrarilly picks the first in sequence if more than one page with same priority -->
				<xsl:variable name="highest-priority-page" select="$target-page[number(@link-priority) eq min($target-page/@link-priority)][1]"/>	
				<!-- FIXME: This test has never been tested. Need a test case for it. -->
				<xsl:if test="count($target-page[number(@link-priority) eq min($target-page/@link-priority)]) > 1">
					<xsl:call-template name="sf:warning">
						<xsl:with-param name="message">
							<xsl:text>More than one target page with the same link priority. </xsl:text>
							<xsl:text>Target pages include:</xsl:text>
							<xsl:value-of select="string-join($target-page[number(@link-priority) eq min($target-page/@link-priority)], ', ')"/>
						</xsl:with-param>
					</xsl:call-template>					
				</xsl:if>

				<xsl:call-template name="make-xref">
					<xsl:with-param name="target-page" select="$highest-priority-page"/>
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="type" select="$type"/>
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
	
	<!--make-xref template-->
	<xsl:template name="make-xref">
		<xsl:param name="target-page"/>
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="current-page-name" as="xs:string"/>
		<xsl:param name="class">default</xsl:param>
		<xsl:param name="content"/>
		<xsl:param name="see-also" as="xs:boolean" select="false()"/>
		
		<xsl:variable name="target-topic-set" select="$target-page/parent::link-catalog/@topic-set-id"/>

		<xsl:variable name="target-directory" select="$target-page/parent::link-catalog/@output-directory"/>
		
		<xsl:variable name="target-directory-path" >
			<xsl:for-each select="tokenize($target-directory, '/')">
				<xsl:if test="position()!=last()">
					<xsl:text>../</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$target-directory"/>
		</xsl:variable>
		
		<xsl:variable name="target-file"  select="string($target-page/@file)"/>		
		
		<xsl:variable name="target-anchor" select="if ($target-page[1]/target[key=$target][@type=$type][1]/@anchor) then concat('#', $target-page[1]/target[key=$target][@type=$type][1]/@anchor) else ''"/>

		
		<xref hint="{$type}">
			<xsl:attribute name="target">
				<xsl:choose>
					<!-- this page -->
					<xsl:when test="$current-page-name=$target-page[1]/@full-name">
						<xsl:choose>
							<xsl:when test="not($target-anchor='')">
								 <xsl:value-of select="$target-anchor"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="sf:warning">
									<xsl:with-param name="message">
										<xsl:text>A page is linking to itself. This is a tool problem, not a content problem. The tools should not generate links to the current page. Report this as bug. Include the following information in the bug report: &#x000A;</xsl:text>
										<xsl:value-of select="'Reference-type=', $type, '&#x000A;'"/>
										<xsl:value-of select="'Target=', $target, '&#x000A;'"/>
										<xsl:value-of select="'Topic id=', ancestor::topic/name, '&#x000A;'"/>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="$target-anchor"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					
					<!-- this topic-set -->
					<xsl:when test="$topic-set-id=$target-topic-set">
						 <xsl:value-of select="concat($target-file, $target-anchor)"/>
					</xsl:when>
					
					<!-- outside this topic-set -->
					<xsl:otherwise>
						<xsl:value-of select="concat($target-directory-path, $target-file, $target-anchor)"/>
					</xsl:otherwise>
					
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:variable name="title">
				<xsl:variable name="target-content" select="normalize-space(string($target-page/target[key=$target][@type=$type]/label))"/>
				
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
			<xsl:attribute name="scope" select="$target-page/@scope"/>

			<xsl:choose>
				<xsl:when test="$see-also">
					<xsl:sequence select="$title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$content"/>
				</xsl:otherwise>
			</xsl:choose>
			</xref>
	</xsl:template>
	

	<xsl:template name="output-cross-reference">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="scope"/>
				
		<xsl:variable name="target-page" select="$link-catalogs/link-catalog/page[target/@type=$type][target/key=$target][esf:in-scope(.,$scope)]"/>
				
		<xsl:choose>
			<xsl:when test="(count($target-page/page/@file) > 1) or (count($link-catalogs/link-catalog/page[@full-name=$target-page/@full-name][@scope=$scope]) > 1)">
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">More than one destination found for the cross reference <xsl:value-of select="$target"/>. Unable to proceed.</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="make-cross-ref">
					<xsl:with-param name="target-page" select="$target-page"/>
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="type" select="$type"/>
					<xsl:with-param name="scope" select="$scope"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

		<!--make-cross-ref template-->
	<xsl:template name="make-cross-ref">
		<xsl:param name="target-page"/>
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="scope"/>

		<xsl:variable name="target-topic-set">
			<xsl:choose>
				<xsl:when test="$scope">
					<xsl:value-of select="$link-catalogs/link-catalog/page[@full-name=$target-page/@full-name][esf:in-scope(.,$scope)]/parent::link-catalog/@topic-set-id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$link-catalogs/link-catalog[page/@full-name=$target-page/@full-name]/@topic-set-id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="target-directory">
			<xsl:choose>
				<xsl:when test="$scope">
					<xsl:value-of select="$link-catalogs/link-catalog/page[@full-name=$target-page/@full-name][esf:in-scope(.,$scope)]/parent::link-catalog/@topic-set-id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$link-catalogs/link-catalog/page[@full-name=$target-page/@full-name][esf:in-scope(.,$scope)]/parent::link-catalog/@output-directory"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="target-directory-path" >
			<xsl:for-each select="tokenize($target-directory, '/')">
				<xsl:if test="position()!=last()">
					<xsl:text>../</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$target-directory"/>
		</xsl:variable>
	
		<xsl:variable name="target-file"  select="string($target-page/@file)"/>		
		
		<xsl:variable name="target-anchor" select="if ($target-page[1]/target[key=$target][@type=$type]/@anchor) then concat('#', $target-page[1]/target[key=$target][@type=$type]/@anchor) else ''"/>

		<xsl:choose>
			<!-- this book -->
			<xsl:when test="$topic-set-id eq $target-topic-set">
				<cross-ref 
					type="{$type}"
					target="{$target}"/>
			</xsl:when>
			
			<!-- outside this book -->
			<xsl:otherwise>
				<bold>
					<xsl:value-of select="$target-page/@title"/>
				</bold>
				<xsl:text> in </xsl:text>
				<italic>
					<xsl:value-of select="$link-catalogs/link-catalog[@topic-set-id=$target-topic-set]/@title"/>
				</italic> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- link-xpath template -->
	<xsl:template name="link-xpath">
		<xsl:param name="target" as="xs:string"/>
		<xsl:param name="link-text" as="xs:string"/>
		<xsl:variable name="scope" select="@scope"/>
		
		<!--Determine whether or not the target exists. -->
		<xsl:choose>
			<xsl:when test="not(esf:target-exists($target, 'xpath', $scope))">
				<!-- if it does not exist, output warning and continue, outputting plain text -->
				<xsl:call-template name="sf:warning">
					<xsl:with-param name="message" select="'Unknown xpath ', $target"/>
				</xsl:call-template>
				<!-- output plain text -->
				<xsl:value-of select="$link-text"/>
			</xsl:when>
			
			<xsl:otherwise>		
				<!-- it does exist so output a link -->
				<xsl:call-template name="output-link">
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="type">xpath</xsl:with-param>
					<xsl:with-param name="scope" select="$scope"/>
					<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
				</xsl:call-template>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- DOCUMENT GROUP -->
	<xsl:template match="*:term">
		<xsl:variable name="term" select="normalize-space(.)"/>
		<xsl:variable name="scope" select="@scope"/>
		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($term, 'term', $scope)">
				<xsl:call-template name="output-link">
					<xsl:with-param name="target" select="$term"/>
					<xsl:with-param name="type">term</xsl:with-param>
					<xsl:with-param name="class">gloss</xsl:with-param>
					<xsl:with-param name="content" select="normalize-space(string-join(.,''))"/>
						<xsl:with-param name="scope" select="$scope"/>
					<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:subject-affinity-not-resolved">
					<xsl:with-param name="message" select="'Term  &quot;', $term, '&quot; not resolved.'"/> 
				</xsl:call-template>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*:topic-id">
		<xsl:variable name="topic" select="@id-ref"/>
		<xsl:variable name="scope" select="@scope"/>
		
		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($topic, 'topic', $scope)">
				<!-- paper or online -->
				<xsl:choose>
					<xsl:when test="$media='paper'">
						<xsl:call-template name="output-cross-reference">
							<xsl:with-param name="target" select="$topic"/>
							<xsl:with-param name="type">topic</xsl:with-param>
							<xsl:with-param name="scope" select="$scope"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<italic>
							<xsl:call-template name="output-link">
								<xsl:with-param name="target" select="$topic"/>
								<xsl:with-param name="type">topic</xsl:with-param>
								<xsl:with-param name="content" as="xs:string">
									<xsl:value-of select="$link-catalogs//target[@type='topic'][key=$topic][esf:in-scope(parent::page, $scope)]/parent::page/@title"/>
								</xsl:with-param>
								<xsl:with-param name="scope" select="$scope"/>
								<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
							</xsl:call-template>
						</italic>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'Topic not found: ', $topic"/> 
				</xsl:call-template>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*:topic-set-id">
		<xsl:variable name="topic-set" select="@id-ref"/>
		<!-- topic set IDs would seem to be inherently unscoped, since the are unique. However, need to make sure we understand the interactions fully before removing the code altogether. -->

		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($topic-set, 'topic-set', '')">
				<!-- paper or online -->
				<xsl:choose>
					<xsl:when test="$media='paper'">
						<italic  hint="document-name">
								<xsl:value-of select="$link-catalogs//target[@type='topic-set'][key=$topic-set]/parent::page/@title"/>
						</italic>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="output-link">
							<xsl:with-param name="target" select="$topic-set"/>
							<xsl:with-param name="type">topic-set</xsl:with-param>
							<xsl:with-param name="content">
								<xsl:value-of select="$link-catalogs//target[@type='topic-set'][key=$topic-set]/parent::page/@title"/>
							</xsl:with-param>
							<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
							<!-- <xsl:with-param name="scope" select="$scope"/> -->
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'Topic set not found: ', $topic-set"/> 
				</xsl:call-template>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*:link-external">
	<!-- FIXME: support other protocols -->
		<xlink href="http://{if (starts-with(@href, 'http://')) then substring-after(@href, 'http://') else @href}">
			<xsl:apply-templates/>
		</xlink>	
	</xsl:template>

	<xsl:template match="*:url">
	<!-- FIXME: support other protocols -->
		<xlink href="{if (starts-with(., 'http://')) then . else concat('http://',.)}">
		 <xsl:apply-templates/>
		</xlink>	
	</xsl:template>

	<xsl:template match="*:subject-affinity">
		<xsl:variable name="content" select="normalize-space(.)"/>
			<xsl:choose>
				<xsl:when test="esf:target-exists(@key, @type, @scope)">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="@key"/>
						<xsl:with-param name="type" select="@type"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="scope" select="@scope"/>
						<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:subject-affinity-not-resolved">
						<xsl:with-param name="message" select="concat(@type, ' name &quot;', @key, '&quot; not resolved.')"/>
					</xsl:call-template>
					<xsl:value-of select="$content"/>								
				</xsl:otherwise>
			</xsl:choose>		
	</xsl:template>
	
	<xsl:template match="*:p/*:bold">
		<bold>
			<xsl:apply-templates/>
		</bold>
	</xsl:template>
	
	<xsl:template match="*:p/*:quote">
		<xsl:text>“</xsl:text>
			<xsl:apply-templates/>
		<xsl:text>”</xsl:text>
	</xsl:template>
	

	<xsl:template match="*:p/*:name">
		<!-- FIXME: handle namespace of the name? -->
		<xsl:if test="not(@key)">
			<xsl:call-template name="sf:warning">
				<xsl:with-param name="message" 
					select="'&quot;name&quot; subject-affinity element found with no &quot;key&quot; attribute:', . "/>
				
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="content" select="normalize-space(.)"/>
		<name type="{@type}">
			<xsl:choose>
				<xsl:when test="esf:target-exists(@key, @type, @scope)">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="@key"/>
						<xsl:with-param name="type" select="@type"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="scope" select="@scope"/>
						<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:subject-affinity-not-resolved">
						<xsl:with-param name="message" select="concat(@type, ' name &quot;', (if (@key) then @key else .), '&quot; not resolved.')"/> 
					</xsl:call-template>
					<xsl:value-of select="$content"/>								
				</xsl:otherwise>
			</xsl:choose>
		</name>	
	</xsl:template>
	
	<xsl:template match="*:decoration">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="*:selection-sequence">
		<gui-label hint="{name()}"><xsl:apply-templates/></gui-label>
	</xsl:template>

	<!-- TEXT STRUCTURE GROUP -->
	<!-- Should be more error checking here to check for captions -->
	
	<xsl:template match="*:table-id">
		<xsl:variable name="table-id" select="@id-ref"/>
		<xsl:if test="not(ancestor::topic//table[@id=$table-id]/title)">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message" select="'No table/title element found for referenced table:', $table-id, '. A title is required for all referenced tables.'"/>
			</xsl:call-template>
		</xsl:if>
				<cross-ref target="{@id-ref}" type="table"/>
	</xsl:template>
	
	<xsl:template match="*:fig-id">
		<xsl:variable name="fig-id" select="@id-ref"/>
		<xsl:variable name="uri" select="@uri"/>
		<xsl:if test="not(ancestor::topic//fig[@id=$fig-id or @uri=$uri]/title)">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message" select="'No fig/title element found for referenced fig:', if($uri) then $uri else $fig-id, '. A title is required for all referenced figs.'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$uri">
				<cross-ref target="{generate-id(ancestor::topic//fig[@uri=$uri]/@uri)}" type="fig"/>
			</xsl:when>
			<xsl:otherwise>
				<cross-ref target="{@id-ref}" type="fig"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*:code-sample-id">
		<cross-ref target="{@id-ref}" type="code-sample"/>
	</xsl:template>

	<xsl:template match="*:procedure-id">
		<cross-ref target="{@id-ref}" type="procedure"/>
	</xsl:template>

	<xsl:template match="*:step-id">
		<cross-ref target="{@id-ref}" type="step"/>
	</xsl:template>
	
	<xsl:template match="*:text-object-ref">
		<xsl:variable name="id" select="@id-ref"/>
		<xsl:choose>
			<xsl:when test="//text-object[id=$id] and not($media='paper')">
				<fold-toggle id="{generate-id()}" initial-state="folded">
					<xsl:apply-templates/>
				</fold-toggle>
			</xsl:when>
			<xsl:otherwise>
				<!-- no warning here because present-text-structures generates it -->
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
		
	<xsl:template match="*:index-entry">
		<xsl:call-template name="create-reference-link">
			<xsl:with-param name="type" select="@type"/>
			<xsl:with-param name="content">
				<xsl:apply-templates/>				
			</xsl:with-param>
		</xsl:call-template> 
	</xsl:template>
	
	
	<xsl:template name="create-reference-link">
		<xsl:param name="type"/>
		<xsl:param name="content"/>
		<xsl:variable name="scope" select="@scope"/>
		<xsl:variable name="target" select="if (@key) then normalize-space(@key) else normalize-space(.)"/>
		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($target, $type, $scope)">
				<xsl:call-template name="output-link">
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="type" select="$type"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="scope" select="$scope"/>
					<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="not-resolved-message">
					<xsl:value-of select="$type"/> string not found: <xsl:value-of select="$target"/>.
				</xsl:variable>
				<xsl:call-template name="sf:subject-affinity-not-resolved">
					<xsl:with-param name="message">
						<xsl:value-of select="$type"/> string not found: &quot;<xsl:value-of select="$target"/>&quot;.
					</xsl:with-param>
				</xsl:call-template>
				<xsl:sequence select="$content"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:function name="esf:process-placeholders" as="node()*">
	<!-- Processes a string to determine if it contains placeholder markup in 
	     the form of a string contained between "{" and "}". Recognizes "{{}"
	     as an escape sequence for a literal "{". Nesting of placeholders is
	     not supported. The use of a literal "{" or "}" inside the placeholder 
	     string is not supported. Does not attempt to detect or report these
	     conditions, however.
	     
	     $string is the string to process.
	     $literal-name is the element name to wrap around a the literal parts
	     of $string.
	     $placeholder-name is the element name to wrap around the placeholder
	     parts of $string.
	 -->
		<xsl:param name="string"/><!-- the string to process -->
		<xsl:param name="literal-name"/><!-- the element name to wrap around literal parts of $string -->
		<xsl:param name="placeholder-name"/><!-- the element name to wrap around placeholder parts of $string -->
		<xsl:analyze-string select="$string" regex="\{{([^}}]*)\}}">
			<xsl:matching-substring>
				<xsl:choose>
					<!-- if empty, ignore -->
					<xsl:when test="regex-group(1)=''"/>
					<!-- recognize {{} as escape sequence for { -->
					<xsl:when test="regex-group(1)='{'">
						<xsl:choose>
							<xsl:when test="$literal-name ne ''">
								<xsl:element name="{$literal-name}"><xsl:value-of select="regex-group(1)"/></xsl:element>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="regex-group(1)"/></xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{$placeholder-name}"><xsl:value-of select="regex-group(1)"/></xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:if test="not(normalize-space(.)='')">
						<xsl:choose>
							<xsl:when test="$literal-name ne''">
								<xsl:element name="{$literal-name}"><xsl:value-of select="."/></xsl:element>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
						</xsl:choose>
				</xsl:if>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:function>
				
	<!-- FIXME: Targets to absorb fields from the synthesis wrapper. Proper fix is to put all the refernceces into the EPPO simple namespace to avoid *: matches, which are always susceptible to matching other things. Might also consider writing the subject-affinities p//subject-affinity, but this has implications for any use of subject-affinity markup outside paragraphs. When this is fixed, remove the ss namespace declaration from the stylesheet element. -->
	<xsl:template match="ss:*"/>
</xsl:stylesheet>
