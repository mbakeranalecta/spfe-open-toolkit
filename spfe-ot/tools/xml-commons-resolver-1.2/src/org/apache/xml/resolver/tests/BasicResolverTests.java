/*
* Licensed to the Apache Software Foundation (ASF) under one or more
* contributor license agreements.  See the NOTICE file distributed with
* this work for additional information regarding copyright ownership.
* The ASF licenses this file to You under the Apache License, Version 2.0
* (the "License"); you may not use this file except in compliance with
* the License.  You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package org.apache.xml.resolver.tests;

import junit.framework.TestCase;

import java.net.URL;

import org.apache.xml.resolver.Catalog;
import org.apache.xml.resolver.CatalogManager;
import org.apache.xml.resolver.tools.CatalogResolver;

public class BasicResolverTests extends TestCase {
  protected Catalog catalog;

  public static void main(String args[]) {
    junit.textui.TestRunner.run(BasicResolverTests.class);
  }

  protected void setUp() throws Exception {
    super.setUp();

    CatalogManager manager = new CatalogManager();

    // Just do this to make sure that the debug level gets set.
    // I could set the value explicitly, but I know that the
    // ant build file is going to set the system property, so just
    // make sure that that gets used.
    int verbosity = manager.getVerbosity();

    catalog = new Catalog(manager);
    catalog.setupReaders();
    catalog.loadSystemCatalogs();
  }

  public void testResolveSystem() {
    String resolved = null;
    String local = "file:/local/system-resolver.dtd";

    try {
      resolved = catalog.resolveSystem("http://example.org/resolver.dtd");
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

  public void testResolvePublic() {
    String resolved = null;
    String local = "file:/local/public-resolver.dtd";

    try {
      resolved = catalog.resolvePublic("-//Apache//DTD Resolver Test//EN",
				       "some-broken-system-identifier");
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

  public void testRewriteSystem() {
    String resolved = null;
    String local = "file:/longest/path";

    try {
      resolved = catalog.resolveSystem("http://rewrite.example.org/longest/path");
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

  public void testResolveURI() {
    String resolved = null;
    String local = "file:/local/uri";

    try {
      resolved = catalog.resolveURI("http://example.org/someURI");
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

  public void testGroup() {
    String resolved = null;
    String local = "file:/local/other/uri";

    try {
      resolved = catalog.resolveURI("http://example.org/someOtherURI");
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

  public void testDelegateSystem() {
    String resolved = null;
    String local = "file:/local/delegated/system-resolver.dtd";

    try {
      resolved = catalog.resolveSystem("http://delegate.example.org/resolver.dtd");
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

  public void testDocument() {
    String resolved = null;
    String local = "file:/default-document";

    try {
      resolved = catalog.resolveDocument();
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

  public void testSystemSuffix() {
    String resolved = null;
    String local = "file:/usr/local/xml/docbook/4.4/docbookx.dtd";

    try {
      resolved = catalog.resolveSystem("http://any/random/path/to/docbookx.dtd");
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

  public void testUriSuffix() {
    String resolved = null;
    String local = "file:/usr/local/xsl/docbook/html/docbook.xsl";

    try {
      resolved = catalog.resolveURI("http://any/path/to/html/docbook.xsl");
    } catch (Exception e) {
      e.printStackTrace();
    }

    assertTrue(local.equals(resolved));
  }

}
