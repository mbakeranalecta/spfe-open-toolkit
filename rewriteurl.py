__author__ = 'Mark'
__copyright__ = "Analecta Communications Inc. 2015"

"""
Rewrite URL
===========

Allows you to create an object that rewrites URLs by consulting
a variety of sources including XML Catalogs and SPFE Configuration
settings.

Note that it is not a full XML Catalog resolver, just a URL rewriter.
It only supports XML Catalogs, not OASIS Catalogs, and it only
looks at nextCatalog and rewriteURI elements. Everything else in
the catalog is ignored.

Rewriting is done solely based on string matching. Path and URL
strings are not normalized. However, composed paths are passed
through os.path.abspath().

To rewrite URLs, create an object of class URLRewriter and initialize
it with the list of resources to use for rewriting URLs. Then
call the rewrite function on the URL to be rewritten.

By default, the URLRewriter will raise an exception if it can't find
a local path for a URL. However, you can pass it a list of
allowed domains for which it will return an external URL.

"""

import os
import subprocess
from collections import namedtuple
from urllib.parse import urljoin
import urllib.request as urllib
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

Rewrite = namedtuple("Rewrite", "start prefix base")
Catalog = namedtuple("Catalog", "file_name xml")

class URLRewriter:
    def __init__(self, catalogs):
        if isinstance(catalogs, list):
            self.catalogs = self._get_catalogs(catalogs)
        elif isinstance(catalogs, str):
            self.catalogs = self._get_catalogs([catalogs])
        else:
            raise TypeError("catalogs must be a list or a string")
        self.catalogs = self._get_catalogs(catalogs)
        self.rewrite_list = self._get_rewrite_list(self.catalogs)

    def _get_catalogs(self, catalogs, all_catalogs=set()):
        if isinstance(catalogs, list):
            cats = catalogs
        elif isinstance(catalogs, str):
            cats = [catalogs]
        else:
            raise TypeError("catalogs must be a list or a string")
        for cat in cats:
            catalog = Catalog(cat, etree.parse(cat))
            for next_catalog in catalog.xml.iterfind('.//{urn:oasis:names:tc:entity:xmlns:xml:catalog}nextCatalog'):
                next_cat_path = os.path.join(os.path.dirname(cat), os.path.normpath(next_catalog.attrib['catalog']))
                self._get_catalogs(next_cat_path, all_catalogs)
            all_catalogs.add(catalog)
        return all_catalogs

    def _get_rewrite_list(self, catalogs):
        rewrite_list = set()
        for cat in catalogs:
            for rewrite in cat.xml.iterfind('.//{urn:oasis:names:tc:entity:xmlns:xml:catalog}rewriteURI'):
                rewrite_list.add(Rewrite(rewrite.attrib['uriStartString'],
                                         rewrite.attrib['rewritePrefix'],
                                         cat.file_name))
        return rewrite_list

    def rewrite_url(self,url):
        for rewrite in self.rewrite_list:
            if url.startswith(rewrite.start):
                return os.path.abspath(os.path.join(rewrite.base, rewrite.prefix + url[len(rewrite.start):]))
        raise KeyError("uriStartString not found.")

if __name__ == '__main__':
    re=URLRewriter('C:/Users/Mark/spfe-open-toolkit/catalog.xml')
    print(re.catalogs)
    print(re.rewrite_list)
    print(re.rewrite_url('http://spfeopentoolkit.org/spfe-ot/1.0/schemas/config/spfe-config.xsd'))