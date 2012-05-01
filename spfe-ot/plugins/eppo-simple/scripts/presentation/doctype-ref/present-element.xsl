<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 exclude-result-prefixes="#all">
	<xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/> 

	
<xsl:template name="link-doc-xpath">
	<xsl:param name="doc-xpath"/>
	<xsl:param name="group"/>
	<!--find the source-->
	<xsl:variable name="xpath" select="$synthesis/synthesis/topic/schema-element[doc-xpath=$doc-xpath]/xpath, $synthesis/synthesis/topic/schema-element/attributes/attribute[doc-xpath=$doc-xpath]/xpath"/>
	<!-- look at only the first match because the same elements may occur in more than one group, which will cause multiple versions to be listed in the synthesis -->
	<xsl:variable name="consumed" select="substring-before($xpath[1],$doc-xpath)"/>
	<xsl:call-template name="link-xpath-segments">
		<xsl:with-param name="xpath" select="$xpath[1]"/>
		<xsl:with-param name="consumed" select="$consumed"/>
		<xsl:with-param name="depth">1</xsl:with-param>
		<xsl:with-param name="group" select="$group"/>
	</xsl:call-template>
</xsl:template>

	<!--================================================
	link-xpath-segments function

	Called recursivly to link the segments of an xpath back 
	to the element named in each segment.
===================================================-->
<xsl:template name="link-xpath-segments">
	<xsl:param name="xpath"/>
	<xsl:param name="consumed"/>
	<xsl:param name="depth" select="0"/>
	<xsl:param name="group"/>

	<!--check depth to make sure it does not run for ever if something else breaks -->
	<xsl:if test="not($xpath=$consumed) and not($depth>10)">

		<!-- calculate this segment of the path -->
		<xsl:variable name="remainder" select="if ($consumed) then substring-after($xpath, $consumed) else string($xpath)"/>

		<xsl:variable name="segments" select="tokenize($remainder, '/')"/>
		<xsl:variable name="segment">
			<xsl:value-of select="if ($segments[1] > '') then $segments[1] else $segments[2]"/>
		</xsl:variable>
		
		<xsl:if test="starts-with($xpath, '/') or $consumed">
			<xsl:text>/</xsl:text>
		</xsl:if>
		
		<xsl:variable name="target" select="if (starts-with($xpath, '/') or $consumed) then concat($consumed, '/', $segment) else $segment"/>
			
		<xsl:call-template name="link-xpath">
			<xsl:with-param name="target" select="$target"/>
			<xsl:with-param name="link-text" select="$segment"/> 
			<xsl:with-param name="group" select="$group"/>
		</xsl:call-template>
		<!-- recursive call -->
		<xsl:call-template name="link-xpath-segments">
			<xsl:with-param name="xpath" select="$xpath"/>
			<xsl:with-param name="consumed" select="$target"/>
			<xsl:with-param name="depth" select="$depth+1"/>
			<xsl:with-param name="group" select="$group"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>


<!-- ==========================================================================
	link-xpath template

	link-xpath is called to create a link in the output. It checks that the 
	link target exists. If it is not, it prints an error on the command line.
=============================================================================-->

