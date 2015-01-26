__author__ = 'Mark Baker'
__copyright__ = "Analecta Communications Inc. 2015"
"""
Configuration parser for SPFE.
"""

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
        self.spfe_dirs = spfe_dirs
        self.content_set_config = etree.parse(config_file)
        print(etree.tostring(self.content_set_config))
        self.config_ns = {'c': 'http://spfeopentoolkit/ns/spfe-ot/config'}
        self.content_set_id = self.content_set_config.find('./c:content-set-id', namespaces=self.config_ns).text
        print(self.content_set_id)
        self.content_set_build_root_directory = self.spfe_dirs['spfe_build_dir'] + '/' + self.content_set_id
        self.content_set_build = self.content_set_build_root_directory + '/build'
        self.content_set_config = self.content_set_build_root_directory + '/config'
        self.content_set_output = self.content_set_build_root_directory + '/output'
        self.content_set_home = self.spfe_dirs['spfe_build_dir'] + '/' + self.content_set_id + '/output'

    def _resolve_defines(self, string):
        defines = {'HOME': self.spfe_dirs['home'],
                   'SPFEOT_HOME': self.spfe_dirs['spfe_ot_home'],
                   'CONTENT_SET_BUILD_DIR': self.content_set_build,
                   'CONTENT_SET_OUTPUT_DIR': self.content_set_output,
                   'CONTENT_SET_BUILD_ROOT_DIR': self.content_set_build_root_directory
        }
        defines_pattern = re.compile('\$\{{([^}}]*)\}}')

"""
    < xsl:variable
    name = "result" >
    < xsl:analyze - string
    select = "$value"
    regex = "\$\{{([^}}]*)\}}" >
    < xsl:matching - substring >
    < xsl:value - of
    select = "$defines[@name=regex-group(1)]/@value" / >

< / xsl:matching - substring >
< xsl:non - matching - substring >
< xsl:value - of
select = "." / >
< / xsl:non - matching - substring >
< / xsl:analyze - string >
< / xsl:variable >
< xsl:value - of
select = "string-join($result,'')" / >
< / xsl:function >
"""