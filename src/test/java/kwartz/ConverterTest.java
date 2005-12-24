/**
 *  @(#) ConverterTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import junit.framework.TestCase;
import java.util.*;

public class ConverterTest extends TestCase {

    public void _testFetchAll(String input, String expected) {
        DefaultConverter converter = new DefaultConverter();
        List list = converter.fetchAll(input);
        StringBuffer actual = new StringBuffer();
        for (Iterator it = list.iterator(); it.hasNext(); ) {
            Tag tag = (Tag)it.next();
            actual.append(tag._inspect().toString());
            actual.append("\n");
        }
        assertEquals(expected, actual.toString());
    }

    public void testFetchAll1() {
        String input = ""
                       + "<html lang=\"ja\">\n"
                       + "  <body>\n"
                       + "    <h1 style=\"color: #fffff\">title</h1>\n"
                       + "  </body>\n"
                       + "</html>\n"
                       ;
        String expected = ""
                          + "tag_str      = \"<html lang=\\\"ja\\\">\\n\"\n"
                          + "before_text  = \"\"\n"
                          + "before_space = \"\"\n"
                          + "tagname      = \"html\"\n"
                          + "attr_str     = \" lang=\\\"ja\\\"\"\n"
                          + "extra_space  = \"\"\n"
                          + "after_space  = \"\\n\"\n"
                          + "is_etag      = false\n"
                          + "is_empty     = false\n"
                          + "is_begline   = true\n"
                          + "is_endline   = true\n"
                          + "start_pos    = 0\n"
                          + "end_pos      = 17\n"
                          + "linenum      = 1\n"
                          + "\n"
                          + "tag_str      = \"  <body>\\n\"\n"
                          + "before_text  = \"\"\n"
                          + "before_space = \"  \"\n"
                          + "tagname      = \"body\"\n"
                          + "attr_str     = \"\"\n"
                          + "extra_space  = \"\"\n"
                          + "after_space  = \"\\n\"\n"
                          + "is_etag      = false\n"
                          + "is_empty     = false\n"
                          + "is_begline   = true\n"
                          + "is_endline   = true\n"
                          + "start_pos    = 17\n"
                          + "end_pos      = 26\n"
                          + "linenum      = 2\n"
                          + "\n"
                          + "tag_str      = \"    <h1 style=\\\"color: #fffff\\\">\"\n"
                          + "before_text  = \"\"\n"
                          + "before_space = \"    \"\n"
                          + "tagname      = \"h1\"\n"
                          + "attr_str     = \" style=\\\"color: #fffff\\\"\"\n"
                          + "extra_space  = \"\"\n"
                          + "after_space  = \"\"\n"
                          + "is_etag      = false\n"
                          + "is_empty     = false\n"
                          + "is_begline   = true\n"
                          + "is_endline   = false\n"
                          + "start_pos    = 26\n"
                          + "end_pos      = 56\n"
                          + "linenum      = 3\n"
                          + "\n"
                          + "tag_str      = \"</h1>\\n\"\n"
                          + "before_text  = \"title\"\n"
                          + "before_space = \"\"\n"
                          + "tagname      = \"h1\"\n"
                          + "attr_str     = \"\"\n"
                          + "extra_space  = \"\"\n"
                          + "after_space  = \"\\n\"\n"
                          + "is_etag      = true\n"
                          + "is_empty     = false\n"
                          + "is_begline   = false\n"
                          + "is_endline   = true\n"
                          + "start_pos    = 61\n"
                          + "end_pos      = 67\n"
                          + "linenum      = 3\n"
                          + "\n"
                          + "tag_str      = \"  </body>\\n\"\n"
                          + "before_text  = \"\"\n"
                          + "before_space = \"  \"\n"
                          + "tagname      = \"body\"\n"
                          + "attr_str     = \"\"\n"
                          + "extra_space  = \"\"\n"
                          + "after_space  = \"\\n\"\n"
                          + "is_etag      = true\n"
                          + "is_empty     = false\n"
                          + "is_begline   = true\n"
                          + "is_endline   = true\n"
                          + "start_pos    = 67\n"
                          + "end_pos      = 77\n"
                          + "linenum      = 4\n"
                          + "\n"
                          + "tag_str      = \"</html>\\n\"\n"
                          + "before_text  = \"\"\n"
                          + "before_space = \"\"\n"
                          + "tagname      = \"html\"\n"
                          + "attr_str     = \"\"\n"
                          + "extra_space  = \"\"\n"
                          + "after_space  = \"\\n\"\n"
                          + "is_etag      = true\n"
                          + "is_empty     = false\n"
                          + "is_begline   = true\n"
                          + "is_endline   = true\n"
                          + "start_pos    = 77\n"
                          + "end_pos      = 85\n"
                          + "linenum      = 5\n"
                          + "\n"
                          ;
        _testFetchAll(input, expected);
    }



    // --------------------

    Class     _klass;
    String    _method;
    Class[]   _argtypes;
    Object    _receiver;
    Object[]  _args;
    Object    _result;
    String    _input;
    String    _expected;
    String    _actual;

    public void _test() throws Exception {
        java.lang.reflect.Method m = _klass.getDeclaredMethod(_method, _argtypes);
        m.setAccessible(true);
        if (_receiver == null) _receiver = _klass.newInstance();
        _result = m.invoke(_receiver, _args);
        if (_result instanceof Expression) {
            _actual = ((Expression)_result)._inspect().toString();
        }
        if (_expected != null) assertEquals(_expected, _actual);
    }


    public void testAttribute01() throws Exception {  // _parseKdAttribute()
        String pdata = ""
                       + "<div id=\"foo\" class=\"klass\" kw:d=\"value:val\">\n"
                       + "text\n"
                       + "</div>\n"
                       ;
        DefaultConverter converter = new DefaultConverter();
        List taglist = converter.fetchAll(pdata);
        Tag tag = (Tag)taglist.get(0);
        //
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseKdAttribute";
        _argtypes = new Class[] {String.class, Tag.class};
        //
        _input    = "mark:bar";                   // valid directive
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals("mark", tag.directive_name);
        assertEquals("bar",  tag.directive_arg);
        //
        _input    = "Mark:bar";                   // invalid directive
        _args     = new Object[] {_input, tag};
        try {
            _test();
            fail("ConversionException expected but nothing happened.");
        } catch (java.lang.reflect.InvocationTargetException ex) {
            if (! (ex.getCause() instanceof ConvertionException)) {
                fail("ConversionException expected but got " + ex.toString());
                throw ex;
            }
        }
        //
        Object[] tuples = {
            new String[] { "  mark",        "bar" },
            new String[] { "value",       "var+1" },
            new String[] { "Value",       "var+2" },
            new String[] { "VALUE",       "var+3" },
            new String[] { "foreach",     "item=list" },
            new String[] { "Foreach",     "item=list" },
            new String[] { "FOREACH",     "item=list" },
            new String[] { "list",        "item=list" },
            new String[] { "List",        "item=list" },
            new String[] { "LIST",        "item=list" },
            new String[] { "while",       "i>0" },
            new String[] { "list",        "i<0" },
            new String[] { "set",         "var=value" },
            new String[] { "if",          "error!=null" },
            new String[] { "elseif",      "warning!=null" },
            new String[] { "else",        "" },
            new String[] { "dummy",       "d1" },
            new String[] { "replace",     "elem1" },
            new String[] { "placeholder", "elem2" },
            new String[] { "include",     "'filename'" },
        };
        for (int i = 0; i < tuples.length; i++) {
            String[] tuple = (String[])tuples[i];
            String dname = tuple[0];
            String darg  = tuple[1];
            _input    = dname + ":" + darg;
            _args     = new Object[] {_input, tag};
            _test();
            assertEquals(dname.trim(), tag.directive_name);
            assertEquals(darg,  tag.directive_arg);
        }
    }


    public void testAttribute02() throws Exception {  // _parseKdAttribute()
        String pdata = ""
                       + "<div id=\"foo\" class=\"klass\" kw:d=\"value:val\">\n"
                       ;
        DefaultConverter converter = new DefaultConverter();
        List taglist = converter.fetchAll(pdata);
        Tag tag = (Tag)taglist.get(0);
        //
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseKdAttribute";
        _argtypes = new Class[] {String.class, Tag.class};
        //
        _input    = "attr:class:klass";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals(null, tag.directive_name);
        assertEquals(null, tag.directive_arg);
        assertTrue(tag.attrs != null);
        assertEquals(1, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(0);
        assertEquals("class", attr.name);
        assertEquals(VariableExpression.class, attr.value.getClass());
        //
        _input    = "Attr:class:klass";
        _args     = new Object[] {_input, tag};
        _test();
        attr = (Attr)tag.attrs.get(0);
        assertEquals(FunctionExpression.class, attr.value.getClass());
        assertEquals("E", ((FunctionExpression)attr.value).getFunctionName());
        //
        _input    = "ATTR:class:klass";
        _args     = new Object[] {_input, tag};
        _test();
        attr = (Attr)tag.attrs.get(0);
        assertEquals(FunctionExpression.class, attr.value.getClass());
        assertEquals("X", ((FunctionExpression)attr.value).getFunctionName());
        //
        _input    = "append:' checked'";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals(null, tag.directive_name);
        assertEquals(null, tag.directive_arg);
        assertTrue(tag.append_exprs != null);
        assertEquals(1, tag.append_exprs.size());
        Object expr = tag.append_exprs.get(0);
        assertEquals(StringExpression.class, expr.getClass());
        //
        _input    = "Append:' selected'";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals(2, tag.append_exprs.size());
        expr = tag.append_exprs.get(1);
        assertEquals(FunctionExpression.class, expr.getClass());
        assertEquals("E", ((FunctionExpression)expr).getFunctionName());
        //
        _input    = "APPEND:' DELETED'";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals(3, tag.append_exprs.size());
        expr = tag.append_exprs.get(2);
        assertEquals(FunctionExpression.class, expr.getClass());
        assertEquals("X", ((FunctionExpression)expr).getFunctionName());
        //
    }

    public void testAttribute03() throws Exception {  // _parseKdAttribute()
        String pdata = ""
                       + "<div id=\"foo\" class=\"klass\" kw:d=\"value:val\">\n"
                       ;
        DefaultConverter converter = new DefaultConverter();
        List taglist = converter.fetchAll(pdata);
        Tag tag = (Tag)taglist.get(0);
        //
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseKdAttribute";
        _argtypes = new Class[] {String.class, Tag.class};
        //
        _input    = "attr:class:klass; append:' checked'; mark:foo[:key]";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals("mark", tag.directive_name);
        assertEquals("foo[:key]", tag.directive_arg);
        assertTrue(tag.attrs != null);
        assertEquals(1, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(0);
        assertEquals("class", attr.name);
        assertEquals(VariableExpression.class, attr.value.getClass());
        assertTrue(tag.append_exprs != null);
        assertEquals(1, tag.append_exprs.size());
        Object expr = tag.append_exprs.get(0);
        assertEquals(StringExpression.class, expr.getClass());
    }

    public void testAttribute04() throws Exception { // _parseAttributes() {
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseAttributes";
        _argtypes = new Class[] {Tag.class};
        //
        Tag tag = new Tag();
        tag.attr_str = " class=\"even\" bgcolor=\"#FFCCCC\" xml:ns=\"foo\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertTrue(tag.attrs != null);
        assertEquals(3, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(0);
        assertEquals("class", attr.name);
        assertEquals("even",  attr.value);
        attr = (Attr)tag.attrs.get(1);
        assertEquals("bgcolor", attr.name);
        assertEquals("#FFCCCC",  attr.value);
        attr = (Attr)tag.attrs.get(2);
        assertEquals("xml:ns", attr.name);
        assertEquals("foo",  attr.value);
    }

    public void testAttribute05() throws Exception { // _parseAttributes() {
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseAttributes";
        _argtypes = new Class[] {Tag.class};
        //
        Tag tag = new Tag();
        tag.attr_str = " class=\"even\" bgcolor=\"#FFCCCC\" id=\"foo\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("mark", tag.directive_name);
        assertEquals("foo", tag.directive_arg);
        assertEquals(3, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(2);
        assertEquals("id", attr.name);
        assertEquals("foo",  attr.value);
        //
        tag = new Tag();
        tag.attr_str = " class=\"even\"  bgcolor=\"#FFCCCC\" id=\"mark:foo\" ";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("mark", tag.directive_name);
        assertEquals("foo", tag.directive_arg);
        assertEquals(2, tag.attrs.size());
        attr = (Attr)tag.attrs.get(0);
        assertEquals("class", attr.name);
        attr = (Attr)tag.attrs.get(1);
        assertEquals("bgcolor", attr.name);
        //
        tag = new Tag();
        tag.attr_str = " class=\"even\" id=\"foo\" id=\"value:var\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("value", tag.directive_name);
        assertEquals("var", tag.directive_arg);
        assertEquals(2, tag.attrs.size());
        attr = (Attr)tag.attrs.get(1);
        assertEquals("id", attr.name);
        assertEquals("foo",  attr.value);
    }


    public void testAttribute06() throws Exception { // _parseAttributes() {
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseAttributes";
        _argtypes = new Class[] {Tag.class};
        //
        Tag tag = new Tag();
        tag.attr_str = " class=\"even\" bgcolor=\"#FFCCCC\" kw:d=\"mark:foo\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("mark", tag.directive_name);
        assertEquals("foo", tag.directive_arg);
        assertEquals(2, tag.attrs.size());
        //
        tag = new Tag();
        tag.attr_str = " id=\"foo\" bgcolor=\"#FFCCCC\" kw:d=\"value:var\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("value", tag.directive_name);
        assertEquals("var", tag.directive_arg);
        assertEquals(2, tag.attrs.size());
        //
    }

    public void testAttribute07() throws Exception { // _parseAttributes() {
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseAttributes";
        _argtypes = new Class[] {Tag.class};
        //
        Tag tag = new Tag();
        tag.attr_str = "id=\"foo\" bgcolor=\"#FFCCCC\""
                     + " kw:d=\"mark:bar;attr:id:xid;attr:class:klass;append:flag?' checked':''\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("mark", tag.directive_name);
        assertEquals("bar", tag.directive_arg);
        assertEquals(3, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(0);
        assertEquals("id", attr.name);
        assertEquals(VariableExpression.class, attr.value.getClass());
        attr = (Attr)tag.attrs.get(1);
        assertEquals("bgcolor", attr.name);
        assertEquals(String.class, attr.value.getClass());
        attr = (Attr)tag.attrs.get(2);
        assertEquals("class", attr.name);
        assertEquals(VariableExpression.class, attr.value.getClass());
        assertTrue(tag.append_exprs != null);
        assertEquals(ConditionalExpression.class, tag.append_exprs.get(0).getClass());
    }


    private void _testConverter() {
        _testConverter(false);
    }
    private void _testConverter(boolean flag_print) {
        Converter converter = new DefaultConverter();
        Statement[] stmts = converter.convert(_input);
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < stmts.length; i++) {
            sb.append(stmts[i]._inspect().toString());
        }
        String actual = sb.toString();
        if (flag_print) {
            System.out.println("*** actual=|" + actual + "|\n");
        } else {
            assertEquals(_expected, actual);
        }
    }

    public void testConverter21() {  // normal text
        _input = ""
                 + "<span>Hello World</span>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<span>\"\n"
                    + ":print\n"
                    + "  \"Hello World\"\n"
                    + ":print\n"
                    + "  \"</span>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testConverter22() {  // Helo @{user}@
        _input = ""
                 + " <span>Hello @{user}@</span>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \" <span>\"\n"
                    + ":print\n"
                    + "  \"Hello \"\n"
                    + "  user\n"
                    + ":print\n"
                    + "  \"</span>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testConverter23() {  // color="@{color}@"
        _input = ""
                 + " <span color=\"@{color}@\">Hello World</span>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \" <span color=\\\"\"\n"
                    + "  color\n"
                    + "  \"\\\">\"\n"
                    + ":print\n"
                    + "  \"Hello World\"\n"
                    + ":print\n"
                    + "  \"</span>\\n\"\n"
                    ;
        _testConverter(false);
    }


    public void testConverter24() {  // keep spaces
        _input = ""
                 + " <div  align=\"center\"   bgcolor=\"#FFFFFF\" >\n"
                 + "    <span style=\"color:red\">CAUTION!</span>\n"
                 + "    <br  />\n"
                 + " </div>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \" <div  align=\\\"center\\\"   bgcolor=\\\"#FFFFFF\\\" >\\n\"\n"
                    + ":print\n"
                    + "  \"    <span style=\\\"color:red\\\">\"\n"
                    + ":print\n"
                    + "  \"CAUTION!\"\n"
                    + ":print\n"
                    + "  \"</span>\\n\"\n"
                    + ":print\n"
                    + "  \"    <br  />\\n\"\n"
                    + ":print\n"
                    + "  \" </div>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective11() {   // id="foo"
        _input = ""
                 + "<div>\n"
                 + " <span id=\"foo\">bar</span>\n"
                 + "</div>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<div>\\n\"\n"
                    + "@element(foo)\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter();
    }

    public void testDirective12() {   // id="mark:foo"
        _input = ""
                 + "<div>\n"
                 + " <span id=\"mark:foo\">bar</span>\n"
                 + "</div>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<div>\\n\"\n"
                    + "@element(foo)\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter();
    }

    public void testDirective13() {    // kw:d="mark:foo"
        _input = ""
                 + "<div>\n"
                 + "  <span id=\"mark:bar\" class=\"klass\" kw:d=\"mark:foo\">bar</span>\n"
                 + "</div>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<div>\\n\"\n"
                    + "@element(foo)\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter();
    }

    public void testDirective21() {    // id="value:var"
        _input = ""
                 + "<li id=\"value:user.name\">foo</li>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<li>\"\n"
                    + ":print\n"
                    + "  .\n"
                    + "    user\n"
                    + "    name\n"
                    + ":print\n"
                    + "  \"</li>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective22() {    // id="Value:var"
        _input = ""
                 + "<li id=\"Value:user.name\">foo</li>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<li>\"\n"
                    + ":print\n"
                    + "  E()\n"
                    + "    .\n"
                    + "      user\n"
                    + "      name\n"
                    + ":print\n"
                    + "  \"</li>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective23() {    // id="Value:var"
        _input = ""
                 + "<li id=\"VALUE:user.name\">foo</li>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<li>\"\n"
                    + ":print\n"
                    + "  X()\n"
                    + "    .\n"
                    + "      user\n"
                    + "      name\n"
                    + ":print\n"
                    + "  \"</li>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective31() {    // id="foreach:item=list"
        _input = ""
                 + "<ul id=\"foreach:item=list\">\n"
                 + "  <li>@{item}@</li>\n"
                 + "</ul>\n"
                 ;
        _expected = ""
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      \"<ul>\\n\"\n"
                    + "    :print\n"
                    + "      \"  <li>\"\n"
                    + "    :print\n"
                    + "      item\n"
                    + "    :print\n"
                    + "      \"</li>\\n\"\n"
                    + "    :print\n"
                    + "      \"</ul>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective32() {    // id="Foreach:item=list"
        _input = ""
                 + "<ul id=\"Foreach:item=list\">\n"
                 + "  <li>@{item}@</li>\n"
                 + "</ul>\n"
                 ;
        _expected = ""
                    + ":expr\n"
                    + "  =\n"
                    + "    item_ctr\n"
                    + "    0\n"
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :block\n"
                    + "    :expr\n"
                    + "      +=\n"
                    + "        item_ctr\n"
                    + "        1\n"
                    + "    :print\n"
                    + "      \"<ul>\\n\"\n"
                    + "    :print\n"
                    + "      \"  <li>\"\n"
                    + "    :print\n"
                    + "      item\n"
                    + "    :print\n"
                    + "      \"</li>\\n\"\n"
                    + "    :print\n"
                    + "      \"</ul>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective33() {    // id="FOREACH:item=list"
        _input = ""
                 + "<ul id=\"FOREACH:item=list\">\n"
                 + "  <li>@{item}@</li>\n"
                 + "</ul>\n"
                 ;
        _expected = ""
                    + ":expr\n"
                    + "  =\n"
                    + "    item_ctr\n"
                    + "    0\n"
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :block\n"
                    + "    :expr\n"
                    + "      +=\n"
                    + "        item_ctr\n"
                    + "        1\n"
                    + "    :expr\n"
                    + "      =\n"
                    + "        item_tgl\n"
                    + "        ?:\n"
                    + "          ==\n"
                    + "            %\n"
                    + "              item_ctr\n"
                    + "              2\n"
                    + "            0\n"
                    + "          \"even\"\n"
                    + "          \"odd\"\n"
                    + "    :print\n"
                    + "      \"<ul>\\n\"\n"
                    + "    :print\n"
                    + "      \"  <li>\"\n"
                    + "    :print\n"
                    + "      item\n"
                    + "    :print\n"
                    + "      \"</li>\\n\"\n"
                    + "    :print\n"
                    + "      \"</ul>\\n\"\n"
                    ;
        _testConverter();
    }



    public void testDirective34() {    // id="list:item=list"
        _input = ""
                 + "<ul id=\"list:item=list\">\n"
                 + "  <li>@{item}@</li>\n"
                 + "</ul>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<ul>\\n\"\n"
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      \"  <li>\"\n"
                    + "    :print\n"
                    + "      item\n"
                    + "    :print\n"
                    + "      \"</li>\\n\"\n"
                    + ":print\n"
                    + "  \"</ul>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective35() {    // id="List:item=list"
        _input = ""
                 + "<ul id=\"List:item=list\">\n"
                 + "  <li>@{item}@</li>\n"
                 + "</ul>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<ul>\\n\"\n"
                    + ":expr\n"
                    + "  =\n"
                    + "    item_ctr\n"
                    + "    0\n"
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :block\n"
                    + "    :expr\n"
                    + "      +=\n"
                    + "        item_ctr\n"
                    + "        1\n"
                    + "    :print\n"
                    + "      \"  <li>\"\n"
                    + "    :print\n"
                    + "      item\n"
                    + "    :print\n"
                    + "      \"</li>\\n\"\n"
                    + ":print\n"
                    + "  \"</ul>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective36() {    // id="LIST:item=list"
        _input = ""
                 + "<ul id=\"LIST:item=list\">\n"
                 + "  <li>@{item}@</li>\n"
                 + "</ul>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<ul>\\n\"\n"
                    + ":expr\n"
                    + "  =\n"
                    + "    item_ctr\n"
                    + "    0\n"
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :block\n"
                    + "    :expr\n"
                    + "      +=\n"
                    + "        item_ctr\n"
                    + "        1\n"
                    + "    :expr\n"
                    + "      =\n"
                    + "        item_tgl\n"
                    + "        ?:\n"
                    + "          ==\n"
                    + "            %\n"
                    + "              item_ctr\n"
                    + "              2\n"
                    + "            0\n"
                    + "          \"even\"\n"
                    + "          \"odd\"\n"
                    + "    :print\n"
                    + "      \"  <li>\"\n"
                    + "    :print\n"
                    + "      item\n"
                    + "    :print\n"
                    + "      \"</li>\\n\"\n"
                    + ":print\n"
                    + "  \"</ul>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective41() {  // while:row=sth.fetch()
        _input = ""
                 + "<ul id=\"while:row=sth.fetch()\">\n"
                 + "  <li>@{row[0]}@</li>\n"
                 + "</ul>\n"
                 ;
        _expected = ""
                    + ":while\n"
                    + "  =\n"
                    + "    row\n"
                    + "    .()\n"
                    + "      sth\n"
                    + "      fetch()\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      \"<ul>\\n\"\n"
                    + "    :print\n"
                    + "      \"  <li>\"\n"
                    + "    :print\n"
                    + "      []\n"
                    + "        row\n"
                    + "        0\n"
                    + "    :print\n"
                    + "      \"</li>\\n\"\n"
                    + "    :print\n"
                    + "      \"</ul>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective42() {  // loop:row=sth.fetch()
        _input = ""
                 + "<ul id=\"loop:row=sth.fetch()\">\n"
                 + "  <li>@{row[0]}@</li>\n"
                 + "</ul>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<ul>\\n\"\n"
                    + ":while\n"
                    + "  =\n"
                    + "    row\n"
                    + "    .()\n"
                    + "      sth\n"
                    + "      fetch()\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      \"  <li>\"\n"
                    + "    :print\n"
                    + "      []\n"
                    + "        row\n"
                    + "        0\n"
                    + "    :print\n"
                    + "      \"</li>\\n\"\n"
                    + ":print\n"
                    + "  \"</ul>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective51() {  // if:error!=null
        _input = ""
                 + "<font color=\"red\" id=\"if:error!=null\">\n"
                 + "  ERROR!\n"
                 + "</font>\n"
                 ;
        _expected = ""
                    + ":if\n"
                    + "  !=\n"
                    + "    error\n"
                    + "    null\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      \"<font color=\\\"red\\\">\\n\"\n"
                    + "    :print\n"
                    + "      \"  ERROR!\\n\"\n"
                    + "    :print\n"
                    + "      \"</font>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective52() {  // elseif:warning!=null
        _input = ""
                 + "<font color=\"red\" id=\"if:error!=empty\">\n"
                 + "  ERROR!\n"
                 + "</font>\n"
                 + "<font color=\"blue\" id=\"elseif:warning!=null\">\n"
                 + "  WARNING\n"
                 + "</font>\n"
                 ;
        _expected = ""
                    + ":if\n"
                    + "  notempty\n"
                    + "    error\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      \"<font color=\\\"red\\\">\\n\"\n"
                    + "    :print\n"
                    + "      \"  ERROR!\\n\"\n"
                    + "    :print\n"
                    + "      \"</font>\\n\"\n"
                    + "  :if\n"
                    + "    !=\n"
                    + "      warning\n"
                    + "      null\n"
                    + "    :block\n"
                    + "      :print\n"
                    + "        \"<font color=\\\"blue\\\">\\n\"\n"
                    + "      :print\n"
                    + "        \"  WARNING\\n\"\n"
                    + "      :print\n"
                    + "        \"</font>\\n\"\n"
                    ;
        _testConverter();
    }

    public void testDirective53() {  // else:
        _input = ""
                 + "<font color=\"red\" id=\"if:error!=empty\">\n"
                 + "  ERROR!\n"
                 + "</font>\n"
                 + "<font color=\"blue\" id=\"elseif:warning!=null\">\n"
                 + "  WARNING\n"
                 + "</font>\n"
                 + "<font color=\"black\" id=\"else:\">\n"
                 + "  Welcome\n"
                 + "</font>\n"
                 ;
        _expected = ""
                    + ":if\n"
                    + "  notempty\n"
                    + "    error\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      \"<font color=\\\"red\\\">\\n\"\n"
                    + "    :print\n"
                    + "      \"  ERROR!\\n\"\n"
                    + "    :print\n"
                    + "      \"</font>\\n\"\n"
                    + "  :if\n"
                    + "    !=\n"
                    + "      warning\n"
                    + "      null\n"
                    + "    :block\n"
                    + "      :print\n"
                    + "        \"<font color=\\\"blue\\\">\\n\"\n"
                    + "      :print\n"
                    + "        \"  WARNING\\n\"\n"
                    + "      :print\n"
                    + "        \"</font>\\n\"\n"
                    + "    :block\n"
                    + "      :print\n"
                    + "        \"<font color=\\\"black\\\">\\n\"\n"
                    + "      :print\n"
                    + "        \"  Welcome\\n\"\n"
                    + "      :print\n"
                    + "        \"</font>\\n\"\n"
                    ;
        _testConverter();
    }

    public void testDirective54() {  // several elseif:
        _input = ""
                 + "<div>\n"
                 + "  <font color=\"red\" id=\"if:error!=empty\">ERROR!</font>\n"
                 + "  <font color=\"blue\" id=\"elseif:warning!=empty\">WARNING</font>\n"
                 + "  <font color=\"green\" id=\"elseif:notify!=empty\">NOTIFICATION</font>\n"
                 + "  <font color=\"black\" id=\"else:\">Welcome</font>\n"
                 + "</div>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<div>\\n\"\n"
                    + ":if\n"
                    + "  notempty\n"
                    + "    error\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      \"  <font color=\\\"red\\\">\"\n"
                    + "    :print\n"
                    + "      \"ERROR!\"\n"
                    + "    :print\n"
                    + "      \"</font>\\n\"\n"
                    + "  :if\n"
                    + "    notempty\n"
                    + "      warning\n"
                    + "    :block\n"
                    + "      :print\n"
                    + "        \"  <font color=\\\"blue\\\">\"\n"
                    + "      :print\n"
                    + "        \"WARNING\"\n"
                    + "      :print\n"
                    + "        \"</font>\\n\"\n"
                    + "    :if\n"
                    + "      notempty\n"
                    + "        notify\n"
                    + "      :block\n"
                    + "        :print\n"
                    + "          \"  <font color=\\\"green\\\">\"\n"
                    + "        :print\n"
                    + "          \"NOTIFICATION\"\n"
                    + "        :print\n"
                    + "          \"</font>\\n\"\n"
                    + "      :block\n"
                    + "        :print\n"
                    + "          \"  <font color=\\\"black\\\">\"\n"
                    + "        :print\n"
                    + "          \"Welcome\"\n"
                    + "        :print\n"
                    + "          \"</font>\\n\"\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter(false);
    }


    public void testDirective55() {  // invalid if-else
        _input = ""
                 + "<div>\n"
                 + "  <font color=\"red\" id=\"if:error!=empty\">\n"
                 + "    ERROR!\n"
                 + "  </font>\n"
                 + "\n"
                 + "  <font color=\"blue\" id=\"elseif:warning!=empty\">\n"
                 + "    WARNING\n"
                 + "  </font>\n"
                 + "</div>\n"
                 ;
        _expected = "";
        try {
          _testConverter(false);
          fail("ConvertionException expected but nothing happened.");
        } catch (ConvertionException ex) {
            // OK
        }
    }


    public void testDirective61() {  // replace:elem1
        _input = ""
                 + "<h1 id=\"mark:title\">...title...</h1>\n"
                 + "text\n"
                 + "<div id=\"replace:title\">foo</div>\n"
                 ;
        _expected = ""
                    + "@element(title)\n"
                    + ":print\n"
                    + "  \"text\\n\"\n"
                    + "@element(title)\n"
                    ;
        _testConverter(false);
    }


    public void testDirective62() {  // replace:elem1:element
        _input = ""
                 + "<h1 id=\"mark:title\">...title...</h1>\n"
                 + "text\n"
                 + "<div id=\"replace:title:element\">foo</div>\n"
                 ;
        _expected = ""
                    + "@element(title)\n"
                    + ":print\n"
                    + "  \"text\\n\"\n"
                    + "@element(title)\n"
                    ;
        _testConverter(false);
    }


    public void testDirective63() {  // replace:elem1:content
        _input = ""
                 + "<h1 id=\"mark:title\">...title...</h1>\n"
                 + "text\n"
                 + "<div id=\"replace:title:content\">foo</div>\n"
                 ;
        _expected = ""
                    + "@element(title)\n"
                    + ":print\n"
                    + "  \"text\\n\"\n"
                    + "@content(title)\n"
                    ;
        _testConverter(false);
    }


    public void testDirective64() {  // placeholder:elem1
        _input = ""
                 + "<h1 id=\"mark:title\">...title...</h1>\n"
                 + "text\n"
                 + "<div id=\"placeholder:title\">foo</div>\n"
                 ;
        _expected = ""
                    + "@element(title)\n"
                    + ":print\n"
                    + "  \"text\\n\"\n"
                    + ":print\n"
                    + "  \"<div>\"\n"
                    + "@element(title)\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter(false);
    }


    public void testDirective65() {  // placeholder:elem1:element
        _input = ""
                 + "<h1 id=\"mark:title\">...title...</h1>\n"
                 + "text\n"
                 + "<div id=\"placeholder:title:element\">foo</div>\n"
                 ;
        _expected = ""
                    + "@element(title)\n"
                    + ":print\n"
                    + "  \"text\\n\"\n"
                    + ":print\n"
                    + "  \"<div>\"\n"
                    + "@element(title)\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter(false);
    }


    public void testDirective66() {  // placeholder:elem1:content
        _input = ""
                 + "<h1 id=\"mark:title\">...title...</h1>\n"
                 + "text\n"
                 + "<div id=\"placeholder:title:content\">foo</div>\n"
                 ;
        _expected = ""
                    + "@element(title)\n"
                    + ":print\n"
                    + "  \"text\\n\"\n"
                    + ":print\n"
                    + "  \"<div>\"\n"
                    + "@content(title)\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter(false);
    }


    public void testDirective71() {  // set:var=value
        _input = ""
                 + "<tr bgcolor=\"@{color}@\" id=\"set:color=i%2==0?'#FFCCCC':'#CCCCFF'\">\n"
                 + "  <td>item=@{item}@</td>\n"
                 + "</tr>\n"
                 ;
        _expected = ""
                    + ":expr\n"
                    + "  =\n"
                    + "    color\n"
                    + "    ?:\n"
                    + "      ==\n"
                    + "        %\n"
                    + "          i\n"
                    + "          2\n"
                    + "        0\n"
                    + "      \"#FFCCCC\"\n"
                    + "      \"#CCCCFF\"\n"
                    + ":print\n"
                    + "  \"<tr bgcolor=\\\"\"\n"
                    + "  color\n"
                    + "  \"\\\">\\n\"\n"
                    + ":print\n"
                    + "  \"  <td>\"\n"
                    + ":print\n"
                    + "  \"item=\"\n"
                    + "  item\n"
                    + ":print\n"
                    + "  \"</td>\\n\"\n"
                    + ":print\n"
                    + "  \"</tr>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective72() {  // dummy:d1
        _input = ""
                 + "<tr>\n"
                 + "  <td>foo</td>\n"
                 + "</tr>\n"
                 + "<tr id=\"dummy:d1\">\n"
                 + "  <td>foo</td>\n"
                 + "</tr>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<tr>\\n\"\n"
                    + ":print\n"
                    + "  \"  <td>\"\n"
                    + ":print\n"
                    + "  \"foo\"\n"
                    + ":print\n"
                    + "  \"</td>\\n\"\n"
                    + ":print\n"
                    + "  \"</tr>\\n\"\n"
                    ;
        _testConverter();
    }


    public void testDirective73() {  // include:'filename'
        //_input = ""
        //_expected = ""
        _input = ""
                 + "<div  bgcolor=\"red\"   style=\"color:red\"\n"
                 + "     id=\"attr:bgcolor=color;attr:ns:class:item[:klass];value:val\" title=\"\">foo</div>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<div  bgcolor=\\\"\"\n"
                    + "  color\n"
                    + "  \"\\\"   style=\\\"color:red\\\" title=\\\"\\\" ns:class=\\\"\"\n"
                    + "  [:]\n"
                    + "    item\n"
                    + "    \"klass\"\n"
                    + "  \"\\\">\"\n"
                    + ":print\n"
                    + "  val\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter();
        //
    }

    public void testDirective82() {  // Attr: and ATTR:
        _input = ""
                 + "<div  bgcolor=\"red\"   style=\"color:red\"\n"
                 + "     id=\"Attr:bgcolor=color;ATTR:ns:class:item[:klass];value:val\" title=\"\">foo</div>\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<div  bgcolor=\\\"\"\n"
                    + "  E()\n"
                    + "    color\n"
                    + "  \"\\\"   style=\\\"color:red\\\" title=\\\"\\\" ns:class=\\\"\"\n"
                    + "  X()\n"
                    + "    [:]\n"
                    + "      item\n"
                    + "      \"klass\"\n"
                    + "  \"\\\">\"\n"
                    + ":print\n"
                    + "  val\n"
                    + ":print\n"
                    + "  \"</div>\\n\"\n"
                    ;
        _testConverter();
        //
    }


    public void testDirective83() {  // attr directive with empty tag
        _input = ""
                 + "<div  bgcolor=\"red\"   style=\"color:red\"\n"
                 + "     id=\"Attr:bgcolor=color;ATTR:ns:class:item[:klass]\" title=\"\" />\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<div  bgcolor=\\\"\"\n"
                    + "  E()\n"
                    + "    color\n"
                    + "  \"\\\"   style=\\\"color:red\\\" title=\\\"\\\" ns:class=\\\"\"\n"
                    + "  X()\n"
                    + "    [:]\n"
                    + "      item\n"
                    + "      \"klass\"\n"
                    + "  \"\\\" />\\n\"\n"
                    ;
        _testConverter();
        //
    }


    public void testDirective84() {  // append, Append, APPEND
        _input = ""
                 + "<input type=\"checkbox\" id=\"foo\" kw:d=\"append:flag?' checked':'';Append:flag?' selected':'';APPEND:flag?' disabled':''\" />\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<input type=\\\"checkbox\\\" id=\\\"foo\\\"\"\n"
                    + "  ?:\n"
                    + "    flag\n"
                    + "    \" checked\"\n"
                    + "    \"\"\n"
                    + "  E()\n"
                    + "    ?:\n"
                    + "      flag\n"
                    + "      \" selected\"\n"
                    + "      \"\"\n"
                    + "  X()\n"
                    + "    ?:\n"
                    + "      flag\n"
                    + "      \" disabled\"\n"
                    + "      \"\"\n"
                    + "  \" />\\n\"\n"
                    ;
        _testConverter();
        //
    }



    // --------------------

    public static void main(String[] args) {
       junit.textui.TestRunner.run(ConverterTest.class);
    }
}
