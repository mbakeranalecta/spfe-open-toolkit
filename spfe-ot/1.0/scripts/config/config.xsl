<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    xmlns:spfe="http://spfeopentoolkit.org/spfe-ot/1.0/xslt/fuctions"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gen="dummy-namespace-for-the-generated-xslt"
    xpath-default-namespace="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="../common/utility-functions.xsl"/>


    <xsl:param name="HOME"/>
    <xsl:param name="SPFEOT_HOME"/>
    <xsl:param name="SPFE_BUILD_DIR"/>
    <xsl:param name="SPFE_BUILD_COMMAND"/>
    <xsl:param name="configfile"/>
    
    <xsl:variable name="config-doc" select="document(sf:local-to-url(translate($configfile, '\', '/')))"/>

    <!-- directories -->
    <xsl:variable name="home" select="translate($HOME, '\', '/')"/>
    <xsl:variable name="spfeot-home" select="translate($SPFEOT_HOME, '\', '/')"/>
    <xsl:variable name="build-directory" select="translate($SPFE_BUILD_DIR, '\', '/')"/>
    <xsl:variable name="doc-set-build-root-directory"
        select="concat($build-directory,  '/', $config-doc/spfe/doc-set/doc-set-id)"/>
    <xsl:variable name="doc-set-build" select="concat($doc-set-build-root-directory, '/build')"/>
    <xsl:variable name="doc-set-config" select="concat($doc-set-build-root-directory, '/config')"/>
    <xsl:variable name="doc-set-output" select="concat($doc-set-build-root-directory, '/output')"/>
    <!--<xsl:variable name="topic-set-build" select="concat($doc-set-build, '/', $config/topic-set-id)"/>-->
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
            <define name="DOC_SET_BUILD_DIR" value="{$doc-set-build}"/>
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
                select="$config-doc"
                mode="load-config"/>
        </spfe>
    </xsl:variable>

    <!-- copy the attribute nodes from the config files -->
    <xsl:template match="@*" priority="-0.1" mode="load-config">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- copy the element nodes from the config files -->
    <!-- add a base-uri attribute to each so we can resolve relative URIs 
         correctly based on the config file in which they occurred -->
    <xsl:template match="*"  mode="load-config">
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
        <xsl:for-each select="//topic-type/href, //object-type/href, //output-format/href, //topic-set/href">
            <xsl:apply-templates select="document(resolve-uri(.,base-uri($this)))"
                mode="load-config"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="href|include|script[not(href)]|build-rules" mode="load-config">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:value-of
                select="sf:url-to-local(resolve-uri(spfe:resolve-defines(.),base-uri()))"/>
        </xsl:element>
    </xsl:template>




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
            <property name="spfe.build.build-directory" value="{$doc-set-build}"/>
            <property name="spfe.build.output-directory" value="{$doc-set-home}"/>
            <property name="spfe.build.link-catalog-directory" value="{$link-catalog-directory}"/>
            <property name="spfe.build.toc-directory" value="{$toc-directory}"/>
            <property name="spfe.doc-set-id" value="{$config/doc-set/doc-set-id}"/>
            

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
            </xsl:for-each>
            
            <xsl:for-each select="$config/output-format">
                <xsl:variable name="format-name" select="name"/>
                <files id="files.{$format-name}.support-files">
                    <xsl:for-each
                        select="$config/output-format[name=$format-name]/support-files/include">
                        <include name="{.}"/>
                    </xsl:for-each>
                </files>                
            </xsl:for-each>

            <target name="--build.synthesis">
                <xsl:for-each select="$config/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <xsl:comment select="$topic-set-id" />
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:if test="sources/sources-to-extract-content-from/include">
                        <build.extracted-content 
                            topic-set-id="{$topic-set-id}"
                            style="{$doc-set-build}/topic-sets/{$topic-set-id}/extract/spfe.extract.xsl">
                            <files-elements>
                                <files id="{$topic-set-id}.sources-to-extract-content-from">
                                    <xsl:for-each
                                        select="$config/topic-set[topic-set-id=$topic-set-id]/sources/sources-to-extract-content-from/include">
                                        <include name="{.}"/>
                                    </xsl:for-each>
                                </files>
                                <pathconvert dirsep="/" pathsep=";"
                                    property="sources-to-extract-content-from"
                                    refid="{$topic-set-id}.sources-to-extract-content-from"/>
                            </files-elements>
                        </build.extracted-content>                    
                    </xsl:if>
                    
                    <build.synthesis topic-set-id="{$topic-set-id}"
                        style="{$doc-set-build}/topic-sets/{$topic-set-id}/synthesis/spfe.synthesis.xsl">
                        <xsl:if
                            test="sources/authored-content/include">
                            <xsl:attribute name="authored-content-files"
                                select="concat('${', $topic-set-id, '.authored-content-files}')"/>
                        </xsl:if>
                    </build.synthesis>
                    
                    <build.link-catalog 
                        topic-set-id="{$topic-set-id}"
                        style="{$doc-set-build}/topic-sets/{$topic-set-id}/link-catalog/spfe.link-catalog.xsl">
                    </build.link-catalog>
                    
                    <build.toc 
                        topic-set-id="{$topic-set-id}"
                        style="{$doc-set-build}/topic-sets/{$topic-set-id}/toc/spfe.toc.xsl">
                    </build.toc>
                    
                </xsl:for-each>
            </target>

            
            <target name="--build.presentation">
                <xsl:for-each select="$config/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <build.presentation 
                        topic-set-id="{$topic-set-id}"
                        style="{$doc-set-build}/topic-sets/{$topic-set-id}/presentation/spfe.presentation.xsl">
                    </build.presentation>
                </xsl:for-each>
            </target>       
          

            <target name="--build.format">
                <xsl:for-each select="$config/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <build.format 
                        topic-set-id="{$topic-set-id}"
                        style="{$doc-set-build}/topic-sets/{$topic-set-id}/format/spfe.format.xsl"
                        output-directory="{if ($topic-set-id=$config/doc-set/home-topic-set) then '' else concat($topic-set-id, '/')}">
                    </build.format>
                </xsl:for-each>
            </target>
            

            <target name="--build.encode">
                <xsl:for-each select="$config/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <build.pdf-encode 
                        topic-set-id="{$topic-set-id}"
                        style="{$doc-set-build}/topic-sets/{$topic-set-id}/encode/spfe.encode.xsl">
                    </build.pdf-encode>
                </xsl:for-each>
            </target>
            
            
            <import file="{$spfeot-home}/1.0/build-tools/spfe-rules.xml"/>
        </project>
    </xsl:template>

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
                <doc-set-output>
                    <xsl:value-of select="$doc-set-output"/>
                </doc-set-output>
                <spfeot-home>
                    <xsl:value-of select="$SPFEOT_HOME"/>
                </spfeot-home>
                <build-command>
                    <xsl:value-of select="$SPFE_BUILD_COMMAND"/>
                </build-command>
                <link-catalog-directory>
                    <xsl:value-of select="$link-catalog-directory"/>
                </link-catalog-directory>
                <toc-directory>
                    <xsl:value-of select="$toc-directory"/>
                </toc-directory>
                <!-- FIXME: don't need to copy the topic set list as it is redundant -->
                <xsl:copy-of select="$config/doc-set"/>
                <xsl:for-each select="$config/topic-set">
                    <xsl:copy>
                        <output-directory>
                            <!-- FIXME: This dir ends with spearator. Others don't. Make consisten (by changing others) -->
                            <xsl:choose>
                                <xsl:when test="topic-set-id=$config/doc-set/home-topic-set">
                                    <xsl:text></xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat( topic-set-id, '/')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </output-directory>
                        <xsl:if test="not(topic-set-link-priority)">
                            <topic-set-link-priority>1</topic-set-link-priority>
                        </xsl:if>
                        <xsl:copy-of select="*"/>
                    </xsl:copy>
                </xsl:for-each>
                
                <xsl:for-each-group select="$config/topic-type" group-by="xmlns">
                    <xsl:variable name="this-topic-type" select="current-group()[1]"/>
                    <topic-type>
                        <xsl:if test="not($this-topic-type/topic-type-link-priority)">
                            <topic-type-link-priority>1</topic-type-link-priority>
                        </xsl:if>
                        <xsl:copy-of select="$this-topic-type/*"/>
                    </topic-type>
                </xsl:for-each-group>
                
                <xsl:for-each-group select="$config//subject-type" group-by="id">
                        <xsl:copy-of select="current-group()[1]" copy-namespaces="no"/>
                </xsl:for-each-group>
                
                <xsl:copy-of select="$config/output-format"/>
            </spfe>

        </xsl:result-document>
    </xsl:template>

    <xsl:namespace-alias stylesheet-prefix="gen" result-prefix="xsl"/>
    <xsl:template name="create-script-files">
        <xsl:param name="topic-set-id"/>

        <xsl:variable name="script-sets">
            <xsl:for-each
                select="$config/topic-set[topic-set-id=$topic-set-id]/topic-types/topic-type">
                <xsl:variable name="xmlns" select="xmlns"/>
                <xsl:sequence select="$config/topic-type[xmlns=$xmlns]/scripts"/>
            </xsl:for-each>
            <xsl:for-each
                select="$config/topic-set[topic-set-id=$topic-set-id]/object-types/object-type">
                <xsl:variable name="xmlns" select="xmlns"/>
                <xsl:sequence select="$config/object-type[xmlns=$xmlns]/scripts"/>
            </xsl:for-each>
            <xsl:for-each
                select="$config/output-format">
                <xsl:sequence select="scripts"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:for-each-group select="$script-sets/scripts/*" group-by="name()">
            <xsl:variable name="script-type"
                select="if (name()='other') then concat('other.',@name) else name()"/>
            <xsl:result-document
                href="file:///{$doc-set-build}/topic-sets/{$topic-set-id}/{$script-type}/spfe.{$script-type}.xsl" method="xml"
                indent="yes" xpath-default-namespace="http://www.w3.org/1999/XSL/Transform">
                <gen:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <!-- It is a mystery to me why we need to put *:script here. The default namespace here
                    should be config, but it does not works without *: prefix. -->
                    <xsl:for-each-group select="current-group()/*:script" group-by="concat(*:href/text(), ' ', normalize-space(*:remap-namespace/*:from), normalize-space(*:remap-namespace/*:to))">
                        <xsl:choose>                
                            <!-- If namespace remapping is specified, create a temp file with remapped namespaces -->
                            <xsl:when test="current-group()/*:remap-namespace">
                                <xsl:variable name="map-from-namespace" select="normalize-space(*:remap-namespace/*:from)"/>
                                <xsl:variable name="map-to-namespace" select="normalize-space(*:remap-namespace/*:to)"/>                                
                                <xsl:variable name="temp-file-name" select="concat(generate-id(*:remap-namespace/*:from), position(), sf:get-file-name-from-path(*:href))"/>
                                
                                <gen:include href="{$temp-file-name}"/>
                                <xsl:result-document
                                    href="file:///{$doc-set-build}/topic-sets/{$topic-set-id}/{$script-type}/{$temp-file-name}" method="text"
                                    indent="no" xpath-default-namespace="http://www.w3.org/1999/XSL/Transform">
                                    <xsl:analyze-string select="unparsed-text(concat('file:///',*:href))" regex="(xmlns.*?=[&quot;&apos;]|xpath-default-namespace=[&quot;&apos;]){sf:escape-for-regex($map-from-namespace)}([&quot;&apos;])">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="concat(regex-group(1),$map-to-namespace,regex-group(2))"/>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:value-of select="."/>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </xsl:result-document>                                
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Otherwise, just link to existing file. -->
                                <gen:include href="{concat(if(starts-with(*:href,'/')) then 'file://' else 'file:/', *:href)}"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </gen:stylesheet>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>
    
   

    
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
</xsl:stylesheet>
