<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:c="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    xmlns:spfe="http://spfeopentoolkit.org/spfe-ot/1.0/xslt/fuctions"
    xmlns:gen="dummy-namespace-for-the-generated-xslt"
    xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="yes"/>


    <xsl:param name="HOME"/>
    <xsl:param name="SPFEOT_HOME"/>
    <xsl:param name="SPFE_BUILD_DIR"/>
    <xsl:param name="SPFE_BUILD_COMMAND"/>

    <!-- directories -->
    <xsl:variable name="home" select="translate($HOME, '\', '/')"/>
    <xsl:variable name="spfeot-home" select="translate($SPFEOT_HOME, '\', '/')"/>
    <xsl:variable name="build-directory" select="translate($SPFE_BUILD_DIR, '\', '/')"/>
    <xsl:variable name="docset-build"
        select="concat($build-directory,  '/', $config/doc-set/@id, '/build')"/>
    <xsl:variable name="topic-set-build" select="concat($docset-build, '/', $config/topic-set-id)"/>
    <xsl:variable name="doc-set-home"
        select="concat($build-directory, '/', $config/doc-set/@id,'/output')"/>
    <xsl:variable name="topicset-home">
        <xsl:choose>
            <xsl:when test="$config/topic-set-id eq $config/doc-set/home-topic-set">
                <xsl:value-of select="$doc-set-home"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($doc-set-home, '/', $config/topic-set-id)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="link-catalog-directory" select="concat($docset-build, '/link-catalogs')"/>
    <xsl:variable name="toc-directory" select="concat($docset-build, '/tocs')"/>

    <xsl:variable name="source" select="/"/>

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
                <xsl:message select="'Getting config file: ', $included-doc"/>
                <xsl:call-template name="get-config-docs">
                    <xsl:with-param name="config-doc" select="doc($included-doc)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'Include file not found:',$included-doc"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="topic-sets/topic-set" mode="get-config-docs">
        <xsl:variable name="topic-set-config" select="resolve-uri(href, base-uri())"/>
        <xsl:choose>
            <xsl:when test="doc-available($topic-set-config)">
                <xsl:value-of select="$topic-set-config"/>
                <xsl:message select="'Getting topic set file: ', $topic-set-config"/>
                <xsl:call-template name="get-config-docs">
                    <xsl:with-param name="config-doc" select="doc($topic-set-config)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'Topic-set file not found:',$topic-set-config"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="@*|node()" mode="get-config-docs">
        <xsl:apply-templates mode="get-config-docs"/>
    </xsl:template>

    <xsl:variable name="raw-config" as="element(spfe)*">
        <xsl:for-each select="$config-docs">
            <xsl:message select="'Loading config file: ', ."/>
            <xsl:apply-templates select="doc(.)/spfe" mode="load-config-doc"/>
        </xsl:for-each>
    </xsl:variable>

    <xsl:template match="spfe/include" mode="load-config-doc">
        <xsl:apply-templates mode="load-config-doc"/>
    </xsl:template>

    <xsl:template match="*" mode="load-config-doc">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="load-config-doc"/>
        </xsl:copy>
    </xsl:template>

    <xsl:variable name="defines" as="element(define)*">
        <xsl:variable name="raw-defines" as="element(define)*">
            <c:define name="HOME" value="{$home}"/>
            <c:define name="SPFEOT_HOME" value="{$spfeot-home}"/>
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

    <!-- copy the attribute nodes from the config files -->
    <xsl:template match="@*" mode="resolve-config" priority="-1">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- copy the element nodes from the config files -->
    <!-- add a base-uri attribute to each so we can resolve relative URIs 
         correctly based on the config file in which they occurred -->
    <xsl:template match="*" mode="resolve-config" priority="-1">
        <xsl:copy>
            <xsl:attribute name="base-uri" select="base-uri(.)"/>
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
        <xsl:message select="'Root match on file ', base-uri()"/>
        <xsl:call-template name="create-build-file"/>
        <xsl:if test="not(/spfe/doc-set)">
            <xsl:message terminate="yes">ERROR: /spfe/doc-set not found in <xsl:value-of
                    select="base-uri()"/>.</xsl:message>
            <!--          
          <xsl:call-template name="create-config-file"/>
          <xsl:call-template name="create-script-files"/>-->
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
                        <xsl:value-of
                            select="if($base) then concat($base, '.other.', @name) else concat('other.', @name)"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="if($base) then concat($base, '.', name($root)) else name($root)"
                        />
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
                    <property
                        name="{if($base) then concat($base, '.', name($root)) else name($root)}"
                        value="{.}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="spfe:URL-to-local">
        <xsl:param name="URL"/>
        <xsl:variable name="newURL">
            <xsl:choose>
                <!-- Windows style -->
                <xsl:when test="matches($URL, '^file:/[a-zA-Z]:/')">
                    <xsl:value-of select="substring-after($URL,'file:/')"/>
                </xsl:when>
                <!-- Windows system path -->
                <xsl:when test="matches($URL, '^[a-zA-Z]:/')">
                    <xsl:value-of select="$URL"/>
                </xsl:when>
                <!-- UNIX style -->
                <xsl:when test="matches($URL, '^file:/')">
                    <xsl:value-of select="substring-after($URL,'file:')"/>
                </xsl:when>
                <!-- unsupported protocol -->
                <xsl:when test="matches($URL, '^[a-zA-Z]+:/')">
                    <xsl:message terminate="yes">
                        <xsl:text>ERROR: A URL with an unsupported protocol was specified in a config file. The URL is: </xsl:text>
                        <xsl:value-of select="$URL"/>
                    </xsl:message>
                </xsl:when>

                <!-- already local -->
                <xsl:otherwise>
                    <xsl:value-of select="$URL"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="replace($newURL, '%20', ' ')"/>
    </xsl:function>

    <xsl:template name="create-build-file">

        <!-- TO DO: check that all the topic sets have unique IDs -->
        <!-- TO DO: check that all the topic sets have unique build directories -->

        <project name="{/spfe/doc-set/@id}" default="{$SPFE_BUILD_COMMAND}">
            <import file="{$spfeot-home}/1.0/build-tools/spfe-rules.xml"/>
            <!--            <target name="config">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="antfile" 
                        select="concat($source/spfe/doc-set/@id, '-', id, '.xml')"/>
                    
                    <xslt classpath="{$spfeot-home}/tools/saxon9he/saxon9he.jar"
                        style="{$spfeot-home}/1.0/scripts/config/config.xsl" 
                        in="{spfe:URL-to-local(resolve-uri(href, base-uri($source)))}"
                        out="{$antfile}"
                        force="yes">
                        <factory name="net.sf.saxon.TransformerFactoryImpl"/>
                        <param name="HOME" expression="{$HOME}"/> 
                        <param name="SPFEOT_HOME" expression="{$SPFEOT_HOME}"/> 
                        <param name="SPFE_BUILD_COMMAND" expression="{$SPFE_BUILD_COMMAND}"/> 
                        <param name="SPFE_BUILD_DIR" expression="{$SPFE_BUILD_DIR}"/> 
                    </xslt>
                </xsl:for-each>                        
            </target>
