<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    xmlns:spfe="http://spfeopentoolkit.org/spfe-ot/1.0/xslt/fuctions"
    xmlns:gen="dummy-namespace-for-the-generated-xslt"
    xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="yes"/>


    <xsl:param name="HOME"/>
    <xsl:param name="SPFEOT_HOME"/>
    <xsl:param name="SPFE_BUILD_DIR"/>
    <xsl:param name="SPFE_BUILD_COMMAND"/>
    <xsl:param name="configfile"/>

    <!-- directories -->
    <xsl:variable name="home" select="translate($HOME, '\', '/')"/>
    <xsl:variable name="spfeot-home" select="translate($SPFEOT_HOME, '\', '/')"/>
    <xsl:variable name="build-directory" select="translate($SPFE_BUILD_DIR, '\', '/')"/>
    <xsl:variable name="doc-set-build-root-directory"
        select="concat($build-directory,  '/', $config/doc-set/doc-set-id)"/>
    <xsl:variable name="doc-set-build" select="concat($doc-set-build-root-directory, '/build')"/>
    <xsl:variable name="doc-set-config" select="concat($doc-set-build-root-directory, '/config')"/>
    <xsl:variable name="topic-set-build" select="concat($doc-set-build, '/', $config/topic-set-id)"/>
    <xsl:variable name="doc-set-home"
        select="concat($build-directory, '/', $config/doc-set/doc-set-id,'/output')"/>
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
    <xsl:variable name="link-catalog-directory" select="concat($doc-set-build, '/link-catalogs')"/>
    <xsl:variable name="toc-directory" select="concat($doc-set-build, '/tocs')"/>

    <xsl:function name="spfe:resolve-defines" as="xs:string">
        <xsl:param name="value"/>
        <xsl:variable name="defines" as="element(define)*">
            <define name="HOME" value="{$home}"/>
            <define name="SPFEOT_HOME" value="{$spfeot-home}"/>
        </xsl:variable>
        <xsl:variable name="result">
            <xsl:analyze-string select="$value" regex="\$\{{([^}}]*)\}}">
                <xsl:matching-substring>
                    <xsl:value-of select="$defines[@name=regex-group(1)]/@value"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join($result,'')"/>
    </xsl:function>

    <xsl:variable name="config" as="element(spfe)*">
        <xsl:message select="'Loading config file ', $configfile"/>
        <spfe>
            <xsl:apply-templates
                select="document(concat('file:///', translate($configfile, '\', '/')))"
                mode="load-config"/>
        </spfe>
    </xsl:variable>

    <!-- copy the attribute nodes from the config files -->
    <xsl:template match="@*" priority="-1" mode="load-config">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- copy the element nodes from the config files -->
    <!-- add a base-uri attribute to each so we can resolve relative URIs 
         correctly based on the config file in which they occurred -->
    <xsl:template match="*" priority="-1" mode="load-config">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="load-config"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="main">
        <xsl:call-template name="create-config-file"/>
        <xsl:call-template name="create-build-file"/>
        <xsl:for-each select="$config/topic-set">
            <xsl:call-template name="create-script-files">
                <xsl:with-param name="topic-set-id" select="topic-set-id"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="spfe" mode="load-config">
        <xsl:variable name="this" select="."/>
        <xsl:apply-templates mode="load-config"/>
        <xsl:for-each select="//href">
            <xsl:apply-templates select="document(resolve-uri(.,base-uri($this)))"
                mode="load-config"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="href|include|script|build-rules" mode="load-config">
        <xsl:element name="{name()}">
            <xsl:value-of
                select="spfe:URL-to-local(resolve-uri(spfe:resolve-defines(.),base-uri()))"/>
        </xsl:element>
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

        <project name="{$config/doc-set/doc-set-id}" default="{$SPFE_BUILD_COMMAND}" xmlns="">

            <property file="{$home}/.spfe/spfe.properties"/>
            <property name="HOME" value="{$home}"/>
            <property name="SPFEOT_HOME" value="{$spfeot-home}"/>
            <property name="spfe.config-file" value="{$doc-set-config}/spfe-config.xml"/>
            <property name="SPFE_BUILD_COMMAND" value="{$SPFE_BUILD_COMMAND}"/>
            <property name="spfe.docset-build-root-directory"
                value="{$doc-set-build-root-directory}"/>
            <property name="spfe.build.build-directory" value="{$topic-set-build}"/>
            <property name="spfe.build.output-directory" value="{$doc-set-home}"/>
            <property name="spfe.build.link-catalog-directory" value="{$link-catalog-directory}"/>
            <property name="spfe.build.toc-directory" value="{$toc-directory}"/>
            <property name="spfe.doc-set-id" value="{$config/doc-set/doc-set-id}"/>

            <target name="--build.toc">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <build.toc topic-set-id="{topic-set-id}" style=""/>
                </xsl:for-each>
            </target>

            <target name="--build.html-format">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <build.html-format topic-set-id="{topic-set-id}" style="" output=""/>
                </xsl:for-each>
            </target>

            <target name="--build.fo-format">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <build.html-format topic-set-id="{topic-set-id}" style="" output=""/>
                </xsl:for-each>
            </target>

            <target name="--build.pdf-encode">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <build.html-format topic-set-id="{topic-set-id}" output=""/>
                </xsl:for-each>
            </target>

            <target name="--build.synthesis">
                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <build.synthesis topic-set-id="{$topic-set-id}"
                        style="{$doc-set-build}/{$topic-set-id}/spfe.synthesis.xsl">
                        <xsl:if
                            test="$config/topic-set[topic-set-id=$topic-set-id]/sources/authored-content/include">
                            <xsl:attribute name="authored-content-files"
                                select="concat('${', $topic-set-id, '.authored-content-files}')"/>
                        </xsl:if>
                    </build.synthesis>
                </xsl:for-each>
            </target>

            <!-- FIXME: Does this allow for more than one extract operation per topic set?
                 and if not, does that matter? What do we do if we want to create a topic 
                 set that extracts content from more than one source to cobine into a single
                 topic type? Can we predefine a config scenario for all the possible ineresting
                 cases, or would it be better to delegate it to the script (which could include
                 the use of 'other' config options. 
            -->
            <target name="--build.extracted-content">
                <!-- only define this stage for topic sets that define sources to extract from -->
                <xsl:for-each select="$config/topic-set[sources/sources-to-extract-content-from/include]">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <xsl:variable name="topic-type-xmlnss" select="//topic-type/xmlns"/>
                        <build.extracted-content 
                            topic-set-id="{$topic-set-id}"
                            style="{$doc-set-build}/{$topic-set-id}/spfe.extract.xsl"
                            sources-to-extract-content-from="${{{$topic-set-id}.sources-to-extract-content-from-files}}"
                            />                    
                </xsl:for-each>
<!--                <xsl:for-each select="$config/doc-set/topic-sets/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <xsl:variable name="topic-type-xmlnss" select="//topic-type/xmlns"/>
                    <xsl:if test="$config/topic-types[xmlns=$topic-type-xmlnss]/scripts/extract/script">
                        <build.extracted-content topic-set-id="{$topic-set-id}"
                            style="{$doc-set-build}/{$topic-set-id}/spfe.extract.xsl"
                            sources-to-extract-content-from="${{{$topic-set-id}.sources-to-extract-content-from-files}}"
                            > </build.extracted-content>
                    </xsl:if>
                    
                </xsl:for-each>
-->            </target>




            <xsl:for-each select="$config/topic-set">
                <xsl:variable name="topic-set-id" select="topic-set-id"/>
                <files id="{$topic-set-id}.authored-content">
                    <xsl:for-each
                        select="$config/topic-set[topic-set-id=$topic-set-id]/sources/authored-content/include">
                        <include name="{.}"/>
                    </xsl:for-each>
                </files>
                <pathconvert dirsep="/" pathsep=";"
                    property="{$topic-set-id}.authored-content-files"
                    refid="{$topic-set-id}.authored-content"/>

                <files id="{$topic-set-id}.sources-to-extract-content-from">
                    <xsl:for-each
                        select="$config/topic-set[topic-set-id=$topic-set-id]/sources/sources-to-extract-content-from/include">
                        <include name="{.}"/>
                    </xsl:for-each>
                </files>
                <pathconvert dirsep="/" pathsep=";"
                    property="{$topic-set-id}.sources-to-extract-content-from-files"
                    refid="{$topic-set-id}.sources-to-extract-content-from"/>
            </xsl:for-each>


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

            <import file="{$spfeot-home}/1.0/build-tools/spfe-rules.xml"/>
        </project>

    </xsl:template>


    <xsl:template name="create-topic-set-build-file">
        <project name="{$config/topic-set-id}" basedir="." default="draft">
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

            <files id="sources-to-extract-content-from">
                <xsl:for-each select="$config/sources/sources-to-extract-content-from/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

            <!--            <files id="text-objects">
                <xsl:for-each select="$config/sources/text-objects/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

            <files id="fragments">
                <xsl:for-each select="$config/sources/fragments/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

-->
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

            <!--            <files id="synonyms">
                <xsl:for-each select="$config/sources/synonyms/include">
                    <include name="{spfe:URL-to-local(resolve-uri(.,@base-uri))}"/>
                </xsl:for-each>
            </files>

-->
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
    <!-- <xsl:template name="create-run-command">
        <xsl:param name="build-command"/>
        <xsl:param name="antfile"/>
        <!-\- Using <exec> rather than <ant> to avoid a memory exhaustion error that occurs when running <ant>. -\->

        <exec executable="cmd" failonerror="yes" osfamily="windows" xmlns="">
            <arg value="/c"/>
            <arg value="ant.bat"/>
            <arg value="-f"/>
            <arg value="{$antfile}"/>
            <arg value="-lib"/>
            <arg value='"%SPFEOT_HOME%\tools\xml-commons-resolver-1.2\resolver.jar"'/>
            <arg value="{$build-command}"/>
            <arg value="-emacs"/>
        </exec>

        <exec executable="ant" failonerror="yes" osfamily="unix" xmlns="">
            <arg value="-f"/>
            <arg value="{$antfile}"/>
            <arg value="-lib"/>
            <arg value='"$SPFEOT_HOME/tools/xml-commons-resolver-1.2/resolver.jar"'/>
            <arg value="{$build-command}"/>
            <arg value="-emacs"/>
        </exec>

    </xsl:template>-->




    <xsl:template name="create-config-file">
        <xsl:if test="not($config//doc-set)">
            <xsl:message terminate="yes">
                <xsl:text>ERROR: /spfe/doc-set not found in </xsl:text>
                <xsl:value-of select="$configfile"/>
                <xsl:text>. The configuration file provided to the build system must define a doc set.</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:message
            select="concat('Generating config file: ', 'file:///', $doc-set-build, '/config/spfe-config.xml')"/>
        <xsl:result-document href="file:///{$doc-set-config}/spfe-config.xml" method="xml"
            indent="yes"
            xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
            xmlns="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
            exclude-result-prefixes="#all">
            <spfe>
                <build-directory>
                    <xsl:value-of select="$build-directory"/>
                </build-directory>
                <doc-set-build>
                    <xsl:value-of select="$doc-set-build"/>
                </doc-set-build>
                <spfeot-home>
                    <xsl:value-of select="$SPFEOT_HOME"/>
                </spfeot-home>
                <xsl:sequence select="$config/*"/>
            </spfe>

        </xsl:result-document>
    </xsl:template>

    <xsl:namespace-alias stylesheet-prefix="gen" result-prefix="xsl"/>
    <xsl:template name="create-script-files">
        <xsl:param name="topic-set-id"/>

        <xsl:variable name="script-sets">
            <xsl:for-each
                select="$config/topic-set[topic-set-id=$topic-set-id]/topic-types/included-topic-types/topic-type">
                <xsl:variable name="xmlns" select="xmlns"/>
                <xsl:sequence select="$config/topic-type[xmlns=$xmlns]/scripts"/>
            </xsl:for-each>
        </xsl:variable>

        <!--<xsl:message select="'$script-sets', $script-sets/scripts/synthesis"/>-->

        <xsl:for-each-group select="$script-sets/scripts/*" group-by="name()">
            <xsl:variable name="script-type"
                select="if (name()='other') then concat('other.',@name) else name()"/>
            <xsl:result-document
                href="file:///{$doc-set-build}/{$topic-set-id}/spfe.{$script-type}.xsl" method="xml"
                indent="yes" xpath-default-namespace="http://www.w3.org/1999/XSL/Transform">
                <gen:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <!-- It is a mystery to me why we need to put *:script here. The default namespace here
                    should be config, but it does not works without *: prefix. -->
                    <xsl:for-each select="distinct-values(current-group()/*:script/text())">
                        <gen:include href="{concat('file:/', .)}"/>
                    </xsl:for-each>
                </gen:stylesheet>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
