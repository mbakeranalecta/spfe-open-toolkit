<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns:spfe="http://spfeopentoolkit.org/spfe-ot/1.0/xslt/fuctions"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gen="dummy-namespace-for-the-generated-xslt"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xpath-default-namespace="http://spfeopentoolkit/ns/spfe-ot/config"
    exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="../common/utility-functions.xsl"/>


    <xsl:param name="HOME"/>
    <xsl:param name="SPFEOT_HOME"/>
    <xsl:param name="SPFE_BUILD_DIR"/>
    <xsl:param name="SPFE_BUILD_COMMAND"/>
    <xsl:param name="configfile"/>

    <xsl:variable name="config-doc"
        select="document(sf:local-to-url(translate($configfile, '\', '/')))"/>

    <!-- directories -->
    <xsl:variable name="home" select="translate($HOME, '\', '/')"/>
    <xsl:variable name="spfeot-home" select="translate($SPFEOT_HOME, '\', '/')"/>
    <xsl:variable name="build-directory" select="translate($SPFE_BUILD_DIR, '\', '/')"/>
    <xsl:variable name="content-set-build-root-directory"
        select="concat($build-directory,  '/', $config-doc/content-set/content-set-id)"/>
    <xsl:variable name="content-set-build"
        select="concat($content-set-build-root-directory, '/build')"/>
    <xsl:variable name="content-set-config"
        select="concat($content-set-build-root-directory, '/config')"/>
    <xsl:variable name="content-set-output"
        select="concat($content-set-build-root-directory, '/output')"/>
    <xsl:variable name="content-set-home"
        select="concat($build-directory, '/', $config/content-set/content-set-id,'/output')"/>
    <xsl:variable name="link-catalog-directory" select="concat($content-set-build, '/link-catalogs')"/>
    <xsl:variable name="toc-directory" select="concat($content-set-build, '/tocs')"/>
    <xsl:variable name="objects-directory" select="concat($content-set-build, '/objects')"/>

    <xsl:function name="spfe:resolve-defines" as="xs:string">
        <xsl:param name="value"/>
        <xsl:variable name="defines" as="element(define)*">
            <define name="HOME" value="{$home}"/>
            <define name="SPFEOT_HOME" value="{$spfeot-home}"/>
            <define name="CONTENT_SET_BUILD_DIR" value="{$content-set-build}"/>
            <define name="CONTENT_SET_OUTPUT_DIR" value="{$content-set-output}"/>
            <define name="CONTENT_SET_BUILD_ROOT_DIR" value="{$content-set-build-root-directory}"/>
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

    <!-- 
    =============================================================================
         Read the configuration 
    =============================================================================
    -->

    <xsl:variable name="config">
        <xsl:call-template name="sf:info">
            <xsl:with-param name="message" select="'Loading config file ', $configfile"/>
        </xsl:call-template>
            <xsl:apply-templates select="$config-doc" mode="load-config"/>
    </xsl:variable>

    <!-- copy the attribute nodes from the config files -->
    <xsl:template match="@*" priority="-0.1" mode="load-config">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- copy the element nodes from the config files -->
    <!-- add a base-uri attribute to each so we can resolve relative URIs 
         correctly based on the config file in which they occurred -->
    <xsl:template match="*" mode="load-config">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="load-config"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="main">
        <!-- FIXME: Check that each topic set file is unique. To do this, need to normalize the locations, not just check the paths as strings. -->
        <xsl:call-template name="create-config-file"/>
        <xsl:call-template name="create-build-file"/>
        <xsl:call-template name="create-script-files"/>
   </xsl:template>
    
    <xsl:template match="/topic-set" mode="load-config">
        <xsl:if test="not(topic-set-link-priority)">
            <topic-set-link-priority>1</topic-set-link-priority>
        </xsl:if>
        <xsl:apply-templates mode="load-config"/>
    </xsl:template>
    <xsl:template match="/topic-set/topic-set-id" mode="load-config"/>
    <xsl:template match="/object-set" mode="load-config"><xsl:apply-templates mode="load-config"/></xsl:template>
    <xsl:template match="/object-set/object-set-id" mode="load-config"/>
    <xsl:template match="/topic-type" mode="load-config">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(topic-type-link-priority)">
                <topic-type-link-priority>1</topic-type-link-priority>
            </xsl:if>
            <xsl:apply-templates mode="load-config"/>
        </xsl:copy>
    </xsl:template>
    <!--<xsl:template match="spfe/topic-type/name" mode="load-config"/>-->
    <xsl:template match="/object-type" mode="load-config"><xsl:apply-templates mode="load-config"/></xsl:template>
    <xsl:template match="/object-type/name" mode="load-config"/>
    <xsl:template match="/structure" mode="load-config"><xsl:apply-templates mode="load-config"/></xsl:template>
    <xsl:template match="/structure/name" mode="load-config"/>
    <xsl:template match="/file-type" mode="load-config"><xsl:apply-templates mode="load-config"/></xsl:template>
    <xsl:template match="/file-type/name" mode="load-config"/>
    <xsl:template match="/structures/name" mode="load-config"/>
    <xsl:template match="content-set/topic-sets" mode="load-config"><xsl:apply-templates mode="load-config"/></xsl:template>
    <xsl:template match="/content-set/object-sets" mode="load-config"><xsl:apply-templates mode="load-config"/></xsl:template>
    <xsl:template match="/content-set/output-formats/output-format" mode="load-config"><xsl:apply-templates mode="load-config"/></xsl:template>
    <xsl:template match="/content-set/output-formats/output-format/name" mode="load-config"/>
    <xsl:template match="/topic-set/topic-types" mode="load-config"><xsl:apply-templates mode="load-config"/></xsl:template>

    <xsl:template match="script" mode="load-config">
        <xsl:param tunnel="yes" name="rewrite-namespace"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="load-config"/>
        <xsl:if test="$rewrite-namespace">
            <xsl:sequence select="$rewrite-namespace"/>
        </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- surpress the including version of the name in favor to the included one -->
    <xsl:template match="topic-type[href]" mode="load-config">
        <xsl:apply-templates mode="load-config"/>
    </xsl:template>
    <xsl:template match="topic-type[href]/name" mode="load-config"/>

    
    <xsl:template match="//topic-type/href| //object-type/href| //output-format/href| //presentation-type/href| //topic-set/href| //object-set/href| //structure/href| //file-type/href //object-type/href" mode="load-config">
        <xsl:variable name="this" select="."/>
        <xsl:if test="not(doc-available(resolve-uri(spfe:resolve-defines(.),base-uri($this))))">
            <xsl:call-template name="sf:error">
                <xsl:with-param name="message">
                    <xsl:text>Configuration file </xsl:text>
                    <xsl:value-of select="resolve-uri(spfe:resolve-defines(.),base-uri($this))"/>
                    <xsl:text> not found. </xsl:text>
                </xsl:with-param>
                <xsl:with-param name="in" select="base-uri(document(''))"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="../rewrite-namespace">
                <xsl:apply-templates
                    select="document(resolve-uri(spfe:resolve-defines(.),base-uri($this)))"
                    mode="load-config">
                    <xsl:with-param name="rewrite-namespace" tunnel="yes">
                        <xsl:sequence select="../rewrite-namespace"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                
            </xsl:when>
        
        <xsl:otherwise>
        <xsl:apply-templates
            select="document(resolve-uri(spfe:resolve-defines(.),base-uri($this)))"
            mode="load-config"/>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xsl:template match="href|include|script[not(href)]|build-rules" mode="load-config">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="sf:url-to-local(resolve-uri(spfe:resolve-defines(.),base-uri()))"
            />
        </xsl:element>
    </xsl:template>

    <!-- 
    =============================================================================
         Create the build file
    =============================================================================
    -->

    <xsl:template name="create-build-file">

        <!-- TO DO: check that all the topic sets have unique IDs -->
        <!-- TO DO: check that all the topic sets have unique build directories -->

        <project name="{$config/content-set/content-set-id}" default="{$SPFE_BUILD_COMMAND}"
            xmlns="">

            <property file="{$home}/.spfe/spfe.properties"/>
            <property name="HOME" value="{$home}"/>
            <property name="SPFEOT_HOME" value="{$spfeot-home}"/>
            <property name="spfe.config-file" value="{$content-set-config}/spfe-config.xml"/>
            <property name="SPFE_BUILD_COMMAND" value="{$SPFE_BUILD_COMMAND}"/>
            <property name="spfe.docset-build-root-directory"
                value="{$content-set-build-root-directory}"/>
            <property name="spfe.build.build-directory" value="{$content-set-build}"/>
            <property name="spfe.build.output-directory" value="{$content-set-home}"/>
            <property name="spfe.build.link-catalog-directory" value="{$link-catalog-directory}"/>
            <property name="spfe.build.objects-directory" value="{$objects-directory}"/>
            <property name="spfe.build.toc-directory" value="{$toc-directory}"/>
            <property name="spfe.content-set-id" value="{$config/content-set/content-set-id}"/>


            <target name="--build.synthesis">
                <xsl:for-each select="$config/content-set/topic-set, $config/content-set/object-set">
                    <xsl:variable name="set-id" select="if (topic-set-id) then topic-set-id else object-set-id"/>
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <xsl:variable name="object-set-id" select="object-set-id"/>
                    <xsl:variable name="dir-path" select="if($topic-set-id) then 'topic-sets' else 'object-sets'"/>
                    <xsl:comment select="$set-id"/>
                    <xsl:text>&#xa;</xsl:text>


                    <xsl:if test="sources/sources-to-extract-content-from/include">

                        <!-- EXTRACT -->
                        <!-- FIXME: Currently, spfe-rules expects a topic-set-id. Should either generalize ID or make separate rule. -->
                        <build.extracted-content topic-set-id="{$set-id}"
                            style="{$content-set-build}/{$dir-path}/{$set-id}/extract/spfe.extract.xsl"
                            output-directory="{$content-set-build}/{$dir-path}/{$set-id}/extract/out">
                            <files-elements>
                                <files id="{$set-id}.sources-to-extract-content-from">
                                    <xsl:for-each
                                        select="$config/content-set/topic-set[topic-set-id=$topic-set-id]/sources/sources-to-extract-content-from/include">
                                        <include name="{.}"/>
                                    </xsl:for-each>
                                    <xsl:for-each
                                        select="$config/content-set/object-set[object-set-id=$set-id]/sources/sources-to-extract-content-from/include">
                                        <include name="{.}"/>
                                    </xsl:for-each>
                                </files>
                                <pathconvert dirsep="/" pathsep=";"
                                    property="sources-to-extract-content-from"
                                    refid="{$set-id}.sources-to-extract-content-from"/>
                            </files-elements>
                        </build.extracted-content>

                        <!-- FIXME: need to distinguish merge content from regular topic content. -->
                        <xsl:if test="sources/authored-content/include">
                            <!-- MERGE -->
                            <build.merge topic-set-id="{$set-id}"
                                style="{$content-set-build}/{$dir-path}/{$set-id}/merge/spfe.merge.xsl"
                                output-directory="{$content-set-build}/{$dir-path}/{$set-id}/merge/out">
                                <files-elements>
                                    <files id="{$set-id}.extracts-to-merge-content-with">
                                        <include
                                            name="{$content-set-build}/{$dir-path}/{$set-id}/extract/out/*.xml"
                                        />
                                    </files>
                                    <pathconvert dirsep="/" pathsep=";"
                                        property="extracts-to-merge-content-with"
                                        refid="{$set-id}.extracts-to-merge-content-with"/>
                                    <files id="{$set-id}.authored-content">
                                        <xsl:for-each
                                            select="$config/content-set/topic-set[topic-set-id=$topic-set-id]/sources/authored-content/include">
                                            <include name="{.}"/>
                                        </xsl:for-each>
                                    </files>
                                    <pathconvert dirsep="/" pathsep=";"
                                        property="authored-content-files"
                                        refid="{$set-id}.authored-content"/>
                                </files-elements>
                            </build.merge>
                        </xsl:if>
                    </xsl:if>

                    <build.resolve topic-set-id="{$set-id}"
                        style="{$content-set-build}/{$dir-path}/{$set-id}/resolve/spfe.resolve.xsl"
                        output-directory="{if ($object-set-id)
                                           then concat($objects-directory, '/', $object-set-id)
                                           else concat($content-set-build,'/topic-sets/',$topic-set-id,'/resolve/out')}">
                        <files-elements>
                            <files id="{$set-id}.authored-content">
                                <xsl:choose>
                                    <xsl:when
                                        test="sources/sources-to-extract-content-from/include and sources/authored-content/include">
                                        <include
                                            name="{$content-set-build}/{$dir-path}/{$set-id}/merge/out/*.xml"
                                        />
                                    </xsl:when>
                                    <xsl:when test="sources/sources-to-extract-content-from/include">
                                        <include
                                            name="{$content-set-build}/{$dir-path}/{$set-id}/extract/out/*.xml"
                                        />
                                    </xsl:when>
                                    <xsl:when test="$object-set-id">
                                        <xsl:for-each select="$config/content-set/object-set[object-set-id=$object-set-id]/sources/authored-content/include">
                                            <include name="{.}"/>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each
                                            select="$config/content-set/topic-set[topic-set-id=$topic-set-id]/sources/authored-content/include">
                                            <include name="{.}"/>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </files>
                            <pathconvert dirsep="/" pathsep=";" property="authored-content-files"
                                refid="{$set-id}.authored-content"/>
                        </files-elements>
                    </build.resolve>

                    <xsl:if test="$topic-set-id"> 
                        <!-- FIXME: Should be building a link catalog for text objects. -->
                    <build.link-catalog topic-set-id="{$topic-set-id}"
                        style="{if ($object-set-id)
                        then concat($content-set-build, '/object-sets/', $object-set-id, '/link-catalog/spfe.link-catalog.xsl')
                        else concat($content-set-build, '/topic-sets/', $topic-set-id, '/link-catalog/spfe.link-catalog.xsl')}"
                        output-directory="{$content-set-build}/link-catalogs"> </build.link-catalog>
                    </xsl:if>

                   <xsl:if test="$topic-set-id"> 
                       <build.toc topic-set-id="{$topic-set-id}"
                           style="{$content-set-build}/topic-sets/{$topic-set-id}/toc/spfe.toc.xsl"
                        output-directory="{$content-set-build}/tocs"> </build.toc>
                   </xsl:if>

                </xsl:for-each>
            </target>

            <target name="--build.presentation">
                <xsl:for-each select="$config/content-set/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <xsl:for-each select="presentation-types/presentation-type">
                        <xsl:variable name="presentation-type" select="."/>
                        <build.present topic-set-id="{$topic-set-id}"
                            style="{$content-set-build}/topic-sets/{$topic-set-id}/present-{$presentation-type}/spfe.present-{$presentation-type}.xsl"
                            output-directory="{$content-set-build}/topic-sets/{$topic-set-id}/present-{$presentation-type}/out">
                            <xsl:if
                                test="$config/content-set/presentation-types/presentation-type[name eq $presentation-type]/copy-to">
                                <xsl:attribute name="copy-to"
                                    select="spfe:resolve-defines($config/content-set/presentation-types/presentation-type[name eq $presentation-type]/copy-to)"
                                />
                            </xsl:if>
                        </build.present>
                    </xsl:for-each>
                </xsl:for-each>
            </target>

            <target name="--build.format">
                <xsl:for-each select="$config/content-set/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <xsl:for-each select="output-formats/output-format">
                        <xsl:variable name="name" select="name"/>
                        <xsl:if test="not($config/content-set/output-formats/output-format[name=$name])">
                            <xsl:call-template name="sf:error">
                                <xsl:with-param name="message">
                                    <xsl:text>Unknown output format specified in topic set configuration.</xsl:text>
                                    <xsl:text> The topic set is: </xsl:text>
                                    <xsl:value-of select="$topic-set-id"/>
                                    <xsl:text>. The specified output format is: </xsl:text>
                                    <xsl:value-of select="$name"/>
                                    <xsl:text>. The known output formats are: </xsl:text>
                                    <xsl:value-of select="string-join($config/content-set/output-formats/output-format/name, ', ')"/>
                                    <xsl:text>.</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="in">
                                    <xsl:value-of select="$topic-set-id"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="not(ancestor::topic-set//scripts/format[@type=$name])">
                            <xsl:call-template name="sf:error">
                                <xsl:with-param name="message">
                                    <xsl:text>No format scripts found for specified output format.</xsl:text>
                                    <xsl:text> The topic set is: </xsl:text>
                                    <xsl:value-of select="$topic-set-id"/>
                                    <xsl:text>. The specified output format is: </xsl:text>
                                    <xsl:value-of select="$name"/>
                                    <xsl:text>. The known script types are: </xsl:text>
                                    <xsl:value-of select="string-join(distinct-values(ancestor::topic-set//scripts/format/@type), ', ')"/>
                                    <xsl:text>.</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:variable name="presentation-type"
                            select="$config/content-set/output-formats/output-format[name=$name][1]/presentation-type"/>
                        <build.format topic-set-id="{$topic-set-id}"
                            style="{$content-set-build}/topic-sets/{$topic-set-id}/format-{name}/spfe.format-{name}.xsl"
                            input-directory="{$content-set-build}/topic-sets/{$topic-set-id}/present-{$presentation-type}/out"
                            
                            output-directory="{$content-set-output}/{if ($topic-set-id=$config/content-set/home-topic-set) then '' else concat($topic-set-id, '/')}">
                            <files-elements>
                                <files id="files.support-files">
                                    <xsl:for-each
                                        select="$config/content-set/output-formats/output-format[name=$name]/support-files/include">
                                        <include name="{.}"/>
                                    </xsl:for-each>
                                </files>
                            </files-elements>
                        </build.format>
                    </xsl:for-each>
                </xsl:for-each>
            </target>

            <target name="--build.encode">
                <xsl:for-each select="$config/content-set/topic-set">
                    <xsl:variable name="topic-set-id" select="topic-set-id"/>
                    <build.pdf-encode topic-set-id="{$topic-set-id}"
                        style="{$content-set-build}/topic-sets/{$topic-set-id}/encode/spfe.encode.xsl"
                    > </build.pdf-encode>
                </xsl:for-each>
            </target>

            <import file="{$spfeot-home}/1.0/build-tools/spfe-rules.xml"/>
        </project>
    </xsl:template>

    <!-- 
    =============================================================================
         Create the config file
    =============================================================================
    -->

    <xsl:template name="create-config-file">
        <xsl:if test="not($config//content-set)">
            <xsl:call-template name="sf:error">
                <xsl:with-param name="message">
                 <xsl:text>Element /content-set not found in </xsl:text>
                 <xsl:value-of select="$configfile"/>
                 <xsl:text>. The configuration file provided to the build system must define a content set.</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="in" select="$configfile"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="sf:info">
            <xsl:with-param name="message" select="concat('Generating config file: ', 'file:///', $content-set-build, '/config/spfe-config.xml')"/>
        </xsl:call-template>
            
        <xsl:result-document href="file:///{$content-set-config}/spfe-config.xml" method="xml"
            indent="yes" xpath-default-namespace="http://spfeopentoolkit/ns/spfe-ot/config"
            xmlns="http://spfeopentoolkit/ns/spfe-ot/config" exclude-result-prefixes="#all">
            <config>
                <build-directory>
                    <xsl:value-of select="$build-directory"/>
                </build-directory>
                <content-set-build>
                    <xsl:value-of select="$content-set-build"/>
                </content-set-build>
                <content-set-output>
                    <xsl:value-of select="$content-set-output"/>
                </content-set-output>
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
                <content-set>                
                    <xsl:for-each select="$config/content-set/topic-set">
                        <xsl:copy>
                            <output-directory>
                                <!-- FIXME: This dir ends with spearator. Others don't. Make consistent (by changing others) -->
                                <xsl:choose>
                                    <xsl:when test="topic-set-id=$config/content-set/home-topic-set">
                                        <xsl:text/>
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
                   <xsl:copy-of select="$config/content-set/*[not(name()='topic-set')]"/>
                </content-set>                 
                <xsl:copy-of select="$config/object-set"/>                
                <xsl:copy-of select="$config/object-type"/>  
                
