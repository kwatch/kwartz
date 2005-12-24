/**
 *  @(#) CompilerTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import junit.framework.TestCase;
import java.util.*;
import java.io.*;

public class CompilerTest extends TestCase {
    String _plogic;
    String _pdata;
    String _expected;
    Map    _context = new HashMap();
    Properties _props = new Properties(Configuration.defaults);

    private void _test() throws Exception {
        _test(false);
    }

    private void _test(boolean flagPrint) throws Exception {
        Compiler compiler = new DefaultCompiler(_props);
        //compiler.addPresentationLogic(_plogic);
        //compiler.addPresentationData(_pdata);
        //BlockStatement stmt = compiler.getBlockStatement();
        Template template = compiler.compileString(_pdata, _plogic);
        Writer writer = new StringWriter();
        template.execute(_context, writer);
        String actual = writer.toString();
        writer.close();
        if (flagPrint)
            System.out.println(actual);
        else
            assertEquals(_expected, actual);
    }

    public void testCompile01() throws Exception {
        _pdata = ""
                 + "Hello <strong id=\"mark:user\">World</strong>!\n"
                 ;
        _plogic = ""
                  + "#user {\n"
                  + "  value: user;\n"
                  + "}\n"
                  ;
        _expected = ""
                    + "Hello <strong>Kwartz</strong>!\n"
                    ;
        _context.put("user", "Kwartz");
        _test();
    }

    public void testCompile02() throws Exception {
        _pdata = ""
                 + "<ul id=\"mark:list\">\n"
                 + "  <li>@{item}@</li>\n"
                 + "</ul>\n"
                 ;
        _plogic = ""
                  + "#list {\n"
                  + "    plogic: {\n"
                  + "        foreach (item in list) {\n"
                  + "            @stag;  // start tag\n"
                  + "            @cont;  // content\n"
                  + "            @etag;  // end tag\n"
                  + "        }\n"
                  + "    }\n"
                  + "}\n"
                  ;
        _expected = ""
                    + "<ul>\n"
                    + "  <li>foo</li>\n"
                    + "</ul>\n"
                    + "<ul>\n"
                    + "  <li>bar</li>\n"
                    + "</ul>\n"
                    + "<ul>\n"
                    + "  <li>baz</li>\n"
                    + "</ul>\n"
                    ;
        List list = java.util.Arrays.asList(new Object[] { "foo", "bar", "baz", });
        _context.put("list", list);
        _test();
    }


    public void testCompile03() throws Exception {
        _pdata = ""
                 + "<table id=\"table\">\n"
                 + "  <tr class=\"odd\" style=\"color:red\" id=\"mark:list\">\n"
                 + "    <td id=\"mark:name\" style=\"font-weight:bold\">foo</td>\n"
                 + "    <td><a href=\"...\" id=\"mark:mail\">foo@mail.org</a></td>\n"
                 + "  </tr>\n"
                 + "  <tr class=\"even\" id=\"mark:dummy\">\n"
                 + "    <td>bar</td>\n"
                 + "    <td>bar@mail.net</td>\n"
                 + "  </tr>\n"
                 + "</table>\n"
                 ;
        _plogic = ""
                  + "#table {\n"
                  + "    tagname:  \"html:table\";\n"
                  + "    append:   flag ? ' align=\"center\"' : '';\n"
                  + "}\n"
                  + "#list {\n"
                  + "    attrs:  \"class\" klass;\n"
                  + "    remove: \"style\", \"width\";\n"
                  + "    plogic: {\n"
                  + "        i = 0;\n"
                  + "        foreach (item in list) {\n"
                  + "            i += 1;\n"
                  + "            klass = i % 2 == 0 ? 'even' : 'odd';\n"
                  + "            @stag;\n"
                  + "            @cont;\n"
                  + "            @etag;\n"
                  + "        }\n"
                  + "    }\n"
                  + "}\n"
                  + "#name {\n"
                  + "  value: item.name;\n"
                  + "}\n"
                  + "#mail {\n"
                  + "  value:  item.email;\n"
                  + "  attrs:  \"href\" \"mailto:\" .+ item.email;\n"
                  + "}\n"
                  + "#dummy {\n"
                  + "  plogic: { }\n"
                  + "}\n"
                  ;
        _expected = ""
                    + "<html:table id=\"table\" align=\"center\">\n"
                    + "  <tr class=\"odd\">\n"
                    + "    <td style=\"font-weight:bold\">Foo</td>\n"
                    + "    <td><a href=\"mailto:foo@foo.org\">foo@foo.org</a></td>\n"
                    + "  </tr>\n"
                    + "  <tr class=\"even\">\n"
                    + "    <td style=\"font-weight:bold\">Bar</td>\n"
                    + "    <td><a href=\"mailto:bar@bar.org\">bar@bar.org</a></td>\n"
                    + "  </tr>\n"
                    + "  <tr class=\"odd\">\n"
                    + "    <td style=\"font-weight:bold\">Baz</td>\n"
                    + "    <td><a href=\"mailto:baz@baz.org\">baz@baz.org</a></td>\n"
                    + "  </tr>\n"
                    + "</html:table>\n"
                    ;
        List list = java.util.Arrays.asList(new Object[] {
            new CompilerTest.User("Foo", "foo@foo.org"),
            new CompilerTest.User("Bar", "bar@bar.org"),
            new CompilerTest.User("Baz", "baz@baz.org"),
        });
        _context.put("list", list);
        _context.put("flag", Boolean.TRUE);
        _test();
    }

    public static class User {
        private String name;
        private String email;
        public User(String name, String email) {
            this.name = name;
            this.email = email;
        }
        public String getName() { return name; }
        public String getEmail() { return email; }
    }


    public void testCompile05() throws Exception {  // escape
        _pdata = ""
                 + "<a href=\"#\" id=\"mark:name\">foo</a>\n"
                 + "<b id=\"value:str\">foo</b><b id=\"value:E(str)\">foo</b><b id=\"value:X(str)\">foo</b>\n"
                 + "<i id=\"value:str\">foo</i><i id=\"Value:str\">foo</i><i id=\"VALUE:str\">foo</i>\n"
                 ;
        _plogic = ""
                  + "#name {\n"
                  + "   value:  user;\n"
                  + "   attrs:  \"href\" email;\n"
                  + "}\n"
                  ;
        _props.setProperty("kwartz.escape", "true");
        _expected = ""
                    + "<a href=\"ab@mail.com?a=1&amp;b=2\">&lt;em&gt;A&amp;B&lt;/em&gt;</a>\n"
                    + "<b>&lt;em&gt;A&amp;B&lt;/em&gt;</b><b>&lt;em&gt;A&amp;B&lt;/em&gt;</b><b><em>A&B</em></b>\n"
                    + "<i>&lt;em&gt;A&amp;B&lt;/em&gt;</i><i>&lt;em&gt;A&amp;B&lt;/em&gt;</i><i><em>A&B</em></i>\n"
                    ;
        _context.put("user",   "<em>A&B</em>");
        _context.put("email",  "ab@mail.com?a=1&b=2");
        _context.put("str",    "<em>A&B</em>");
        _test();
    }


/*
    public void testCompileXX() throws Exception {
        _plogic = ""
                  ;
        _pdata = ""
                 ;
        _expected = ""
                    ;
        List list = java.util.Arrays.asList(new Object[] { "foo", "bar", "baz", });
        _context.put("list", list);
        _test();
    }
*/

}
