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
    def __init__(self, config_file, spfe_dirs):
        self.config_file = config_file
        self.abs_config_file = 'file:///' + os.path.abspath(config_file).replace('\\', '/')
        print(config_file, self.abs_config_file)
        self.spfe_dirs = spfe_dirs
        self.content_set_config = etree.parse(config_file)
        self.config_ns = {'c': 'http://spfeopentoolkit/ns/spfe-ot/config'}
        self.content_set_id = self.content_set_config.find('./c:content-set-id', namespaces=self.config_ns).text
        self.content_set_build_root_dir = self.spfe_dirs['spfe_build_dir'] + '/' + self.content_set_id
        self.content_set_build_dir = self.content_set_build_root_dir + '/build'
        self.content_set_config_dir = self.content_set_build_root_dir + '/config'
        self.content_set_output_dir = self.content_set_build_root_dir + '/output'
        self.content_set_home = self.spfe_dirs['spfe_build_dir'] + '/' + self.content_set_id + '/output'
        self.defines = {'HOME': self.spfe_dirs['home'],
                        'SPFEOT_HOME': self.spfe_dirs['spfe_ot_home'],
                        'CONTENT_SET_BUILD_DIR': self.content_set_build_dir,
                        'CONTENT_SET_OUTPUT_DIR': self.content_set_output_dir,
                        'CONTENT_SET_BUILD_ROOT_DIR': self.content_set_build_root_dir
        }
        self.full_config = self._resolve_config(self.content_set_config, self.abs_config_file)

    def _resolve_config(self, config, file_name):
        resolved_config = subprocess.check_output(['java',
                                                   '-classpath',
                                                   self.spfe_dirs.spfe_ot_home + '/tools/saxon9he/saxon9he.jar',
                                                   'net.sf.saxon.Transform',
                                                   '-it:main',
                                                   '-xsl:' + self.spfe_dirs.spfe_ot_home + '/1.0/scripts/config/config.xsl',
                                                   '-o:' + self.spfe_dirs.spfe_temp_build_file,
                                                   'configfile=' + self.abs_config_file,
                                                   'HOME=' + self.spfe_dirs.home,
                                                   'SPFEOT_HOME=' + self.spfe_dirs.spfe_ot_home,
                                                   'SPFE_BUILD_DIR=' + self.spfe_dirs.spfe_build_dir])

        # for href in resolved_config.iterfind('.//c:href', namespaces=self.config_ns):
        # url = urljoin(file_name, self._resolve_defines(href.text))
        #     print('URL: ' + url)
        #     href.extend(self._resolve_config(etree.parse(url), url))
        # if resolved_config is not None:
        #     print(etree.tostring(resolved_config))
        return resolved_config

    def _resolve_defines(self, string):
        defines_pattern = re.compile('\$\{([^}]*)\}')
        resolved = re.sub(defines_pattern, self._replace_defines, string)
        return resolved

    def _replace_defines(self, match):
        try:
            return self.defines[match.group(1)]
        except KeyError:
            Exception("Invalid define ${" + match.group(1) + "}")


if __name__ == '__main__':
    pass