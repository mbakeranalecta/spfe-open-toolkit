__author__ = 'Mark Baker'
__copyright__ = "Analecta Communications Inc. 2015"

"""
Configuration parser for SPFE.
"""

import os
# XSLT only works with posixpaths, so use posixpath for values passed to XSLT
import posixpath
import shutil
import subprocess
import itertools
from glob import glob
from collections import namedtuple

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
            self._run_XSLT2(script=self.spfe_env['spfe_ot_home'] + '/1.0/scripts/config/load-config.xsl',
                            infile=self.abs_config_file,
                            HOME=self.spfe_env['home'],
                            SPFEOT_HOME=self.spfe_env['spfe_ot_home'],
                            SPFE_BUILD_DIR=self.spfe_env['spfe_build_dir']
            )
        )

        self.build_scripts = {}

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

        self._prettyprint(self.config)


    def write_config_file(self):
        etree.register_namespace('config', "http://spfeopentoolkit.org/ns/spfe-ot/config")

        # Write the spfe environment variables to the config file.
        os.makedirs(self.content_set_config_dir, exist_ok=True)
        etree.ElementTree(self.config).write(self.content_set_config_dir + '/pconfig.xml',
                                             xml_declaration=True,
                                             encoding="utf-8")

    def _prettyprint(self, elem, level=0):
        """
        Prettyprint an XML element tree.
        :param elem: The root elements to be prettyprinted.
        :param level: The current recursion level.
        :return: Nothing.
        """
        i = "\n" + level * "  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "  "
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
            for elem in elem:
                self._prettyprint(elem, level + 1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i

    def write_script_files(self):
        """
        Write out the script files for each step of the build process.
        :return: Nothing
        """
        Script = namedtuple('Script', 'href step step_type rw_from rw_to')
        SetScripts = namedtuple('SetScripts', 'id set_type scripts')
        topic_sets = []
        for topic_or_object_set in itertools.chain(self.config.iterfind(
                '{0}content-set/{0}topic-set'.format('{http://spfeopentoolkit.org/ns/spfe-ot/config}')),
                                                   self.config.iterfind(
                '{0}content-set/{0}object-set'.format('{http://spfeopentoolkit.org/ns/spfe-ot/config}'))):
            try:
                set_id = topic_or_object_set.find('./{0}topic-set-id'.format('{http://spfeopentoolkit.org/ns/spfe-ot/config}')).text
                set_type = 'topic-set'
            except AttributeError:
                set_id = topic_or_object_set.find('./{0}object-set-id'.format('{http://spfeopentoolkit.org/ns/spfe-ot/config}')).text
                set_type = 'object-set'
            scripts_set = set()
            for scripts in topic_or_object_set.iterfind('.//{0}scripts'.format('{http://spfeopentoolkit.org/ns/spfe-ot/config}')):
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
                            rw_from = script.find(
                                '{http://spfeopentoolkit.org/ns/spfe-ot/config}rewrite-namespace/{http://spfeopentoolkit.org/ns/spfe-ot/config}from').text
                        except AttributeError:
                            rw_from = None
                        try:
                            rw_to = script.find(
                                '{http://spfeopentoolkit.org/ns/spfe-ot/config}rewrite-namespace/{http://spfeopentoolkit.org/ns/spfe-ot/config}to').text
                        except AttributeError:
                            rw_to = None
                        scripts_set.add(Script(href, step_name, step_type, rw_from, rw_to))
            topic_sets.append(SetScripts(set_id, set_type, list(scripts_set)))

        # For each topic set
        # For each step
        # Create a base script for step
        # 		For each script
        # 			If namespace rewrite specified
        # 				If namespace found in script
        # 					Rewrite namespaces
        # 					Generate temp file name
        # 					Write temp file
        # 					Add generated file name include to base script
        # 					Continue
        # 			Add original file url to base script


        for ts in topic_sets:
            print("Configuring build for " + ts.id)
            self.build_scripts.update({ts.id:{}})
            #pull out a list of steps using set comprehension
            for step in {(s.step, s.step_type) for s in ts.scripts}:
                script_dir = '/'.join([self.content_set_build_dir,
                                       ts.set_type+'s',
                                       ts.id,
                                       step[0]])
                if step[1]:
                    script_dir += '-' + step[1]
                #for all the scripts for this step
                scripts_to_include = []
                for script in {t for t in ts.scripts if (t.step, t.step_type) == step}:
                    if script.rw_to:
                        scripts_to_include.append(self._rewrite_namespaces(script, script_dir))
                    else:
                        scripts_to_include.append(script.href)

                # Write out the containing script
                step_name_with_type = "{step}{type}".format(
                    step=script.step, type=('-' + script.step_type) if script.step_type else '')
                script_file = "spfe.{step_name_with_type}.xsl".format(
                    step_name_with_type=step_name_with_type)
                new_fn = "/".join([script_dir, script_file])

                os.makedirs(script_dir, exist_ok=True)
                with open(new_fn, 'w', encoding="utf8") as of:
                    print('<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">', file=of)
                    for line in {s for s in scripts_to_include}:
                        print('<xsl:include href="file:///{0}"/>'.format(line), file=of)
                    print('</xsl:stylesheet>', file=of)
                self.build_scripts[ts.id].update({(script.step, script.step_type): new_fn})

    def build_topic_sets(self):
        topic_set_id_list = []
        for topic_set in self.config.iterfind(
                '{ns}content-set/{ns}topic-set'.format(ns="{http://spfeopentoolkit.org/ns/spfe-ot/config}")):
            topic_set_id_list.append(topic_set.find('./{http://spfeopentoolkit.org/ns/spfe-ot/config}topic-set-id').text)
        object_set_id_list = []
        for object_set in self.config.iterfind(
                '{ns}content-set/{ns}object-set'.format(ns="{http://spfeopentoolkit.org/ns/spfe-ot/config}")):
            object_set_id_list.append(object_set.find('./{http://spfeopentoolkit.org/ns/spfe-ot/config}object-set-id').text)
        for topic_set_id in topic_set_id_list:
            self._build_synthesis_stage(topic_set_id=topic_set_id)
        for object_set_id in object_set_id_list:
            self._build_synthesis_stage(object_set_id=object_set_id)
        for topic_set_id in topic_set_id_list:
            self._build_presentation_stage(topic_set_id)
        for topic_set_id in topic_set_id_list:
            self._build_formatting_stage(topic_set_id)
        for topic_set_id in topic_set_id_list:
            self._build_encoding_stage(topic_set_id)


    def _build_synthesis_stage(self, *, topic_set_id=None, object_set_id=None):
        assert topic_set_id is None or object_set_id is None
        set_id = topic_set_id if topic_set_id is not None else object_set_id
        set_type = 'topic-set' if topic_set_id is not None else "object-set"
        print("Starting synthesis stage for " + set_id)
        ts_config = self.config.find('{ns}content-set/{ns}topic-set[{ns}topic-set-id="{tsid}"]'.format(
            ns="{http://spfeopentoolkit.org/ns/spfe-ot/config}", tsid=topic_set_id)
        ) if topic_set_id is not None else self.config.find(
            '{ns}content-set/{ns}object-set[{ns}object-set-id="{osid}"]'.format(
            ns="{http://spfeopentoolkit.org/ns/spfe-ot/config}", osid=object_set_id)
        )

        executed_steps=[]
        if ts_config.find("{0}sources/{0}sources-to-extract-content-from/{0}include".format(
                        '{http://spfeopentoolkit.org/ns/spfe-ot/config}')) is not None:
            executed_steps.append('extract')
            source_files = []
            for x in ts_config.findall(
                "{0}sources/{0}sources-to-extract-content-from/{0}include".format(
                '{http://spfeopentoolkit.org/ns/spfe-ot/config}')):
                source_files += (glob(x.text))
            extract_output_dir = posixpath.join(posixpath.dirname(self.build_scripts[set_id][('extract', None)]),'out')
            self._build_extract_step(set_id=set_id,
                                     set_type=set_type,
                                     script=self.build_scripts[set_id][('extract', None)],
                                     output_dir=extract_output_dir,
                                     source_files=source_files)

            if ts_config.find("{0}sources/{0}authored-content/{0}include".format(
                        '{http://spfeopentoolkit.org/ns/spfe-ot/config}')) is not None:
                executed_steps.append('merge')
                extracted_files = glob(extract_output_dir+'/*')
                source_files = []
                for y in ts_config.findall(
                "{0}sources/{0}authored-content/{0}include".format(
                '{http://spfeopentoolkit.org/ns/spfe-ot/config}')):
                    source_files += (glob(y.text))
                merge_output_dir = posixpath.join(posixpath.dirname(self.build_scripts[set_id][('merge', None)]),'out')
                self._build_merge_step(set_id=set_id,
                                       set_type=set_type,
                                       script=self.build_scripts[set_id][('merge', None)],
                                       output_dir=merge_output_dir,
                                       authored_files=source_files,
                                       extracted_files=extracted_files)

        # Call the resolve step
        topic_files =[]
        if 'merge' in executed_steps:
            topic_files = glob(merge_output_dir+'/*')
        elif 'extract' in executed_steps:
            topic_files = glob(extract_output_dir+'/*')
        else:
            for y in ts_config.findall(
                "{0}sources/{0}authored-content/{0}include".format(
                '{http://spfeopentoolkit.org/ns/spfe-ot/config}')):
                    topic_files += [posixpath.normpath(x) for x in glob(y.text)]

        resolve_output_dir = posixpath.join(posixpath.dirname(self.build_scripts[set_id][('resolve', None)]),'out') if topic_set_id is not None else posixpath.join(self.content_set_build_dir, 'objects', set_id)
        self._build_resolve_step(set_id=set_id,
                                 set_type=set_type,
                                 script=self.build_scripts[set_id][('resolve', None)],
                                 output_dir=resolve_output_dir,
                                 topic_files=topic_files)

        # Call the toc step
        try:
            toc_output_dir = posixpath.join(posixpath.dirname(self.build_scripts[set_id][('toc', None)]),'out')
            synthesis_files = glob(resolve_output_dir+'/*')
            self._build_toc_step(set_id=set_id,
                                 set_type=set_type,
                                 script=self.build_scripts[set_id][('toc', None)],
                                 output_dir=toc_output_dir,
                                 synthesis_files=synthesis_files)
        except KeyError:
            # There is no toc set script, so skip it
            pass


        # Call the link-catalog step
        try:
            link_catalog_output_dir = posixpath.join(self.content_set_build_dir, 'link-catalogs')
            synthesis_files = glob(resolve_output_dir+'/*')
            self._build_toc_step(set_id=set_id,
                                 set_type=set_type,
                                 script=self.build_scripts[set_id][('link-catalog', None)],
                                 output_dir=link_catalog_output_dir,
                                 synthesis_files=synthesis_files)
        except KeyError:
            pass

    def _build_extract_step(self, set_id, set_type, script, output_dir, source_files):
        print("Building extract step for " + set_id)
        infile = posixpath.join(self.content_set_config_dir, 'pconfig.xml')
        outfile = posixpath.join(self.content_set_build_dir, set_type+'s', set_id, 'extracted.flag')
        parameters = {'set-id': set_id,
                      'output-directory': output_dir,
                      'sources-to-extract-content-from': ';'.join(source_files)}
        self._run_XSLT2(script=script, infile=infile, outfile=outfile, initial_template='main', **parameters)

    def _build_merge_step(self, set_id, set_type, script, output_dir, authored_files, extracted_files):
        infile = posixpath.join(self.content_set_config_dir, 'pconfig.xml')
        outfile = posixpath.join(self.content_set_build_dir, set_type+'s', set_id, 'merge.flag')
        parameters = {'set-id': set_id,
                      'output-directory': output_dir,
                      'authored-content-files': ';'.join(authored_files),
                      'extracted-content-files': ';'.join(extracted_files)}
        self._run_XSLT2(script=script, infile=infile, outfile=outfile, initial_template='main', **parameters)

    def _build_resolve_step(self, set_id, set_type, script, output_dir, topic_files):
        infile = posixpath.join(self.content_set_config_dir, 'pconfig.xml')
        outfile = posixpath.join(self.content_set_build_dir, set_type+'s', set_id, 'resolve.flag')
        parameters = {'set-id': set_id,
                      'output-directory': output_dir,
                      'authored-content-files': ';'.join(topic_files)}
        self._run_XSLT2(script=script, infile=infile, outfile=outfile, initial_template='main', **parameters)

    def _build_toc_step(self, set_id, set_type, script, output_dir, synthesis_files):
        infile = posixpath.join(self.content_set_config_dir, 'pconfig.xml')
        outfile = posixpath.join(self.content_set_build_dir, set_type+'s', set_id, 'toc.flag')
        parameters = {'set-id': set_id,
                      'output_directory': output_dir,
                      'synthesis-files': ';'.join(synthesis_files)}
        self._run_XSLT2(script=script, infile=infile, outfile=outfile, initial_template='main', **parameters)

    def _build_link_catalog_step(self, set_id, set_type, script, output_dir, synthesis_files):
        infile = posixpath.join(self.content_set_config_dir, 'pconfig.xml')
        outfile = posixpath.join(self.content_set_build_dir, set_type+'s', set_id, 'link-catalog.flag')
        parameters = {'set-id': set_id,
                      'output-directory': output_dir,
                      'synthesis-files': ';'.join(synthesis_files)}
        self._run_XSLT2(script=script, infile=infile, outfile=outfile, initial_template='main', **parameters)


    def _build_presentation_stage(self, topic_set_id):
        print("Starting presentation stage for " + topic_set_id)
        for presentation_type in [item[1] for item in self.build_scripts[topic_set_id] if item[0] == 'present']:
            present_output_dir = posixpath.join(posixpath.dirname(self.build_scripts[topic_set_id][('present', presentation_type)]),'out')
            self._build_present_step(topic_set_id=topic_set_id,
                                     script=self.build_scripts[topic_set_id][('present', presentation_type)],
                                     output_dir=present_output_dir,
                                     synthesis_files= [x.replace('\\', '/') for x in glob(posixpath.join(posixpath.dirname(self.build_scripts[topic_set_id][('resolve', None)]),'out')+'/*')],
                                     toc_files=glob(posixpath.join(self.content_set_build_dir, 'tocs')+'/*'),
                                     link_catalog_files=glob(posixpath.join(self.content_set_build_dir, 'link-catalogs')+'/*'),
                                     object_files=[x.replace('\\', '/') for x in glob(posixpath.join(self.content_set_build_dir, 'objects')+'/*/*')])

    def _build_present_step(self,
                            topic_set_id,
                            script,
                            output_dir,
                            synthesis_files,
                            toc_files,
                            link_catalog_files,
                            object_files):
        print('object_files', object_files)
        infile = posixpath.join(self.content_set_config_dir, 'pconfig.xml')
        outfile = posixpath.join(self.content_set_build_dir, 'topic-sets', topic_set_id, 'link-catalog.flag')
        parameters = {'topic-set-id': topic_set_id,
                      'output-directory': output_dir,
                      'synthesis-files': ';'.join(synthesis_files),
                      'toc-files': ';'.join(toc_files),
                      'link-catalog-files': ';'.join(link_catalog_files),
                      'object-files': ';'.join(object_files)}
        self._run_XSLT2(script=script, infile=infile, outfile=outfile, initial_template='main', **parameters)

    def _build_formatting_stage(self, topic_set_id):
        print("Starting formatting stage for " + topic_set_id)
        for format_type in [item[1] for item in self.build_scripts[topic_set_id] if item[0] == 'format']:
            # FIXME: This should be calculated based on whether there is encoding to be done
            home_topic_set = self.config.find('{ns}content-set/{ns}home-topic-set'.format(
                ns="{http://spfeopentoolkit.org/ns/spfe-ot/config}")).text
            if home_topic_set == topic_set_id:
                format_output_dir = self.content_set_output_dir
            else:
                format_output_dir = posixpath.join(self.content_set_output_dir, topic_set_id)
            presentation_type = self.config.find('{ns}content-set/{ns}output-formats/{ns}output-format[{ns}name="{ft}"]/{ns}presentation-type'.format(
                ns="{http://spfeopentoolkit.org/ns/spfe-ot/config}", ft=format_type)).text

            print(presentation_type, self.build_scripts)
            try:
                presentation_files = [x.replace('\\', '/') for x in glob(posixpath.join(posixpath.dirname(self.build_scripts[topic_set_id][('present', presentation_type)]),'out')+'/*')]
            except KeyError:
                exit("Could not find presentation files of type " + presentation_type + " for format type " + format_type + ".")
            self._build_format_step(topic_set_id=topic_set_id,
                                    format_type=format_type,
                                    script=self.build_scripts[topic_set_id][('format', format_type)],
                                    output_dir=format_output_dir,
                                    presentation_files=presentation_files)

    def _build_format_step(self,
                           topic_set_id,
                           format_type,
                           script,
                           output_dir,
                           presentation_files):
        infile = posixpath.join(self.content_set_config_dir, 'pconfig.xml')
        outfile = posixpath.join(self.content_set_build_dir, 'topic-sets', topic_set_id, 'format.flag')
        parameters = {'topic-set-id': topic_set_id,
                      'output-directory': output_dir,
                      'presentation-files': ';'.join(presentation_files)}
        self._run_XSLT2(script=script, infile=infile, outfile=outfile, initial_template='main', **parameters)

        # Copy images to output
        image_output_dir = os.path.join(output_dir, 'images')
        os.makedirs(image_output_dir, exist_ok=True)
        image_list = os.path.join(self.content_set_build_dir, 'topic-sets', topic_set_id, "image-list.txt")
        with open(image_list) as il:
            for image_file in il:
                shutil.copy(image_file.strip(), image_output_dir)

        # Copy support files
        style_output_dir = os.path.join(output_dir, 'style')
        os.makedirs(style_output_dir, exist_ok=True)
        for sf in self.config.iterfind(
                "{0}content-set/{0}output-formats/{0}output-format[{0}name='{1}']/{0}support-files/{0}include".format(
                        '{http://spfeopentoolkit.org/ns/spfe-ot/config}', format_type)):
            if os.path.isdir(sf.text):
                shutil.copytree(sf.text, style_output_dir)
            else:
                for file in glob(sf.text):
                    shutil.copy(file, style_output_dir)

    def _build_encoding_stage(self, topic_set_id):
        print("Starting encoding stage for " + topic_set_id)

    def _build_encode_step(self):
        pass


    def _rewrite_namespaces(self, script, script_dir):
        """
        Rewrite the namespaces in a script, write out the temporary script
        to a file, and return the path to that file.
        :param script: A named tuple of type Script
        :return: The file path of the created file
        """
        doctored_file_name = re.sub(r'\W', '_', script.rw_to) + '_' + os.path.basename(script.href)
        regex = re.compile(
            "(xmlns.*?=['\"]|xpath-default-namespace=['\"]|\\{)" + re.escape(script.rw_from) + "(['\"\\}])")

        with open(script.href, encoding="utf8") as f:
            scr = f.read()
            Result = namedtuple("Result", "text count")
            result = Result(*regex.subn(r'\1' + script.rw_to + r'\2', scr))
            if result.count == 0:  # no substitutions made
                return script.href
            else:
                new_fn = "/".join([script_dir, doctored_file_name])
                os.makedirs(script_dir, exist_ok=True)
                with open(new_fn, 'w', encoding="utf8") as of:
                    of.write(result.text)
                return new_fn

    def _run_XSLT2(self, script, infile=None, outfile=None, initial_template=None, **kwargs):
        """
        Encapsulate an XSLT call so we can change how they are run.
        :param script: The file name of the XSLT script to be run.
        :param infile: The file name of the input to process.
        :param outfile: The file name of the output to create.
        :param initial_template: The name of the initial XSLT template to run.
        :param kwargs: Any parameters to pass to the XSLT script.
        :return: The output of the XSLT processes, unless output is specified.
        """
        try:
            process_call = ['java',
                            '-classpath',
                            self.spfe_env["spfe_ot_home"] + '/tools/saxon9he/saxon9he.jar' + os.pathsep +
                            self.spfe_env["spfe_ot_home"] + '/tools/xml-commons-resolver-1.2/resolver.jar',
                            'net.sf.saxon.Transform',
                            '-xsl:{0}'.format(script),
                            '-catalog:{0}'.format('file:/'+self.spfe_env["spfe_ot_home"]+'/../catalog.xml'+os.pathsep+self.spfe_env["home"]+'/.spfe/catalog.xml')
            ]
            if infile:
                process_call.append('-s:{0}'.format(infile))
            if outfile:
                process_call.append('-o:{0}'.format(outfile))
            if initial_template:
                process_call.append('-it:{0}'.format(initial_template))
            for key, value in kwargs.items():
                process_call.append("{0}={1}".format(key, value))
            if outfile:
                subprocess.check_call(process_call)
                return None
            else:
                return subprocess.check_output(process_call)
        except subprocess.CalledProcessError as err:
            if err.returncode == 1:
                exit("Build failed due to error reported by XSLT script.")
            raise

if __name__ == '__main__':
    pass