-->
            <target name="clean">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="antfile"
                        select="concat($source/spfe/doc-set/@id, '-', id,  '.xml')"/>

                    <xsl:call-template name="create-run-command">
                        <xsl:with-param name="build-command" select="'clean'"/>
                        <xsl:with-param name="antfile" select="$antfile"/>
                    </xsl:call-template>
                </xsl:for-each>
            </target>

            <target name="cat">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="antfile"
                        select="concat($source/spfe/doc-set/@id, '-', id,  '.xml')"/>

                    <xsl:call-template name="create-run-command">
                        <xsl:with-param name="build-command" select="'cat'"/>
                        <xsl:with-param name="antfile" select="$antfile"/>
                    </xsl:call-template>
                </xsl:for-each>
            </target>

            <target name="list-pages" depends="cat, -list"> </target>

            <target name="toc">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="antfile"
                        select="concat($source/spfe/doc-set/@id, '-', id,  '.xml')"/>

                    <xsl:call-template name="create-run-command">
                        <xsl:with-param name="build-command" select="'toc'"/>
                        <xsl:with-param name="antfile" select="$antfile"/>
                    </xsl:call-template>
                </xsl:for-each>
            </target>

            <target name="draft" depends="toc, cat, list-pages">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="antfile"
                        select="concat($source/spfe/doc-set/@id, '-', id,  '.xml')"/>

                    <xsl:call-template name="create-run-command">
                        <xsl:with-param name="build-command" select="'draft'"/>
                        <xsl:with-param name="antfile" select="$antfile"/>
                    </xsl:call-template>
                </xsl:for-each>
            </target>

            <target name="final" depends="toc, cat">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="antfile"
                        select="concat($source/spfe/doc-set/@id, '-', id,  '.xml')"/>

                    <xsl:call-template name="create-run-command">
                        <xsl:with-param name="build-command" select="'final'"/>
                        <xsl:with-param name="antfile" select="$antfile"/>
                    </xsl:call-template>
                </xsl:for-each>
            </target>

            <target name="pdf" depends="toc, cat">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="antfile"
                        select="concat($source/spfe/doc-set/@id, '-', id,  '.xml')"/>

                    <xsl:call-template name="create-run-command">
                        <xsl:with-param name="build-command" select="'pdf'"/>
                        <xsl:with-param name="antfile" select="$antfile"/>
                    </xsl:call-template>
                </xsl:for-each>
            </target>

        </project>
    </xsl:template>


    <xsl:template name="create-topic-set-build-file">
        <project name="{$config/topic-set-id}" basedir="." default="draft">
            <property file="{$home}/.spfe/spfe.properties"/>
            <property name="HOME" value="{$home}"/>
            <property name="SPFEOT_HOME" value="{$spfeot-home}"/>
            <property name="spfe.config-file" value="{$topic-set-build}/config/spfe-config.xml"/>
            <property name="SPFE_BUILD_COMMAND" value="{$SPFE_BUILD_COMMAND}"/>
            <xsl:sequence select="spfe:xml2properties(($config/topic-set-id)[1], 'spfe')"/>
            <xsl:sequence select="spfe:xml2properties(($config/topic-set-type)[1], 'spfe')"/>
            <xsl:sequence select="spfe:xml2properties(($config/wip-site)[1], 'spfe')"/>
            <xsl:sequence select="spfe:xml2properties(($config/messages)[1], 'spfe')"/>

            <xsl:for-each select="$config/scripts/*">
                <xsl:choose>
                    <xsl:when test="name()='other'">
                        <property name="spfe.scripts.other.{@name}"
                            value="{$topic-set-build}/spfe.other.{@name}.xsl"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <property name="spfe.scripts.{name()}"
                            value="{$topic-set-build}/spfe.{name()}.xsl"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>

            <property name="spfe.build.build-directory" value="{$topic-set-build}"/>

            <property name="spfe.build.output-directory" value="{$topicset-home}"/>
            <property name="spfe.build.link-catalog-directory" value="{$link-catalog-directory}"/>
            <property name="spfe.build.toc-directory" value="{$toc-directory}"/>

            <xsl:sequence
                select="spfe:xml2properties((spfe:URL-to-local(resolve-uri(($config/build/build-rules)[1], ($config/build/build-rules)[1]/@base-uri))), 'spfe.build')"/>
            <property name="spfe.deployment"
                value="{concat(($config/build/output-directory)[1], '/', ($config/topic-set-id)[1])}"/>

            <files id="authored-content-for-merge">
                <xsl:for-each select="$config/sources/authored-content-for-merge/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

            <files id="files-to-extract-content-from">
                <xsl:for-each select="$config/sources/files-to-extract-content-from/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>
            
            <target name="--build.synthesis">
                <build.synthesis style="" topic-set-id="{$config/topic-set-id}">
                    <files id="topics">
                        <xsl:for-each select="$config/sources/topics/include">
                            <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                        </xsl:for-each>
                    </files>
                </build.synthesis>
            </target>
            
            <target name="--build.link-catalog">
                <build.link-catalog style="" topic-set-id="{$config/topic-set-id}"/>
            </target>
            
            <target name="--build.list-pages">
                <build.list-pages style="" topic-set-id="{$config/topic-set-id}"/>
            </target>
            
            <target name="--build.presentation-web">
                <build.presentation-web style="" topic-set-id="{$config/topic-set-id}"/>
            </target>
            
            <target name="--build.presentation-book">
                <build.presentation-web style="" topic-set-id="{$config/topic-set-id}"/>
            </target>
            
            <files id="text-objects">
                <xsl:for-each select="$config/sources/text-objects/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

            <files id="fragments">
                <xsl:for-each select="$config/sources/fragments/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

            <files id="graphics">
                <xsl:for-each select="$config/sources/graphics/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>


            <files id="strings">
                <xsl:for-each select="$config/sources/strings/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

            <files id="link-catalogs">
                <include name="{concat($link-catalog-directory, '/*.xml')}"/>
            </files>

            <files id="tocs">
                <include name="{concat($toc-directory, '/*.xml')}"/>
            </files>

            <files id="synonyms">
                <xsl:for-each select="$config/sources/synonyms/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

            <xsl:for-each select="$config/sources/other">
                <files id="other.{@name}">
                    <xsl:for-each select="include">
                        <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                    </xsl:for-each>
                </files>
            </xsl:for-each>

            <xsl:choose>
                <xsl:when test="$config/build/build-rules[1]">
                    <xsl:for-each select="$config/build/build-rules[1]">
                        <import file="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <import file="{$config/SPFEOT_HOME}/1.0/build-tools/spfe-rules.xml"/>
                </xsl:otherwise>
            </xsl:choose>

            <resources id="spfe.style.html-style-directories">
                <xsl:for-each select="$config/style/html-style-directories/include">
                    <fileset dir="{spfe:URL-to-local(resolve-uri(. ,@base-uri))}"/>
                </xsl:for-each>
            </resources>

            <xsl:for-each select="$config/other">
                <property name="spfe.other.{@name}" value="{.}"/>
            </xsl:for-each>

        </project>

    </xsl:template>

    <!--   <xsl:template name="create-build-file">
        <xsl:choose>
            <!-\- if the config file specifies a doc set, create a build file for doc set -\->
            <xsl:when test="/spfe/doc-set">
                <xsl:call-template name="create-docset-build-file"/>
            </xsl:when>
            
            <!-\- otherwise, create build file for topic-set -\->
            <xsl:otherwise>  
                <xsl:call-template name="create-topic-set-build-file"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
