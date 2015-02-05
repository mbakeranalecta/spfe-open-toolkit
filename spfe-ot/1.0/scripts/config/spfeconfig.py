__author__ = 'Mark Baker'
__copyright__ = "Analecta Communications Inc. 2015"

"""
Configuration parser for SPFE.
"""

import os
import subprocess
from collections import namedtuple
import rewriteurl


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
    import xml.etree.ElementTree as etree
    print("running with ElementTree")


class SPFEConfig:
    def __init__(self, config_file, spfe_env):
        self.config_file = config_file
        self.abs_config_file = 'file:///' + os.path.abspath(config_file).replace('\\', '/')
        self.content_set_config = etree.parse(config_file)
        self.config_ns = {'config': 'http://spfeopentoolkit.org/ns/spfe-ot/config'}
        self.content_set_id = self.content_set_config.find('./config:content-set-id', namespaces=self.config_ns).text
        self.spfe_env = spfe_env
        self.content_set_build_root_dir = self.spfe_env['spfe_build_dir'] + '/' + self.content_set_id
        self.content_set_build_dir = self.content_set_build_root_dir + '/build'
        self.spfe_env.update(
            {'content_set_build_root_dir': self.spfe_env['spfe_build_dir'] + '/' + self.content_set_id,
             'content_set_build_dir': self.content_set_build_root_dir + '/build',
             'content_set_config_dir': self.content_set_build_root_dir + '/config',
             'content_set_output_dir': self.content_set_build_root_dir + '/output',
             'content_set_home': self.spfe_env['spfe_build_dir'] + '/' + self.content_set_id + '/output',
             'link_catalog_directory': self.content_set_build_dir + '/link-catalogs',
             'toc_directory': self.content_set_build_dir + '/tocs'
            }
        )
        self.content_set_build_dir = self.content_set_build_root_dir + '/build'
        self.content_set_config_dir = self.content_set_build_root_dir + '/config'
        self.content_set_output_dir = self.content_set_build_root_dir + '/output'
        self.content_set_home = self.spfe_env['spfe_build_dir'] + '/' + self.content_set_id + '/output'
        self.content_set_config = etree.XML(
            subprocess.check_output(
            ['java',
             '-classpath',
             self.spfe_env['spfe_ot_home'] + '/tools/saxon9he/saxon9he.jar',
             'net.sf.saxon.Transform',
             '-xsl:' + self.spfe_env['spfe_ot_home'] + '/1.0/scripts/config/load-config.xsl',
             '-s:' + self.abs_config_file,
             'HOME=' + self.spfe_env['home'],
             'SPFEOT_HOME=' + self.spfe_env['spfe_ot_home'],
             'SPFE_BUILD_DIR=' + self.spfe_env['spfe_build_dir']]))

        self.config = etree.XML(
            """
<config xmlns="http://spfeopentoolkit.org/ns/spfe-ot/config">
    <build-directory>{spfe_build_dir}</build-directory>
    <content-set-build>{content_set_build_dir}</content-set-build>
    <content-set-output>{content_set_output_dir}</content-set-output>
    <spfeot-home>{spfe_ot_home}</spfeot-home>
    <build-command>{spfe_build_command}</build-command>
    <link-catalog-directory>{link_catalog_directory}</link-catalog-directory>
    <toc-directory>{toc_directory}</toc-directory>
</config>
""".format(**self.spfe_env))

        content_set = etree.SubElement(self.config, '{http://spfeopentoolkit.org/ns/spfe-ot/config}content-set')
        content_set.extend(self.content_set_config)

        # Calculate output directories for each topic set.
        for topic_set in self.config.iterfind(
                '{http://spfeopentoolkit.org/ns/spfe-ot/config}content-set/{http://spfeopentoolkit.org/ns/spfe-ot/config}topic-set'):
            topic_set_id = topic_set.find('{http://spfeopentoolkit.org/ns/spfe-ot/config}topic-set-id').text
            home_topic_set = self.config.find(
                '{http://spfeopentoolkit.org/ns/spfe-ot/config}content-set/{http://spfeopentoolkit.org/ns/spfe-ot/config}home-topic-set').text
            output_directory = etree.Element('{http://spfeopentoolkit.org/ns/spfe-ot/config}output-directory')
            if topic_set_id != home_topic_set:
                output_directory.text = topic_set_id + '/'
            topic_set.insert(0, output_directory)

        self.prettyprint(self.config)


    def write_config_file(self):
        etree.register_namespace('config', "http://spfeopentoolkit.org/ns/spfe-ot/config")

        # Write the spfe environment variables to the config file.

        etree.ElementTree(self.config).write(self.content_set_config_dir + '/pconfig.xml',
                                        xml_declaration=True,
                                        encoding="utf-8")

    def prettyprint(self, elem, level=0):
        i = "\n" + level * "  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "  "
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
            for elem in elem:
                self.prettyprint(elem, level + 1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i

    def write_script_files(self):
        Script = namedtuple('Script', 'href step step_type rw_from rw_to')
        TopicSet =namedtuple('TopicSet', 'id scripts')
        topic_sets = []
        for topic_set in self.config.iterfind(
                '{http://spfeopentoolkit.org/ns/spfe-ot/config}content-set/{http://spfeopentoolkit.org/ns/spfe-ot/config}topic-set'):
            topic_set_id = topic_set.find('./{http://spfeopentoolkit.org/ns/spfe-ot/config}topic-set-id').text
            scripts_set = set()
            for scripts in topic_set.iterfind('.//{http://spfeopentoolkit.org/ns/spfe-ot/config}scripts'):
                for step in scripts:
                    script_type = step.tag
                    for script in step:
                        step_name = step.tag.split("}")[1][0:]
                        try:
                            step_type = step.attrib['type']
                        except KeyError:
                            step_type = None
                        href = script.find('{http://spfeopentoolkit.org/ns/spfe-ot/config}href').text
                        try:
                            rw_from = script.find('{http://spfeopentoolkit.org/ns/spfe-ot/config}rewrite-namespace/{http://spfeopentoolkit.org/ns/spfe-ot/config}from').text
                        except AttributeError:
                            rw_from = None
                        try:
                            rw_to = script.find('{http://spfeopentoolkit.org/ns/spfe-ot/config}rewrite-namespace/{http://spfeopentoolkit.org/ns/spfe-ot/config}to').text
                        except AttributeError:
                            rw_to = None
                        scripts_set.add(Script(href, step_name, step_type,  rw_from, rw_to))
            topic_sets.append( TopicSet(topic_set_id, list(scripts_set)))

        # For each topic set
        # 	For each step
        # 		Create a base script for step
        # 		For each script
        # 			If namespace rewrite specified
        # 				If namespace found in script
        # 					Rewrite namespaces
        # 					Generate temp file name
        # 					Write temp file
        # 					Add generated file name include to base script
        # 					Continue
        # 			Add original file url to base script

        # os.environ["XML_CATALOG_FILES"] = os.path.abspath(self.spfe_env["spfe_ot_home"] + "/../catalog.xml")
        # print (os.environ["XML_CATALOG_FILES"])

        for ts in topic_sets:
            print(ts.id)
            #pull out a list of steps using set comprehension
            for step in {(s.step, s.step_type) for s in ts.scripts}:
                script_dir = '/'.join([self.content_set_build_dir,
                            'topic-sets',
                            ts.id,
                            step[0]])
                if step[1]:
                    script_dir += '-' + step[1]
                #for all the scripts for this step
                print( step)
                scripts_to_include=[]
                for script in {t for t in ts.scripts if (t.step, t.step_type) == step}:
                    if script.rw_to:
                        scripts_to_include.append(self.rewrite_namespaces(script, script_dir))
                    else:
                        scripts_to_include.append(script.href)
                print(*scripts_to_include, sep='\n')

                # Write out the containing script
                script_file = "spfe." + script.step
                if script.step_type:
                    script_file += '-' + script.step_type
                script_file += '.xsl'
                new_fn = "/".join([script_dir, script_file ])
                print(new_fn)
                os.makedirs(script_dir, exist_ok=True)
                with open(new_fn, 'w', encoding="utf8") as of:
                    print('<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">', file=of)
                    for line in {s for s in scripts_to_include}:
                        print('<xsl:include href="file:///{0}"/>'.format(line), file=of)
                    print('</xsl:stylesheet>', file=of)




    def rewrite_namespaces(self, script, script_dir):
        """
        Rewrite the namespaces in a script, write out the temporary script
        to a file, and return the path to that file.
        :param script: A named tuple of type Script
        :return: The file path of the created file
        """
        doctored_file_name = re.sub(r'\W', '_', script.rw_to) + '_' + os.path.basename(script.href)
        regex = re.compile("(xmlns.*?=['\"]|xpath-default-namespace=['\"]|\\{)" + re.escape(script.rw_from) + "(['\"\\}])")

        with open(script.href, encoding="utf8") as f:
            scr = f.read()
            Result = namedtuple("Result", "text count")
            result = Result(*regex.subn(r'\1' + script.rw_to + r'\2',scr))
            if result.count == 0: # no substitutions made
                return script.href
            else:
                new_fn = "/".join([script_dir, doctored_file_name])
                os.makedirs(script_dir, exist_ok=True)
                with open(new_fn, 'w', encoding="utf8") as of:
                    of.write(result.text)
                return new_fn


if __name__ == '__main__':
    pass