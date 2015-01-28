__author__ = 'Mark Baker'
__copyright__ = "Analecta Communications Inc. 2015"

"""
Configuration parser for SPFE.
"""

import os
from urllib.parse import urljoin
import subprocess

try:
    import regex as re

    re_supports_unicode_categories = True
except ImportError:
    import re

    re_supports_unicode_categories = False

try:
    from lxml import etree

    print("running with lxml.etree")
except ImportError:
    try:
        # normal cElementTree install
        import cElementTree as etree

        print("running with cElementTree")
    except ImportError:
        try:
            # normal ElementTree install
            import elementtree.ElementTree as etree

            print("running with ElementTree")
        except ImportError:
            print("Failed to import ElementTree from any known place")


class SPFEConfig:
    def __init__(self, config_file, spfe_env):
        self.config_file = config_file
        self.abs_config_file = 'file:///' + os.path.abspath(config_file).replace('\\', '/')
        self.content_set_config = etree.parse(config_file)
        self.config_ns = {'config': 'http://spfeopentoolkit/ns/spfe-ot/config'}
        self.content_set_id = self.content_set_config.find('./config:content-set-id', namespaces=self.config_ns).text
        self.spfe_env = spfe_env
        self.content_set_build_root_dir = self.spfe_env['spfe_build_dir'] + '/' + self.content_set_id
        self.content_set_build_dir = self.content_set_build_root_dir + '/build'
        self.content_set_config_dir = self.content_set_build_root_dir + '/config'
        self.content_set_output_dir = self.content_set_build_root_dir + '/output'
        self.content_set_home = self.spfe_env['spfe_build_dir'] + '/' + self.content_set_id + '/output'
        self.content_set_config = subprocess.check_output(
            ['java',
             '-classpath',
             self.spfe_env['spfe_ot_home'] + '/tools/saxon9he/saxon9he.jar',
             'net.sf.saxon.Transform',
             '-xsl:' + self.spfe_env['spfe_ot_home'] + '/1.0/scripts/config/load-config.xsl',
             '-s:' + self.abs_config_file,
             'HOME=' + self.spfe_env['home'],
             'SPFEOT_HOME=' + self.spfe_env['spfe_ot_home'],
             'SPFE_BUILD_DIR=' + self.spfe_env['spfe_build_dir']])

    def write_config_file(self):
        etree.register_namespace('config', "http://spfeopentoolkit/ns/spfe-ot/config")

        config = etree.Element('{http://spfeopentoolkit/ns/spfe-ot/config}config')
        build_directory = etree.SubElement(config, '{http://spfeopentoolkit/ns/spfe-ot/config}build-directory')
        build_directory.text = self.spfe_env['spfe_build_dir']
        content_set_build = etree.SubElement(config, '{http://spfeopentoolkit/ns/spfe-ot/config}content-set-build')
        content_set_build.text = self.content_set_build_dir
        content_set_output = etree.SubElement(config, '{http://spfeopentoolkit/ns/spfe-ot/config}content-set-output')
        content_set_output.text = self.content_set_output_dir
        spfe_ot_home = etree.SubElement(config, '{http://spfeopentoolkit/ns/spfe-ot/config}spfeot-home')
        spfe_ot_home.text = self.spfe_env['spfe_ot_home']
        build_command = etree.SubElement(config, '{http://spfeopentoolkit/ns/spfe-ot/config}build-command')
        build_command.text = self.spfe_env['spfe_build_command']
        link_catalog_directory = etree.SubElement(config, '{http://spfeopentoolkit/ns/spfe-ot/config}link-catalog-directory')
        link_catalog_directory.text = self.content_set_build_dir + '/link-catalogs'
        toc_directory = etree.SubElement(config, '{http://spfeopentoolkit/ns/spfe-ot/config}toc-directory')
        toc_directory.text = self.content_set_build_dir + '/tocs'
        content_set = etree.SubElement(config,'{http://spfeopentoolkit/ns/spfe-ot/config}content-set')
        content_set.extend(etree.XML(self.content_set_config))

        for topic_set in config.iterfind('{http://spfeopentoolkit/ns/spfe-ot/config}content-set/{http://spfeopentoolkit/ns/spfe-ot/config}topic-set'):
            topic_set_id = topic_set.find('{http://spfeopentoolkit/ns/spfe-ot/config}topic-set-id').text
            home_topic_set = config.find('{http://spfeopentoolkit/ns/spfe-ot/config}content-set/{http://spfeopentoolkit/ns/spfe-ot/config}home-topic-set').text
            output_directory = etree.Element('{http://spfeopentoolkit/ns/spfe-ot/config}output-directory')
            if topic_set_id != home_topic_set:
                output_directory.text = topic_set_id + '/'
            topic_set.insert(0, output_directory)

        etree.ElementTree(config).write(self.content_set_config_dir + '/pconfig.xml',
                                        pretty_print=True,
                                        xml_declaration=True,
                                        encoding="utf-8",
                                        )
        x = """

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
                <xsl:for-each-group select="$config//subject-type" group-by="id">
                    <xsl:copy-of select="current-group()[1]" copy-namespaces="no"/>
                </xsl:for-each-group>

                <xsl:copy-of select="$config/output-format"/>
            </config>"""

        if __name__ == '__main__':
            pass