<!--                <xsl:for-each-group select="$config/topic-type" group-by="name">
                    <xsl:variable name="this-topic-type" select="current-group()[1]"/>
                    <topic-type>
                        <xsl:if test="not($this-topic-type/topic-type-link-priority)">
                            <topic-type-link-priority>1</topic-type-link-priority>
                        </xsl:if>
                        <xsl:copy-of select="$this-topic-type/*"/>
                    </topic-type>
                </xsl:for-each-group>
-->
                <xsl:for-each-group select="$config//subject-type" group-by="id">
                    <xsl:copy-of select="current-group()[1]" copy-namespaces="no"/>
                </xsl:for-each-group>

                <xsl:copy-of select="$config/output-format"/>
            </config>

        </xsl:result-document>
    </xsl:template>

    <!-- 
    =============================================================================
         Create the script files 
    =============================================================================
    -->

    <xsl:namespace-alias stylesheet-prefix="gen" result-prefix="xsl"/>
    <xsl:template name="create-script-files">
        
        <xsl:for-each select="$config/content-set/topic-set">
            <xsl:variable name="topic-set-id" select="topic-set-id"/>
            
            <xsl:variable name="script-list">
                <xsl:sequence select="descendant::scripts"/>
                <xsl:for-each select="$config/content-set/presentation-type">
                    <scripts>
                        <present type="{name}">
                            <xsl:sequence select="scripts/script"/>
                        </present>
                    </scripts>
                </xsl:for-each>
                
                <xsl:for-each
                    select="$config/content-set/presentation-type/topic-types/topic-type[name = $config/topic-set[topic-set-id=$topic-set-id][1]/topic-types/topic-type/name]">
                    <scripts>
                        <present type="{../../name}">
                            <xsl:sequence select="scripts/script"/>
                        </present>
                    </scripts>
                </xsl:for-each>
                
                <!-- FIXME: Do we need to check which output formats are being built, or has this been done above? -->
                <xsl:for-each select="$config/content-set/output-formats/output-format">
                    <xsl:sequence select="scripts"/>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:call-template name="output-script-set-files">
                <xsl:with-param name="script-list" select="$script-list"/>
                <xsl:with-param name="topic-set-id" select="$topic-set-id"/>
            </xsl:call-template>
        </xsl:for-each>
            <!-- FIXME: Need to get the presentation-type scripts for objects. (Not format.) -->
            
        <xsl:for-each select="$config/content-set/object-set">
            <xsl:variable name="object-set-id" select="object-set-id"/>
            
            <xsl:variable name="script-list">
                <xsl:sequence select="descendant::scripts"/>
                <xsl:for-each select="$config/content-set/presentation-type">
                    <scripts>
                        <present type="{name}">
                            <xsl:sequence select="scripts/script"/>
                        </present>
                    </scripts>
                </xsl:for-each>
                
                <xsl:for-each
                    select="$config/content-set/presentation-type/topic-types/topic-type[name = $config/topic-set[object-set-id=$object-set-id][1]/topic-types/topic-type/name]">
                    <scripts>
                        <present type="{../../name}">
                            <xsl:sequence select="scripts/script"/>
                        </present>
                    </scripts>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:call-template name="output-script-set-files">
                <xsl:with-param name="script-list" select="$script-list"/>
                <xsl:with-param name="object-set-id" select="$object-set-id"/>
            </xsl:call-template>
        </xsl:for-each>
        
    </xsl:template>
        
    <xsl:template name="output-script-set-files">
        <xsl:param name="script-list"/>
        <xsl:param name="topic-set-id" select="''"/>
        <xsl:param name="object-set-id" select="''"/>
        
        <!-- FIXME: Should test that each of the required script sets is present and raise error if not. -->
        <xsl:for-each-group select="$script-list/scripts/*" group-by="concat(name(), '.', @type)">
            <!-- FIXME: is other still supported? Should it be? -->
            <xsl:variable name="script-type"
                select="if (name()='other') then concat('other.',@name) else name()"/>
            <xsl:variable name="script-name-with-type"
                select="concat($script-type, if (@type) then concat('-', @type) else '')"/>
            <xsl:variable name="script-output-directory"
                select="if ($object-set-id)
                then concat($content-set-build, '/object-sets/', $object-set-id, '/', $script-name-with-type)
                else concat($content-set-build, '/topic-sets/', $topic-set-id, '/', $script-name-with-type)"/>
                       
            <xsl:variable name="script-rewrite-list">
                <xsl:for-each-group select="current-group()/config:script"
                    group-by="concat(*:href/text(), ' ', normalize-space(config:rewrite-namespace/config:from), normalize-space(config:rewrite-namespace/config:to))">
                    <script>
                        <xsl:choose>
                            <!-- If namespace remapping is specified, create a temp file with remapped namespaces -->
                            <xsl:when test="current-group()/config:rewrite-namespace">
                                <xsl:variable name="script-to-be-remapped" select="unparsed-text(concat('file:///',config:href))"/>
                                <xsl:variable name="map-from-namespace" select="normalize-space(config:rewrite-namespace/config:from)"/>
                                <xsl:variable name="map-to-namespace" select="normalize-space(config:rewrite-namespace/config:to)"/>
                                <xsl:variable name="regex">
                                    <xsl:text>(xmlns.*?=[&quot;&apos;]|xpath-default-namespace=[&quot;&apos;])</xsl:text>
                                    <xsl:value-of select="sf:escape-for-regex($map-from-namespace)"/>
                                    <xsl:text>([&quot;&apos;])</xsl:text>
                                </xsl:variable>
                                
                                <map-from-namespace>
                                    <xsl:sequence select="$map-from-namespace"/>
                                </map-from-namespace>
                                <map-to-namespace>
                                    <xsl:sequence select="$map-to-namespace"/>
                                </map-to-namespace>
                                <script-to-be-remapped>
                                    <xsl:sequence select="$script-to-be-remapped"/>
                                </script-to-be-remapped>
                                
                                <xsl:choose>
                                    <xsl:when test="matches($script-to-be-remapped, $regex)">
                                        <regex><xsl:value-of select="$regex"/></regex>
                                        <output-file-name>
                                            <xsl:value-of select="concat(generate-id(config:rewrite-namespace/config:from), position(), sf:get-file-name-from-path(config:href))"/>
                                        </output-file-name>"
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Otherwise, just link to existing file. -->                                
                                        <output-file-name remap="no">
                                            <xsl:value-of select="concat(if(starts-with(config:href,'/')) then 'file://' else 'file:/', config:href)"/>
                                        </output-file-name>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Otherwise, just link to existing file. -->
                                <output-file-name remap="no">
                                    <xsl:value-of select="concat(if(starts-with(config:href,'/')) then 'file://' else 'file:/', config:href)"/>
                                </output-file-name>
                            </xsl:otherwise>
                        </xsl:choose>
                    </script>
                </xsl:for-each-group>
            </xsl:variable>
                        
            <xsl:for-each-group select="$script-rewrite-list/config:script" group-by="config:output-file-name">
                <xsl:if test="not(config:output-file-name/@remap='no')">
                    <xsl:result-document
                        href="file:///{$script-output-directory}/{config:output-file-name}"
                        method="text" indent="no"
                        xpath-default-namespace="http://www.w3.org/1999/XSL/Transform">
                        <xsl:variable name="map-to-namespace" select="config:map-to-namespace"/>
                        <xsl:analyze-string select="config:script-to-be-remapped" regex="{config:regex}">
                            <xsl:matching-substring>
                                <xsl:value-of select="concat(regex-group(1),$map-to-namespace,regex-group(2))"/>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:result-document>
                </xsl:if>
            </xsl:for-each-group>
            <xsl:result-document
                href="file:///{$script-output-directory}/spfe.{$script-name-with-type}.xsl"
                method="xml" indent="yes"
                xpath-default-namespace="http://www.w3.org/1999/XSL/Transform">
                <gen:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:for-each-group select="$script-rewrite-list/config:script" group-by="config:output-file-name">
                        <gen:include href="{config:output-file-name}"/>
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