-->
    <xsl:template name="create-run-command">
        <xsl:param name="build-command"/>
        <xsl:param name="antfile"/>
        <!-- Using <exec> rather than <ant> to avoid a memory exhaustion error that occurs when running <ant>. -->

        <exec executable="cmd" failonerror="yes" osfamily="windows">
            <arg value="/c"/>
            <arg value="ant.bat"/>
            <arg value="-f"/>
            <arg value="{$antfile}"/>
            <arg value="-lib"/>
            <arg value='"%SPFEOT_HOME%\tools\xml-commons-resolver-1.2\resolver.jar"'/>
            <arg value="{$build-command}"/>
            <arg value="-emacs"/>
        </exec>

        <exec executable="ant" failonerror="yes" osfamily="unix">
            <arg value="-f"/>
            <arg value="{$antfile}"/>
            <arg value="-lib"/>
            <arg value='"$SPFEOT_HOME/tools/xml-commons-resolver-1.2/resolver.jar"'/>
            <arg value="{$build-command}"/>
            <arg value="-emacs"/>
        </exec>

    </xsl:template>

    <xsl:template name="create-expanded-config-file">
        <xsl:message
            select="concat('Generating expanded config file: ', 'file:///', $docset-build, '/config/spfe-config.xml')"/>
        <xsl:result-document href="file:///{$docset-build}/config/spfe-config.xml" method="xml"
            indent="yes"
            xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
            xmlns="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config">
            <spfe>
                <dir-separator>
                    <!-- detect OS based on separator in $HOME -->
                    <xsl:value-of select="if ($home eq $HOME) then ':' else ';'"/>
                </dir-separator>
                <build-command>
                    <xsl:value-of select="$SPFE_BUILD_COMMAND"/>
                </build-command>
                <user-home>
                    <xsl:value-of select="$home"/>
                </user-home>
                <spfeot-home>
                    <xsl:value-of select="$spfeot-home"/>
                </spfeot-home>

                <doc-set>
                    <title>
                        <xsl:value-of select="$config/doc-set/title"/>
                    </title>
                    <topic-set-type-order>
                        <xsl:for-each select="$config/doc-set/topic-set-type-order/topic-set-type">
                            <topic-set-type>
                                <xsl:apply-templates/>
                            </topic-set-type>
                        </xsl:for-each>
                    </topic-set-type-order>
                    <home-topic-set>
                        <xsl:value-of select="$config/doc-set/home-topic-set"/>
                    </home-topic-set>
                    <topic-sets>
                        <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                            <topic-set>
                                <id>
                                    <xsl:value-of select="id"/>
                                </id>
                                <href>
                                    <xsl:value-of select="href"/>
                                </href>
                            </topic-set>
                        </xsl:for-each>
                    </topic-sets>
                </doc-set>

                <topic-type-aliases>
                    <xsl:for-each-group select="$config/topic-type-aliases/topic-type" group-by="id">
                        <xsl:copy-of select="current-group()[1]" copy-namespaces="no"/>
                    </xsl:for-each-group>
                </topic-type-aliases>

                <xsl:copy-of select="($config/topic-set-id)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/topic-set-type)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/topic-type-order)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/messages)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/condition-tokens)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/default-topic-scope)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/default-subject-affinity-scope)[1]"
                    copy-namespaces="no"/>
                <xsl:copy-of select="($config/home-topic-set)[1]" copy-namespaces="no"/>

                <build>
                    <output-directory>
                        <xsl:value-of select="$topicset-home"/>
                    </output-directory>
                    <build-directory>
                        <xsl:value-of select="$topic-set-build"/>
                    </build-directory>
                    <link-catalog-directory>
                        <xsl:value-of select="$link-catalog-directory"/>
                    </link-catalog-directory>
                    <toc-directory>
                        <xsl:value-of select="$toc-directory"/>
                    </toc-directory>
                </build>

                <!-- this is not catching anything. What was it for? -->
                <xsl:copy-of select="($config/format)[1]" copy-namespaces="no"/>

                <strings>
                    <xsl:for-each-group select="$config/strings/string" group-by="@id">
                        <xsl:copy-of select="current-group()[1]" copy-namespaces="no"/>
                    </xsl:for-each-group>
                </strings>

                <other>
                    <xsl:for-each select="$config/other">
                        <xsl:element name="{@name}">
                            <xsl:attribute name="base-uri" select="base-uri(.)"/>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </other>
            </spfe>
        </xsl:result-document>
    </xsl:template>


    <xsl:template name="create-config-file">
        <xsl:message
            select="concat('Generating config file: ', 'file:///', $topic-set-build, '/config/spfe-config.xml')"/>
        <xsl:result-document href="file:///{$topic-set-build}/config/spfe-config.xml" method="xml"
            indent="yes"
            xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
            xmlns="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config">
            <spfe>
                <dir-separator>
                    <!-- detect OS based on separator in $HOME -->
                    <xsl:value-of select="if ($home eq $HOME) then ':' else ';'"/>
                </dir-separator>
                <build-command>
                    <xsl:value-of select="$SPFE_BUILD_COMMAND"/>
                </build-command>
                <user-home>
                    <xsl:value-of select="$home"/>
                </user-home>
                <spfeot-home>
                    <xsl:value-of select="$spfeot-home"/>
                </spfeot-home>
                <topic-type-aliases>
                    <xsl:for-each-group select="$config/topic-type-aliases/topic-type" group-by="id">
                        <xsl:copy-of select="current-group()[1]" copy-namespaces="no"/>
                    </xsl:for-each-group>
                </topic-type-aliases>

                <xsl:copy-of select="($config/topic-set-id)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/topic-set-type)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/topic-type-order)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/messages)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/condition-tokens)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/default-topic-scope)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/default-subject-affinity-scope)[1]"
                    copy-namespaces="no"/>
                <xsl:copy-of select="($config/home-topic-set)[1]" copy-namespaces="no"/>

                <build>
                    <output-directory>
                        <xsl:value-of select="$topicset-home"/>
                    </output-directory>
                    <build-directory>
                        <xsl:value-of select="$topic-set-build"/>
                    </build-directory>
                    <link-catalog-directory>
                        <xsl:value-of select="$link-catalog-directory"/>
                    </link-catalog-directory>
                    <toc-directory>
                        <xsl:value-of select="$toc-directory"/>
                    </toc-directory>
                </build>
                <xsl:copy-of select="($config/format)[1]" copy-namespaces="no"/>
                <xsl:copy-of select="($config/doc-set)[1]" copy-namespaces="no"/>

                <strings>
                    <xsl:for-each-group select="$config/strings/string" group-by="@id">
                        <xsl:copy-of select="current-group()[1]" copy-namespaces="no"/>
                    </xsl:for-each-group>
                </strings>

                <other>
                    <xsl:for-each select="$config/other">
                        <xsl:element name="{@name}">
                            <xsl:attribute name="base-uri" select="base-uri(.)"/>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </other>
            </spfe>
        </xsl:result-document>
    </xsl:template>

    <xsl:namespace-alias stylesheet-prefix="gen" result-prefix="xsl"/>
    <xsl:template name="create-script-files">
        <xsl:variable name="script-style" select="$config/script-style"/>
        <xsl:for-each-group select="$config/scripts/*" group-by="name()">
            <xsl:variable name="script-type"
                select="if (name()='other') then concat('other.',@name) else name()"/>
            <xsl:result-document href="file:///{$topic-set-build}/spfe.{$script-type}.xsl"
                method="xml" indent="yes"
                xpath-default-namespace="http://www.w3.org/1999/XSL/Transform">
                <gen:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:for-each-group select="current-group()/c:script"
                        group-by="resolve-uri(.,@base-uri)">
                        <!-- FIXME: need to figure out if this should be import or include -->
                        <!-- FIXME: looks like include may be preferable to avoid complexities with import precedence -->
                        <!-- FIXME: But examine if this mechanism is actually worthwhile. -->
                        <!--                        <gen:import href="file:///{.}"/>-->
                        <!-- I'm not clear why resolve-uri seems to include the file:/ protocol string in Linux and not Windows, but it does, so we need to check.-->
                        <xsl:variable name="uri" select="resolve-uri(.,@base-uri)"/>
                        <xsl:choose>
                            <xsl:when test="@style">
                                <xsl:if
                                    test="tokenize(@style, '\s+') = tokenize($script-style, '\s+')">
                                    <gen:include
                                        href="{if (starts-with($uri, 'file:/')) then $uri else concat('file:/', $uri)}"
                                    />
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <gen:include
                                    href="{if (starts-with($uri, 'file:/')) then $uri else concat('file:/', $uri)}"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </gen:stylesheet>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
