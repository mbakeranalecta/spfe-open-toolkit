__author__ = 'Mark Baker'
__copyright__ = "Analecta Communications Inc. 2015"

"""
Configuration parser for SPFE.
"""

import os
import itertools
from collections import namedtuple
from . import util
import copy

try:
    import regex as re

    re_supports_unicode_categories = True
except ImportError:
    import re

    re_supports_unicode_categories = False

try:
    from lxml import etree
except ImportError:
    print("SPFE requires the lxml module. The easiest way to install it, "
          "particularly on Windows, may be to install a preconfigured "
          "package such as Anaconda which installs all the required libraries.")
    raise

class SPFEConfigSettingNotFound(Exception):
    """
    Raised if a setting path is not found in the config object.
    """
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class SPFEConfigNotASetting(Exception):
    """
    Raised if a setting path is not the leaf of a tree, and is therefore
    not a single setting but a group of settings.
    """
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)


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
             'catalog_directory': self.content_set_build_dir + '/catalogs',
             'toc_directory': self.content_set_build_dir + '/tocs'
            }
        )
        self.content_set_build_dir = self.content_set_build_root_dir + '/build'
        self.content_set_config_dir = self.content_set_build_root_dir + '/config'
        self.content_set_output_dir = self.content_set_build_root_dir + '/output'
        self.content_set_home = self.spfe_env['spfe_build_dir'] + '/' + self.content_set_id + '/output'
        self.content_set_config = etree.XML(
            util.run_XSLT2(script=self.spfe_env['spfe_ot_home'] + '/1.0/scripts/config/load-config.xsl',
                            env=self.spfe_env,
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
    <catalog-directory>{catalog_directory}</catalog-directory>
    <toc-directory>{toc_directory}</toc-directory>
</config>
""".format(**self.spfe_env))

        content_set = etree.SubElement(self.config, '{http://spfeopentoolkit.org/ns/spfe-ot/config}content-set')
        content_set.extend(self.content_set_config)

        # Calculate output directories for each topic set.
        for topic_set in self.config.iterfind(
                '{http://spfeopentoolkit.org/ns/spfe-ot/config}content-set/{http://spfeopentoolkit.org/ns/spfe-ot/config}topic-set'):
            topic_set_id = topic_set.find('{http://spfeopentoolkit.org/ns/spfe-ot/config}topic-set-id').text
            home_topic_set = self.setting('content-set/home-topic-set')
            output_directory = etree.Element('{http://spfeopentoolkit.org/ns/spfe-ot/config}output-directory')
            if topic_set_id != home_topic_set:
                output_directory.text = topic_set_id
            topic_set.insert(0, output_directory)

        self._prettyprint(self.config)

    def _add_namespace_to_xpath(self, xpath, ns="{http://spfeopentoolkit.org/ns/spfe-ot/config}"):
        result = []
        for x in re.split(r'([/\[]+)', xpath):
            try:
                result.append(ns+x if re.match('[_\w]', x[0]) else x)
            except IndexError:
                pass
        return ''.join(result)
    def setting(self, setting_path, settings_object=None):
        if settings_object is None:
            settings_object = self.config
        result = settings_object.find(self._add_namespace_to_xpath(setting_path))
        if result is None:
            raise SPFEConfigSettingNotFound(setting_path)
        elif len(result) != 0:
            # result has children, so it not a setting
            raise SPFEConfigNotASetting(setting_path)
        else:
            return result.text

    def setting_exists(self, setting_path, settings_object=None):
        """
        Test if a setting is defined.
        :param setting_path: The xpath of the setting.
        :param settings_object: The settings object to search. Defaults to the full config object.
        :return: True is the setting exists; else False.
        """
        try:
            _ = self.setting(setting_path, settings_object)
            return True
        except SPFEConfigSettingNotFound:
            return False
    def settings(self, setting_path, settings_object=None):
        if settings_object is None:
            settings_object = self.config
        result = settings_object.findall(self._add_namespace_to_xpath(setting_path))
        if not result:
            raise SPFEConfigSettingNotFound(setting_path)
        else:
            return [r.text for r in result]

    def config_subset(self,setting_path, settings_object=None):
        if settings_object is None:
            settings_object = self.config
        result = settings_object.find(self._add_namespace_to_xpath(setting_path))
        if result is None:
            raise SPFEConfigSettingNotFound(setting_path)
        else:
            return result

    def iter_config_subset(self,setting_path, settings_object=None):
        if settings_object is None:
            settings_object = self.config
        return settings_object.iterfind(self._add_namespace_to_xpath(setting_path))


    def write_config_file(self):
        etree.register_namespace('config', "http://spfeopentoolkit.org/ns/spfe-ot/config")

        # Write the spfe environment variables to the config file.
        os.makedirs(self.content_set_config_dir, exist_ok=True)
        config_file = copy.copy(self.config)
        for structures in config_file.findall('*//{http://spfeopentoolkit.org/ns/spfe-ot/config}structures'):
            structures.getparent().remove(structures)
        for scripts in config_file.findall('*//{http://spfeopentoolkit.org/ns/spfe-ot/config}scripts'):
            scripts.getparent().remove(scripts)
        etree.ElementTree(config_file).write(self.content_set_config_dir + '/spfe-config.xml',
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
        for topic_or_object_set in itertools.chain(
            self.iter_config_subset('content-set/topic-set'),
            self.iter_config_subset('content-set/object-set')
        ):
            try:
                set_id = self.setting('topic-set-id', topic_or_object_set)
                set_type = 'topic-set'
            except SPFEConfigSettingNotFound:
                set_id = self.setting('object-set-id', topic_or_object_set)
                set_type = 'object-set'
            scripts_set = set()
            for scripts in self.iter_config_subset('.//scripts', topic_or_object_set): #.iterfind('.//{0}scripts'.format('{http://spfeopentoolkit.org/ns/spfe-ot/config}')):
                for step in scripts:
                    script_type = step.tag
                    for script in step:
                        step_name = step.tag.split("}")[1][0:]
                        try:
                            step_type = step.attrib['type']
                        except KeyError:
                            step_type = None
                        href = self.setting('href', script)
                        try:
                            rw_from = self.setting('rewrite-namespace/from', script)
                        except SPFEConfigSettingNotFound:
                            rw_from = None
                        try:
                            rw_to = self.setting('rewrite-namespace/to', script)
                        except SPFEConfigSettingNotFound:
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


if __name__ == '__main__':
    pass