<xsl:template name="link-xpath">
	<xsl:param name="target" as="xs:string"/>
	<xsl:param name="link-text" as="xs:string"/>
	<xsl:param name="group"/>
	
	<xsl:variable name="targets" select="$synthesis//schema-element, $synthesis//attribute"/>
	
	<!--Determine whether or not the target exists. -->
	<xsl:choose>
		<xsl:when test="count($targets[xpath = $target]) > 1">
			<xsl:call-template name="warning">
				<xsl:with-param name="message" select="'Ambiguous xpath ', $target"/>
			</xsl:call-template>
			<!-- output plain text -->
			<xsl:value-of select="$link-text"/>
		</xsl:when>			
		
		<xsl:when test="not($targets[xpath = $target])">
			<!-- if it does not exist, report the error but continue, outputting plain text -->
			<xsl:call-template name="warning">
				<xsl:with-param name="message" select="'Unknown xpath', $target, '(link-text=', $link-text, ')'"/>
			</xsl:call-template>
			<!-- output plain text -->
			<xsl:value-of select="$link-text"/>
		</xsl:when>
		
		<xsl:otherwise>		
			<!-- it does exist so output a link -->
			<xsl:variable name="href">
				<xsl:value-of select="if (contains($target, '/@')) 
				then 		
					translate(substring-before($target, '/@'), '/', '_' )
				else
					translate($target, '/', '_' )"/>
				<xsl:text>.html</xsl:text>
				<xsl:if test="contains($target, '/@')">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="substring-after($target, '/@')"/>
				</xsl:if>
			</xsl:variable>
									
			<xref target="{$href}" title="Link to: {$target}">
 				<xsl:value-of select="$link-text"/>
			</xref>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

	<!-- 
		=================
		Element templates
		=================
	-->
	
	<!-- topic -->
	<xsl:template match="topic">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- schema-element -->
	<xsl:template match="schema-element">
		<xsl:variable name="xpath" select="xpath"/>
		<xsl:variable name="name" select="name"/>
		<!-- info -->
		<xsl:call-template name="info">
			<xsl:with-param name="message" select="'Creating page ', xpath/text()"/>
		</xsl:call-template>
		<page type="API" name="{translate(xpath, '/', '_')}">
			<anchor name="{translate(xpath, '/', '_')}"/>
			
			<title>Element: <xsl:value-of select="$name"/></title>
			
			<xsl:if test="doctype">
				<labeled-item>
					<label>Document type</label>
					<item>
						<p>
							<xsl:variable name="to-link">
								<doctype-ref><xsl:value-of select="doctype"/></doctype-ref>
							</xsl:variable>
							<xsl:apply-templates select="$to-link"/>
						</p>
					</item>
				</labeled-item>	
			</xsl:if>
			
			<labeled-item>
				<label>XPath</label>
				<item>
					<p>
						<xsl:call-template name="link-doc-xpath">
							<xsl:with-param name="doc-xpath" select="doc-xpath"/>
						</xsl:call-template>
					</p>
				</item>
			</labeled-item>	
			
			<labeled-item>
				<label>Description</label>
				<item>
					<xsl:if test="not(description)"><p/></xsl:if>
					<xsl:apply-templates select="description"/>
				</item>
			</labeled-item>	

			<labeled-item>
				<label>Rendering</label>
				<item>
					<xsl:if test="not(rendering)"><p>N/A</p></xsl:if>
					<xsl:apply-templates select="rendering"/>
				</item>
			</labeled-item>	

			<labeled-item>
				<label>Linking</label>
				<item>
					<xsl:if test="not(linking)"><p>N/A</p></xsl:if>
					<xsl:apply-templates select="linking"/>
				</item>
			</labeled-item>	
			
			<labeled-item>
				<label>Validation</label>
				<item>
					<xsl:if test="not(validation)"><p>N/A</p></xsl:if>
					<xsl:apply-templates select="validation"/>
				</item>
			</labeled-item>	
			
			<xsl:if test="allowed-in/xpath">
				<labeled-item>
					<label>Allowed in</label>
					<item>
						<ul>
							<xsl:for-each select="allowed-in/xpath">
							<xsl:sort select="."/>
							<xsl:variable name="child-xpath" select="."/>
							<p>
								<name hint="element-name">
									<xsl:call-template name="link-xpath">
										<xsl:with-param name="target" select="$child-xpath"/>
										<xsl:with-param name="link-text" select="concat($child-xpath,  '')"/>
									</xsl:call-template>
								</name>
							</p>
							</xsl:for-each>
						</ul>
					</item>
				</labeled-item>
			</xsl:if>
			
			<labeled-item>
				<label>Use</label>
				<!-- FIXME: need a more sophisticated reading of schema groups 
				     to define usage more accurately-->
				<item>
					<p>
						<xsl:choose>
							<xsl:when test="minOccurs='0' or group='choice'">Optional</xsl:when>
							<xsl:otherwise>Required</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="maxOccurs='unbounded'">, unbounded</xsl:if>
					</p>
				</item>
			</labeled-item>
			
			<labeled-item>
				<label>Children</label>
				<item>
					<xsl:if test="not(children/*)">
						<p>None</p>
					</xsl:if>
					<xsl:for-each select="children/child">
						<xsl:sort select="."/>
						<xsl:variable name="child-xpath" select="."/>
						<p>
							<name hint="element-name">
								<xsl:call-template name="link-xpath">
									<xsl:with-param name="target" select="$child-xpath"/>
									<xsl:with-param name="link-text" select="//schema-element[xpath eq $child-xpath]/name"/>
								</xsl:call-template>
							</name>
						</p>
					</xsl:for-each>
				</item>
			</labeled-item>	
			
			<labeled-item>
				<label>Attributes</label>
				<item>
					<xsl:if test="not(attributes/attribute)">
						<p>None</p>
					</xsl:if>
					<xsl:for-each select="attributes/attribute">
						<xsl:sort select="name"/>
						<p>
							<name hint="attribute-name">
								<xref target="#{name}">
									<xsl:value-of select="name"/>
								</xref>
							</name>
						</p>
					</xsl:for-each>
				</item>
			</labeled-item>	
			
			<!-- restrictions -->
			<xsl:call-template name="format-restrictions"/>
			
			<!-- Add the attributes -->
			<xsl:for-each select="attributes/attribute">
				<xsl:sort select="name"/>
				<xsl:call-template name="format-attribute"/>
			</xsl:for-each>
		</page>
	</xsl:template>
	
 	<!-- FIXME: these should be parent and/or namespace qualified to avoid clashing with other uses of the name -->
	<xsl:template match="required-by|verified-by|location|unspecified|special|precis|name"> 
		<xsl:apply-templates/>	
	</xsl:template>
	
	<xsl:template match="type"/>
	
	<!-- 
		============================
		format-restrictions template
		============================
	-->
	<xsl:template name="format-restrictions">
		<labeled-item>
			<label>Restrictions</label>
			<item>
				<xsl:choose>
					<xsl:when test="not(restrictions/restriction)">
						<p>None</p>
					</xsl:when>
					<xsl:otherwise>
						<ul>
							<xsl:for-each select="restrictions/restriction">
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</xsl:otherwise>
				</xsl:choose>
			</item>
		</labeled-item>
	</xsl:template>
	
	<!-- 
		=========================
		Format Attribute template
		=========================
	-->
	<xsl:template name="format-attribute">
		<xsl:variable name="self" select="xpath"/>
		<anchor name="{name}"/>
		<subhead>Attribute: <xsl:value-of select="name"/></subhead>
		
		<labeled-item>
			<label>XPath</label>
			<item hint="xpath">
				<xsl:call-template name="link-doc-xpath">
					<xsl:with-param name="doc-xpath" select="doc-xpath"/>
				</xsl:call-template>
			</item>
		</labeled-item>	
		
		<!-- description -->	
		<labeled-item>
			<label>Description</label>
			<item><!-- no <p> because description contains <p>, but add p if no description -->
				<xsl:if test="not(description)"><p/></xsl:if>
				<xsl:apply-templates select="description"/>
			</item>
		</labeled-item>	
		
		<!-- Use -->
		<labeled-item>
			<label>Use</label>
			<item>
				<p>
					<xsl:choose>
						<xsl:when test="use = 'required'">Required</xsl:when>
						<xsl:otherwise>Optional</xsl:otherwise>
					</xsl:choose>
				</p>
			</item>
		</labeled-item>
		
		
		<!-- XML data type -->
		<xsl:variable name="type" select="type"/>
		<labeled-item>
			<label>XML data type</label> 
			<item>
				<xsl:choose>
					<xsl:when test="syntax">
						<p>
							<fold-toggle id="{generate-id()}" initial-state="folded">
								<xsl:value-of select="$type"/>
							</fold-toggle>
						</p>
							<fold id="{generate-id()}" type="text-object" initial-state="closed" reference-text="{$type}">
								<xsl:apply-templates select="syntax/production[symbol=$type]/description/*"/>
								<p><bold>ABNF for <xsl:value-of select="$type"/></bold></p>
								<code-block>
								<xsl:for-each select="syntax/production">
									<xsl:call-template name="format-expanded-abnf">
										<xsl:with-param name="production" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</code-block>	
						</fold>
					</xsl:when>
					<xsl:otherwise>
						<p>
							<xsl:value-of select="$type"/>
						</p>
					</xsl:otherwise>
				</xsl:choose>
			</item>
		</labeled-item>	
		
		<!-- not specified -->
		<labeled-item>
			<label>Behavior if not specified</label>
			<item>
				<xsl:choose>
					<xsl:when test="not(values/unspecified)"><p>N/A</p></xsl:when> 
					<xsl:otherwise>
						<xsl:apply-templates select="values/unspecified"/>
					</xsl:otherwise>
				</xsl:choose>
			</item>
		</labeled-item>
		
		<!-- Special -->
		<labeled-item>
			<label>Values with special meanings</label>
			<item>
				<xsl:choose>
					<xsl:when test="values/value"> 
						<xsl:for-each select="values/value">
							<xsl:sort select="."/>
							<!-- FIXME: this is a hork that will not handle all text-group cases. Need to change to subheads for main headings to use labelled-item here. -->
							<p>
								<value hint="attribute-value">
									<xsl:value-of select="."/>
								</value>
								<xsl:text>: </xsl:text>
								<xsl:apply-templates select="following-sibling::description[1]/p[1]/node()"/>
							</p>
								<xsl:apply-templates select="following-sibling::description[1]/p[preceding-sibling::p]"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise><p>None</p></xsl:otherwise>
				</xsl:choose>
			</item>
		</labeled-item>
		<!-- restrictions -->
		<xsl:call-template name="format-restrictions"/>
	</xsl:template>
	
	
</xsl:stylesheet>
