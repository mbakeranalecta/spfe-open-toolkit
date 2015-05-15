__author__ = 'Mark Baker'
__copyright__ = 'Analecta Communications Inc. 2015'

from lxml import etree

catns = {'c': 'http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/catalog'}


class CompiledCatalog:
    def __init__(self, *catalog_file):
        self.catalogs = {}
        self.pages = {}
        self.targets = {}
        for cf in catalog_file:
            c = etree.parse(cf)
            cat = c.xpath('//c:catalog', namespaces=catns)
            cat_name =cat[0].attrib['topic-set-id']
            self.catalogs.update({cat_name: cat[0].attrib})
            this_catalog = self.catalogs[cat_name]
            for p in c.xpath('//c:page', namespaces=catns):
                page_name = p.attrib['full-name']
                self.pages.update({page_name: p.attrib})
                self.pages[page_name].update({'catalog':'foo'})
                this_page = self.pages[page_name]
                for t in p.xpath('c:target', namespaces=catns):
                    qualified_key = (t.xpath('string(c:type)', namespaces=catns),
                                     t.xpath('string(c:key)', namespaces=catns),
                                     t.xpath('string(c:namespace)', namespaces=catns)
                    )
                    if qualified_key in self.targets:
                        self.targets[qualified_key].append(this_page)
                    else:
                        self.targets.update({qualified_key: [this_page]})

    def page(self, full_name):
        return self.pages[full_name]

    def target(self, key_type, key, namespace=''):
        return self.targets[(key_type, key, namespace)]

    def pages_for_target(self, key_type, key, namespace=''):
        return self.targets[(key_type, key, namespace)]

    def __str__(self):
        return self.targets.__str__()


if __name__ == '__main__':
    test_file = 'testdata/spfe-development.catalog.xml'
    try:
        print("Test - Create CompiledCatalog object:", end=' ')
        try:
            catalog = CompiledCatalog(test_file)
            assert isinstance(catalog, CompiledCatalog), "compile_catalog returned None."
            print("PASS")
        except NameError as e:
            print("FAIL", e)
        except AssertionError as e:
            print("FAIL", e)

        print("Test - CompiledCatalog has page:", end=' ')
        try:
            assert catalog.page(
                '{http://spfeopentoolkit.org/ns/spfe-docs}think-plan-do-topic#adding-a-content-set') is not None, "Page not found"
            print("PASS")
        except AssertionError as e:
            print("FAIL", e)

        print("Test - CompiledCatalog has key:", end=' ')
        try:
            assert catalog.target('feature', 'content set') is not None, "Key not found"
            print("PASS")
        except AssertionError as e:
            print("FAIL", e)

        print("Test - Key lookup fails for invalid key:", end=' ')
        try:
            assert catalog.target('feature', 'gruznatz') is None, "Record returned for invalid key"
        except KeyError:
            print("PASS")
        except AssertionError as e:
            print("FAIL", e)

        print("Test - CompiledCatalog key lookup:", end=' ')
        try:
            assert (catalog.target('feature', 'content set')[0]['full-name']) == \
                   '{http://spfeopentoolkit.org/ns/spfe-docs}think-plan-do-topic#adding-a-content-set', "Key lookup failed"
            print("PASS")
        except AssertionError as e:
            print("FAIL", e)


    except Exception as e:
        print('FAIL', e)
        raise

