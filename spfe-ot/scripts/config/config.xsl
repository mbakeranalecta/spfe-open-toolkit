<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:c="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    xmlns:spfe="http://spfeopentoolkit.org/spfe-ot/1.0/xslt/fuctions"
    xmlns:gen="dummy-namespace-for-the-generated-xslt"
    xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config" exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="build-dir" select="translate(($config/build/build-directory)[1], '\', '/')"/>
    
    <xsl:param name="HOME"/>
    <xsl:param name="SPFEOT_HOME"/>
    <xsl:param name="SPFE_BUILD_COMMAND"/>
    
    <xsl:variable name="config-docs" as="xs:string*">
        <xsl:value-of select="base-uri()"/>
        <xsl:call-template name="get-config-docs">
            <xsl:with-param name="config-doc" select="."/>
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:template name="get-config-docs">
        <xsl:param name="config-doc"/>
         <xsl:apply-templates select="$config-doc/spfe/include" mode="get-config-docs"/>
    </xsl:template>
    
    <xsl:template match="include" mode="get-config-docs">
        <xsl:variable name="included-doc" select="resolve-uri(@href, base-uri())"/>
        <xsl:choose>
            <xsl:when test="doc-available($included-doc)">
                <xsl:value-of select="$included-doc"/>
                <xsl:call-template name="get-config-docs">
                    <xsl:with-param name="config-doc" select="doc($included-doc)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'Include file not found:',$included-doc"></xsl:message>
            </xsl:otherwise>
        </xsl:choose>  
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="get-config-docs">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:variable name="raw-config" as="element(spfe)*">
        <xsl:for-each select="$config-docs">
            <xsl:message  select="'Loading config file: ', ."/>
            <xsl:apply-templates select="doc(.)" mode="load-config-doc"/>
        </xsl:for-each>    
    </xsl:variable>

    
 
    <xsl:template match="spfe/include" mode="load-config-doc">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="load-config-doc">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="load-config-doc"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="defines" as="element(define)*">
        <xsl:variable name="raw-defines" as="element(define)*">
            <c:define name="HOME" value="{translate($HOME, '\', '/')}"/>
            <c:define name="SPFEOT_HOME" value="{translate($SPFEOT_HOME, '\', '/')}"/>
          <xsl:for-each select="$raw-config//define">
              <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$raw-defines">
          <c:define name="{@name}">
              <xsl:attribute name="value">
                  <xsl:call-template name="resolve-define">
                      <xsl:with-param name="defines" select="$raw-defines"/>
                      <xsl:with-param name="value" select="@value"/>
                  </xsl:call-template>
              </xsl:attribute>
          </c:define>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template name="resolve-define">
        <xsl:param name="defines"/>
        <xsl:param name="value"/>
        <xsl:analyze-string select="$value" regex="\$\{{([^}}]*)\}}">
            <xsl:matching-substring>
                <xsl:variable name="key" select="regex-group(1)"/>
                <xsl:choose>
                    <xsl:when test="$defines[@name=$key][1]">
                        <xsl:call-template name="resolve-define">
                            <xsl:with-param name="defines" select="$defines"/>
                            <xsl:with-param name="value" select="$defines[@name=$key][1]/@value"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="'Unresolved define', $key"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
            
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:variable name="config" as="element(spfe)*">
        <xsl:apply-templates select="$raw-config" mode="resolve-config"/>
    </xsl:variable>
    
    <xsl:template match="@*|node()" mode="resolve-config" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="resolve-config"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="define" mode="resolve-config">
        <xsl:apply-templates mode="resolve-config"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="resolve-config">
        <xsl:analyze-string select="." regex="\$\{{([^}}]*)\}}">
            <xsl:matching-substring>
                <xsl:variable name="key" select="regex-group(1)"/>
                <xsl:choose>
                    <xsl:when test="$defines[@name=$key]">
                            <xsl:value-of select="$defines[@name=$key]/@value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="'Unresolved define', $key"/>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
            
        </xsl:analyze-string>
        
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:call-template name="create-build-file"/>
        <xsl:message select="'There is no doc-set:', not(/spfe/doc-set)"></xsl:message>
        <xsl:if test="not(/spfe/doc-set)">
          <xsl:call-template name="create-config-file"/>
          <xsl:call-template name="create-script-files"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="spfe:xml2properties">
        <!-- Convert an XML structure into a set of property statements -->
        <!-- FIXME: Should root be optional (as it is now) or required? -->
        <xsl:param name="root"/>
        <xsl:param name="base" as="xs:string"/>
        <xsl:for-each select="$root">
            <xsl:variable name="new-name">
                <xsl:choose>
                    <xsl:when test="name() eq 'other'">
                        <xsl:value-of select="if($base) then concat($base, '.other.', @name) else concat('other.', @name)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="if($base) then concat($base, '.', name($root)) else name($root)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="child::*">
                    <xsl:for-each select="child::*">
                        <xsl:sequence select="spfe:xml2properties(., $new-name)"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <property name="{if($base) then concat($base, '.', name($root)) else name($root)}" value="{.}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>        
    </xsl:function>
    
    <xsl:function name="spfe:URL-to-local">
        <xsl:param name="URL"/>
        <xsl:choose>
            <xsl:when test="matches($URL, 'file:/[:alpha:]/')">
                <xsl:value-of select="substring-after($URL,'file:/')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring-after($URL,'file:')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="create-build-file">
        <xsl:choose>
            <!-- if the config file specifies a doc set, create a build file for doc set -->
            <xsl:when test="/spfe/doc-set">
                <xsl:variable name="source" select="/"/>
                <project name="{/spfe/doc-set/@id}" default="{$SPFE_BUILD_COMMAND}">
                    <target name="{$SPFE_BUILD_COMMAND}"> 
                      <xsl:for-each select="$config/doc-set/topic-set">
                          <xsl:variable name="antfile" 
                              select="concat($source/spfe/doc-set/@id, position(), '.xml')"/>
                          <echo>Running config.xsl on <xsl:value-of select="spfe:URL-to-local(resolve-uri(., base-uri($source)))"/></echo>
                          <xslt classpath="{translate($SPFEOT_HOME, '\', '/')}/tools/saxon9he/saxon9he.jar"
                              style="{translate($SPFEOT_HOME, '\', '/')}/scripts/config/config.xsl" 
                              in="{spfe:URL-to-local(resolve-uri(., base-uri($source)))}"
                              out="{$antfile}"
                              force="yes">
                              <param name="HOME" expression="{$HOME}"/> 
                              <param name="SPFEOT_HOME" expression="{$SPFEOT_HOME}"/> 
                              <param name="SPFE_BUILD_COMMAND" expression="{$SPFE_BUILD_COMMAND}"/> 
                          </xslt>

                          <ant antfile="{$antfile}"
                               target="{$SPFE_BUILD_COMMAND}"/>
                      </xsl:for-each>
                    </target>
                </project> 
            </xsl:when>
            
            <!-- otherwise, create build file for topic-set -->
            <xsl:otherwise>  
              <project name="{$config/topic-set-id}" basedir="." default="draft">
                  <property file="{translate($HOME, '\', '/')}/.spfe/spfe.properties"/>
                  <property name="HOME" value="{translate($HOME, '\', '/')}"/>
                  <property name="SPFEOT_HOME" value="{translate($SPFEOT_HOME, '\', '/')}"/>
                  <property name="spfe.config-file" value="{translate(($config/build/build-directory)[1], '\', '/')}/config/spfe-config.xml"/>
                  <xsl:sequence select="spfe:xml2properties(($config/topic-set-id)[1], 'spfe')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/publication-info/title)[1], 'spfe.publication-info')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/publication-info/release)[1], 'spfe.publication-info')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/publication-info/product)[1], 'spfe.publication-info')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/publication-info/copyright)[1], 'spfe.publication-info')"/>
                  <xsl:sequence select="spfe:xml2properties($config/publication-info/other, 'spfe.publication-info')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/wip-site)[1], 'spfe')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/messages)[1], 'spfe')"/>
                  
                  <xsl:for-each select="$config/scripts/*">
                      <xsl:choose>
                          <xsl:when test="name()='other'">
                              <property name="spfe.scripts.other.{@name}" value="{$build-dir}/spfe.other.{@name}.xsl"/>
                          </xsl:when>
                          <xsl:otherwise>
                              <property name="spfe.scripts.{name()}" value="{$build-dir}/spfe.{name()}.xsl"/>
                          </xsl:otherwise>
                      </xsl:choose>
                      
                  </xsl:for-each>
                 
                  <xsl:sequence select="spfe:xml2properties(($config/build/build-directory)[1], 'spfe.build')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/build/output-directory)[1], 'spfe.build')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/build/link-catalog-directory)[1], 'spfe.build')"/>
                  <xsl:sequence select="spfe:xml2properties(($config/build/build-rules)[1], 'spfe.build')"/>
                  
                  <xsl:sequence select="spfe:xml2properties(($config/deployment/output-path)[1], 'spfe.deployment')"/>
                  
                  <files id="topics">
                      <xsl:for-each select="$config/sources/topics/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </files>
                  
                  <files id="text-objects">
                      <xsl:for-each select="$config/sources/text-objects/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </files>
                  
                  <files id="fragments">
                      <xsl:for-each select="$config/sources/fragments/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </files>
                  
                  <files id="graphics">
                      <xsl:for-each select="$config/sources/graphics/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </files>
                  
                  <files id="graphics-catalog">
                      <xsl:for-each select="$config/sources/graphics-catalog/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </files>
                  
                  <files id="strings">
                      <xsl:for-each select="$config/sources/strings/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </files>
                  
                  <files id="link-catalogs">
                      <xsl:for-each select="$config/sources/link-catalogs/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </files>
                  
      <!--            <files id="css">
                      <xsl:for-each select="$config/sources/css/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </files>
                  
                  <fileset id="javascript" dir=".">
                      <xsl:for-each select="$config/sources/css/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </fileset>
       -->           
                  <fileset id="synonyms" dir=".">
                      <xsl:for-each select="$config/sources/synonyms/include">
                          <include name="{.}"/>
                      </xsl:for-each>
                  </fileset>
                  
                  <xsl:for-each select="$config/sources/other">
                      <files id="other.{@name}">
                          <xsl:for-each select="include">
                              <include name="{.}"/>
                          </xsl:for-each>
                      </files>
                  </xsl:for-each>
                  
                  <xsl:choose>
                      <xsl:when test="$config/build/build-rules[1]">
                          <import file="{$config/build/build-rules[1]}"/>
                      </xsl:when>
                      <xsl:otherwise>
                          <import file="{$config/SPFEOT_HOME}/1.0/build-tools/spfe-rules.xml"/>
                      </xsl:otherwise>
                  </xsl:choose>
                  <xsl:for-each select="$config/other">
                      <property name="spfe.other.{@name}" value="{.}"/>
                  </xsl:for-each>
                  
              </project>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    

    
    <xsl:template name="create-config-file">
        <xsl:message select="concat('Generating config file: ', 'file:///', translate(($config/build/build-directory)[1], '\','/'), '/config/spfe-config.xml')"/>
         <xsl:result-document href="file:///{translate(($config/build/build-directory)[1], '\','/')}/config/spfe-config.xml" method="xml" indent="yes" xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config" xmlns="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config">
            <spfe>
                <dir-separator>
                    <xsl:value-of select="if (translate($HOME, '\', '/') eq $HOME) then ':' else ';'"/>
                </dir-separator>
                <build-command><xsl:value-of select="$SPFE_BUILD_COMMAND"/></build-command>
                <user-home><xsl:value-of select="translate($HOME, '\', '/')"/></user-home>
                <spfeot-home><xsl:value-of select="translate($SPFEOT_HOME, '\', '/')"/></spfeot-home>
                <xsl:copy-of select="$config/relative-to-list" copy-namespaces="no"/>
                <xsl:copy-of select="$config/topic-type-aliases" copy-namespaces="no"/>
                <xsl:copy-of select="($config/topic-set-id)[1]" copy-namespaces="no"/>
                <publication-info>
                    <xsl:copy-of select="($config/publication-info/title)[1]" copy-namespaces="no"/>
                    <xsl:copy-of select="($config/publication-info/release)[1]" copy-namespaces="no"/>
                    <xsl:copy-of select="($config/publication-info/product)[1]" copy-namespaces="no"/>
                    <xsl:copy-of select="($config/publication-info/copyright)[1]" copy-namespaces="no"/>
                </publication-info>

                <xsl:copy-of select="($config/topic-type-order)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/messages)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/condition-tokens)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/default-topic-scope)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/default-mention-scope)[1]" copy-namespaces="no"/>
                <build>
                    <output-directory>
                        <xsl:value-of select="translate(($config/build/output-directory)[1], '\', '/')"/>
                    </output-directory>
                    <build-directory>
                        <xsl:copy-of select="translate(($config/build/build-directory)[1], '\', '/')"/>
                    </build-directory>
                    <link-catalog-directory>
                        <xsl:copy-of select="translate(($config/build/link-catalog-directory)[1], '\', '/')"/>
                    </link-catalog-directory>
                </build>
                <deployment>
                    <output-path>
                        <xsl:value-of select="translate(($config/deployment/output-path)[1], '\', '/')"/>
                    </output-path>
                </deployment>
                <xsl:copy-of select="($config/format)[1]" copy-namespaces="no"/>    
                <other>
                 <xsl:for-each select="$config/other">
                     <xsl:element name="{@name}">
                         <xsl:value-of select="."/>
                     </xsl:element>
                 </xsl:for-each>
                </other>
            </spfe>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:namespace-alias stylesheet-prefix="gen" result-prefix="xsl"/>
    <xsl:template name="create-script-files">
        <xsl:for-each select="$config/scripts/*">
            <xsl:variable name="script-type" select="if (name()='other') then concat('other.',@name) else name()"/>            
            <xsl:result-document href="file:///{$build-dir}/spfe.{$script-type}.xsl" method="xml" indent="yes" xpath-default-namespace="http://www.w3.org/1999/XSL/Transform">
                <gen:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    version="2.0" >
                    <xsl:for-each select="c:script">
                        <!-- FIXME: need to figure out if this should be import or include -->
                        <gen:import href="file:///{.}"/>
                    </xsl:for-each>
                </gen:stylesheet>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>